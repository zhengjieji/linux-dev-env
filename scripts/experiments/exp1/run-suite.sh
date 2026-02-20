#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

MODES="${EXP1_MODES:-baseline-no-katran katran-orig-bpf}"
RATES="${EXP1_RATES:-50000 100000 150000 200000 250000 300000 350000 400000 450000 500000 550000 600000 650000 700000 750000 800000 850000 900000 950000 1000000}"
DURATION_SECS="${EXP1_DURATION_SECS:-${KATRAN_DURATION_SECS:-30}}"
REPEATS="${EXP1_REPEATS:-${KATRAN_REPEATS:-3}}"
LABEL="${EXP1_LABEL:-exp1-suite}"
PROGRESS_INTERVAL="${EXP1_PROGRESS_INTERVAL:-${KATRAN_PROGRESS_INTERVAL:-1}}"
RESULTS_DIR="${EXP1_SUITES_DIR:-${ROOT_DIR}/results/exp1/suites}"

exec "${ROOT_DIR}/scripts/katran/run-suite.sh" \
  --modes "${MODES}" \
  --rates "${RATES}" \
  --duration "${DURATION_SECS}" \
  --repeats "${REPEATS}" \
  --label "${LABEL}" \
  --progress-interval "${PROGRESS_INTERVAL}" \
  --results-dir "${RESULTS_DIR}" \
  "$@"
