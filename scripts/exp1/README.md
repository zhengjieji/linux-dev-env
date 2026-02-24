# Experiment 1 Scripts

This directory contains runnable automation for **Experiment 1**:

- `direct-nginx`: vm2 `wrk` -> vm1 `nginx`
- `vanilla-katran`: vm2 `wrk` -> vm1 Katran VIP -> vm1 `nginx`
- `both`: run direct first, then vanilla Katran with the same wrk protocol

Lifecycle behavior:
- starts dual VMs before measurement
- stops dual VMs after completion (unless `--keep-vms`)
- archives older runs of the same type and keeps only the latest under `results/exp1/`

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

You can run one path only:

```sh
scripts/exp1/run.sh --mode direct
scripts/exp1/run.sh --mode katran
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
- tiny wrk sweep (`c=1,2`, short warmup/duration, one repeat)
- starts VMs, prepares nginx/wrk, sanity checks, runs workload, writes summaries/plots, stops VMs

`make exp1-run`
- runs `scripts/exp1/run.sh` in default `both` mode
- executes two run kinds sequentially:
  1. `direct-nginx`
  2. `vanilla-katran`
- each run kind uses wrk sweep defaults:
  - `c=1 2 4 8 16 32 64 128 256`
  - `t=4` (per point uses `min(t, connections)`)
  - `warmup=15s`, `duration=60s`, `repeats=5`
  - katran LRU size: `1000000`
- generates per-run plots and one cross-path comparison plot

`make exp1-plot EXP1_RUN_DIR=results/exp1/<run-id>-<kind>`
- no VM/workload run
- regenerates plots for a single existing run folder

## CPU Pinning Defaults

Default pinning is enabled for Exp1:

- host/QEMU pinning: `DUAL_VM1_HOST_CPUSET=auto`, `DUAL_VM2_HOST_CPUSET=auto`
- host/VM shape defaults: `DUAL_VM1_VCPUS=4`, `DUAL_VM2_VCPUS=4`, `DUAL_VM1_MEMORY_MB=4096`, `DUAL_VM2_MEMORY_MB=4096`
- guest process pinning:
  - `EXP1_NGINX_CPUSET=0-3`
  - `EXP1_WRK_CPUSET=0-3`
  - `EXP1_KATRAN_CPUSET=0-3`

Disable any pinning layer by setting it to `off`.

## Direct Script Options (common)

```sh
scripts/exp1/run.sh \
  --mode both \
  --wrk-connections "1 2 4 8 16 32 64" \
  --wrk-threads 4 \
  --wrk-warmup 10 \
  --wrk-duration 60 \
  --wrk-repeats 3 \
  --nginx-cpuset 0-3 \
  --wrk-cpuset 0-3 \
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
- `metadata/vm1-system.txt`, `metadata/vm2-system.txt`
- `wrk-summary.csv`, `wrk-summary-agg.csv`
- `plots/wrk-overview.png`

Comparison folder includes:

- `plots/wrk-direct-vs-katran.png`
- `comparison-summary.csv`

Archived older runs:

- `results/exp1/archive/direct-nginx/`
- `results/exp1/archive/vanilla-katran/`
