# Experiment 1 Results Report (Direct Nginx vs Vanilla Katran, wrk + wrk2)

## 1. 报告范围

- 实验阶段：Experiment 1 baseline（Step 1 + Step 2）
- 运行 ID：`20260225T014131Z`
- 运行日期（UTC）：2026-02-25
- 路径对比：
  1. `direct-nginx`: `vm2 -> vm1 nginx (192.168.100.1:8080)`
  2. `vanilla-katran`: `vm2 -> VIP 192.168.100.100:8080 -> vm1 nginx`
- 工作负载：`wrk` + `wrk2`（不含 httperf）

## 2. 本次配置

- `wrk`（closed-loop）：
  - connections: `1 2 4 8 16 32 64 128 256`
  - threads: `4`
  - warmup / duration / repeats: `15s / 60s / 5`
- `wrk2`（open-loop）：
  - target rates: `50000 100000 150000 200000 250000 300000 350000 400000 450000 500000`
  - threads / connections: `4 / 256`
  - warmup / duration / repeats: `15s / 60s / 5`
- pinning：
  - host: vm1/vm2 `auto`
  - guest: `nginx=0-3`, `wrk=0-3`, `wrk2=0-3`, `katran=0-3`

## 3. 数据质量检查

- `wrk`：direct/katran 各 `45` 个样本点（`9 * 5`），`max_non2xx=0`, `max_socket_timeouts=0`
- `wrk2`：direct/katran 各 `50` 个样本点（`10 * 5`），`max_non2xx=0`, `max_socket_timeouts=0`

本次结果可用于对比分析。

## 4. Part A - wrk 结果（closed-loop）

| connections | direct RPS | katran RPS | katran vs direct | direct p99 (ms) | katran p99 (ms) | katran vs direct |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 7880 | 7431 | -5.70% | 0.1558 | 0.1604 | +2.95% |
| 2 | 16314 | 16557 | +1.49% | 0.1502 | 0.1506 | +0.27% |
| 4 | 45288 | 43038 | -4.97% | 0.1282 | 0.1308 | +2.03% |
| 8 | 107400 | 103946 | -3.22% | 0.1134 | 0.1166 | +2.82% |
| 16 | 170079 | 167460 | -1.54% | 0.1480 | 0.1532 | +3.51% |
| 32 | 224100 | 221166 | -1.31% | 0.2202 | 0.2252 | +2.27% |
| 64 | 251348 | 245984 | -2.13% | 0.3770 | 0.3990 | +5.84% |
| 128 | 272147 | 265373 | -2.49% | 0.7194 | 0.7416 | +3.09% |
| 256 | 279078 | 272833 | -2.24% | 1.1500 | 1.2000 | +4.35% |

wrk 总体结论（9 点平均）：

- RPS：`-2.456%`（katran 相对 direct）
- p99：`+3.014%`（katran 相对 direct）

解读：`wrk` 下 Katran 有稳定小幅开销，量级约“吞吐 -2.5%，p99 +3%”。

## 5. Part B - wrk2 结果（open-loop）

| target rate | direct RPS | katran RPS | direct/target | katran/target | direct p99 (ms) | katran p99 (ms) |
|---:|---:|---:|---:|---:|---:|---:|
| 50000 | 49267 | 49515 | 98.5% | 99.0% | 3.5 | 3.3 |
| 100000 | 99382 | 99171 | 99.4% | 99.2% | 3.0 | 3.1 |
| 150000 | 149285 | 148967 | 99.5% | 99.3% | 2.8 | 2.8 |
| 200000 | 198764 | 198765 | 99.4% | 99.4% | 2.9 | 2.9 |
| 250000 | 248628 | 248454 | 99.5% | 99.4% | 3.0 | 9.1 |
| 300000 | 277876 | 271796 | 92.6% | 90.6% | 4364.0 | 5568.0 |
| 350000 | 278282 | 272043 | 79.5% | 77.7% | 11986.0 | 13036.0 |
| 400000 | 278268 | 272948 | 69.6% | 68.2% | 17934.0 | 18774.0 |
| 450000 | 279156 | 273508 | 62.0% | 60.8% | 22434.0 | 22966.0 |
| 500000 | 277915 | 273368 | 55.6% | 54.7% | 26170.0 | 26636.0 |

wrk2 总体结论：

- 全部 10 点平均：RPS `-0.999%`, p99 `+24.787%`
- 仅过载区（`>=300k`）平均：RPS `-2.000%`, p99 `+9.037%`

解读：

1. `<=250k` 基本能跟上目标速率（~99%），延迟在毫秒级。
2. `300k` 开始进入瓶颈区，吞吐平台约 `278k`（direct）和 `272-273k`（katran），p99 上升到秒级。
3. 在瓶颈区，katran 相对 direct 仍有约 `2%` 吞吐差距和约 `9%` 的 p99 差距。

## 6. 综合结论

1. `wrk` 与 `wrk2` 的方向一致：vanilla-katran 相对 direct-nginx 存在稳定开销。
2. 这个开销在非过载区不大，但在接近/超过瓶颈后，p99 差距会被放大。
3. 本次 run 已可作为 Exp2/Exp3 的基线数据。

## 7. 产物路径

- direct：`results/exp1/20260225T014131Z-direct-nginx`
- katran：`results/exp1/20260225T014131Z-vanilla-katran`
- comparison：`results/exp1/20260225T014131Z-comparison`
- wrk 对比图：`results/exp1/20260225T014131Z-comparison/plots/wrk-direct-vs-katran.png`
- wrk2 对比图：`results/exp1/20260225T014131Z-comparison/plots/wrk2-direct-vs-katran.png`
