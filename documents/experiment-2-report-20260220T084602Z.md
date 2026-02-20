# Experiment 2 Result Report

## Scope
This report summarizes the latest available Exp2 artifacts:
- discovery id: `20260220T160223Z-discovery`
- throughput suite id: `20260220T160444Z-exp2-throughput`
- latency suite id: `20260220T111839Z-exp2-latency`
- analysis id: `20260220T170406Z-analysis`
- oracle build id: `20260220T160145Z-oracle-build`

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

Workload matrix used by the artifacts in this report:
- throughput/loss: offered rates `50,000` to `1,000,000` pps, step `50,000`, `30s`, repeats `1` (from `20260220T160444Z-exp2-throughput`)
- latency proxy: offered rates `50,000` to `1,000,000` pps, step `50,000`, `30s`, repeats `3` (from `20260220T111839Z-exp2-latency`)
- discovery: `600,000` pps, `120s`, snapshot interval `30s` (3 snapshots)

## Workload and Measurement Implementation Detail

### 1) Command chain used in Exp2
Throughput suite command path:
- `make exp2-run-throughput`
- `scripts/experiments/exp2/run-throughput.sh`
- `scripts/katran/run-suite.sh`
- per case: `scripts/katran/run-experiment.sh --mode <mode> --rate-pps <offered_rate> --duration <sec>`
- inside VM2: `/linux-dev-env/scripts/katran/vm2-run-workload.sh --rate-pps <offered_rate> --duration <sec> ...`

Example case command (from host via ssh):
```sh
/linux-dev-env/scripts/katran/vm2-run-workload.sh \
  --vip 192.168.100.100 --dport 80 \
  --rate-pps <offered_rate> --duration <duration_sec> \
  --dst-mac 52:54:00:aa:00:11 --output /tmp/katran-workload-<run_id>.txt
```

Latency suite command path:
- `make exp2-run-latency`
- `scripts/experiments/exp2/run-latency.sh`
- per case it runs workload and ping together on VM2 (same offered rate and duration)

Example latency command pattern (from host via ssh):
```sh
( /linux-dev-env/scripts/katran/vm2-run-workload.sh --vip 192.168.100.100 --dport 80 \
    --rate-pps <offered_rate> --duration <duration_sec> --output <workload_out> ) \
  & ping -D -n -i <ping_interval_sec> -w <duration_sec> 192.168.100.100 > <ping_out>; wait
```

### 2) What "offered rate" means and how pktgen is configured
`offered_rate` is the **target send rate** configured for VM2 pktgen (X-axis for throughput/loss analysis).

In `vm2-run-workload.sh`, the rate is translated to pktgen controls:
- `PACKETS = RATE_PPS * DURATION_SECS`
- `DELAY_NS = 1_000_000_000 / RATE_PPS`
- why `1_000_000_000` (`1e9`): pktgen `delay` is in nanoseconds, and `1 second = 10^9 ns`
- equivalent relation: `offered_rate (pps) = 10^9 / delay_ns = count / duration_sec`

Then written to `/proc/net/pktgen/<iface>`:
- `count ${PACKETS}`
- `delay ${DELAY_NS}`
- `pkt_size ${PKT_SIZE}`
- `dst ${VIP}`
- `dst_mac ${DST_MAC}`
- `udp_dst_min ${DPORT}` / `udp_dst_max ${DPORT}`
- start with `echo "start" >/proc/net/pktgen/pgctrl`

So "offered rate" is not inferred from results; it is explicitly programmed into pktgen for each case.

### 3) How measured throughput is extracted
Per run (`run-experiment.sh`):
- Reads VM2 pktgen output file.
- Parses direct `NNNpps` line into `measured_pps_nnnpps`.
- Parses `Result:` line (`packets`, `usec`) and computes:
  - `measured_pps_result = packets * 1_000_000 / usec`
- Writes compatibility field:
  - `measured_pps`: prefer `measured_pps_nnnpps`; fallback to `measured_pps_result`
- Writes source tracking fields:
  - `measured_pps_source` in `{nnnpps,result,missing}`
  - `measurement_note` (e.g., `nnnpps_only`, `fallback_result`, `missing_nnnpps_and_result`)

Missing-value rule:
- if both `NNNpps` and `Result` are missing, throughput is recorded as missing (not imputed).

### 4) Y-axis definitions used in analysis/plots
Throughput:
- X-axis: offered rate (pps)
- Y-axis: measured throughput median (pps)
- aggregation: median over repeats for each `(mode, offered_rate)`
- source separation (no mixing):
  - figure A: only `measured_pps_nnnpps`
  - figure B: only `measured_pps_result`

Loss:
- X-axis: offered rate (pps)
- Y-axis: median loss rate (%)
- per-sample formula:
  - `loss_rate = max(0, 1 - measured_pps_source_specific / offered_pps)`
- plotted value is median across repeats (then shown as percent), computed separately per source.
Latency (this report's numeric summary):
- X-axis: offered rate (pps)
- Y-axis: RTT metric in ms (`avg`, `p99`, `p999`) from VM2 ping samples under load
- aggregation: per rate, median over repeats, then high-load region average for comparison tables

Note:
- This report still uses the historical latency run `20260220T111839Z-exp2-latency` (`avg/p99/p999` columns).
- Current Exp2 pipeline code has been updated to peak-latency-over-time plotting (`X=time`, `Y=peak RTT ms`).

## What Is Measured
Primary metrics:
- throughput (two separated sources: `measured_pps_nnnpps` and `measured_pps_result`)
- loss (`loss_rate = max(0, 1 - measured_pps_source_specific / offered_pps)`, computed per source)

Secondary metrics:
- latency proxy under load (VM2 ping RTT to VIP): `avg_ms`, `p99_ms`, `p999_ms` (for this historical latency run)
- bytecode delta between Exp1 original and Exp2 oracle object (size/instruction/jump counts)

## Evaluation Criteria
Correctness criteria:
- all configured cases complete successfully
- mode setup matches labels
- oracle object must be different from original object

Performance criteria:
- oracle should show consistent gain over original in high-load region if hard-coded constants are effective
- gains should be stable across repeats

## Results
Functional status:
- throughput suite: `ok_cases=60`, `failed_cases=0` (repeats=1)
- latency suite: `ok_cases=180`, `failed_cases=0` (repeats=3)
- discovery: `14` maps marked invariant in the 3-snapshot window

Oracle build / bytecode status:
- `oracle_sha256`: `96021a72b4aae526ee8c0811fff15319da185b0d42f2f3e7f3a73d3e0a403fda`
- `orig_sha256`: `eb3e8c4bc9f2ceeeca3401713fa51a07a0c58d51cf85958dea4a8aa6000a2a26`
- `objects_identical=0` (true oracle-vs-orig comparison)
- bytecode delta:
  - total size: `-16,544 bytes` (`-82.89%`)
  - total instructions: `-2,048`
  - total jumps: `-238`

Throughput summary (high-load 600k to 1000k, average of per-rate medians):
- baseline: `519,110.889` pps
- katran-orig: `565,414.444` pps
- katran-oracle: `579,538.000` pps

High-load average uplift:
- orig vs baseline: `+46,303.556 pps` (`+8.92%`)
- oracle vs baseline: `+60,427.111 pps` (`+11.64%`)
- oracle vs orig: `+14,123.556 pps` (`+2.50%`)

High-load average loss rate (600k to 1000k):
- baseline: `0.334039`
- katran-orig: `0.273273`
- katran-oracle: `0.255882`

Knee point (first median loss > 1%):
- baseline: `550,000` pps
- katran-orig: `550,000` pps
- katran-oracle: `600,000` pps

Per-rate uplift range in high-load region (600k to 1000k):
- orig vs baseline: min `+4.09%`, max `+12.54%`
- oracle vs baseline: min `+10.26%`, max `+13.17%`
- oracle vs orig: min `-0.52%`, max `+6.66%`

Latency proxy summary (high-load 600k to 1000k, per-rate median then averaged):
- baseline: avg RTT `1.037 ms`, p99 `2.822 ms`, p999 `3.652 ms`
- katran-orig: avg RTT `1.679 ms`, p99 `3.247 ms`, p999 `4.354 ms`
- katran-oracle: avg RTT `1.746 ms`, p99 `3.303 ms`, p999 `3.914 ms`

Latency relative comparison (high-load averages):
- oracle vs orig:
  - avg RTT: `+4.00%`
  - p99 RTT: `+1.75%`
  - p999 RTT: `-10.10%`

## Interpretation
Does result match Exp2 expectation?
- For throughput/loss: yes.
- For latency: inconclusive for this campaign pairing.

What is confirmed:
- This is a valid true oracle comparison (`objects_identical=0`).
- Oracle build shows substantial structural reduction in bytecode size/instructions/jumps.
- In the latest throughput campaign, `katran-oracle-bpf` outperforms `katran-orig-bpf` and baseline in high-load throughput/loss.

What is not fully confirmed:
- Throughput and latency in this report come from different suite timestamps and repeat settings (`throughput repeats=1`, `latency repeats=3`), so cross-metric conclusions should be treated carefully.

What this result reflects:
- With current oracle hard-code, throughput/loss behavior is improved versus original under this run.
- A matched-latency rerun under the same campaign settings is still needed for strict end-to-end confirmation.

Notes on data quality:
- mixed run-set analysis (`throughput=20260220T160444Z`, `latency=20260220T111839Z`)
- throughput uses repeats=1 (no variance estimate)
- source-separated plots require source columns in `suite-index.csv`; legacy suites may be plotted in compatibility mode from `measured_pps`
- `latency-index.csv` still contains blank `packet_loss_pct` for some rows while case status is `ok`

## Key Artifacts
- Plan reference: `documents/experiment-2.md`
- Report file: `documents/experiment-2-report-20260220T084602Z.md`
- Discovery summary: `results/exp2/discovery/20260220T160223Z-discovery/summary.md`
- Discovery candidates: `results/exp2/discovery/20260220T160223Z-discovery/invariant-candidates.csv`
- Throughput suite summary: `results/exp2/measurement/throughput/20260220T160444Z-exp2-throughput/suite-summary.md`
- Throughput medians: `results/exp2/measurement/throughput/20260220T160444Z-exp2-throughput/suite-medians.csv`
- Latency index: `results/exp2/measurement/latency/20260220T111839Z-exp2-latency/latency-index.csv`
- Oracle build summary: `results/exp2/oracle-builds/20260220T160145Z-oracle-build/summary.md`
- Bytecode compare summary: `results/exp2/oracle-builds/20260220T160145Z-oracle-build/bytecode/summary.md`
- Final analysis summary: `results/exp2/analysis/20260220T170406Z-analysis/summary.md`
- Final analysis medians (compat): `results/exp2/analysis/20260220T170406Z-analysis/throughput-loss-medians.csv`
- Final analysis medians (NNNpps only): `results/exp2/analysis/20260220T170406Z-analysis/throughput-loss-medians-nnnpps.csv`
- Final analysis medians (Result only): `results/exp2/analysis/20260220T170406Z-analysis/throughput-loss-medians-result.csv`
- Final throughput source summary: `results/exp2/analysis/20260220T170406Z-analysis/throughput-source-summary.csv`
- Final plots (NNNpps): `results/exp2/analysis/20260220T170406Z-analysis/plots/throughput-median-vs-rate-nnnpps.png`
- Final plots (Result): `results/exp2/analysis/20260220T170406Z-analysis/plots/throughput-median-vs-rate-result.png`
- Final analysis latency index: `results/exp2/analysis/20260220T170406Z-analysis/latency-index.csv`
