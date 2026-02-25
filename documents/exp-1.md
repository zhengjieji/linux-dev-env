# Experiment 1 - Baselines (Step 1 Direct + Step 2 Vanilla Katran)

> Last updated: 2026-02-24
> This document reflects the current implementation in `scripts/exp1/run.sh` and `Makefile`.

## 1) Goal and scope

Experiment 1 has two baseline paths, each measured under two workload protocols (`wrk` + `httperf`):

1. Step 1 (`direct-nginx`): client VM load tool -> vm1 nginx
2. Step 2 (`vanilla-katran`): client VM load tool -> vm1 Katran VIP -> vm1 nginx

The purpose of Step 2 is to measure the baseline overhead of adding Katran/XDP into the request path, before any oracle/automation optimization.

## 2) Topology

Default layout:

- vm1 data IP: `192.168.100.1`
- vm2 data IP: `192.168.100.2`
- nginx runs on vm1, serves HTTP on port `8080`
- wrk runs on vm2
- httperf runs on vm2 by default

Optional multi-client httperf layout (4 VMs total):

- vm1 server
- vm2/vm3/vm4 parallel httperf clients (`EXP1_HTTPERF_CLIENT_VMS="vm2 vm3 vm4"`)

Paths:

- Direct:

```text
client VM(s) (wrk/wrk2/httperf) -> 192.168.100.1:8080 (nginx on vm1)
```

- Vanilla Katran:

```text
client VM(s) (wrk/wrk2/httperf) -> 192.168.100.100:8080 (VIP on vm1/Katran) -> real 192.168.100.1:8080 (nginx)
```

## 3) Default workload setting (current)

From `Makefile` defaults:

- mode: `both` (run direct first, then vanilla-katran)
- workloads: `both` (`wrk` + `wrk2`)
- wrk:
  - connections sweep: `1 2 4 8 16 32 64 128 256`
  - threads: `4` (runtime uses `min(threads, connections)` per point)
  - warmup/measurement/repeats: `15s / 60s / 5`
- wrk2:
  - target-rate sweep: `50000 100000 150000 200000 250000 300000 350000 400000 450000 500000`
  - threads/connections: `4 / 256`
  - warmup/measurement/repeats: `15s / 60s / 5`
  - binary: `wrk2` (auto-build in client VM when missing and `EXP1_WRK2_AUTO_BUILD=1`)
- httperf:
  - offered-rate sweep: `5000 10000 20000 40000 80000 120000 160000 200000`
  - warmup/measurement/repeats: `15s / 60s / 5`
  - timeout: `5s`
  - clients: `vm2` (override via `EXP1_HTTPERF_CLIENT_VMS`)
  - workers per client VM: `1` (override via `EXP1_HTTPERF_WORKERS_PER_VM`)
  - optional client nofile set before each httperf run: `off` (override via `EXP1_HTTPERF_ULIMIT_NOFILE`)
- response object: static file `exp1-1k.txt` served by nginx
- nginx benchmark vhost uses `access_log off` (avoid disk-pressure side effects during long runs)

## 4) CPU pinning defaults

- host layer (QEMU):
  - `DUAL_VM1_HOST_CPUSET=auto`
  - `DUAL_VM2_HOST_CPUSET=auto`
  - `DUAL_VM3_HOST_CPUSET=auto`
  - `DUAL_VM4_HOST_CPUSET=auto`
  - `DUAL_VM1_VCPUS=4`, `DUAL_VM2_VCPUS=4`, `DUAL_VM3_VCPUS=4`, `DUAL_VM4_VCPUS=4`
  - `DUAL_VM1_MEMORY_MB=4096`, `DUAL_VM2_MEMORY_MB=4096`, `DUAL_VM3_MEMORY_MB=4096`, `DUAL_VM4_MEMORY_MB=4096`
- guest process layer:
  - `EXP1_NGINX_CPUSET=0-3`
  - `EXP1_WRK_CPUSET=0-3`
  - `EXP1_WRK2_CPUSET=0-3`
  - `EXP1_HTTPERF_CPUSET=0-3`
  - `EXP1_KATRAN_CPUSET=0-3`

You can disable any layer with `off`.

## 5) Step 2 Katran setting (implemented)

### 5.1 Artifact build

Step 2 uses three artifacts:

- `source/katran/_build/build/example_grpc/katran_server_grpc`
- `source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o`
- `source/katran/example_grpc/goclient/src/katranc/main/main`

Build command:

```sh
make exp1-katran-build
```

`make exp1-run` can auto-trigger this build if artifacts are missing (`EXP1_KATRAN_AUTO_BUILD=1`, default).
Exp1 build also compiles Katran BPF with `LOCAL_DELIVERY_OPTIMIZATION` so local VIP->local real (same vm1) works correctly.

### 5.2 Runtime Katran parameters

Default Step 2 parameters:

- VIP: `192.168.100.100`
- gRPC control port: `50051`
- forwarding cores: `0,1,2,3`
- LRU size: `1000000`
- default MAC: `52:54:00:aa:00:22` (vm2 data-plane MAC)

### 5.3 Runtime setup on vm1

Before starting Katran, Exp1 script does:

1. detect vm1 data interface by MAC `52:54:00:aa:00:11`
2. clean old Katran process and old XDP attach
3. ensure `ipip0` and `ipip60` exist and are up
4. add `127.0.0.42/32` to `ipip0`
5. add VIP `192.168.100.100/32` to `lo`
6. set `rp_filter=0`

Then start `katran_server_grpc` on vm1 and wait until gRPC is ready.

### 5.4 VIP/real programming

After Katran server is up, script programs it via gRPC client:

1. clear previous VIP/reals (`-C`)
2. add VIP `192.168.100.100:8080` (`-A -t`)
3. add real `192.168.100.1` to that VIP (`-a -t ... -r ...`)

For this topology (Katran and nginx on the same vm1), Exp1 sets:

- VIP flag: `LOCAL_VIP`
- real flag: `LOCAL_REAL`

In this baseline, there is only one real backend, so Step 2 focuses on path overhead comparison, not load distribution quality.

## 6) Sanity gates used before each run kind

For each run kind (`direct-nginx` or `vanilla-katran`), script checks:

1. sanity client VM can ping target IP (direct IP or VIP)
2. sanity client VM can `curl` workload URL, and returned bytes match vm1 source file size
3. sanity client VM can `curl` `/healthz` on the tested path (direct IP or VIP)

If any check fails, run stops.

## 7) What is measured and saved

Per measured `wrk` run, script stores:

- full wrk raw output
- parsed throughput `Requests/sec` (RPS)
- latency avg/stdev/p99 (ms)
- error fields (`non2xx`, `socket_timeouts`)
- vm1 CPU utilization + client CPU utilization aggregate (computed from `/proc/stat` deltas)
- summary files:
  - `wrk-summary.csv`
  - `wrk-summary-agg.csv`

Per measured `wrk2` run, script stores:

- full wrk2 raw output
- parsed target rate / achieved throughput / p99 latency
- error fields (`non2xx`, `socket_timeouts`)
- vm1 CPU utilization + client CPU utilization aggregate (computed from `/proc/stat` deltas)
- summary files:
  - `wrk2-summary.csv`
  - `wrk2-summary-agg.csv`

Per measured `httperf` run, script stores:

- full httperf raw output
- parsed offered rate / achieved request rate / response time
- error fields (`errors_total`, `non2xx`, `socket_timeouts`)
- vm1 CPU utilization + client CPU utilization aggregate (computed from `/proc/stat` deltas)
- summary files:
  - `httperf-summary.csv`
  - `httperf-summary-agg.csv`

Plots:

- per run kind: `plots/wrk-overview.png`
- per run kind: `plots/wrk2-overview.png`
- per run kind: `plots/httperf-overview.png`
- for mode `both`: `results/exp1/<run-id>-comparison/plots/wrk-direct-vs-katran.png`
- for mode `both`: `results/exp1/<run-id>-comparison/plots/wrk2-direct-vs-katran.png`
- for mode `both`: `results/exp1/<run-id>-comparison/plots/httperf-direct-vs-katran.png`
- comparison tables:
  - wrk: `results/exp1/<run-id>-comparison/comparison-summary.csv` and `wrk-comparison-summary.csv`
  - wrk2: `results/exp1/<run-id>-comparison/wrk2-comparison-summary.csv`
  - httperf: `results/exp1/<run-id>-comparison/httperf-comparison-summary.csv`

## 8) How to run

### 8.1 Full default (Step 1 + Step 2)

```sh
make exp1-run
```

### 8.2 One path only

```sh
scripts/exp1/run.sh --mode direct
scripts/exp1/run.sh --mode katran
```

### 8.3 One workload only

```sh
scripts/exp1/run.sh --mode both --workloads wrk
scripts/exp1/run.sh --mode both --workloads wrk2
scripts/exp1/run.sh --mode both --workloads httperf
```

### 8.4 Multi-client httperf (4 VMs total)

```sh
make exp1-run EXP1_WORKLOADS=httperf EXP1_HTTPERF_CLIENT_VMS="vm2 vm3 vm4"
```

### 8.5 Fast smoke (direct only, wrk only)

```sh
make exp1-smoke
```

### 8.6 Dual-VM style httperf with multiple workers on vm2

```sh
make exp1-run EXP1_WORKLOADS=httperf EXP1_HTTPERF_CLIENT_VMS="vm2" EXP1_HTTPERF_WORKERS_PER_VM=3
```

## 9) Expected trend to check

For end-to-end HTTP serving under both workload protocols (`wrk` / `httperf`), expected ordering is:

- Direct baseline should be fastest
- Vanilla Katran should be slower or similar at low load, and usually shows extra overhead near knee/saturation

If Katran appears faster than direct by a wide margin, verify sanity gates and confirm requests actually reach nginx.
