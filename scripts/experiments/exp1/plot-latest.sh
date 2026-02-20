#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [plot-suite options]

Plot the latest Exp1 suite by default.

Environment:
  EXP1_SUITES_DIR   Suite root (default: ${ROOT_DIR}/results/exp1/suites)
  EXP1_SUITE_DIR    Explicit suite directory (overrides latest detection)

Examples:
  $(basename "$0")
  EXP1_SUITE_DIR=${ROOT_DIR}/results/exp1/suites/<suite-id> $(basename "$0")
USAGE
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

SUITES_DIR="${EXP1_SUITES_DIR:-${ROOT_DIR}/results/exp1/suites}"
SUITE_DIR="${EXP1_SUITE_DIR:-}"

if [ -z "${SUITE_DIR}" ]; then
  SUITE_DIR="$(ls -1dt "${SUITES_DIR}"/* 2>/dev/null | head -n1 || true)"
fi

if [ -z "${SUITE_DIR}" ] || [ ! -d "${SUITE_DIR}" ]; then
  echo "[exp1-plot][error] no suite found under ${SUITES_DIR}" >&2
  exit 1
fi

exec "${ROOT_DIR}/scripts/katran/plot-suite.sh" \
  --suite-dir "${SUITE_DIR}" \
  --install-gnuplot-user \
  "$@"
