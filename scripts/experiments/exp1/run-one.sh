#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

MODE="${EXP1_MODE:-${KATRAN_MODE:-baseline-no-katran}}"
RATE_PPS="${EXP1_RATE_PPS:-${KATRAN_RATE_PPS:-200000}}"
DURATION_SECS="${EXP1_DURATION_SECS:-${KATRAN_DURATION_SECS:-30}}"
RESULTS_DIR="${EXP1_RUNS_DIR:-${ROOT_DIR}/results/exp1/runs}"

exec "${ROOT_DIR}/scripts/katran/run-experiment.sh" \
  --mode "${MODE}" \
  --rate-pps "${RATE_PPS}" \
  --duration "${DURATION_SECS}" \
  --results-dir "${RESULTS_DIR}" \
  "$@"
