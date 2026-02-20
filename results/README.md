# Results Layout

All outputs are stored under `results/experiments/`.

## One-off Run
- path: `results/experiments/<run-id>/`
- contents: `meta.env`, `logs-host/`, `logs-vm1/`, `logs-vm2/`, `metrics/`, `summary.csv`, `summary.md`

## Suite Run
- root: `results/experiments/<suite-id>/`
- case runs: `results/experiments/<suite-id>/runs/<run-id>/`
- case logs: `results/experiments/<suite-id>/logs-cases/*.log`
- suite artifacts: `suite-index.csv`, `suite-medians.csv`, `suite-summary.md`, `plots/`
