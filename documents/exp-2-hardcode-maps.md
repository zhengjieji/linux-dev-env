# Exp2 Hardcode Maps 详细说明（专业版 + 白话版）

本文是当前 Exp2 hardcode 实现的“逐 map 设计说明”，目标是回答四个问题：

1. 这个 map 在数据路径里具体做什么？
2. 为什么在当前实验里它是 invariant（不变）？
3. 我们是如何 hardcode 的？
4. 为什么用这种 hardcode 方式，而不是别的方式？

## 0) 数据来源与判定口径

- 发现结果（当前这轮）：
  - `results/exp2/discovery/20260227T195253Z-stageA/specialization-spec.json`
  - `results/exp2/discovery/20260227T195253Z-stageA/samples/sample-000/*`
- map 类型与容量：
  - `results/exp2/discovery/20260227T195253Z-stageA/samples/sample-000/map-show.json`
- 当前手写 hardcode 实现：
  - `source/katran/katran/lib/bpf/oracle/exp2_oracle_handwritten.h`
  - `source/katran/katran/lib/bpf/oracle/exp2_oracle_api.h`
  - `source/katran/katran/lib/bpf/balancer.bpf.c`
  - `source/katran/katran/lib/bpf/pckt_parsing.h`

说明：

- “出现次数”按源码静态调用点统计，不是运行时命中次数。
- 本文只覆盖 discovery 判定为 invariant 且与 hardcode 相关的 map。
- `reals_stats`/`stats` 在本轮是非 invariant，不在 hardcode 范围。

## 1) 总览（先看结论）

| map | 类型 | 当前状态 | hardcode 类型 | 结论 |
|---|---|---|---|---|
| `vip_map` | `hash` | invariant | 值级 | 已 hardcode |
| `ch_rings` | `array`(超大) | invariant | 值级（按活跃 VIP） | 已 hardcode |
| `reals` | `array` | invariant | 值级 | 已 hardcode |
| `ctl_array` | `array` | invariant | 值级 | 已 hardcode |
| `vip_miss_stats` | `array` | invariant | 值级+路径剪枝 | 已 hardcode |
| `decap_dst` | `hash` | invariant(空) | 路径剪枝 | 已 hardcode |
| `vip_to_down_rea` (`vip_to_down_reals_map`) | `hash_of_maps` | invariant(空) | 路径剪枝 | 已 hardcode |
| `lru_miss_stats` | `percpu_array` | invariant(全零) | 路径剪枝 | 已 hardcode |
| `quic_stats_map` | `percpu_array` | invariant(全零) | 路径剪枝 | 已 hardcode（禁 QUIC 路径） |
| `server_id_stats` | `percpu_array` | invariant(全零) | 路径剪枝 | 已 hardcode |
| `server_id_map` | `array`(超大) | invariant(hash-only) | 路径剪枝 | 已 hardcode（不做值替换） |
| `lru_mapping` | `array_of_maps` | invariant | 部分（策略） | 已部分 hardcode |
| `fallback_cache` | `lru_hash` | invariant(空) | 部分（策略） | 已部分 hardcode |
| `subprograms` | `prog_array` | invariant | 不可值级 hardcode | 保持原生 |

---

## 2) 逐 map 详细说明

### 2.1 `vip_map`

- map 类型：`hash`（`max_entries=512`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:38`
- 主要调用位置：
  - `source/katran/katran/lib/bpf/balancer.bpf.c:449`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:869`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:877`

专业解释：

- key 是 `vip_definition`（VIP IP/端口/协议），value 是 `vip_meta`（如 `vip_num`、flags）。
- 这是后续一致性哈希、特性分支（本地 VIP、QUIC VIP 等）的入口元数据。

白话解释：

- 这是“服务目录表”。先看用户请求的是哪个 VIP，再决定后面怎么分流。

当前值（sample-000）：

- 只有 1 条：
  - VIP=`192.168.100.100:8080/tcp`
  - value=`flags=32(F_LOCAL_VIP), vip_num=0`

为什么不变：

- 本实验全程只配置一个 VIP，控制面不动态增删 VIP。

什么时候会变：

- 新增/删除 VIP、修改端口协议、切换 VIP flags 时会变。

hardcode 方式：

- 值级 hardcode，手写 helper：
  - `exp2_oracle_lookup_vip_map()`  
  - 位置：`source/katran/katran/lib/bpf/oracle/exp2_oracle_handwritten.h:36`
- 在数据路径先走 helper，失败再 fallback 到 `bpf_map_lookup_elem(&vip_map, ...)`。

为什么这样做：

- 表很小、值稳定、且在热路径早期，直接常量化收益稳定且风险低。

---

### 2.2 `ch_rings`

- map 类型：`array`（`max_entries=33554944`，超大）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:73`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:154`

专业解释：

- 一致性哈希环：`ring_key = RING_SIZE * vip_num + hash`，value 是 `real_index`。
- 是 VIP 到 backend 的核心选路表。

白话解释：

- 这是“大转盘”。每个请求哈希后落到转盘某格，格子里写着要转发到哪个后端。

当前值（sample-000）：

- 由于 map 太大，discovery 使用 hash-only：
  - `ch_rings.hash.json`：`9df258f6...`
- 未保存全量 dump（避免数 GB 文件）。

为什么不变：

- 本实验后端集合与权重固定，ring 没有被重建。

什么时候会变：

- backend 上下线、权重调整、ring 重算参数变化时会变。

hardcode 方式：

- 值级 hardcode（针对当前活跃 VIP）：
  - `exp2_oracle_lookup_ch_ring(vip_num, hash, &real_pos)` 对 `vip_num=0` 固定返回 `real_pos=1`
  - 位置：`source/katran/katran/lib/bpf/oracle/exp2_oracle_handwritten.h:54`
- 接入点：`balancer.bpf.c:150`

为什么这样做：

- 当前实验中活跃 VIP 实际落到同一 real（index=1），可直接去掉最重的 array lookup。

---

### 2.3 `reals`

- map 类型：`array`（`max_entries=4096`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:82`
- 主要调用位置：
  - `source/katran/katran/lib/bpf/pckt_parsing.h:355`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:171`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:215`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:587`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:1014`

专业解释：

- `real_index -> real_definition(dst IP + flags)`，是最终 backend 地址表。

白话解释：

- 这是“后端通讯录”。拿到后端编号后，在这里查到真实 IP。

当前值（sample-000）：

- `4096` 个槽位里仅 `key=1` 非零：
  - `dst=192.168.100.2`
  - `flags=2 (F_LOCAL_REAL)`
- 其余 key 全部零值。

为什么不变：

- 后端节点固定，编号与地址未变。

什么时候会变：

- 扩缩容、后端 IP 变化、flags 变化（如 local/remote）时会变。

hardcode 方式：

- 值级 hardcode，手写 helper：
  - `key==1` 返回 `exp2_oracle_real_1`
  - 其他合法 key 返回 `exp2_oracle_real_zero`
  - 位置：`source/katran/katran/lib/bpf/oracle/exp2_oracle_handwritten.h:83`

为什么这样做：

- 稀疏大数组，热点只在 1 个条目，常量化性价比高。

---

### 2.4 `ctl_array`

- map 类型：`array`（`max_entries=16`）
- 定义位置：`source/katran/katran/lib/bpf/control_data_maps.h:41`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:1159`

专业解释：

- 控制参数表。当前关键项是 `idx=0` 的默认路由 MAC（用于改写二层目的 MAC）。

白话解释：

- 这是“系统配置常量表”，其中第 0 格是“发包要写到哪个 MAC”。

当前值（sample-000）：

- `key=0` 为 `56077945164882`，对应 MAC `[82,84,0,170,0,51]`（即 `52:54:00:aa:00:33`）。
- 其他 key 都是 0。

为什么不变：

- 拓扑和目的下一跳 MAC 固定。

什么时候会变：

- VM 网卡/MAC 变化、L2 路径变化时会变。

hardcode 方式：

- 值级 hardcode：
  - `exp2_oracle_lookup_ctl_array()` 在 `key=0` 返回固定 MAC，其他 key 返回零值
  - 位置：`source/katran/katran/lib/bpf/oracle/exp2_oracle_handwritten.h:105`

为什么这样做：

- 主路径只依赖固定下标，最适合常量替换。

---

### 2.5 `vip_miss_stats`

- map 类型：`array`（`max_entries=1`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:108`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:655`

专业解释：

- 指定“对哪个 VIP 统计 LRU miss”。逻辑在 `update_vip_lru_miss_stats()` 内。

白话解释：

- 这是“我只盯哪个 VIP 的丢缓存次数”的开关。

当前值（sample-000）：

- 只有 `key=0`，内容是全零 VIP（`0.0.0.0:0/proto0`），与当前 active VIP 不匹配。

为什么不变：

- 控制面没有切换这个统计目标。

什么时候会变：

- 需要改监控目标 VIP 时会变。

hardcode 方式：

- 值级 + 路径级结合：
  - `exp2_oracle_lookup_vip_miss_stats()` 固定返回零 VIP
  - 同时 `EXP2_ORACLE_VIP_MISS_NEVER_MATCH_ACTIVE=1` 直接短路该统计分支
  - 代码位置：
    - `exp2_oracle_handwritten.h:140`
    - `balancer.bpf.c:633`

为什么这样做：

- 该统计在当前 workload 永远不会命中，直接剪枝最干净。

---

### 2.6 `decap_dst`

- map 类型：`hash`（`max_entries=512`）
- 定义位置：`source/katran/katran/lib/bpf/control_data_maps.h:62`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:240`

专业解释：

- 用于决定 decap 后是否 `XDP_PASS` 到内核或继续在 XDP 流程处理。

白话解释：

- 这是“哪些目的地址要走特殊解封装路径”的白名单。

当前值（sample-000）：

- 空表 `[]`。

为什么不变：

- 本实验没有配置 decap 目的白名单。

什么时候会变：

- 开启跨 POP decap、严格 decap 策略时会变。

hardcode 方式：

- 路径级 hardcode：
  - `EXP2_ORACLE_DECAP_DST_EMPTY=1` 时直接视作无命中，不做 map lookup
  - 位置：`balancer.bpf.c:232`

为什么这样做：

- 对空 hash 做值替换没有意义，直接删 lookup 更直接。

---

### 2.7 `vip_to_down_rea`（源码名 `vip_to_down_reals_map`）

- map 类型：`hash_of_maps`（外层 `max_entries=512`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:248`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:743`

专业解释：

- VIP -> 下线 real 集合（inner hash），用于 UDP flow migration 避开故障 real。

白话解释：

- 这是“某个 VIP 下哪些后端已下线”的黑名单表。

当前值（sample-000）：

- 空表 `[]`。

为什么不变：

- 实验期间没有下线 backend，也没触发 migration 维护。

什么时候会变：

- backend 健康状态变化、控制面写入 down list 时会变。

hardcode 方式：

- 路径级 hardcode：
  - `EXP2_ORACLE_VIP_TO_DOWN_REALS_EMPTY=1`
  - `check_udp_flow_migration()` 直接早返回
  - 位置：`balancer.bpf.c:732`

为什么这样做：

- `hash_of_maps` 不适合值级替换，且当前为空集，最优是剪掉整段逻辑。

---

### 2.8 `lru_miss_stats`

- map 类型：`percpu_array`（`max_entries=4096`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:100`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:671`

专业解释：

- 记录每个 real 的 LRU miss 计数（每 CPU 一份）。

白话解释：

- 这是“每个后端被缓存 miss 了多少次”的计数器。

当前值（sample-000）：

- 4096 项全为 0（所有 CPU 都为 0）。

为什么不变：

- 当前流量模式下该统计未被触发。

什么时候会变：

- 打开/命中对应统计逻辑、出现真实 LRU miss 计数累加时会变。

hardcode 方式：

- 路径级 hardcode：
  - `EXP2_ORACLE_LRU_MISS_STATS_ALL_ZERO=1`
  - `update_vip_lru_miss_stats()` 直接返回
  - 位置：`balancer.bpf.c:640`

为什么这样做：

- 这是纯统计 side-path，剪掉对转发语义无影响。

---

### 2.9 `quic_stats_map`

- map 类型：`percpu_array`（`max_entries=1`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:126`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:978`

专业解释：

- 统计 QUIC 路由行为（CID 解析、fallback 等）。

白话解释：

- 这是“QUIC 专用计分板”。

当前值（sample-000）：

- 全部字段全 0（所有 CPU 都是 0）。

为什么不变：

- 当前 workload 不走 QUIC 路径。

什么时候会变：

- 流量里出现 QUIC 且开启相关路由逻辑时会变。

hardcode 方式：

- 路径级 hardcode（主手段）：
  - `EXP2_ORACLE_ALL_VIPS_NO_QUIC=1`
  - 整个 QUIC 分支编译期不进入
  - 位置：`balancer.bpf.c:955`
- 说明：
  - `EXP2_ORACLE_QUIC_STATS_ALL_ZERO` 在头文件中定义了，但当前代码没有单独 `#if` 使用；
  - 真正生效的是“禁 QUIC 路径”这个宏。

为什么这样做：

- 对未命中路径，直接编译期裁剪比“保留逻辑 + 返回零值”更干净。

---

### 2.10 `server_id_stats`

- map 类型：`percpu_array`（`max_entries=512`）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:228`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:715`

专业解释：

- 统计 server-id 路由中新连接与 LRU 不一致等情况。

白话解释：

- 这是“server-id 路由健康度计数器”。

当前值（sample-000）：

- 512 项全为 0（所有 CPU 的 `v1/v2` 都为 0）。

为什么不变：

- 当前场景 server-id 路由链路基本未启用/未命中。

什么时候会变：

- 开启并命中 server-id 路由时会变。

hardcode 方式：

- 路径级 hardcode：
  - `EXP2_ORACLE_SERVER_ID_STATS_ALL_ZERO=1`
  - `incr_server_id_routing_stats()` 直接 return
  - 位置：`balancer.bpf.c:708`

为什么这样做：

- 纯统计路径，裁剪后不影响转发结果。

---

### 2.11 `server_id_map`

- map 类型：`array`（`max_entries=16777214`，超大）
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:163`
- 主要调用位置：
  - `source/katran/katran/lib/bpf/pckt_parsing.h:334`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:572`
  - `source/katran/katran/lib/bpf/balancer.bpf.c:993`

专业解释：

- `server_id -> real_index`，用于 QUIC/UDP stable routing/TCP option 路由。

白话解释：

- 这是“带 server-id 的快速直达表”。

当前值（sample-000）：

- 因表极大，discover 使用 hash-only：
  - `server_id_map.hash.json`：`ac9902c2...`

为什么不变：

- 实验期间 server-id 到 real 的映射未更新。

什么时候会变：

- 变更 server-id 分配、后端分配策略、控制面重建映射时会变。

hardcode 方式：

- 不做值级 hardcode（太大且无全量 dump，风险高）。
- 做路径级 hardcode：
  - `exp2_oracle_lookup_server_id_map()` 恒 `false`（passthrough）
  - 同时关闭相关路径：
    - `EXP2_ORACLE_ALL_VIPS_NO_QUIC=1`
    - `EXP2_ORACLE_ALL_VIPS_NO_UDP_STABLE_ROUTING=1`
    - `EXP2_ORACLE_DISABLE_TCP_SERVER_ID_ROUTING=1`
  - 位置：
    - `exp2_oracle_handwritten.h:126`
    - `pckt_parsing.h:315`
    - `balancer.bpf.c:955,1054,1068`

为什么这样做：

- 在当前 workload 下这些路径不活跃，路径剪枝收益更稳，避免硬编码超大表带来的维护风险。

---

### 2.12 `lru_mapping`

- map 类型：`array_of_maps`
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:64`
- 主要调用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:930`

专业解释：

- `cpu_id -> 对应 LRU map`（map-in-map 外层索引）。

白话解释：

- 这是“每个 CPU 用哪本 LRU 缓存”的目录。

当前值（sample-000）：

- `cpu 0/1/2/3 -> inner map id 1/2/3/4`。

为什么不变：

- CPU 数与 lru map 初始化固定。

什么时候会变：

- CPU 拓扑变化、LRU map 重新组织时会变。

hardcode 方式：

- 部分 hardcode（策略级）：
  - 不能把 inner-map 指针值硬编码成普通常量（eBPF verifier 与 map-in-map 语义限制）。
  - 采用：
    - `EXP2_ORACLE_LRU_MAPPING_INVARIANT=1`
    - `EXP2_ORACLE_FALLBACK_CACHE_EMPTY=1`
    - 若 `lru_mapping` lookup 失败则直接 drop，不再走 fallback
  - 位置：`balancer.bpf.c:931`

为什么这样做：

- 保留合法 map-in-map 访问，同时删除无效 fallback 分支。

---

### 2.13 `fallback_cache`

- map 类型：`lru_hash`
- 定义位置：`source/katran/katran/lib/bpf/balancer_maps.h:47`
- 使用位置：`source/katran/katran/lib/bpf/balancer.bpf.c:938`（作为 fallback 指针）

专业解释：

- 当 `lru_mapping` 取不到 per-cpu map 时，用这张全局 fallback LRU。

白话解释：

- 这是“备用缓存本”。

当前值（sample-000）：

- 空表 `[]`。

为什么不变：

- 正常情况下不会走 fallback，故始终空。

什么时候会变：

- `lru_mapping` 异常、或故障场景回退时可能写入。

hardcode 方式：

- 部分 hardcode（路径级）：
  - 通过上一节的宏组合去掉 fallback 行为，不直接替换 map 值。

为什么这样做：

- 该 map 的核心价值在“兜底语义”而非固定值，删分支比替换值更合理。

---

### 2.14 `subprograms`

- map 类型：`prog_array`
- 定义位置：`source/katran/katran/lib/bpf/control_data_maps.h:69`
- 调用位置：`source/katran/katran/lib/bpf/balancer_helpers.h:78`（`bpf_tail_call`）

专业解释：

- tail call 目标程序索引表，决定跳转到哪个 eBPF 子程序。

白话解释：

- 这是“程序跳转表”，类似函数指针表，但由内核管理。

当前值（sample-000）：

- `key=0 -> prog id 6`。

为什么不变：

- 本实验中子程序装载关系固定。

什么时候会变：

- 更换/重载子程序、变更 tail call 编排时会变。

hardcode 方式：

- 不做值级 hardcode（不可替代）：
  - `bpf_tail_call` 必须通过 `prog_array` map 由内核完成跳转，不能用普通常量代替。

为什么这样做：

- 这是 eBPF 机制限制，不是工程偏好。

---

## 3) 补充：哪些 map 不在 hardcode 范围

- `stats`、`reals_stats`：discovery 判定非 invariant（会随流量变化），不应 hardcode。
- 这两类 map 是“运行时计数器”，本质上就应该变化。

## 4) 最终结论（本轮）

- 值级 hardcode（直接替换 map 值）：  
  `vip_map`、`ch_rings`、`reals`、`ctl_array`、`vip_miss_stats`
- 路径级 hardcode（编译期剪枝/早返回）：  
  `decap_dst`、`vip_to_down_rea`、`lru_miss_stats`、`quic_stats_map`、`server_id_stats`、`server_id_map`
- 部分 hardcode（受 eBPF 语义限制）：  
  `lru_mapping`、`fallback_cache`
- 不可值级 hardcode：  
  `subprograms`（`prog_array` tail call 语义）

以上均为“手写 hardcode”，没有使用自动生成器。
