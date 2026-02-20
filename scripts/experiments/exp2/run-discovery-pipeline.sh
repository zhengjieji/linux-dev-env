#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_DISCOVERY_ROOT_DEFAULT}"
RATE_PPS=""
DURATION_SECS=""
INTERVAL_SECS=""
MAX_DUMP_LINES=""
VIP=""
VIP_PORT=""
NO_VM_START=0
NO_VM_SETUP=0
KEEP_VMS_UP=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 discovery-only pipeline:
  precheck -> vm setup -> discovery

Options:
  --out-root <path>             Discovery output root (default: ${OUT_ROOT})
  --rate-pps <n>                Pass-through to discovery --rate-pps
  --duration <sec>              Pass-through to discovery --duration
  --interval <sec>              Pass-through to discovery --interval
  --max-dump-lines <n>          Pass-through to discovery --max-dump-lines
  --vip <ip>                    Pass-through to discovery --vip
  --vip-port <n>                Pass-through to discovery --vip-port
  --no-vm-start                 Assume VMs already running
  --no-vm-setup                 Skip explicit vm setup call
  --keep-vms-up                 Do not stop dual VMs when run finishes
  -h, --help                    Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
			;;
		--rate-pps)
			[ $# -gt 1 ] || exp2_die "--rate-pps requires value"
			RATE_PPS="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || exp2_die "--duration requires value"
			DURATION_SECS="$2"
			shift 2
			;;
		--interval)
			[ $# -gt 1 ] || exp2_die "--interval requires value"
			INTERVAL_SECS="$2"
			shift 2
			;;
		--max-dump-lines)
			[ $# -gt 1 ] || exp2_die "--max-dump-lines requires value"
			MAX_DUMP_LINES="$2"
			shift 2
			;;
		--vip)
			[ $# -gt 1 ] || exp2_die "--vip requires value"
			VIP="$2"
			shift 2
			;;
		--vip-port)
			[ $# -gt 1 ] || exp2_die "--vip-port requires value"
			VIP_PORT="$2"
			shift 2
			;;
		--no-vm-start)
			NO_VM_START=1
			shift
			;;
		--no-vm-setup)
			NO_VM_SETUP=1
			shift
			;;
		--keep-vms-up)
			KEEP_VMS_UP=1
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

STARTED_VMS_BY_SCRIPT=0

cleanup_dual_vms() {
	if [ "${STARTED_VMS_BY_SCRIPT}" -eq 1 ] && [ "${KEEP_VMS_UP}" -eq 0 ]; then
		exp2_log "stopping dual VMs after Exp2 discovery run"
		if ! make -C "${ROOT_DIR}" dual-vm-stop >/dev/null 2>&1; then
			exp2_log "warning: failed to stop dual VMs; run manually: make dual-vm-stop"
		fi
	fi
}
trap cleanup_dual_vms EXIT

"${ROOT_DIR}/scripts/experiments/init-results-layout.sh"
if [ "${NO_VM_START}" -eq 0 ]; then
	exp2_log "starting dual VMs before discovery precheck"
	maybe_start_dual_vms 0
	STARTED_VMS_BY_SCRIPT=1
fi

"${EXP2_DIR}/precheck.sh" --require-vms
if [ "${NO_VM_SETUP}" -eq 0 ]; then
	vm_setup_args=(--out-root "${EXP2_SETUP_ROOT_DEFAULT}")
	[ "${NO_VM_START}" -eq 1 ] && vm_setup_args+=(--no-vm-start)
	"${EXP2_DIR}/vm-setup.sh" "${vm_setup_args[@]}"
fi

discovery_args=(--out-root "${OUT_ROOT}")
[ "${NO_VM_START}" -eq 1 ] && discovery_args+=(--no-vm-start)
[ "${NO_VM_SETUP}" -eq 1 ] && discovery_args+=(--no-vm-setup)
[ -n "${RATE_PPS}" ] && discovery_args+=(--rate-pps "${RATE_PPS}")
[ -n "${DURATION_SECS}" ] && discovery_args+=(--duration "${DURATION_SECS}")
[ -n "${INTERVAL_SECS}" ] && discovery_args+=(--interval "${INTERVAL_SECS}")
[ -n "${MAX_DUMP_LINES}" ] && discovery_args+=(--max-dump-lines "${MAX_DUMP_LINES}")
[ -n "${VIP}" ] && discovery_args+=(--vip "${VIP}")
[ -n "${VIP_PORT}" ] && discovery_args+=(--vip-port "${VIP_PORT}")

"${EXP2_DIR}/discovery.sh" "${discovery_args[@]}"

exp2_log "Exp2 discovery-only pipeline complete"
