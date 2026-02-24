# Experiment 1 - Baselines (Step 1 Direct + Step 2 Vanilla Katran)

> Last updated: 2026-02-23
> This document reflects the current implementation in `scripts/exp1/run.sh` and `Makefile`.

## 1) Goal and scope

Experiment 1 has two baseline paths under the same wrk protocol:

1. Step 1 (`direct-nginx`): vm2 wrk -> vm1 nginx
2. Step 2 (`vanilla-katran`): vm2 wrk -> vm1 Katran VIP -> vm1 nginx

The purpose of Step 2 is to measure the baseline overhead of adding Katran/XDP into the request path, before any oracle/automation optimization.

## 2) Topology

Current dual-VM layout:

- vm1 data IP: `192.168.100.1`
- vm2 data IP: `192.168.100.2`
- nginx runs on vm1, serves HTTP on port `8080`
- wrk runs on vm2

Paths:

- Direct:

```text
vm2 (wrk) -> 192.168.100.1:8080 (nginx on vm1)
```

- Vanilla Katran:

```text
vm2 (wrk) -> 192.168.100.100:8080 (VIP on vm1/Katran) -> real 192.168.100.1:8080 (nginx)
```

## 3) Default workload setting (current)

From `Makefile` defaults:

- mode: `both` (run direct first, then vanilla-katran)
- tool: `wrk` only
- connections sweep: `1 2 4 8 16 32 64 128 256`
- threads: `4` (runtime uses `min(threads, connections)` per point)
- warmup: `15s`
- measurement: `60s`
- repeats: `5`
- response object: static file `exp1-1k.txt` served by nginx
- nginx benchmark vhost uses `access_log off` (avoid disk-pressure side effects during long runs)

## 4) CPU pinning defaults

- host layer (QEMU):
  - `DUAL_VM1_HOST_CPUSET=auto`
  - `DUAL_VM2_HOST_CPUSET=auto`
  - `DUAL_VM1_VCPUS=4`, `DUAL_VM2_VCPUS=4`
  - `DUAL_VM1_MEMORY_MB=4096`, `DUAL_VM2_MEMORY_MB=4096`
- guest process layer:
  - `EXP1_NGINX_CPUSET=0-3`
  - `EXP1_WRK_CPUSET=0-3`
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

1. vm2 can ping target IP (direct IP or VIP)
2. vm2 can `curl` workload URL, and returned bytes match vm1 source file size
3. vm2 can `curl` `/healthz` on the tested path (direct IP or VIP)

If any check fails, run stops.

## 7) What is measured and saved

Per measured wrk run, script stores:

- full wrk raw output
- parsed throughput `Requests/sec` (RPS)
- latency avg/stdev/p99 (ms)
- error fields (`non2xx`, `socket_timeouts`)
- vm1/vm2 CPU utilization (computed from `/proc/stat` deltas)

Summary files per run kind:

- `wrk-summary.csv`
- `wrk-summary-agg.csv`

Plots:

- per run kind: `plots/wrk-overview.png`
- for mode `both`: `results/exp1/<run-id>-comparison/plots/wrk-direct-vs-katran.png`
- comparison table: `results/exp1/<run-id>-comparison/comparison-summary.csv`

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

### 8.3 Fast smoke (direct only)

```sh
make exp1-smoke
```

## 9) Expected trend to check

For end-to-end HTTP serving with same workload protocol, expected ordering is:

- Direct baseline should be fastest
- Vanilla Katran should be slower or similar at low load, and usually shows extra overhead near knee/saturation

If Katran appears faster than direct by a wide margin, verify sanity gates and confirm requests actually reach nginx.
