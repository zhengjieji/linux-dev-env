# 实验 2 结果报告（阶段 A 发现）

## 1. 报告范围

- 实验阶段：实验 2 / 阶段 A（发现）
- 运行日期（UTC）：2026-02-25
- 最新完整运行：
  1. `wrk`：`20260225T172725Z-stageA`
  2. `wrk2`：`20260225T175014Z-stageA`
- 产物目录：
  1. `results/exp2/discovery/20260225T172725Z-stageA`
  2. `results/exp2/discovery/20260225T175014Z-stageA`

## 2. 本次配置（关键参数）

- `sample_maps=all`（评估 balancer 挂载的全部 map）
- `sample_count=10`, `sample_interval_secs=30`, `steady_warmup_secs=30`
- 大 map 策略：
  - `max_map_dump_entries=1000000`
  - 超阈值 map 用 `hash_only` 采样
  - 若判定 invariant，保留 1 份 final dump（`keep_invariant_hash_only_dump=1`）
- 本次运行使用 `measure_tail_secs=1200`，保证 10 次采样窗口可完成

## 3. 数据质量检查

- 两个负载都完成了 10/10 采样点。
- `samples_missing_total=0`（无丢样本）。
- `hash_only` map（`ch_rings`, `server_id_map`）均有：
  - `final_dump_used=1`
  - `final_dump_hash_match=1`

## 4. 发现阶段结论

两次运行（`wrk` 与 `wrk2`）结论完全一致：

- 总 map 数：`14`
- **map 级不变量**：`12`
- 非 map 级不变量：`2`（`reals_stats`, `stats`）
- **entry 级不变量 map 数**：`5`

entry 级不变量 map（及稳定 entry 数）：

1. `ctl_array`（16）
2. `lru_mapping`（4）
3. `reals`（4096）
4. `vip_map`（1）
5. `vip_miss_stats`（1）

可作为阶段 B 硬编码的优先候选：

- map 级：`ch_rings`, `ctl_array`, `fallback_cache`, `lru_mapping`, `lru_miss_stats`, `quic_stats_map`, `reals`, `server_id_map`, `server_id_stats`, `vip_map`, `vip_miss_stats`, `vip_to_down_rea`
- 不建议按不变量硬编码：`reals_stats`, `stats`

## 5. 术语说明：entry 级 vs map 级

### 5.1 什么是 map 级不变量

定义：在采样窗口内，一个 map 的“整体状态”在每个采样点都一致。  
判定信号：`map_invariant=1`（本质是 map 级 hash 在所有 sample 相同）。

含义：可以把该 map 当作“整体常量”看待（尤其适合数组型配置 map）。

### 5.2 什么是 entry 级不变量

定义：某个 key 在所有采样点都出现，且该 key 对应 value 在所有采样点都不变。  
判定信号：`entry_analysis.invariant_entries` 中存在该 key。

含义：即使整个 map 会变化，也可能有“稳定子集 key/value”可被硬编码。

### 5.3 二者区别

1. 粒度不同：
   - map 级：整个 map
   - entry 级：map 内的部分 key
2. 严格程度不同：
   - map 级更严格（整体必须稳定）
   - entry 级更细粒度（允许局部稳定）
3. 在本次结果中：
   - 12 个 map 已达 map 级不变量
   - 5 个 map 还可给出明确 entry 级稳定 key/value

## 6. map 级不变量逐项解释（BPF 语义）

以下解释基于最新 `wrk2` run：`20260225T175014Z-stageA`。

本次 12 个 map 级不变量可以分成两类：

1. 控制面配置型 map（实验期间没改配置，所以不变）
2. 功能统计/状态 map（对应代码路径未触发，所以一直为 0 或空）

逐项说明：

1. `vip_map`
   - 作用：VIP -> `vip_meta(flags, vip_num)`，是数据面查 VIP 的主入口。
   - 为什么不变：实验期间没有增删/修改 VIP。
   - 什么时候会变：控制面执行 add/del VIP，或修改 VIP flags。

2. `ch_rings`
   - 作用：一致性哈希环槽位 -> real index。
   - 为什么不变：后端 real 集合和权重在实验窗口内固定。
   - 什么时候会变：增删 real、改权重、重建 hash ring。

3. `reals`
   - 作用：real index -> 后端地址与 real flags。
   - 为什么不变：后端列表未调整。
   - 什么时候会变：增删 real，或 real 属性变更。

4. `ctl_array`
   - 作用：封装控制数据（如默认 MAC）。
   - 为什么不变：程序加载后控制字段未更新。
   - 什么时候会变：修改 MAC/ifindex，或重载并改控制参数。

5. `lru_mapping`
   - 作用：CPU -> inner LRU map（map-in-map 外层）。
   - 为什么不变：attach 完成后 CPU 到 inner map 的绑定固定。
   - 什么时候会变：forwarding cores 改变，或重新 attach LRU。

6. `fallback_cache`
   - 作用：当 `lru_mapping` 查找失败时的兜底 LRU。
   - 为什么不变：本次没有走 fallback 路径，map 始终空。
   - 什么时候会变：`lru_mapping` 异常/缺失，或测试场景强制走 fallback。

7. `lru_miss_stats`
   - 作用：按 real 统计“被监控 VIP”的 LRU miss 次数。
   - 为什么不变：当前 `vip_miss_stats` 里是默认监控项，未对齐业务 VIP，计数未增长。
   - 什么时候会变：设置被监控 VIP 且发生 LRU miss。

8. `vip_miss_stats`
   - 作用：定义“哪个 VIP 需要统计 LRU miss”（单槽位配置）。
   - 为什么不变：实验期间未更新该配置。
   - 什么时候会变：调用控制面接口更新监控 VIP。

9. `quic_stats_map`
   - 作用：QUIC 路由相关统计（cid 版本、cid 命中、fallback 等）。
   - 为什么不变：本次 VIP 不是 QUIC VIP 路径，计数全 0。
   - 什么时候会变：启用 QUIC VIP 并有 QUIC 流量进入该分支。

10. `server_id_map`
   - 作用：server_id -> real index（用于 QUIC/server-id 路由）。
   - 为什么不变：没有 server_id 控制面更新。
   - 什么时候会变：注册/失效/重校验 server_id 映射。

11. `server_id_stats`
   - 作用：server-id 路由命中与 LRU 不一致统计。
   - 为什么不变：server-id 路由分支未触发，计数全 0。
   - 什么时候会变：QUIC/server-id 路径被实际流量命中。

12. `vip_to_down_rea`（`vip_to_down_reals_map`）
   - 作用：记录每个 VIP 下“down real”集合（UDP flow migration 依赖）。
   - 为什么不变：实验中未标记 real down/up，map 一直空。
   - 什么时候会变：健康检查或控制面更新 real 健康状态。

补充说明（避免误解）：

1. map 级不变量只说明“整张 map 的哈希不变”，不等于语义上永远不变。
2. `lru_mapping` 不变只代表外层绑定稳定，不代表 inner `katran_lru*` 的流状态不变。
3. `stats` 与 `reals_stats` 非 invariant 是预期现象，因为它们在 fast path 持续累加计数。

## 7. 不变量 map 的类型与代码位置

> 说明：下面 map type 以本次运行时观测为准（`samples/sample-000/map-show.json`）。  
> 其中 `server_id_map` 在源码中支持 `hash/array` 两种编译形态；本次实际加载类型是 `array`。

| map | 运行时类型 | 声明位置 | 数据面调用位置（`balancer.bpf.c`） | 控制面主要写入位置（`KatranLb.cpp`） |
|---|---|---|---|---|
| `vip_map` | `hash` | `balancer_maps.h:38` | `420`, `787`, `790`（多次查找） | `3025`（更新）, `3034`（删除） |
| `ch_rings` | `array` | `balancer_maps.h:73` | `146`（查找） | `1304`, `1310`（批量更新） |
| `reals` | `array` | `balancer_maps.h:82` | `159`, `198`, `540`, `898`（多次查找） | `3083`（更新） |
| `ctl_array` | `array` | `control_data_maps.h:41` | `1033`（查找） | `804`, `824`, `974`, `1524`（更新） |
| `lru_mapping` | `array_of_maps` | `balancer_maps.h:64` | `839`（查找到 inner map） | `554`, `555`（绑定 inner map） |
| `fallback_cache` | `lru_hash` | `balancer_maps.h:47` | `841`（fallback 选择）；间接更新发生在 `172`, `634`（通过 `lru_map` 指针） | 常规实验无控制面固定写入；调试/清理路径见 `2509`, `2553`, `2815`, `2852`, `3006` |
| `lru_miss_stats` | `percpu_array` | `balancer_maps.h:100` | `603`（查找） | `1918`（重置），`1958`（查找读取） |
| `vip_miss_stats` | `array` | `balancer_maps.h:108` | `588`（查找） | `851`（初始化）, `1893`（更新监控 VIP） |
| `quic_stats_map` | `percpu_array` | `balancer_maps.h:126` | `876`（查找） | 主要为读取统计：`2017` |
| `server_id_map` | `array`（本次） | `balancer_maps.h:155/163`（条件编译） | `534`, `886`（查找） | `1796`, `3277`, `3300`（更新）, `3273`（删除） |
| `server_id_stats` | `percpu_array` | `balancer_maps.h:228` | `641`（查找） | 主要为读取统计：`3261` |
| `vip_to_down_rea` (`vip_to_down_reals_map`) | `hash_of_maps` | `balancer_maps.h:248` | `662`（外层查找）, `664`（内层查找） | `3324`, `3355`, `3385`（新增/更新）, `3467`, `3529`（删除） |

补充：

1. 是的，多个 map 在数据面会被多次调用（例如 `vip_map`, `reals`, `server_id_map`）。  
2. `lru_mapping/fallback_cache` 的更新是“通过 `lru_map` 指针间接发生”，因此行号不总是直接出现 map 名称。  
3. `server_id_map` 的 map 类型需要结合编译选项判断；本次运行时明确是 `array`。

## 8. 关键文件

- `results/exp2/discovery/20260225T172725Z-stageA/invariant-summary.csv`
- `results/exp2/discovery/20260225T172725Z-stageA/specialization-spec.json`
- `results/exp2/discovery/20260225T175014Z-stageA/invariant-summary.csv`
- `results/exp2/discovery/20260225T175014Z-stageA/specialization-spec.json`

## 9. 阶段 B：全量 invariant 硬编码实现（当前版本）

> 说明：这一节记录“代码实现层面”已经落地的 Oracle 方案，不是性能结论。  
> 本次目标是把 Stage A 识别的不变量全部纳入硬编码路径（或编译期裁剪路径）。

实现入口：

1. 生成器：`scripts/exp2/generate-oracle.py`
2. 生成头：`source/katran/katran/lib/bpf/oracle/exp2_oracle_generated.h`
3. API shim：`source/katran/katran/lib/bpf/oracle/exp2_oracle_api.h`
4. 数据面接入：
   - `source/katran/katran/lib/bpf/balancer.bpf.c`
   - `source/katran/katran/lib/bpf/pckt_parsing.h`

### 9.1 每个 invariant map 的硬编码方式与原因

1. `vip_map`（`hash`）
   - 做法：生成 `exp2_oracle_lookup_vip_map()`，按 key（vipv6/port/proto）精确匹配，命中返回静态 `vip_meta`。
   - 原因：条目很小（当前 1 条），直接常量匹配最简单，省去 map helper。

2. `ch_rings`（`array`, 大表）
   - 做法：只硬编码“活跃 VIP 的 ring 段”，`exp2_oracle_lookup_ch_ring(vip_num, hash)` 直接数组索引。
   - 原因：整表非常大，但热路径只访问活跃 VIP 段；该方式保留 O(1) 查找且避免无关段膨胀。

3. `reals`（`array`）
   - 做法：稀疏硬编码“非零 entry”，并提供 `real_zero` 作为默认 0 值；`exp2_oracle_lookup_reals()` 用 `switch(key)`。
   - 原因：`array` 语义里大量槽位是 0，稀疏化可减少无意义常量。

4. `ctl_array`（`array`）
   - 做法：全量静态数组 `exp2_oracle_ctl_array[]`，`exp2_oracle_lookup_ctl_array()` 直接返回指针。
   - 原因：容量小（16），全量硬编码最直接。

5. `vip_miss_stats`（`array`，key=0）
   - 做法：硬编码 key=0 对应 `vip_definition`；`exp2_oracle_lookup_vip_miss_stats()` 仅支持 key=0。
   - 原因：该 map 本质就是单槽位配置。

6. `vip_to_down_rea` / `vip_to_down_reals_map`（`hash_of_maps`）
   - 做法：生成宏 `EXP2_ORACLE_VIP_TO_DOWN_REALS_EMPTY=1`，在 `check_udp_flow_migration()` 直接编译期早退。
   - 原因：发现阶段证明该 map 为空，运行时不需要进入 down-real 检查分支。

7. `server_id_map`（`array`，超大）
   - 做法：当前 spec 下启用 `EXP2_ORACLE_SERVER_ID_MAP_LOOKUP_PASSTHROUGH=1`，helper 返回 false（回落原 map）；同时把 server-id 相关路径编译期裁剪（见下）。
   - 原因：该 map final dump 约 1.9GB，直接全量扫描/展开成本过高；且本次 workload 下 server-id 路径可被证明不触发。

8. `quic_stats_map`（`percpu_array`）
   - 做法：利用 `EXP2_ORACLE_ALL_VIPS_NO_QUIC=1`，在 `process_packet()` 编译期移除 QUIC 分支。
   - 原因：没有 QUIC VIP，整个路径可静态消除，`quic_stats_map` 不再访问。

9. `server_id_stats`（`percpu_array`）
   - 做法：`EXP2_ORACLE_SERVER_ID_STATS_ALL_ZERO=1` 时，`incr_server_id_routing_stats()` 直接 return。
   - 原因：发现阶段全零，且本 workload 的 server-id 路由路径被裁剪。

10. `lru_miss_stats`（`percpu_array`）
    - 做法：`EXP2_ORACLE_VIP_MISS_NEVER_MATCH_ACTIVE=1` 时，`update_vip_lru_miss_stats()` 编译期直接 return。
    - 原因：监控 VIP 与活跃 VIP 不匹配，不会命中计数分支。

11. `lru_mapping`（`array_of_maps`）
    - 做法：保留运行时 map lookup，不做“值常量化”；仅记录宏 `EXP2_ORACLE_LRU_MAPPING_INVARIANT`。
    - 原因：value 是 inner-map 引用（运行时对象），不能像普通标量/结构体那样静态内联。

12. `fallback_cache`（`lru_hash`）
    - 做法：保留运行时行为，不做静态替换；记录 `EXP2_ORACLE_FALLBACK_CACHE_EMPTY`。
    - 原因：它是运行时状态缓存（并可能在异常路径被写入），不适合固定成只读常量。

### 9.2 新增的关键编译期策略宏

本次生成头里已包含：

1. `EXP2_ORACLE_ALL_VIPS_NO_QUIC=1`
2. `EXP2_ORACLE_ALL_VIPS_NO_UDP_STABLE_ROUTING=1`
3. `EXP2_ORACLE_ALL_VIPS_NO_UDP_FLOW_MIGRATION=1`
4. `EXP2_ORACLE_VIP_TO_DOWN_REALS_EMPTY=1`
5. `EXP2_ORACLE_VIP_MISS_NEVER_MATCH_ACTIVE=1`
6. `EXP2_ORACLE_SERVER_ID_STATS_ALL_ZERO=1`
7. `EXP2_ORACLE_DISABLE_TCP_SERVER_ID_ROUTING=1`
8. `EXP2_ORACLE_SERVER_ID_MAP_LOOKUP_PASSTHROUGH=1`

其中第 7/8 项是这次新增，用于避免对 1.9GB `server_id_map` dump 做低收益全量扫描。

## 10. 原版 vs 优化版 BPF 程序静态对比（最新）

对比方式：

1. 同一套源码（当前分支），仅切换编译宏：
   - Vanilla：`-DLOCAL_DELIVERY_OPTIMIZATION`
   - Oracle：`-DLOCAL_DELIVERY_OPTIMIZATION -DEXP2_ORACLE_CH_RINGS`
2. 使用同一 clang/llc 工具链，通过 `build_bpf_modules_opensource.sh` 编译。
3. 对比对象：`balancer.bpf.o` 的 `xdp` section 与 helper call。

结果：

| 指标 | Vanilla | Oracle（全量 invariant 版） | 变化 |
|---|---:|---:|---:|
| `balancer.bpf.o` 文件大小 | 158,424 B | 387,920 B | +144.9% |
| `xdp` section 大小 | 21,112 B | 16,632 B | -21.2% |
| `xdp` 指令条数 | 2,546 | 1,995 | -21.6% |
| `xdp` helper call 总数 | 84 | 50 | -40.5% |
| `.rodata` 大小 | 0 B | 262,336 B | +262,336 B |

helper call 细分（`call id -> 次数`）：

1. Vanilla：`1:66, 2:4, 5:8, 8:2, 44:4`
2. Oracle：`1:38, 2:2, 5:4, 8:2, 44:4`

### 10.1 指令数减少的根因（直接回答）

是的，**本次指令数减少，核心原因就是“用 Stage A 导出的 map 数据做了编译期特化”**。  
但严格说法是：

1. 不是 clang 直接去读取运行时 map；
2. 而是先由 `generate-oracle.py` 把 map 快照转成 C 常量/宏（`exp2_oracle_generated.h`）；
3. 再由编译器对这些常量做内联、常量传播、死代码消除（DCE）。

### 10.2 这次具体做了哪些优化

1. 用 `vip_map` 的不变量推导策略宏，直接裁剪整段分支：
   - `EXP2_ORACLE_ALL_VIPS_NO_QUIC=1`：移除 QUIC 路径；
   - `EXP2_ORACLE_ALL_VIPS_NO_UDP_STABLE_ROUTING=1`：移除 UDP stable routing 路径；
   - `EXP2_ORACLE_ALL_VIPS_NO_UDP_FLOW_MIGRATION=1`：移除 UDP flow migration 路径。

2. 用 `vip_to_down_reals_map` 的“恒为空”结果，编译期早退：
   - `EXP2_ORACLE_VIP_TO_DOWN_REALS_EMPTY=1`，`check_udp_flow_migration()` 不再进入 down-real 查找。

3. 用 `vip_miss_stats` 与活跃 VIP 不匹配的结果，编译期早退：
   - `EXP2_ORACLE_VIP_MISS_NEVER_MATCH_ACTIVE=1`，`update_vip_lru_miss_stats()` 直接返回。

4. 用 `server_id_stats` 全零 + 负载路径不可达，裁剪 server-id 路由：
   - `EXP2_ORACLE_DISABLE_TCP_SERVER_ID_ROUTING=1`：禁用 TCP server-id 路由块；
   - `EXP2_ORACLE_SERVER_ID_STATS_ALL_ZERO=1`：`incr_server_id_routing_stats()` 直接返回。

5. 把热点 map lookup 替换为静态常量 helper（命中时不走 map helper）：
   - `vip_map` -> `exp2_oracle_lookup_vip_map`
   - `ch_rings` -> `exp2_oracle_lookup_ch_ring`
   - `reals` -> `exp2_oracle_lookup_reals`
   - `ctl_array` -> `exp2_oracle_lookup_ctl_array`
   - `vip_miss_stats` -> `exp2_oracle_lookup_vip_miss_stats`

6. `server_id_map` 因体量极大（final dump 约 1.9GB），本次未做全量表展开：
   - 采用 `EXP2_ORACLE_SERVER_ID_MAP_LOOKUP_PASSTHROUGH=1`（helper 返回 false）；
   - 通过前述分支裁剪避免在本 workload 下产生这一路径的热开销。

### 10.3 为什么这些优化会反映到当前数字

1. `xdp` 指令数下降（`2546 -> 1995`）：
   - 大块不可达分支被删；
   - 运行时查 map 的通用路径被替换/简化。

2. helper call 降低（`84 -> 50`）：
   - 主要体现在 `call 1` 和 `call 2` 的减少（`66->38`, `4->2`）。

3. `.rodata` 增大（`0 -> 262,336 B`）且对象文件变大（+144.9%）：
   - 是把运行时 map 内容“前移”为编译期静态常量的直接结果。

结论：这组静态指标变化，和本次“用 map 不变量做编译期特化”的实现是一致的。

## 11. 本次实现边界（明确说明）

1. 这是 workload-specific Oracle：基于本次 Stage A（`20260225T175014Z-stageA`）的稳定性假设。
2. `server_id_map` 没有做全量值展开，而是通过路径裁剪 + passthrough 组合处理。
3. `lru_mapping`/`fallback_cache` 属于运行时状态型 map，当前保留运行时访问语义，不做静态值内联。
