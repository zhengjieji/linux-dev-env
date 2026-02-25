# Experiment 1 Scripts

This directory contains runnable automation for **Experiment 1**:

- `direct-nginx`: client VM load tool (`wrk`/`httperf`) -> vm1 `nginx`
- `vanilla-katran`: client VM load tool (`wrk`/`httperf`) -> vm1 Katran VIP -> vm1 `nginx`
- `both`: run direct first, then vanilla Katran with the same protocol set

Lifecycle behavior:
- starts dual VMs before measurement
- stops dual VMs after completion (unless `--keep-vms`)
- archives older runs of the same type (including `comparison`) and keeps only the latest under `results/exp1/`

## One-Time Prerequisites

Build/update runtime image:

```sh
make docker
```

Build Katran artifacts for Step 2 (server binary, balancer BPF object, gRPC client):

```sh
make exp1-katran-build
```

`make exp1-run` can auto-trigger this build when artifacts are missing (`EXP1_KATRAN_AUTO_BUILD=1`, default).
Exp1 builds Katran BPF with `LOCAL_DELIVERY_OPTIMIZATION` so local VIP->local real traffic (same vm1) works.

## Small Test (fast smoke)

Use this for quick end-to-end validation (direct path only):

```sh
make exp1-smoke
```

Equivalent script command:

```sh
scripts/exp1/run.sh \
  --mode direct \
  --workloads wrk \
  --wrk-threads 1 \
  --wrk-connections "1 2" \
  --wrk-warmup 2 \
  --wrk-duration 4 \
  --wrk-repeats 1
```

## Full Experiment Run

Default full run (`both`):

```sh
make exp1-run
```

Equivalent script command:

```sh
scripts/exp1/run.sh --mode both
```

`make exp1-run` defaults to `--workloads both` (run wrk + wrk2 as two separate parts; use `--workloads all` to include httperf).
You can run one path only:

```sh
scripts/exp1/run.sh --mode direct
scripts/exp1/run.sh --mode katran
```

You can run one workload only:

```sh
scripts/exp1/run.sh --mode both --workloads wrk
scripts/exp1/run.sh --mode both --workloads wrk2
scripts/exp1/run.sh --mode both --workloads httperf
```

For multi-client httperf (4 VMs total: vm1 server + vm2/vm3/vm4 clients):

```sh
make exp1-run EXP1_WORKLOADS=httperf EXP1_HTTPERF_CLIENT_VMS="vm2 vm3 vm4"
```

For dual-VM style httperf with one client VM and multiple workers on that VM:

```sh
make exp1-run EXP1_WORKLOADS=httperf EXP1_HTTPERF_CLIENT_VMS="vm2" EXP1_HTTPERF_WORKERS_PER_VM=3
```

## What Each Command Runs

`make exp1-katran-build`
- runs `scripts/exp1/build-katran.sh`
- builds Katran + example gRPC server + gRPC Go client in `source/katran/`
- rebuilds Katran BPF with `LOCAL_DELIVERY_OPTIMIZATION` for Exp1 local-delivery topology
- outputs used by Exp1 Step 2:
  - `source/katran/_build/build/example_grpc/katran_server_grpc`
  - `source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o`
  - `source/katran/example_grpc/goclient/src/katranc/main/main`

`make exp1-smoke`
- runs `scripts/exp1/run.sh` in `direct` mode
- workload is forced to `wrk` for speed
- tiny wrk sweep (`c=1,2`, short warmup/duration, one repeat)
- starts VMs, prepares nginx/wrxk, sanity checks, runs workload, writes summaries/plots, stops VMs

`make exp1-run`
- runs `scripts/exp1/run.sh` in default `both` mode
- executes two run kinds sequentially:
  1. `direct-nginx`
  2. `vanilla-katran`
- three workload parts are available; default `both` runs wrk + wrk2:
  - **wrk** (closed-loop):
    - `c=1 2 4 8 16 32 64 128 256`
    - `t=4` (per point uses `min(t, connections)`)
    - `warmup=15s`, `duration=60s`, `repeats=5`
  - **wrk2** (open-loop):
  - target rates: `50000 100000 150000 200000 250000 300000 350000 400000 450000 500000`
  - `threads=4`, `connections=256`
  - `warmup=15s`, `duration=60s`, `repeats=5`
  - binary: `wrk2` (auto-build from source in client VM when missing and `EXP1_WRK2_AUTO_BUILD=1`)
  - **httperf** (open-loop):
  - offered rates: `5000 10000 20000 40000 80000 120000 160000 200000`
  - `warmup=15s`, `duration=60s`, `repeats=5`, `timeout=5s`
  - default clients: `vm2` (override by `EXP1_HTTPERF_CLIENT_VMS`, allowed: `vm2 vm3 vm4`)
  - workers per client VM: `1` (override by `EXP1_HTTPERF_WORKERS_PER_VM`)
  - optional per-run nofile set for httperf client shell: `off` (override by `EXP1_HTTPERF_ULIMIT_NOFILE`)
- per run kind each workload writes independent summaries/plots
- comparison folder writes wrk/wrk2/httperf comparison plots separately
- katran LRU size: `1000000`

`make exp1-plot EXP1_RUN_DIR=results/exp1/<run-id>-<kind>`
- no VM/workload run
- regenerates plots for a single existing run folder

## CPU Pinning Defaults

Default pinning is enabled for Exp1:

- host/QEMU pinning: `DUAL_VM1_HOST_CPUSET=auto`, `DUAL_VM2_HOST_CPUSET=auto`, `DUAL_VM3_HOST_CPUSET=auto`, `DUAL_VM4_HOST_CPUSET=auto`
- host/VM shape defaults: `DUAL_VM1_VCPUS=4`, `DUAL_VM2_VCPUS=4`, `DUAL_VM3_VCPUS=4`, `DUAL_VM4_VCPUS=4`, `DUAL_VM1_MEMORY_MB=4096`, `DUAL_VM2_MEMORY_MB=4096`, `DUAL_VM3_MEMORY_MB=4096`, `DUAL_VM4_MEMORY_MB=4096`
- guest process pinning:
  - `EXP1_NGINX_CPUSET=0-3`
  - `EXP1_WRK_CPUSET=0-3`
  - `EXP1_HTTPERF_CPUSET=0-3`
  - `EXP1_KATRAN_CPUSET=0-3`

Disable any pinning layer by setting it to `off`.

## Direct Script Options (common)

```sh
scripts/exp1/run.sh \
  --mode both \
  --workloads all \
  --wrk-connections "1 2 4 8 16 32 64" \
  --wrk-threads 4 \
  --wrk-warmup 10 \
  --wrk-duration 60 \
  --wrk-repeats 3 \
  --wrk2-rates "50000 100000 150000 200000 250000 300000 350000 400000 450000 500000" \
  --wrk2-threads 4 \
  --wrk2-connections 256 \
  --wrk2-warmup 10 \
  --wrk2-duration 60 \
  --wrk2-repeats 3 \
  --wrk2-cpuset 0-3 \
  --httperf-rates "5000 10000 20000 40000 80000 120000" \
  --httperf-warmup 10 \
  --httperf-duration 60 \
  --httperf-repeats 3 \
  --httperf-timeout 5 \
  --httperf-client-vms "vm2 vm3 vm4" \
  --httperf-workers-per-vm 1 \
  --httperf-ulimit-nofile off \
  --nginx-cpuset 0-3 \
  --wrk-cpuset 0-3 \
  --httperf-cpuset 0-3 \
  --katran-cpuset 0-3
```

Katran-specific knobs are controlled by env vars (for example `EXP1_KATRAN_VIP`, `EXP1_KATRAN_FORWARDING_CORES`, `EXP1_KATRAN_LRU_SIZE`, `EXP1_KATRAN_AUTO_BUILD`).

SSH resilience knobs (for transient `kex_exchange_identification` / reset errors):

- `EXP1_SSH_RETRIES` (default `4`)
- `EXP1_SSH_RETRY_DELAY_SECS` (default `2`)
- `EXP1_SSH_RECOVER_WAIT_SECS` (default `20`)

## Outputs

For `--mode both`, typical artifacts are:

- `results/exp1/<timestamp>-direct-nginx/`
- `results/exp1/<timestamp>-vanilla-katran/`
- `results/exp1/<timestamp>-comparison/`

Key files per run kind:

- `metadata/run-config.env`
- `metadata/vm1-system.txt`, `metadata/vm2-system.txt` (and `vm3-system.txt` / `vm4-system.txt` when used)
- `wrk-summary.csv`, `wrk-summary-agg.csv`
- `wrk2-summary.csv`, `wrk2-summary-agg.csv`
- `httperf-summary.csv`, `httperf-summary-agg.csv`
- `plots/wrk-overview.png`
- `plots/wrk2-overview.png`
- `plots/httperf-overview.png`

Comparison folder includes:

- `plots/wrk-direct-vs-katran.png`
- `comparison-summary.csv` (legacy wrk summary name)
- `wrk-comparison-summary.csv`
- `plots/wrk2-direct-vs-katran.png`
- `wrk2-comparison-summary.csv`
- `plots/httperf-direct-vs-katran.png`
- `httperf-comparison-summary.csv`

Archived older runs:

- `results/exp1/archive/direct-nginx/`
- `results/exp1/archive/vanilla-katran/`
- `results/exp1/archive/comparison/`
