#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
DUAL_VM_SCRIPT="${ROOT_DIR}/scripts/dual-vm.sh"

log() {
	echo "[katran] $*"
}

die() {
	echo "[katran][error] $*" >&2
	exit 1
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

safe_label() {
	local raw="$1"
	local cleaned
	cleaned="$(printf '%s' "${raw}" | tr -cs '[:alnum:]._-' '-')"
	cleaned="${cleaned#-}"
	cleaned="${cleaned%-}"
	if [ -z "${cleaned}" ]; then
		cleaned="run"
	fi
	printf '%s\n' "${cleaned}"
}

new_run_id() {
	local label
	label="$(safe_label "$1")"
	echo "$(date -u +%Y%m%dT%H%M%SZ)-${label}"
}

ssh_vm() {
	local vm="$1"
	shift
	"${DUAL_VM_SCRIPT}" ssh "${vm}" "$@"
}

ensure_dual_vm_up() {
	make -C "${ROOT_DIR}" dual-vm1 >/dev/null
	make -C "${ROOT_DIR}" dual-vm2 >/dev/null
}
