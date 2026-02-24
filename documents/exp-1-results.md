# Experiment 1 Results Report (Step 1: Direct Nginx + wrk)

## 1. 报告范围

- 实验阶段：Experiment 1, Step 1（Direct baseline）
- 运行目录：`results/exp1/20260222T210742Z-direct-nginx`
- 运行日期（UTC）：2026-02-22
- 拓扑：`vm2 (wrk client) -> vm1 (nginx server)`，无 Katran/XDP 路径

本报告只覆盖 Step 1：建立可解释、可复现实验基线。

## 2. 实验目标（Step 1）

1. 建立 direct path 下的基线性能曲线（无 Katran）。
2. 明确并发增加时的吞吐与延迟趋势，识别 knee/平台区。
3. 记录 server/client 两侧 CPU 利用率，检查是否存在明显 client-side bottleneck。
4. 形成后续 Step 2（Vanilla Katran）可直接对比的基线数据。

## 3. 实验配置

### 3.1 负载与时长

- 工具：`wrk`
- 并发连接（sweep）：`1 2 4 8 16 32 64 128 256`
- 线程数：`4`（每点实际线程数为 `min(4, connections)`）
- 预热：`15s`
- 正式测量：`60s`
- 每点重复：`5`
- 总测量点：`9 * 5 = 45`

### 3.2 服务器与流量目标

- server IP：`192.168.100.1`
- server port：`8080`
- server file：`exp1-1k.txt`（1KB 静态文件）
- nginx 运行在 vm1，wrk 运行在 vm2

### 3.3 CPU pinning

- host-level（QEMU）：`DUAL_VM1_HOST_CPUSET=auto`, `DUAL_VM2_HOST_CPUSET=auto`
- guest-level（process）：`EXP1_NGINX_CPUSET=0-3`, `EXP1_WRK_CPUSET=0-3`

### 3.4 采集指标

每个测量点都会记录：

1. 吞吐：`requests_per_sec`（wrk `Requests/sec`）
2. 延迟：`p99_ms`（以及 avg/stdev）
3. 错误：`non2xx_responses`、`socket_timeouts`
4. CPU 利用率：`vm1_cpu_util_pct`、`vm2_cpu_util_pct`（由 `/proc/stat` 前后差分计算）

## 4. 结果（聚合）

来源：`wrk-summary-agg.csv`

| connections | repeats | rps_mean | p99_ms_mean | vm1_cpu_util_pct_mean | vm2_cpu_util_pct_mean |
|---:|---:|---:|---:|---:|---:|
| 1 | 5 | 7248.41 | 0.1716 | 2.1861 | 1.5815 |
| 2 | 5 | 15310.30 | 0.1510 | 5.2485 | 2.6680 |
| 4 | 5 | 44088.13 | 0.1354 | 11.1604 | 6.5320 |
| 8 | 5 | 108315.55 | 0.1140 | 30.1949 | 13.6428 |
| 16 | 5 | 174080.49 | 0.1466 | 43.6294 | 22.9691 |
| 32 | 5 | 225772.84 | 0.2212 | 51.3532 | 30.3957 |
| 64 | 5 | 253811.05 | 0.3762 | 57.0401 | 30.8759 |
| 128 | 5 | 273508.74 | 0.7154 | 61.9408 | 32.6559 |
| 256 | 5 | 282195.60 | 1.1500 | 66.0566 | 34.2954 |

补充质量检查：

- `max_non2xx = 0`
- `max_socket_timeouts = 0`

## 5. 结果分析

### 5.1 吞吐趋势

1. `c=1 -> 64`：吞吐快速增长（7.2k -> 253.8k RPS）。
2. `c=64 -> 128`：增幅明显放缓（约 +7.8%）。
3. `c=128 -> 256`：进一步趋于平台（约 +3.2%）。

结论：吞吐曲线已呈现“接近平台”的典型形态，knee 大致在 `64~128` 区间。

### 5.2 延迟趋势

1. 低并发（1~8）p99 维持在 `0.11~0.17ms`。
2. 从 `32` 开始明显抬升（`0.22ms`）。
3. `64/128/256` 分别约 `0.38/0.72/1.15ms`，随负载上升加速增长。

结论：与吞吐平台区一致，延迟在高并发区上升明显，趋势合理。

### 5.3 CPU 利用率与瓶颈位置

1. vm1 CPU 利用率从 `2.19%` 升至 `66.06%`。
2. vm2 CPU 利用率从 `1.58%` 升至 `34.30%`。
3. 全区间 vm1 > vm2，且高并发下吞吐趋缓而 vm1 仍上升。

结论：当前证据更支持“服务侧/服务路径先成为主要限制因素”，不是 client 先顶满。

### 5.4 稳定性

- 大部分并发点重复性较好（中高并发 CV 较低）。
- 低并发点（尤其 `c=2, c=4`）抖动相对更大，但不影响整体趋势判读。

## 6. 图表与产物

- 总览图：`results/exp1/20260222T210742Z-direct-nginx/plots/wrk-overview.png`
- 原始汇总：`results/exp1/20260222T210742Z-direct-nginx/wrk-summary.csv`
- 聚合汇总：`results/exp1/20260222T210742Z-direct-nginx/wrk-summary-agg.csv`
- 本次配置：`results/exp1/20260222T210742Z-direct-nginx/metadata/run-config.env`

## 7. 当前问题与风险

1. 最高点仍有小幅增长（`128 -> 256` 仍 +3.2%），平台区已出现但尚未完全“压平”。
2. vm1 利用率未到 90%+，说明瓶颈可能不只是纯 CPU 算力，也可能包含网络栈/锁/调度等路径开销。
3. 低并发点方差略高，建议后续报告中以中高并发趋势为主解释。

## 8. Progress（项目进度）

### Exp1 Step 1（Direct baseline）

- [x] 目标路径跑通（vm2 wrk -> vm1 nginx）
- [x] 固定参数 sweep（connections + repeats）完成
- [x] RPS/p99 曲线完成并可视化
- [x] 每点 server/client CPU 利用率采集与绘图完成
- [x] 错误与超时检查（本次均为 0）
- [x] 形成可复现实验结果包

Step 1 状态：**已完成（可作为基线）**

### 下一步（按实验路线）

1. Exp1 Step 2：在同一测量协议下加入 Vanilla Katran 路径，做 direct vs vanilla 对照。
2. 复用当前同一套图和指标（RPS/p99/CPU util），重点对比 knee 区间差异。
