# Exp2：三节点四组对照（No-Relay）配置说明

本文只记录 **No-Relay** 口径下的 Exp2 四条曲线配置，目标是保证每条曲线的实验设置可追溯、可复现、可审计。

## 1. 结果来源（本次记录对应的实际运行）

- four-way 汇总目录：`results/exp2/eval-fourway-norelay/fourway-20260302T013849Z/`
- 四条曲线对应 run：
  - `direct`：`results/exp2/eval-fourway-norelay/direct/20260302T013849Z-direct-nginx/`
  - `direct+forward`：`results/exp2/eval-fourway-norelay/forward/20260302T020351Z-direct-forward/`
  - `vanilla katran`：`results/exp2/eval-fourway-norelay/vanilla/20260302T022852Z-vanilla-katran/`
  - `oracle katran`：`results/exp2/eval-fourway-norelay/oracle/20260302T025438Z-vanilla-katran/`

说明：`oracle` 这条曲线在 `run_kind` 字段里仍显示 `vanilla-katran`，这是脚本标签复用；应以其 `katran_server_bin_vm` / `katran_bpf_obj_vm` 路径判断是否为 Oracle 产物。

## 2. 全局共享设置（四条曲线一致）

### 2.1 拓扑与角色

- `vm1`：client（运行 `wrk`/`wrk2`）
- `vm2`：LB
- `vm3`：backend（Nginx）

### 2.2 VM 与 CPU

- 每个 VM：`4 vCPU`，`4096 MB`
- host pinning：`vm1=auto, vm2=auto, vm3=auto`
- guest cpuset：
  - `nginx_cpuset=0-3`
  - `wrk_cpuset=0-3`
  - `wrk2_cpuset=0-3`
  - `katran_cpuset=0-3`（katran 组）

### 2.3 业务与目标

- 后端服务：`vm3:8080`
- 文件：`exp1-1k.txt`
- `server_ip=192.168.100.3`
- `vip(forward/katran)=192.168.100.100`

### 2.4 压测参数

- `wrk`：
  - `connections=1 2 4 8 16 32 64 128 256`
  - `threads=4`
  - `warmup=15s`
  - `duration=60s`
  - `repeats=1`
- `wrk2`：
  - `rates=50000 100000 150000 200000 250000 300000 350000 400000 450000 500000`
  - `threads=4`
  - `connections=256`
  - `warmup=15s`
  - `duration=60s`
  - `repeats=1`

## 3. 四条曲线详细设置

## 3.1 曲线 A：Direct（无中间层）

### 3.1.1 路径

- 流量路径：`vm1 -> vm3:8080`
- `wrk_target_ip=192.168.100.3`

### 3.1.2 关键配置

- `mode=direct`
- `run_kind=direct-nginx`
- 不依赖 VIP，不走 vm2 中转

### 3.1.3 语义

- 作为无 LB 的纯基线，用来给四组对照提供上限参考。

## 3.2 曲线 B：Direct + Forward（内核转发）

### 3.2.1 路径

- 流量路径：`vm1 -> vm2(VIP) -> vm3:8080`
- `wrk_target_ip=192.168.100.100`

### 3.2.2 关键配置

- `mode=forward`
- `run_kind=direct-forward`
- `forward_vip=192.168.100.100`

### 3.2.3 内核与路由动作（脚本实际执行）

- 函数入口：`prepare_direct_forward_lb()`（`scripts/exp1/run.sh:833`）
- `vm2`（LB）动作（`scripts/exp1/run.sh:847-852`）：
  - 删除 `lo` 上可能残留的 VIP：`ip addr del VIP/32 dev lo`
  - 开启内核转发：`sysctl -w net.ipv4.ip_forward=1`
  - 关闭严格反向路径检查：`rp_filter=0`
  - 设置前向路由：`VIP/32 -> via vm3`
- `vm1`（client）动作（`scripts/exp1/run.sh:854-858`）：
  - 设置目标路由：`VIP/32 -> via vm2`
- `vm3`（backend）动作（`scripts/exp1/run.sh:860-866`）：
  - 在 `lo` 绑定 `VIP/32`，保证目的 VIP 的流量可以本地交付给 Nginx
  - 设置回程路由：`client_ip/32 -> via vm2`

数据包语义（无 NAT、无用户态 relay）：

1. `vm1 -> VIP`，经路由送到 `vm2`
2. `vm2` 仅按内核 FIB 转发到 `vm3`
3. `vm3` 因 `lo` 挂 VIP，把请求交给本地 Nginx
4. 响应源地址保持 VIP，经 `vm3 -> vm2 -> vm1` 返回

这是纯内核 L3 转发路径，不启用户态 `socat/relay` 进程。

## 3.3 曲线 C：Vanilla Katran（No-Relay）

### 3.3.1 路径

- 流量路径：`vm1 -> vm2(VIP, XDP/Katran) -> vm3:8080`
- `wrk_target_ip=192.168.100.100`

### 3.3.2 Katran关键开关

- `mode=katran`
- `run_kind=vanilla-katran`
- `katran_real_ip=192.168.100.3`
- `katran_enable_lb_relay=0`（禁用户态 relay）
- `katran_local_delivery_flags=0`（非 local-delivery）
- `katran_required_bpf_define=LOCAL_DELIVERY_OPTIMIZATION INLINE_DECAP_IPIP`
- `katran_default_mac=52:54:00:aa:00:33`（指向 backend MAC）

### 3.3.3 Katran产物

- `katran_server_bin_vm=/linux-dev-env/source/katran/_build/build/example_grpc/katran_server_grpc`
- `katran_bpf_obj_vm=/linux-dev-env/source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o`
- `katran_auto_build=1`

### 3.3.4 No-Relay辅助配置

- `vm2` 开启转发与 `rp_filter=0`，用于 remote-backend 路径
- `vm1` 添加 `VIP/32 -> vm2` 路由
- `vm3` 启用 decap 相关接口（`ipip0/ipip60`）、`lo` 绑定 VIP、回程路由经 `vm2`

### 3.3.5 Katran 转发实现细节（对应脚本）

- LB 侧 Katran 主入口：`prepare_katran_lb()`（`scripts/exp1/run.sh:2021`）
  - 绑定/清理 XDP：`scripts/exp1/run.sh:2144-2145`
  - 启动 `katran_server_grpc`：`scripts/exp1/run.sh:2174-2183`
  - 通过 goclient 写 VIP/REAL：
    - no-relay/no-local 模式（本实验）走 `-A` + `-a -r real_ip`（`scripts/exp1/run.sh:2203-2204`）

- no-relay 关键保护：
  - 当 `local_delivery=0` 且 `lb_relay=0` 时，LB 不在 `lo` 保留 VIP
  - 对应代码：`scripts/exp1/run.sh:2161-2164`
  - 目的：避免 backend 回包（源地址为 VIP）在 LB 被误判为“本地地址流量”

- remote-backend 路径准备：
  - `prepare_katran_forwarder_vm2()`（`scripts/exp1/run.sh:959`）：
    - `vm2` 开 `ip_forward`，并关闭 `rp_filter`（`scripts/exp1/run.sh:966-968`）
  - `prepare_katran_remote_backend_path()`（`scripts/exp1/run.sh:985`）：
    - `vm1`：`VIP/32 -> vm2`（`scripts/exp1/run.sh:994-999`）
    - `vm3`：准备 `ipip0/ipip60`、关闭 `rp_filter`、`lo` 挂 VIP、回程路由指回 `vm2`（`scripts/exp1/run.sh:1005-1020`）

- backend decap 侧准备：
  - `prepare_katran_backend_decap()`（`scripts/exp1/run.sh:1050`）
  - 在 `vm3` 数据网卡也启动 Katran server/XDP 以覆盖 decap 路径准备，见 `scripts/exp1/run.sh:1139-1146`

数据包语义（no-relay）：

1. `vm1` 将 `VIP` 流量发给 `vm2`
2. `vm2` 在网卡 ingress 的 XDP 阶段执行 Katran 程序，查 `vip_map/ch_rings/reals`
3. Katran 将请求导向 `vm3`（real）
4. `vm3` decap/入栈后交给 Nginx，响应再按回程路由返回 `vm1`

## 3.4 曲线 D：Oracle Katran（No-Relay）

### 3.4.1 路径

- 路径与曲线 C 完全一致：`vm1 -> vm2(VIP, XDP/Katran) -> vm3:8080`
- `wrk_target_ip=192.168.100.100`

### 3.4.2 与 Vanilla 的共同项

- `katran_real_ip=192.168.100.3`
- `katran_enable_lb_relay=0`
- `katran_local_delivery_flags=0`
- 同样启用 remote-backend 的转发/路由辅助动作

### 3.4.3 与 Vanilla 的差异（核心）

- Oracle 使用独立构建产物：
  - `katran_server_bin_vm=/linux-dev-env/source/katran/_build_exp2_oracle/build/example_grpc/katran_server_grpc`
  - `katran_bpf_obj_vm=/linux-dev-env/source/katran/_build_exp2_oracle/deps/bpfprog/bpf/balancer.bpf.o`
  - `katran_lib_dirs=/linux-dev-env/source/katran/_build_exp2_oracle/deps/lib:/linux-dev-env/source/katran/_build_exp2_oracle/deps/lib64`
- `katran_auto_build=0`（直接用已有 Oracle 构建）
- `katran_required_bpf_define=LOCAL_DELIVERY_OPTIMIZATION EXP2_ORACLE_CH_RINGS INLINE_DECAP_IPIP`

## 4. 四条曲线的“只差异项”速查表

| 曲线 | mode/run_kind | target ip | 是否经 vm2 | relay | local_delivery_flags | Katran 产物 |
|---|---|---|---|---|---|---|
| direct | `direct / direct-nginx` | `192.168.100.3` | 否 | N/A | N/A | N/A |
| direct+forward | `forward / direct-forward` | `192.168.100.100` | 是（内核转发） | 否 | N/A | N/A |
| vanilla katran | `katran / vanilla-katran` | `192.168.100.100` | 是（XDP+转发） | `0` | `0` | `_build` |
| oracle katran | `katran / vanilla-katran` | `192.168.100.100` | 是（XDP+转发） | `0` | `0` | `_build_exp2_oracle` |

## 5. 结果文件（本次 no-relay four-way）

- 汇总 CSV：
  - `results/exp2/eval-fourway-norelay/fourway-20260302T013849Z/wrk-fourway-summary.csv`
  - `results/exp2/eval-fourway-norelay/fourway-20260302T013849Z/wrk2-fourway-summary.csv`
- 对比图：
  - `results/exp2/eval-fourway-norelay/fourway-20260302T013849Z/plots/wrk-fourway.png`
  - `results/exp2/eval-fourway-norelay/fourway-20260302T013849Z/plots/wrk2-fourway.png`

## 6. 备注

- 本次 `repeat=1`，标准差列为 0，图上不会出现可见误差条。
- 若要误差条，请把 `wrk/wrk2 repeats` 调到 `>=3`（建议 `5`）。
