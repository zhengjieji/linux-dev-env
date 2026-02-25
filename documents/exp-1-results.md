# Experiment 1 Results Report (Step 1 + Step 2: Direct Nginx vs Vanilla Katran)

## 1. 报告范围

- 实验阶段：Experiment 1 完整基线（Step 1 + Step 2）
- 运行 ID：`20260224T024240Z`
- 运行日期（UTC）：2026-02-24
- 对比路径：
  1. `direct-nginx`: `vm2 (wrk) -> vm1 nginx (192.168.100.1:8080)`
  2. `vanilla-katran`: `vm2 (wrk) -> VIP 192.168.100.100:8080 -> vm1 nginx`

本报告基于该次完整 run 的最新结果，覆盖 direct 与 vanilla-katran 的对照结论。

## 2. 实验配置（本次 run）

- 工具：`wrk`
- 并发 sweep：`1 2 4 8 16 32 64 128 256`
- 线程数：`4`（每点实际 `min(4, connections)`）
- warmup：`15s`
- measure：`60s`
- repeats：`5`
- 每条路径共 `45` 个测量点（`9 * 5`）
- CPU pinning：
  - host: `DUAL_VM1_HOST_CPUSET=auto`, `DUAL_VM2_HOST_CPUSET=auto`
  - guest: `EXP1_NGINX_CPUSET=0-3`, `EXP1_WRK_CPUSET=0-3`, `EXP1_KATRAN_CPUSET=0-3`
- Katran 参数（Step 2）：VIP `192.168.100.100`，gRPC `50051`，forwarding cores `0,1,2,3`

## 3. 结果总览

### 3.1 数据质量

- `direct-nginx/wrk-summary.csv`：46 行（1 表头 + 45 测量）
- `vanilla-katran/wrk-summary.csv`：46 行（1 表头 + 45 测量）
- 两条路径均为：
  - `max_non2xx = 0`
  - `max_socket_timeouts = 0`

说明本次结果有效，没有明显功能错误/超时污染。

### 3.2 关键对比（聚合均值）

| connections | direct RPS | katran RPS | RPS 差值 | direct p99 (ms) | katran p99 (ms) | p99 差值 |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 7267 | 7189 | -1.08% | 0.1540 | 0.1632 | +5.97% |
| 2 | 14797 | 15482 | +4.63% | 0.1536 | 0.1566 | +1.95% |
| 4 | 44283 | 42265 | -4.56% | 0.1304 | 0.1340 | +2.76% |
| 8 | 107205 | 104494 | -2.53% | 0.1136 | 0.1168 | +2.82% |
| 16 | 170372 | 167997 | -1.39% | 0.1486 | 0.1528 | +2.83% |
| 32 | 224081 | 222399 | -0.75% | 0.2210 | 0.2246 | +1.63% |
| 64 | 252214 | 249242 | -1.18% | 0.3768 | 0.3878 | +2.92% |
| 128 | 273289 | 268430 | -1.78% | 0.7086 | 0.7282 | +2.77% |
| 256 | 280383 | 277672 | -0.97% | 1.1460 | 1.1960 | +4.36% |

整体统计（9 个并发点平均）：

- 平均 RPS 变化：`-1.07%`（Katran 相对 Direct）
- 平均 p99 变化：`+3.11%`

中高并发（`c >= 16`）更有代表性：

- 平均 RPS 变化：`-1.21%`
- 平均 p99 变化：`+2.90%`

峰值点（`c=256`）：

- Direct：`280382.862 RPS`, `p99=1.1460ms`
- Vanilla Katran：`277671.660 RPS`, `p99=1.1960ms`
- 差值：RPS `-0.97%`, p99 `+4.36%`

## 4. 结果解读（我对这次结果的看法）

1. 结果整体是“健康且可解释”的。  
Direct 大多数点吞吐更高、延迟更低，符合“引入 Katran 路径会增加一些开销”的预期方向。

2. 开销量级不大，但在中高并发上是稳定存在的。  
`c>=16` 区间里，Katran 基本都表现为约 `1%` 级吞吐损失和约 `3%` 级 p99 增加，这足够作为 Exp2/Exp3 的优化基线。

3. 低并发局部反常（例如 `c=2` Katran RPS 略高）可以视为统计抖动。  
该点差异与单点波动量级接近，不改变整体趋势判读；而中高并发差异方向一致。

4. CPU 利用率曲线两条路径非常接近。  
这说明当前开销主要体现在端到端吞吐/延迟，而不是简单表现为“某一侧 CPU 明显更高”。

## 5. 图表与产物

- direct 运行目录：`results/exp1/20260224T024240Z-direct-nginx`
- katran 运行目录：`results/exp1/20260224T024240Z-vanilla-katran`
- 对比目录：`results/exp1/20260224T024240Z-comparison`
- 对比图：`results/exp1/20260224T024240Z-comparison/plots/wrk-direct-vs-katran.png`
- 对比表：`results/exp1/20260224T024240Z-comparison/comparison-summary.csv`

## 6. 结论与下一步

Exp1（Step1+Step2）状态：**完成**。  
当前 baseline 已经具备进入 Exp2（Oracle hard-code）所需的对照基础。

建议 Exp2 重点观察：

1. `c=64~256` 的 RPS 与 p99 改善幅度（最能体现是否回收 Katran 基线开销）。
2. 保持与本次完全一致的 wrk 参数与 pinning，确保对照可复现。
