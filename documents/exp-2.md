# 实验 2 —— Oracle 硬编码上界（发现阶段与运行阶段分离）

> **目标**：评估配置 map 特化（specialization）的理论上界。流程是：  
> 1) 在目标负载下先做**发现阶段**，找出稳定不变的 map 值；  
> 2) 将这些值硬编码到 Katran BPF（Oracle 版本）；  
> 3) 做干净的三组对比：**无 Katran / 原版 Katran / Oracle Katran**。  
> **关键要求**：发现阶段允许有侵入性；正式对比阶段必须无额外观测开销。

默认沿用实验 1 的指标与作图方式（Nginx + wrk 基线）。

---

## 实现状态（2026-02-25）

- 阶段 A 发现工具已实现：
  - `scripts/exp2/discover.sh`
  - `scripts/exp2/analyze-maps.py`
- Makefile 入口：
  - `make exp2-discover`
- 阶段 B（Oracle）已实现最小闭环（当前只做 `ch_rings` 活跃 VIP ring 段硬编码）：
  - `scripts/exp2/generate-oracle.py`：从 Stage A `specialization-spec.json` 生成 `exp2_oracle_generated.h`
  - `scripts/exp2/build-oracle.sh`：生成 header + 独立目录构建 Oracle Katran（不覆盖 vanilla）
  - `make exp2-oracle-build`
- 阶段 C（评估）已实现单命令入口：
  - `scripts/exp2/eval.sh`：串行运行 `direct / vanilla / opt`，并生成三方对比图
  - `make exp2-eval`

快速开始：

```sh
make exp2-discover
```

基于最新 Stage A 生成并构建 Oracle（默认）：

```sh
make exp2-oracle-build
```

仅验证生成（不编译）：

```sh
make exp2-oracle-build EXP2_ORACLE_SKIP_BUILD=1
```

基于已有 Oracle 产物运行完整三方评估（不重跑 discover / build）：

```sh
make exp2-eval
```

`make exp2-discover` 当前默认行为：

- 分别对 `wrk` 与 `wrk2` 各跑一次阶段 A
- 使用 `EXP2_STAGEA_MAPS=all`（采样 balancer 挂载的全部 map）
- 超大 map 默认仅哈希采样（`EXP2_STAGEA_MAX_MAP_DUMP_ENTRIES=1000000`）
- 若仅哈希采样的 map 判定为不变，仅保留 1 份最终全量 dump（`EXP2_STAGEA_KEEP_INVARIANT_HASH_ONLY_DUMP=1`）

自定义窗口示例：

```sh
make exp2-discover \
  EXP2_STAGEA_WORKLOAD=wrk2 \
  EXP2_STAGEA_WRK2_RATE=300000 \
  EXP2_STAGEA_STEADY_WARMUP_SECS=45 \
  EXP2_STAGEA_SAMPLE_INTERVAL_SECS=30 \
  EXP2_STAGEA_SAMPLE_COUNT=8
```

按负载类型分开跑：

```sh
make exp2-discover EXP2_STAGEA_WORKLOAD=wrk EXP2_STAGEA_WRK_CONNECTIONS="256"
make exp2-discover EXP2_STAGEA_WORKLOAD=wrk2 EXP2_STAGEA_WRK2_RATE=300000
```

全 map 覆盖：

```sh
make exp2-discover EXP2_STAGEA_MAPS=all
```

核心输出：

- `results/exp2/discovery/<run-id>-stageA/specialization-spec.json`
- `results/exp2/discovery/<run-id>-stageA/invariant-summary.csv`

其中 `specialization-spec.json` 已包含 map 级与 entry 级不变量，以及 map 元信息，可直接作为阶段 B 的硬编码输入。

`make exp2-oracle-build` 当前默认行为：

- 默认读取 `results/exp2/discovery` 下**最新** `*-stageA/specialization-spec.json`
- 仅硬编码 `ch_rings` 的“活跃 VIP ring 段”
- 生成头文件：
  - `source/katran/katran/lib/bpf/oracle/exp2_oracle_generated.h`
- Oracle 编译 define 默认：
  - `-DLOCAL_DELIVERY_OPTIMIZATION -DEXP2_ORACLE_CH_RINGS`
- Oracle 构建目录默认：
  - `source/katran/_build_exp2_oracle`（与 vanilla 隔离）
- 输出运行配置：
  - `results/exp2/oracle/<run-id>-build/oracle-artifacts.env`

`make exp2-eval` 当前默认行为：

- 三个 lane 顺序运行：
  - `direct`（no-katran）
  - `vanilla`（原版 Katran）
  - `opt`（读取最新 `results/exp2/oracle/*-build/oracle-artifacts.env`）
- 每个 lane 复用 `exp1-run` 的 full 默认参数（wrk + wrk2）
- 三方对比输出：
  - `results/exp2/eval/threeway-<run-id>/`

---

## 0) 术语定义

- **无 Katran（Direct）**：客户端直接访问后端 Nginx（IP:port）。
- **原版 Katran（Vanilla）**：客户端访问 VIP，经原始 Katran BPF 转发到 Nginx。
- **Oracle Katran（硬编码）**：与原版路径一致，但将发现阶段得到的不变配置硬编码到 BPF。

---

## 1) 两阶段流程

### 阶段 A —— 发现阶段（负载 + Katran + map 采样）

**目的**：识别在目标负载窗口内可视为“动态常量”的 map / entry。  
**注意**：阶段 A 不用于最终性能作图。

#### A1. 在 Katran 路径上运行目标负载

- 数据面部署 **Vanilla Katran**（VIP 生效）。
- 运行与阶段 B 一致的 Nginx + wrk / wrk2 负载轮廓。

#### A2. 稳态多次采样 map

- 先预热到稳态（建议 30–60 秒）。
- 在稳态窗口内多次采样：
  - `t0`（预热后）, `t1`, …, `t_end`
  - 建议周期 30–60 秒，总时长 5–10 分钟（可调）
- 常规 map：每个采样点存全量 dump。
- 超大 map：每个采样点仅存哈希，避免重复大文件。
- 每个采样点计算 map 哈希（必要时 entry 哈希）用于变更判定。

#### A3. 判定“负载窗口内不变”

一个 entry 判为 Oracle 可用不变量，至少满足：

- 稳态窗口内所有采样点 value 一致；
- 若能观测更新事件，则窗口内无更新证据更好。

说明：不要求证明“永远不变”，只要求“在本次目标工作负载窗口内稳定”。

#### A4. 阶段 A 产出：specialization spec

输出机器可读 spec（可由脚本生成），至少包含：

- map 名称 / id
- key（字节或可读格式）
- value（字节或解码字段）
- map 类型（array/hash 等）及 key/value 大小

对于仅哈希采样的大 map：

- 先用多采样点哈希判定是否不变；
- 若判定不变，再保留 1 份最终全量 dump 供阶段 B 生成硬编码常量。

---

### 阶段 B —— 运行阶段（干净对比阶段）

**目的**：输出可用于报告/论文的 Direct vs Vanilla vs Oracle 对比曲线。  
**要求**：阶段 B 必须干净，不做 map dump，不加额外 BPF 观测逻辑。

#### B0. 构建 Oracle 版本

输入：

- 阶段 A 的 specialization spec
- 相关 Katran BPF 源码

要求：

- 将目标查表位点替换为可被编译器常量传播与 DCE 的表达方式；
- 保持语义等价，不改变功能行为。

校验：

- Oracle 能成功编译并加载；
- 同负载下与 Vanilla 功能一致（HTTP 正确性、返回码、后端命中）。

#### B0.1 阶段 B 实施计划（按 map 类型）

目标：在不影响原版实验的前提下，构建独立 Oracle 版本，并对阶段 A 判定的不变 map 做可复现硬编码。

1. 构建隔离（必须）

- Oracle 使用独立编译目标与产物，不能覆盖原版。
- 建议结构：
  - `balancer.bpf.c`：保持 vanilla 路径
  - `balancer_oracle.bpf.c`（或同源 + 独立编译宏）：仅 Oracle 使用
  - 自动生成文件：`oracle_consts.h` / `oracle_lookup.h`
- 运行时通过不同对象文件与加载流程区分 `vanilla-katran` 与 `oracle-katran`。

2. 自动生成流程

- 输入：`invariant-summary.csv` + `specialization-spec.json` + `final-dumps/*.json`
- 输出：
  - 常量数据（数组/稀疏表）
  - 查表辅助函数（替代 map 查找）
- 要求：同一份阶段 A 结果重复生成时，Oracle 代码应一致，避免手工改表。

3. 按 map type 的硬编码策略

- `array`（如 `ctl_array`, `reals`, `ch_rings`, `vip_miss_stats`）：
  - 优先静态常量数组直接索引（O(1)）。
- `hash`（如 `vip_map`，以及某些编译配置下的 `server_id_map`）：
  - 小规模用 `if/switch`；
  - 中大规模用“排序 KV + 二分查找”。
- `percpu_array`（如 `quic_stats_map`, `server_id_stats`, `lru_miss_stats`）：
  - 多为统计面；优先做路径裁剪或恒定返回，不把运行时计数直接替换成静态常量。
- `array_of_maps`（`lru_mapping`）与 `lru_hash`（`fallback_cache`）：
  - 属于运行时状态结构，不做全量常量替换；
  - 仅在不改语义前提下裁剪不可能分支。
- `hash_of_maps`（`vip_to_down_reals_map`）：
  - 若判定不变且为空：硬编码为“总是 miss”；
  - 若非空：按 VIP 生成稀疏 down-real 集合查询。

4. 大 map 处理（重点）

- `ch_rings`（`max_entries` 超大）：
  - 不硬编码整张表；
  - 只硬编码活跃 VIP 的 ring 段：`vip_num * RING_SIZE ... + RING_SIZE - 1`；
  - 默认使用稠密数组（每 VIP 一段，查找 O(1)），后续可评估 RLE/区间压缩。
- `server_id_map`（容量大但常稀疏）：
  - 只生成非零项稀疏表，不生成全量 16M 槽位；
  - 查找使用二分或哈希辅助结构。

5. 本次不变 map 落地建议

- 优先硬编码（热路径收益高）：`vip_map`, `ch_rings`（活跃段）, `reals`, `ctl_array`
- 语义硬编码/路径裁剪：`server_id_map`, `vip_to_down_reals_map`, `quic_stats_map`, `server_id_stats`, `vip_miss_stats`, `lru_miss_stats`
- 不做静态常量替换：`lru_mapping`, `fallback_cache`（运行时状态/绑定关系）

6. 验证顺序

- 编译与加载：Oracle 与原版均可独立启动；
- 功能等价：同负载下 HTTP 成功率与后端命中一致；
- 性能对比：仅在阶段 B 的干净运行中比较 `direct` / `vanilla` / `oracle`。

#### B1. 运行条件

在**相同**负载轮廓下运行三组条件：

1. **无 Katran（Direct）**
2. **原版 Katran（Vanilla）**
3. **Oracle Katran（硬编码）**

其余条件保持一致：

- 相同 Nginx 配置
- 相同客户端 wrk / wrk2 配置（线程、连接、速率/并发扫点）
- 相同 CPU pinning 与机器部署

---

## 2) 指标（与实验 1 一致）

### 主指标（报告用）

- **吞吐**：wrk 输出的 `Requests/sec`
- **延迟**：平均延迟 + `p99`（可选 `p999`）
- **错误**：非 2xx、超时、连接错误

### 可选：时间序列峰值延迟

在接近拐点的代表性高负载点：

- 采样窗口化尾延迟（例如 1 秒窗口 p99）
- 定义峰值延迟为窗口 p99 的最大值

---

## 3) 运行协议（每个负载点）

1. 预热 10–30 秒（丢弃）
2. 正式测量 60–180 秒
3. 重复 3–5 次
4. 保存：
   - 完整 wrk 输出
   - 运行命令行
   - Nginx/服务端 CPU 快照与客户端 CPU 快照

作图：

- `并发(或速率) -> RPS`
- `并发(或速率) -> p99 延迟`

三条曲线分别对应 Direct / Vanilla / Oracle（无 Katran / 原版 / 硬编码）。

---

## 4) 正确性闸门（Oracle 特别重要）

全量扫点前先确认：

- **Direct**：请求确实命中后端 Nginx，客户端收到 200。
- **原版（Vanilla）**：访问 VIP 能正确转发到 Nginx，返回 200。
- **Oracle**：
  - 仍能命中 Nginx；
  - 与原版功能行为一致；
  - 无异常错误峰值。

若出现 Oracle 看起来“异常更快”，优先检查是否发生路径短路（例如请求未到 Nginx）。

---

## 5) 交付物

1. 三组对比图：

- Direct vs Vanilla vs Oracle（三组）的吞吐曲线（RPS）
- Direct vs Vanilla vs Oracle（三组）的尾延迟曲线（p99）

2. Oracle 变更摘要：

- 硬编码了哪些 map/entry（来自 specialization spec）
- 阶段 A 的稳定性证据
- （可选）代码规模变化、分支消除证据

---

## 6) 常见失败模式与快速排查

- **Oracle 明显快于 Direct**：
  - 常见原因是请求未真正到达 Nginx，先查 Nginx 日志与计数器。
- **原版（Vanilla）与 Oracle 几乎完全重合**：
  - 可能是硬编码未覆盖热路径，或常量传播未生效。
- **结果抖动很大**：
  - 排查 CPU pinning、客户端瓶颈、背景噪声，确认阶段 B 已移除发现阶段行为。
