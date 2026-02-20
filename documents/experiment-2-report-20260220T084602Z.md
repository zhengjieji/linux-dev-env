# Experiment 2 Result Report

## Scope
This report summarizes the completed Exp2 run set:
- discovery id: `20260220T054754Z-discovery`
- throughput suite id: `20260220T055019Z-exp2-throughput`
- latency suite id: `20260220T075910Z-exp2-latency`
- analysis id: `20260220T084602Z-analysis`
- oracle build id: `20260220T054716Z-oracle-build`

Compared modes:
1. `baseline-no-katran`
2. `katran-orig-bpf`
3. `katran-oracle-bpf`

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
- `katran-orig-bpf`: same setup plus Katran BPF object attached via XDP generic
- `katran-oracle-bpf`: same runtime path as `katran-orig-bpf`, but loads Exp2 oracle object

Workload matrix:
- throughput/loss: offered rates `50,000` to `1,000,000` pps, step `50,000`, `30s`, repeats `3`
- latency proxy: rates `100,000 / 300,000 / 600,000 / 900,000`, `30s`, repeats `3`
- discovery: `600,000` pps, `120s`, snapshot interval `30s` (3 snapshots)

## What Is Measured
Primary metrics:
- throughput (`measured_pps` from VM2 pktgen)
- loss (`loss_rate = max(0, 1 - measured_pps / offered_pps)`)

Secondary metrics:
- latency proxy under load (VM2 ping RTT to VIP): median of `avg_ms`, `p99_ms`, `p999_ms`
- bytecode delta between Exp1 original and Exp2 oracle object (size/instruction/jump counts)

## Evaluation Criteria
Correctness criteria:
- all configured cases complete successfully
- mode setup matches labels

Performance criteria:
- oracle should show consistent gain over original in high-load region if hard-coded constants are effective
- gains should be stable across repeats

## Results
Functional status:
- throughput suite: `ok_cases=180`, `failed_cases=0`
- latency suite: `36/36` cases completed with status `ok`
- discovery: `14` maps marked invariant within the 3-snapshot window

Oracle build / bytecode status:
- `patch_file` is empty in this run
- oracle and original object SHA256 are identical
- bytecode delta is zero:
  - size delta: `0`
  - instruction delta: `0`
  - jump delta: `0`

Throughput summary (high-load 600k to 1000k, average median pps):
- baseline: `560,394.000`
- katran-orig: `577,457.778`
- katran-oracle: `575,021.556`

High-load average uplift:
- orig vs baseline: `+17,063.778 pps` (`+3.04%`)
- oracle vs baseline: `+14,627.556 pps` (`+2.61%`)
- oracle vs orig: `-2,436.222 pps` (`-0.42%`)

Per-rate uplift range in high-load region:
- orig vs baseline: min `-1.08%`, max `+4.41%`
- oracle vs baseline: min `-0.78%`, max `+6.83%`
- oracle vs orig: min `-2.40%`, max `+3.04%`

High-load average loss rate (600k to 1000k):
- baseline: `0.279620`
- katran-orig: `0.258559`
- katran-oracle: `0.261129`

Latency proxy summary (rates 600k and 900k, median-of-repeats then averaged across those rates):
- baseline: avg RTT `0.934 ms`, p99 `2.305 ms`
- katran-orig: avg RTT `1.866 ms`, p99 `3.155 ms`
- katran-oracle: avg RTT `1.802 ms`, p99 `3.160 ms`

## Interpretation
Does result match Exp2 expectation?
- Partially.

What is confirmed:
- Exp2 pipeline is runnable and produces stable throughput/loss/latency artifacts.
- Relative to baseline, Katran modes improve throughput in saturation region on this setup.

What is not yet confirmed:
- The core Exp2 oracle hypothesis (benefit from hard-coded constants) is not isolated by this run.
- In this run, `katran-oracle-bpf` object is byte-for-byte identical to `katran-orig-bpf`, so this is not a true optimized-oracle comparison.

What this result reflects:
- This run is valid as a clean three-mode benchmark dataset.
- It should be treated as a pre-optimization baseline for Exp2, not as evidence of oracle hard-code benefit.

## Key Artifacts
- Plan reference: `documents/experiment-2.md`
- Report file: `documents/experiment-2-report-20260220T084602Z.md`
- Discovery summary: `results/exp2/discovery/20260220T054754Z-discovery/summary.md`
- Discovery candidates: `results/exp2/discovery/20260220T054754Z-discovery/invariant-candidates.csv`
- Throughput suite summary: `results/exp2/measurement/throughput/20260220T055019Z-exp2-throughput/suite-summary.md`
- Throughput medians: `results/exp2/measurement/throughput/20260220T055019Z-exp2-throughput/suite-medians.csv`
- Oracle build summary: `results/exp2/oracle-builds/20260220T054716Z-oracle-build/summary.md`
- Bytecode compare summary: `results/exp2/oracle-builds/20260220T054716Z-oracle-build/bytecode/summary.md`
- Final analysis summary: `results/exp2/analysis/20260220T084602Z-analysis/summary.md`
- Final analysis medians: `results/exp2/analysis/20260220T084602Z-analysis/throughput-loss-medians.csv`
- Final analysis latency index: `results/exp2/analysis/20260220T084602Z-analysis/latency-index.csv`
- Final plots directory: `results/exp2/analysis/20260220T084602Z-analysis/plots/`
