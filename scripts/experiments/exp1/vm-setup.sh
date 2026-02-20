#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

make -C "${ROOT_DIR}" katran-vm1-setup
make -C "${ROOT_DIR}" katran-vm2-setup
