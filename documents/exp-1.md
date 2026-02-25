# Experiment 1 基线实验说明（Step 1 Direct + Step 2 Vanilla Katran）

> Last updated: 2026-02-25
> 本文档与 `scripts/exp1/run.sh`、`Makefile` 当前实现保持一致。

## 1) 实验目标与范围

Experiment 1 包含两条基线路径：

1. Step 1（`direct-nginx`）：客户端 VM 直接访问 vm1 上的 nginx
2. Step 2（`vanilla-katran`）：客户端 VM 访问 vm1 上 Katran 的 VIP，再转发到 vm1 上 nginx

实验目标是量化“引入 Katran/XDP 转发路径”本身带来的吞吐与延迟开销，作为后续 Exp2/Exp3 的对照基线。

当前默认工作负载为两部分：

- `wrk`（闭环）
- `wrk2`（开环）

`httperf` 仍保留实现，但不再是默认全量实验内容。

## 2) 组件与工具说明（设置含义）

- `nginx`：
  - 被测 HTTP 服务端，运行在 vm1，监听 `8080`
  - 提供静态文件 `exp1-1k.txt`，并提供 `/healthz` 用于可用性检查
  - 在实验中代表“真实后端服务”
- `wrk`：
  - 高性能 HTTP 压测工具（闭环 closed-loop）
  - 用固定并发连接数 `-c` 和线程数 `-t` 反复请求，下一次请求依赖上一次响应完成
  - 适合观察不同并发下的饱和吞吐（RPS）和延迟（尤其 p99）
- `wrk2`：
  - 基于 wrk 的恒定速率压测工具（开环 open-loop）
  - 使用 `-R` 指定目标发包/请求速率，客户端持续按目标速率发请求，不随服务端响应速度自适应回退
  - 更适合定位系统瓶颈拐点（knee）以及过载区排队时延

## 3) 拓扑

默认拓扑：

- vm1 数据面 IP：`192.168.100.1`
- vm2 数据面 IP：`192.168.100.2`
- nginx 在 vm1
- wrk / wrk2 在 vm2

两条访问路径：

- Direct：

```text
vm2 (wrk/wrk2) -> 192.168.100.1:8080 (nginx on vm1)
```

- Vanilla Katran：

```text
vm2 (wrk/wrk2) -> 192.168.100.100:8080 (VIP on vm1/Katran) -> 192.168.100.1:8080 (nginx)
```

## 4) 当前默认实验参数

来自 `Makefile`/`run.sh` 默认值：

- mode：`both`（先 direct，再 vanilla-katran）
- workloads：`both`（即 `wrk + wrk2`）

`wrk`（closed-loop）：

- connections：`1 2 4 8 16 32 64 128 256`
- threads：`4`（运行时使用 `min(threads, connections)`）
- warmup / duration / repeats：`15s / 60s / 5`

`wrk2`（open-loop）：

- target rates：`50000 100000 150000 200000 250000 300000 350000 400000 450000 500000`
- threads / connections：`4 / 256`
- warmup / duration / repeats：`15s / 60s / 5`
- binary：`wrk2`（缺失时可自动构建，`EXP1_WRK2_AUTO_BUILD=1`）

服务对象：

- nginx 返回文件：`exp1-1k.txt`
- benchmark vhost 使用 `access_log off`，减少磁盘 IO 干扰

可选（非默认）：

- `httperf` 可通过 `--workloads httperf` 或 `--workloads all` 单独启用

## 5) CPU Pinning 默认值

host 层（QEMU）：

- `DUAL_VM1_HOST_CPUSET=auto`
- `DUAL_VM2_HOST_CPUSET=auto`
- `DUAL_VM3_HOST_CPUSET=auto`
- `DUAL_VM4_HOST_CPUSET=auto`
- VM 规格默认：每台 `vcpus=4`、`memory=4096MB`

guest 进程层：

- `EXP1_NGINX_CPUSET=0-3`
- `EXP1_WRK_CPUSET=0-3`
- `EXP1_WRK2_CPUSET=0-3`
- `EXP1_KATRAN_CPUSET=0-3`
- `EXP1_HTTPERF_CPUSET=0-3`（仅在启用 httperf 时生效）

将任一项设为 `off` 可关闭对应 pinning。

## 6) Step 2 Katran 设置

### 6.1 构建产物

Step 2 依赖以下文件：

- `source/katran/_build/build/example_grpc/katran_server_grpc`
- `source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o`
- `source/katran/example_grpc/goclient/src/katranc/main/main`

构建命令：

```sh
make exp1-katran-build
```

`make exp1-run` 在产物缺失时可自动触发构建（`EXP1_KATRAN_AUTO_BUILD=1`）。

### 6.2 运行时关键参数（默认）

- VIP：`192.168.100.100`
- gRPC 控制端口：`50051`
- forwarding cores：`0,1,2,3`
- LRU size：`1000000`
- default MAC：`52:54:00:aa:00:22`（vm2 数据面 MAC）

### 6.3 vm1 侧准备流程（脚本自动执行）

1. 按 MAC `52:54:00:aa:00:11` 识别 vm1 数据网卡
2. 清理旧 Katran 进程和旧 XDP 挂载
3. 确保 `ipip0`、`ipip60` 存在并启动
4. 在 `ipip0` 上配置 `127.0.0.42/32`
5. 在 `lo` 上配置 VIP `192.168.100.100/32`
6. 设置 `rp_filter=0`

之后启动 `katran_server_grpc` 并等待 gRPC ready，再通过 goclient 编程 VIP/real。

## 7) 每次 run 的健壮性检查

对每个 run kind（`direct-nginx` / `vanilla-katran`）都会执行：

1. 客户端 VM 能 ping 通目标 IP（direct IP 或 VIP）
2. 客户端 VM 能 curl 目标 URL，且返回字节数与 vm1 源文件一致
3. 客户端 VM 能 curl `/healthz`

任一检查失败，实验停止。

## 8) 采集指标与输出文件

`wrk` 每次测量会保存：

- 原始输出（raw）
- `Requests/sec`（RPS）
- 延迟（avg/stdev/p99）
- 错误字段（`non2xx`, `socket_timeouts`）
- vm1/vm2 CPU 利用率
- 汇总：`wrk-summary.csv`、`wrk-summary-agg.csv`

`wrk2` 每次测量会保存：

- 原始输出（raw）
- 目标速率、实际吞吐、延迟（含 p99）
- 错误字段（`non2xx`, `socket_timeouts`）
- vm1/vm2 CPU 利用率
- 汇总：`wrk2-summary.csv`、`wrk2-summary-agg.csv`

图表：

- 单路径：`plots/wrk-overview.png`、`plots/wrk2-overview.png`
- `mode=both` 对比图：
  - `results/exp1/<run-id>-comparison/plots/wrk-direct-vs-katran.png`
  - `results/exp1/<run-id>-comparison/plots/wrk2-direct-vs-katran.png`

对比表：

- `results/exp1/<run-id>-comparison/wrk-comparison-summary.csv`
- `results/exp1/<run-id>-comparison/wrk2-comparison-summary.csv`

说明：若显式启用 `httperf`，会额外生成对应 summary 和 plot。

## 9) 运行方式

### 9.1 默认全量（wrk + wrk2）

```sh
make exp1-run
```

等价：

```sh
scripts/exp1/run.sh --mode both --workloads both
```

### 9.2 只跑一条路径

```sh
scripts/exp1/run.sh --mode direct
scripts/exp1/run.sh --mode katran
```

### 9.3 只跑一种工作负载

```sh
scripts/exp1/run.sh --mode both --workloads wrk
scripts/exp1/run.sh --mode both --workloads wrk2
```

### 9.4 可选：启用 httperf（非默认）

```sh
scripts/exp1/run.sh --mode both --workloads httperf
scripts/exp1/run.sh --mode both --workloads all
```

### 9.5 快速冒烟（direct + wrk）

```sh
make exp1-smoke
```

## 10) 结果判读建议

- `wrk` 重点看并发扫描下的吞吐上限与 p99 变化
- `wrk2` 重点看目标速率达到比例（achieved/target）与瓶颈点后的排队时延
- 同参数下，`vanilla-katran` 相对 `direct-nginx` 的差异即为当前基线开销
