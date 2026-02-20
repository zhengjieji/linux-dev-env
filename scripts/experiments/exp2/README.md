# Experiment 2 Scripts

Implemented scripts:

- `precheck.sh`: host/vm readiness checks.
- `vm-setup.sh`: VM setup + connectivity/tool verification.
- `prepare-source.sh`: create isolated `source/katran-exp2` and build object.
- `build-oracle.sh`: auto-applies `patches/oracle-default.patch` (unless disabled), builds oracle object, and fails if oracle hash equals original.
- `bytecode-compare.sh`: dump/disassemble orig vs oracle bytecode and emit size/instruction/jump deltas.
- `test-smoke.sh`: functional gate (baseline/orig/oracle short runs).
- `discovery.sh`: map snapshot/hash discovery run.
- `run-throughput.sh`: throughput/loss suite for baseline/orig/oracle.
- `run-latency.sh`: under-load RTT proxy suite (ICMP while traffic runs) with one-line progress/ETA, defaulting to the same rate matrix as throughput.
- `analyze.sh`: merge throughput/loss(+latency) summaries.
- `plot.sh`: generate Exp2 plots (throughput/loss and latency if available).
- `run-all.sh`: end-to-end Exp2 pipeline.

Make targets:

- `make exp2-precheck`
- `make exp2-vm-setup`
- `make exp2-prepare-source`
- `make exp2-build-oracle`
- `make exp2-bytecode-compare`
- `make exp2-test-smoke`
- `make exp2-discovery`
- `make exp2-run-throughput`
- `make exp2-run-latency`
- `make exp2-analyze`
- `make exp2-plot`
- `make exp2-install-plot-tool`
- `make exp2-run-all`

All Exp2 outputs are under `results/exp2/`.
