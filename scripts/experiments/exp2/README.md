# Experiment 2 Scripts

Implemented scripts:

- `precheck.sh`: host/vm readiness checks.
- `vm-setup.sh`: VM setup + connectivity/tool verification.
- `prepare-source.sh`: create isolated `source/katran-exp2` and build object.
- `build-oracle.sh`: auto-applies `patches/oracle-default.patch` (unless disabled), builds oracle object, and fails if oracle hash equals original.
- `bytecode-compare.sh`: dump/disassemble orig vs oracle bytecode and emit size/instruction/jump deltas.
- `test-smoke.sh`: functional gate (baseline/orig/oracle short runs).
- `discovery.sh`: raw map snapshot/hash discovery run.
- `run-discovery-pipeline.sh`: discovery-only pipeline (`precheck -> vm setup -> discovery`).
- `run-throughput.sh`: throughput/loss suite for baseline/orig/oracle.
- `run-latency.sh`: under-load RTT proxy suite (ICMP while traffic runs), outputs RTT time-series and peak RTT (`peak_ms`), with one-line progress/ETA.
- `analyze.sh`: merge throughput/loss(+latency) summaries with source-separated outputs (`nnnpps` vs `result`).
- `plot.sh`: generate Exp2 plots (two throughput/loss sets: `NNNpps`-only and `Result`-only, plus peak-latency-vs-time if available).
- `run-all.sh`: measurement pipeline (`precheck -> vm setup -> prepare source -> oracle build -> smoke -> throughput -> latency -> analyze`). Discovery is not run by default; pass `--with-discovery` only when needed.

Make targets:

- `make exp2-precheck`
- `make exp2-vm-setup`
- `make exp2-prepare-source`
- `make exp2-build-oracle`
- `make exp2-bytecode-compare`
- `make exp2-test-smoke`
- `make exp2-discovery` (raw discovery)
- `make exp2-run-discovery` (discovery pipeline)
- `make exp2-run-throughput`
- `make exp2-run-latency`
- `make exp2-analyze`
- `make exp2-plot`
- `make exp2-install-plot-tool`
- `make exp2-run-all` (measurement pipeline)
- `make exp2-run-measurement` (alias of `exp2-run-all`)

All Exp2 outputs are under `results/exp2/`.
