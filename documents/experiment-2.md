# Experiment Plan 2 — Oracle Hard-code Upper Bound

> Purpose: quantify the best-case upside of replacing runtime-invariant Katran config-map lookups with compile-time constants, under the same environment as Experiment 1.
> Rule: discovery can be intrusive; measurement runs must be uninstrumented.

## 1) Scope and Research Question

RQ: If stable config-map values are hard-coded into the BPF program, how much improvement can we get in end-to-end dataplane performance, and how much is from global simplification (not only lookup removal)?

## 2) Consistency With Experiment 1 (Must Keep Fixed)

Use exactly the same baseline environment as Experiment 1:

- topology:
  - VM1 (LB): `192.168.100.1/24`
  - VM2 (generator): `192.168.100.2/24`
  - VIP: `192.168.100.100:80`
  - backends on VM1: `10.200.1.2:8080`, `10.200.2.2:8080`
- datapath mode semantics:
  - `baseline-no-katran`: IPVS only, no XDP attached
  - `katran-orig-bpf`: same setup + Katran BPF attached with `xdpgeneric`
  - `katran-oracle-bpf`: same as `katran-orig-bpf`, but hard-coded oracle object
- workload generator: VM2 `pktgen` UDP, packet size `64B`
- offered-rate matrix: `50,000` to `1,000,000` pps, step `50,000`
- duration per run: `30s`
- repeats per `(mode, rate)`: `3`

If any of the above changes, results are no longer directly comparable to Experiment 1.

## 3) Conditions

Compare three conditions:

1. Native baseline: `baseline-no-katran`
2. Vanilla Katran: `katran-orig-bpf`
3. Oracle Katran: `katran-oracle-bpf`

## 4) Metrics and How They Are Measured

### 4.1 Throughput (primary)

- definition: successfully achieved packet rate (`pps`)
- measurement source (recorded separately, no mixing):
  - `measured_pps_nnnpps`: parsed from pktgen `NNNpps` line
  - `measured_pps_result`: computed from `Result:` line as `packets * 1_000_000 / usec`
  - `measured_pps` is compatibility field (prefer `measured_pps_nnnpps`, fallback to `measured_pps_result`)
  - `measured_pps_source` and `measurement_note` record which source was used and whether values are missing
- implementation reference: current harness `summary.csv` / `suite-index.csv`

### 4.2 Loss (primary)

- definition: traffic not delivered/processed under offered load
- per-point formula:
  - `loss_rate = max(0, 1 - measured_pps_source_specific / offered_pps)`
  - `loss_pps  = max(0, offered_pps - measured_pps_source_specific)`
- measurement source: derived from offered rate + selected throughput source of the same run (`measured_pps_nnnpps` or `measured_pps_result`, never mixed in one curve)

### 4.3 Latency (required but separate track)

- definition: 峰值延迟 (peak RTT, ms) under load
- required measurement method: external request/response path (not BPF-internal map writes)
- plot definition: X-axis is time (elapsed seconds), Y-axis is latency (peak RTT, ms)
- note on current harness: current `pktgen` flow is one-way throughput-oriented, so latency is measured via ICMP RTT proxy under load.
- plan: keep Exp2 main comparison on throughput/loss first; latency sub-run records RTT time-series and reports per-case peak RTT under the same topology and modes.

## 5) Run Structure

### Run A — Discovery (intrusive, not for performance claims)

Goal: identify map entries that remain invariant in steady state.

- warm up traffic
- snapshot candidate maps at multiple timestamps (e.g., every 30-60s)
- hash each snapshot to detect changes
- output:
  - invariant candidate list `(map, key, value)`
  - evidence of stability across the window

### Run B — Vanilla Measurement (clean)

- disable discovery instrumentation
- run the fixed Exp1 matrix using `katran-orig-bpf` (+ optionally `baseline-no-katran` for same run batch)
- collect throughput/loss and run-level stability

### Run C — Oracle Measurement (clean)

- apply hard-code patch and build oracle BPF object
- run the exact same matrix as Run B
- collect the same metrics and compare directly

## 6) Hard-code Strategy

- hard-code only values proven stable in Run A window
- preserve semantics for the tested workload profile
- prefer constants that affect control flow to expose compiler/JIT propagation and DCE
- optional ablation:
  - oracle-lookup-only (block propagation)
  - oracle-full (allow full propagation)

### 6.1 Current Oracle Patch (All 14 Invariant Candidates)

This repository now uses a full hard-code patch for all 14 invariant candidates found in:
- `results/exp2/discovery/20260220T090617Z-discovery/invariant-candidates.csv`

Default patch file:
- `scripts/experiments/exp2/patches/oracle-default.patch`

Patch implementation location (applied in isolated Exp2 source):
- `source/katran-exp2/katran/lib/bpf/balancer.bpf.c`

Hard-code mapping (which map, how):
- `stats`: all `bpf_map_lookup_elem(&stats, ...)` replaced by `exp2_lookup_stats(...)` returning one fixed `struct lb_stats` storage object.
- `ctl_array`: replaced with `exp2_lookup_ctl_array()` returning one fixed `struct ctl_value` object.
- `vip_map`: replaced by `exp2_lookup_vip_map(...)` returning `NULL` (models empty hash map snapshot).
- `lru_mapping`: replaced by `exp2_lookup_lru_mapping(...)` returning `NULL` (forces fallback path).
- `fallback_cache`: hardcoded as always-miss in `connection_table_lookup()` and `check_and_update_real_index_in_lru()`; updates are skipped when `lru_map == &fallback_cache`.
- `ch_rings`: replaced by `exp2_lookup_ch_rings(...)` returning a fixed `__u32` value (`0`).
- `reals`: replaced by `exp2_lookup_reals(...)` returning one fixed `struct real_definition`.
- `reals_stats`: replaced by `exp2_lookup_reals_stats(...)` returning fixed `struct lb_stats` storage.
- `lru_miss_stats`: replaced by `exp2_lookup_lru_miss_stats(...)` returning fixed `__u32` storage.
- `vip_miss_stats`: replaced by `exp2_lookup_vip_miss_stats(...)` returning fixed `struct vip_definition` storage.
- `quic_stats_map`: replaced by `exp2_lookup_quic_stats_map(...)` returning fixed `struct lb_quic_packets_stats` storage.
- `server_id_map`: replaced by `exp2_lookup_server_id_map(...)` returning fixed `__u32` storage.
- `server_id_stats`: replaced by `exp2_lookup_server_id_stats(...)` returning fixed `struct lb_stats` storage.
- `vip_to_down_reals_map`: replaced by `exp2_lookup_vip_to_down_reals_map(...)` returning `NULL` (no down-real override map).

Verification commands:
```sh
make exp2-build-oracle
# then inspect
cat results/exp2/oracle-builds/<run-id>/manifest.env
cat results/exp2/oracle-builds/<run-id>/bytecode/summary.md
```

## 7) Correctness Checks

Before accepting performance numbers:

- mode setup matches label (`baseline`, `orig`, `oracle`)
- connectivity and forwarding path remain functional
- oracle constants match Run A snapshot values
- no unexpected attach/load failures

## 8) Outputs

Per run:

- `meta.env`
- `metrics/vm1.txt`
- `metrics/vm2.txt`
- `metrics/vm2-workload.txt`
- `summary.csv`
- `summary.md`

Per suite:

- `suite-index.csv`
- `suite-medians.csv` (compat effective)
  - `suite-medians-nnnpps.csv`
  - `suite-medians-result.csv`
  - `plots/throughput-source-summary.csv`
- `suite-summary.md`
- plots (throughput/loss; peak-latency-vs-time charts when latency sub-run is enabled)

## 9) Decision Criteria

- primary: oracle shows consistent gain vs vanilla in knee/saturation region
- stability: gains remain under repeats (no one-off spikes only)
- correctness: no regression in functional checks

If oracle gain is consistent, proceed to **Experiment 3** automation pipeline.

## 10) Pitfalls Checklist

- generator bottleneck hides real LB behavior
- accidental config drift from Exp1 settings (rate range/duration/repeats/topology)
- instrumentation left enabled during measurement
- comparing runs with different attach mode or workload profile

## 11) How to Run Exp2

### 11.1 Measurement pipeline (recommended)

```sh
make exp2-run-all
# same as: make exp2-run-measurement
```

Default behavior: this is measurement-only and does **not** run discovery.
If you explicitly want legacy one-shot behavior, pass `--with-discovery` via `EXP2_RUN_ALL_EXTRA_ARGS`.

Default behavior: `exp2-build-oracle` auto-uses `scripts/experiments/exp2/patches/oracle-default.patch` and fails fast if oracle and original object hashes are identical (to prevent fake comparisons).

Default behavior: if `exp2-run-all` starts dual VMs, it stops them automatically at the end.
To keep them running:

```sh
make exp2-run-all EXP2_RUN_ALL_EXTRA_ARGS="--keep-vms-up"
```

This executes measurement stages only:

1. precheck
2. vm setup
3. isolated source prepare
4. oracle object build
5. smoke test
6. throughput suite
7. latency suite
8. analysis

### 11.2 Discovery-only pipeline

Use this when refreshing invariant-map evidence (separate from measurement):

```sh
make exp2-run-discovery
```

Quick custom discovery example:

```sh
make exp2-run-discovery \
  EXP2_DISCOVERY_RATE_PPS=100000 EXP2_DISCOVERY_DURATION_SECS=10 \
  EXP2_DISCOVERY_INTERVAL_SECS=5 EXP2_DISCOVERY_MAX_DUMP_LINES=200
```

For a raw discovery call without precheck/vm-setup wrapper, use:

```sh
make exp2-discovery
```

### 11.3 Fast measurement sanity run

```sh
make exp2-run-all \
  EXP2_RATES="100000" EXP2_REPEATS=1 EXP2_DURATION_SECS=5 \
  EXP2_LAT_RATES="100000" EXP2_LAT_REPEATS=1 EXP2_LAT_DURATION_SECS=5 \
  EXP2_LAT_PING_INTERVAL=0.05 EXP2_LAT_PROGRESS_INTERVAL=1
```

If VMs are already up and prepared:

```sh
make exp2-run-all EXP2_RUN_ALL_EXTRA_ARGS="--no-vm-start --no-vm-setup"
```

### 11.4 Step-by-step (manual control)

Measurement path:

```sh
make exp-results-init
make exp2-precheck
make exp2-vm-setup
make exp2-prepare-source
make exp2-build-oracle
# optional manual bytecode compare
make exp2-bytecode-compare
make exp2-test-smoke
make exp2-run-throughput
make exp2-run-latency
make exp2-analyze
make exp2-plot
```

Discovery path (separate):

```sh
make exp2-run-discovery
# or: make exp2-discovery
```

## 12) What Is Run and What Is Measured

### 12.1 What each stage runs

- `exp2-precheck`: verifies host tools, Linux config flags, VM SSH reachability.
- `exp2-vm-setup`: configures vm1/vm2 runtime, verifies ping and required tools.
- `exp2-prepare-source`: prepares isolated `source/katran-exp2` and builds BPF object there.
- `exp2-build-oracle`: builds oracle object in isolated tree, auto-applies default oracle patch unless disabled, and fails if oracle hash equals original hash; also dumps orig/oracle bytecode comparison outputs.
- `exp2-test-smoke`: short baseline/orig/oracle execution gate before long runs.
- `exp2-discovery`: runs intrusive map snapshot/hash collection for invariance candidates (raw discovery call).
- `exp2-run-discovery`: discovery-only pipeline (`precheck -> vm setup -> discovery`).
- `exp2-run-all` (or `exp2-run-measurement`): measurement-only pipeline; discovery is skipped by default.
- `exp2-run-throughput`: runs baseline/orig/oracle suite over offered pps matrix.
- `exp2-run-latency`: runs under-load RTT proxy suite (ICMP sampling during load), stores RTT time-series, computes peak RTT (peak_ms), and shows one-line progress/ETA; by default it uses the same rate matrix as throughput.
- `exp2-plot`: generates two throughput/loss plot sets (NNNpps-only and Result-only) plus peak-latency-vs-time plots from latest analysis output.
- `exp2-analyze`: merges suite outputs and computes loss/median summaries.

### 12.2 What is measured

- throughput (two separated sources):
  - `measured_pps_nnnpps` from pktgen `NNNpps` line
  - `measured_pps_result` from `Result:` (`packets * 1_000_000 / usec`)
  - missing source values are kept blank and counted; not backfilled into source-specific analysis.
- loss:
  - `loss_pps = max(0, offered_pps - measured_pps_source_specific)`
  - `loss_rate = max(0, 1 - measured_pps_source_specific/offered_pps)`
- latency proxy: peak RTT (peak_ms) and packet loss percent from VM2 ping sampling under load; per-case time-series is saved as elapsed_sec,rtt_ms.
- bytecode structure deltas (orig vs oracle object):
  - per-program/section code size (bytes)
  - disassembled instruction count
  - branch-jump count (`if`/`goto`)
  - disassembly diffs to inspect removed branch instructions.

## 13) Expected Outputs and Success Criteria

### 13.1 Output directories

- `results/exp2/precheck/`
- `results/exp2/setup/`
- `results/exp2/smoke/`
- `results/exp2/discovery/`
- `results/exp2/measurement/throughput/`
- `results/exp2/measurement/latency/`
- `results/exp2/oracle-builds/`
  - each oracle build contains `bytecode/` with disassembly and diffs
- `results/exp2/analysis/`

### 13.2 Key files to check

- discovery:
  - `snapshot-index.csv`
  - `invariant-candidates.csv`
- throughput suite:
  - `suite-index.csv`
  - `suite-medians.csv` (compat effective)
  - `suite-medians-nnnpps.csv`
  - `suite-medians-result.csv`
  - `plots/throughput-source-summary.csv`
- latency suite:
  - `latency-index.csv`
- oracle-build bytecode:
  - `bytecode/section-metrics.csv`
  - `bytecode/summary.md`
  - `bytecode/orig/` and `bytecode/oracle/` disassembly dumps
  - `bytecode/diff/*.diff.txt` and `*.removed-branches.txt`
- analysis:
  - `throughput-index.csv`
  - `loss-index.csv` (compat)
  - `loss-index-nnnpps.csv`
  - `loss-index-result.csv`
  - `throughput-loss-medians.csv` (compat)
  - `throughput-loss-medians-nnnpps.csv`
  - `throughput-loss-medians-result.csv`
  - `throughput-source-summary.csv`
  - `summary.md`

### 13.3 Expected run status

- all commands exit `0`.
- smoke stage passes for all three modes: baseline/orig/oracle.
- throughput `suite-index.csv` has rows for all configured modes/rates/repeats.
- analysis `summary.md` points to valid throughput suite and generated CSV outputs.
