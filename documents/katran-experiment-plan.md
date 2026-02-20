# Katran Experiment Plan

## Objective
Create a reproducible benchmark workflow for BPF optimization studies.

Current implemented comparison modes:
1. `baseline-no-katran`
2. `katran-orig-bpf`

Future mode:
- `katran-opt-bpf` (not implemented yet)

## What Exactly Is Being Run

### Mode A: `baseline-no-katran`
- VM1 dataplane: Linux IPVS (`ip_vs`) only.
- No XDP program attached on VM1 data interface.
- VIP: `192.168.100.100:80`.
- Two backend namespaces in VM1:
  - `rs1` -> `10.200.1.2:8080`
  - `rs2` -> `10.200.2.2:8080`
- VM2 workload: `pktgen` UDP traffic to VIP.

### Mode B: `katran-orig-bpf`
- Same VIP, same backends, same workload profile.
- VM1 additionally attaches Katran BPF object on data interface using XDP generic mode.

Only mode changes; topology/workload stay constant to keep comparison fair.

## Topology
- Host orchestrates both VMs.
- VM1 (LB under test): `192.168.100.1/24`
- VM2 (traffic generator): `192.168.100.2/24`
- VIP: `192.168.100.100:80`

## Prerequisites
From repository root:

```sh
# build environment once
make docker
make vmlinux

# boot dual VMs
make dual-vm1
make dual-vm2

# clone katran source and build balancer.bpf.o on host
make katran-clone
# optional ref pin:
# scripts/katran/clone-katran.sh --ref <tag-or-commit>
# optional manual rebuild:
# make katran-build-host
```

## Step-by-Step Commands

### 1) Prepare VM1/VM2 runtime once per boot
```sh
make katran-vm1-setup
make katran-vm2-setup
```

### 2) Run baseline experiment
```sh
make katran-exp-one \
  KATRAN_MODE=baseline-no-katran \
  KATRAN_RATE_PPS=200000 \
  KATRAN_DURATION_SECS=30
```

### 3) Run Katran original experiment
```sh
make katran-exp-one \
  KATRAN_MODE=katran-orig-bpf \
  KATRAN_RATE_PPS=200000 \
  KATRAN_DURATION_SECS=30
```

### 4) Run full matrix (recommended)
```sh
make katran-exp-suite

# custom matrix example
scripts/katran/run-suite.sh \
  --modes "baseline-no-katran katran-orig-bpf" \
  --rates "$(seq 50000 50000 1000000)" \
  --duration 30 \
  --repeats 3
```
During suite runs, host prints one-line progress with ETA.
Plots are auto-generated under `results/experiments/<suite-id>/plots/` after each case and at suite end.
Plots show median throughput plus standard-deviation (stdev) error bars when repeats > 1.
If gnuplot is missing, install without sudo:

```sh
make katran-install-plot-tool
```

Regenerate plots manually:

```sh
make katran-plot-suite KATRAN_SUITE_DIR=results/experiments/<suite-id>
```

## What Outputs To Check
Result hierarchy:
- one-off run: `results/experiments/<run-id>/`
- suite root: `results/experiments/<suite-id>/`
- suite case runs: `results/experiments/<suite-id>/runs/<run-id>/`
- suite case logs: `results/experiments/<suite-id>/logs-cases/*.log`

Per-run files to inspect:
- `meta.env`
- `metrics/vm1.txt`
- `metrics/vm2.txt`
- `metrics/vm2-workload.txt`
- `summary.csv`
- `summary.md`

Suite files to inspect:
- `suite-index.csv`
- `suite-medians.csv`
- `suite-summary.md`
- plots: `plots/throughput-vs-rate.png`, `plots/throughput-vs-rate.svg`

## Expected Results

### Functional expectations
Both modes should:
- finish without script errors
- produce `summary.csv` and `summary.md`
- show valid backend/VIP setup on VM1

Mode-specific expectations:
- `baseline-no-katran`: no XDP attach on VM1 data iface
- `katran-orig-bpf`: XDP attach visible in `bpftool net show` / `ip -d link`

### Performance expectations
- Throughput (`measured_pps`) should be stable across repeated runs at same rate.
- Difference between modes should become clearer at higher offered load.
- Single run is not enough for claim; use repeated runs.

## Evaluation Criteria (for optimization project)

### 1. Correctness criteria
- No mode setup failures.
- No obvious traffic-path breakage.
- Backend path stays valid across all tests.

### 2. Measurement quality criteria
- Same topology for all modes.
- Same rates and durations for all modes.
- At least 3-5 repeats per `(mode, rate)`.
- Compare medians, not best-case single result.

### 3. Optimization claim criteria (future `katran-opt-bpf`)
Report at each rate:
- median pps per mode
- `% improvement opt vs orig`
- `% delta orig vs baseline`
- notes on packet drops, attach/counter anomalies

### 4. Regression criteria
Treat as regression if any of these occurs:
- setup/attach instability
- routing correctness issues
- improved pps but worse correctness/stability

## Suggested Result Table Template
For each offered rate:
- `baseline_median_pps`
- `katran_orig_median_pps`
- `katran_opt_median_pps` (future)
- `opt_vs_orig_%`
- `orig_vs_baseline_%`
- `notes`

This gives a defensible performance story for BPF optimization work.
