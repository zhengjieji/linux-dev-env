# Katran Experiment Result Report

## Scope
This report summarizes the completed suite run:
- suite id: `20260219T233444Z-katran-suite`
- suite path: `results/experiments/20260219T233444Z-katran-suite/`

Compared modes:
1. `baseline-no-katran`
2. `katran-orig-bpf`

## Setting
Topology and runtime setting:
- dual-VM testbed
- VM1 (load balancer under test): `192.168.100.1/24`
- VM2 (traffic generator): `192.168.100.2/24`
- VIP: `192.168.100.100:80`
- backend namespaces on VM1:
  - `10.200.1.2:8080`
  - `10.200.2.2:8080`

Mode behavior:
- `baseline-no-katran`: IPVS only, no XDP attach on VM1 data interface
- `katran-orig-bpf`: same IPVS/backends/workload, plus Katran BPF object attached via XDP generic on VM1 data interface

Workload matrix:
- offered rates: `50,000` to `1,000,000` pps, step `50,000`
- duration per run: `30s`
- repeats per `(mode, rate)`: `3`
- total cases: `120`

## What Is Measured
Primary metric:
- `measured_pps` from VM2 pktgen result (actual achieved packets per second)

For each `(mode, rate)`:
- median throughput across 3 repeats
- standard deviation (`stdev_pps`) across 3 repeats

## Evaluation Criteria
Correctness criteria:
- all cases complete successfully
- mode setup consistent with label (`baseline` no XDP, `katran` with XDP)

Performance criteria:
- compare medians under identical topology/workload
- look for divergence under high offered load (saturation region)
- use stdev to assess stability of each mode

## Results
Functional result:
- `ok_cases: 120`, `failed_cases: 0`
- source: `results/experiments/20260219T233444Z-katran-suite/suite-summary.md`

Performance summary:
- up to `550k` offered pps: both modes are effectively identical
- from `600k` to `1,000k` offered pps: Katran is consistently higher

High-load (600k to 1000k) aggregate:
- baseline average median throughput: `558,812.67 pps`
- katran average median throughput: `582,286.00 pps`
- absolute gain: `+23,473.33 pps`
- relative gain: `+4.20%` (average)

Per-rate uplift in high-load region:
- min uplift: `+3.41%` (at `750k`)
- max uplift: `+5.67%` (at `900k`)

Stability observation:
- baseline variance spikes at some high rates (example: `900k`, stdev `15755.73`)
- katran variance is generally lower at those points (example: `900k`, stdev `6339.29`)

## Interpretation
Does result match expectation?
- Yes.

Why:
- Experiment settings are controlled (same topology/workload, only dataplane mode changes).
- At low load, both modes track offered rate.
- At high load, baseline saturates around ~`559k` pps, while Katran sustains around ~`582k` pps.
- This behavior is consistent with expectation that XDP-based datapath helps under CPU/packet-rate pressure.

What this result reflects:
- In this VM + xdpgeneric setup, Katran original BPF improves throughput in saturation region by about `4%`.
- The result is suitable as a baseline for a future `katran-opt-bpf` optimization comparison.

## Key Artifacts
- Suite summary: `results/experiments/20260219T233444Z-katran-suite/suite-summary.md`
- Suite medians: `results/experiments/20260219T233444Z-katran-suite/suite-medians.csv`
- Plots: `results/experiments/20260219T233444Z-katran-suite/plots/throughput-vs-rate.png`
- Plan reference: `documents/katran-experiment-plan.md`
