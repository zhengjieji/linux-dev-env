# Experiment 2：3-Node + 4 组对照（已实现）

> 状态：已实现并完成 short 全点验证。  
> 目的：把“拓扑成本”和“Katran 逻辑成本”拆开观测，并评估 Oracle 优化收益。

## 1. 实际拓扑与角色

- `vm1`：Client（`wrk` / `wrk2`）
- `vm2`：LB（`direct-forward` 或 Katran）
- `vm3`：Backend（Nginx）

默认由 `exp2-eval-four-set` 传给 `exp1/run.sh`：

- `EXP1_CLIENT_VM=vm1`
- `EXP1_LB_VM=vm2`
- `EXP1_BACKEND_VM=vm3`

## 2. 四组实验（实际实现）

### 2.1 `direct`

- 路径：`vm1 -> vm3:8080`
- 含义：无中间层基线。

### 2.2 `direct-forward`

- 路径：`vm1 -> vm2(VIP) -> vm3:8080`
- 含义：测“多一跳/中间层”固定成本。
- 实现细节：vm2 用 `socat` 监听 VIP 并转发到 backend。

说明：这里最终采用用户态 relay（`socat`），不是内核 L3 forwarding；优点是稳定、可控、快速复现实验路径。

### 2.3 `vanilla-katran`

- 路径：`vm1 -> vm2(VIP, vanilla Katran) -> vm3:8080`
- 实现关键：
  - `KATRAN_REAL_IP=vm2`（real 指向 LB 本机）
  - `KATRAN_LOCAL_DELIVERY_FLAGS=1`（`LOCAL_VIP|LOCAL_REAL`）
  - `KATRAN_ENABLE_LB_RELAY=1`，由 vm2 relay 到 vm3 backend

这样可以在 2 台物理机、3 VM 的限制下，强制经过 LB 路径并保持链路稳定。

### 2.4 `oracle-katran`

- 路径同 vanilla；
- 仅替换 Katran 产物为 Oracle 构建产物（`_build_exp2_oracle` 下 server/bin + bpf obj）；
- 其余拓扑、workload、cpuset 参数与 vanilla 保持一致。

## 3. 入口与默认参数

统一入口：

- `make exp2-eval-four-set`

关键默认值（来自 `Makefile`）：

- `wrk`：connections=`1 2 4 8 16 32 64 128 256`，`warmup=15s`，`duration=60s`，`repeats=5`
- `wrk2`：rates=`50k..500k`（步长 50k），`warmup=15s`，`duration=60s`，`repeats=5`
- 结果目录：`results/exp2/eval-fourway/`

## 4. 小规模验证（已完成）

已完成 short 全点验证（`repeat=1, warmup=2s, duration=8s`）：

- run id：`fourway-20260227T040610Z`
- 输出目录：`results/exp2/eval-fourway/fourway-20260227T040610Z/`

产物：

- `plots/wrk-fourway.png`
- `plots/wrk2-fourway.png`
- `wrk-fourway-summary.csv`
- `wrk2-fourway-summary.csv`

完整性检查：

- wrk：4 组 x 9 点 = 36 行数据（+ header）
- wrk2：4 组 x 10 点 = 40 行数据（+ header）
- 组标签齐全：`direct-nginx` / `direct-forward` / `vanilla-katran` / `oracle-katran`

## 5. 结果解读时注意事项

1. Oracle 组在 `exp1` 内部 run kind 仍显示为 `vanilla-katran`（历史命名复用），但其二进制/obj 来自 Oracle env；应以 `fourway` 汇总 CSV 里的 `oracle-katran` 标签和 run-config/env 为准。
2. 若 `repeats=1`，标准差会是 0，图上不会有可见 error bar；要看误差条需 `repeats>1`。
3. `exp2-eval-four-set` 会把旧同类结果归档到 `archive/`，默认只保留最新一组在主目录。
4. Full run 时间长（默认参数下是长作业），建议后台运行并看日志。

## 6. 与最初草案的差异

- 草案里 `direct-forward` 倾向内核转发；当前实现改为用户态 relay（`socat`）以降低不确定性。
- 没有新增独立的 `EXP1_MODE=fourway`；而是通过 `scripts/exp2/eval-four-set.sh` 顺序编排四组 `exp1` 子运行并统一汇总作图。

## 7. 建议的 full run 命令

```bash
make exp2-eval-four-set
```

如需显式固定 full 参数（与默认一致）：

```bash
EXP1_WRK_REPEATS=5 EXP1_WRK_WARMUP=15 EXP1_WRK_DURATION=60 \
EXP1_WRK2_REPEATS=5 EXP1_WRK2_WARMUP=15 EXP1_WRK2_DURATION=60 \
make exp2-eval-four-set
```

## 8. 最新 Full Run 结果（2026-03-01）

本节基于最新完整实验（`repeat=5`）：

- fourway run id：`20260301T055721Z`
- 汇总目录：`results/exp2/eval-fourway/fourway-20260301T055721Z/`
- 数据文件：
  - `wrk-fourway-summary.csv`
  - `wrk2-fourway-summary.csv`

### 8.1 各组峰值吞吐（rps_mean）

`wrk`（closed-loop）峰值：

- `direct-nginx`：`322,820`（`c=256`）
- `direct-forward`：`287,046`（`c=256`）
- `vanilla-katran`：`126,132`（`c=256`）
- `oracle-katran`：`126,506`（`c=256`）

`wrk2`（open-loop）峰值：

- `direct-nginx`：`324,276`（`rate=400k`）
- `direct-forward`：`289,598`（`rate=350k`）
- `vanilla-katran`：`126,134`（`rate=350k`）
- `oracle-katran`：`126,676`（`rate=400k`）

### 8.2 Oracle 相对 Vanilla 的提升

`wrk`：

- 全点平均提升：`-0.039%`
- 高负载区（`c>=64`）平均提升：`+0.279%`
- 饱和区典型点：
  - `c=128`：`+0.558%`
  - `c=256`：`+0.297%`

`wrk2`：

- 全点平均提升：`+0.283%`
- 高负载区（`rate>=200k`）平均提升：`+0.425%`
- 典型点：
  - `rate=300k`：`+0.593%`
  - `rate=400k`：`+0.585%`
  - `rate=500k`：`+0.080%`

结论（本次 full run）：

- Oracle 对 Vanilla 的收益存在，但量级偏小，主要在高负载区更稳定，约 `0.3%~0.6%`。
- 这与当前工作负载下“可被优化的 Katran 逻辑占整体端到端成本比例有限”一致。

### 8.3 关于误差条（error bar）

- 本次是 `repeat=5`，CSV 中 `rps_std` 非零，误差条已绘制。
- 视觉上不明显的原因是：吞吐 y 轴范围大（从 0 到数十万），而 `std` 相对 `mean` 多数只有 `0.5%~1.5%`，所以误差条看起来很短。
