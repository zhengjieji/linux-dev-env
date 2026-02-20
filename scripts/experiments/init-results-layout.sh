#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

mkdir -p \
  "${ROOT_DIR}/results/exp1/runs" \
  "${ROOT_DIR}/results/exp1/suites" \
  "${ROOT_DIR}/results/exp2/precheck" \
  "${ROOT_DIR}/results/exp2/setup" \
  "${ROOT_DIR}/results/exp2/smoke" \
  "${ROOT_DIR}/results/exp2/discovery" \
  "${ROOT_DIR}/results/exp2/measurement/throughput" \
  "${ROOT_DIR}/results/exp2/measurement/latency" \
  "${ROOT_DIR}/results/exp2/oracle-builds" \
  "${ROOT_DIR}/results/exp2/analysis" \
  "${ROOT_DIR}/results/exp3/runs" \
  "${ROOT_DIR}/results/exp3/analysis"

echo "[experiments] initialized results layout under ${ROOT_DIR}/results"
