#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

"${ROOT_DIR}/tools/kernel-track/tests/run.sh"
"${SCRIPT_DIR}/vm-linux-dev/run.sh"

echo "[PASS] all non-destructive test suites completed"
