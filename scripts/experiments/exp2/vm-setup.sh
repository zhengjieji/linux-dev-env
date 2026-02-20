#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_SETUP_ROOT_DEFAULT}"
NO_VM_START=0
DRY_RUN=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Setup and verify Exp2 VM runtime prerequisites.

Options:
  --out-root <path>  Output root for setup logs (default: ${OUT_ROOT})
  --no-vm-start      Assume VMs are already running
  --dry-run          Print steps only
  -h, --help         Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
			;;
		--no-vm-start)
			NO_VM_START=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			exp2_die "unknown option: $1"
			;;
	esac
done

OUT_ROOT="$(resolve_path_exp2 "${OUT_ROOT}")"
RUN_ID="$(new_exp2_id setup)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

if [ "${DRY_RUN}" -eq 1 ]; then
	exp2_log "[dry-run] would start/verify VMs and run vm1/vm2 setup scripts"
	echo "RUN_DIR=${RUN_DIR}"
	exit 0
fi

maybe_start_dual_vms "${NO_VM_START}"

exp2_log "running vm1 setup"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-setup.sh --vip 192.168.100.100" >"${RUN_DIR}/vm1-setup.log" 2>&1

exp2_log "running vm2 setup"
ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-setup.sh" >"${RUN_DIR}/vm2-setup.log" 2>&1

exp2_log "verifying vm1 tools"
ssh_vm vm1 "command -v bpftool && command -v ipvsadm && ip -brief addr" >"${RUN_DIR}/vm1-verify.log" 2>&1

exp2_log "verifying vm2 pktgen"
ssh_vm vm2 "test -e /proc/net/pktgen/pgctrl && ip -brief addr" >"${RUN_DIR}/vm2-verify.log" 2>&1

exp2_log "verifying vm1<->vm2 ping"
ssh_vm vm1 "ping -c 1 -W 2 192.168.100.2" >"${RUN_DIR}/vm1-ping-vm2.log" 2>&1
ssh_vm vm2 "ping -c 1 -W 2 192.168.100.1" >"${RUN_DIR}/vm2-ping-vm1.log" 2>&1

{
	echo "run_id=${RUN_ID}"
	echo "run_dir=${RUN_DIR}"
	echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "no_vm_start=${NO_VM_START}"
} >"${RUN_DIR}/summary.env"

{
	echo "# Exp2 VM Setup Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- run_dir: ${RUN_DIR}"
	echo "- status: ok"
} >"${RUN_DIR}/summary.md"

exp2_log "vm setup complete: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
