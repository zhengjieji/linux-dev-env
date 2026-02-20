#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

RUN_LATENCY=1
RUN_DISCOVERY=1
NO_VM_START=0
NO_VM_SETUP=0
KEEP_VMS_UP=0
PATCH_FILE=""
RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"

TP_MODES=""
TP_RATES=""
TP_REPEATS=""
TP_DURATION=""
TP_PROGRESS_INTERVAL=""

LAT_MODES=""
LAT_RATES=""
LAT_REPEATS=""
LAT_DURATION=""
LAT_PING_INTERVAL=""
LAT_PROGRESS_INTERVAL=""

DISCOVERY_RATE=""
DISCOVERY_DURATION=""
DISCOVERY_INTERVAL=""
DISCOVERY_MAX_DUMP_LINES=""

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run full Exp2 pipeline:
  precheck -> vm setup -> prepare source -> oracle build -> smoke -> discovery -> throughput -> latency -> analyze

Options:
  --patch <path>                 Optional oracle patch to apply in Exp2 source
  --runtime-image <name>         Runtime image for build (default: ${RUNTIME_IMAGE})
  --skip-latency                 Skip latency sub-run
  --skip-discovery               Skip discovery run
  --no-vm-start                  Assume VMs are already running
  --no-vm-setup                  Skip explicit vm setup call (not recommended)
  --keep-vms-up                  Do not stop dual VMs when run finishes

  Throughput overrides:
  --tp-modes "..."              Pass-through to run-throughput --modes
  --tp-rates "..."              Pass-through to run-throughput --rates
  --tp-repeats <n>               Pass-through to run-throughput --repeats
  --tp-duration <sec>            Pass-through to run-throughput --duration
  --tp-progress-interval <n>     Pass-through to run-throughput --progress-interval

  Latency overrides:
  --lat-modes "..."             Pass-through to run-latency --modes
  --lat-rates "..."             Pass-through to run-latency --rates
  --lat-repeats <n>              Pass-through to run-latency --repeats
  --lat-duration <sec>           Pass-through to run-latency --duration
  --lat-ping-interval <sec>      Pass-through to run-latency --ping-interval
  --lat-progress-interval <n>    Pass-through to run-latency --progress-interval

  Discovery overrides:
  --discovery-rate <n>           Pass-through to discovery --rate-pps
  --discovery-duration <sec>     Pass-through to discovery --duration
  --discovery-interval <sec>     Pass-through to discovery --interval
  --discovery-max-dump-lines <n> Pass-through to discovery --max-dump-lines

  -h, --help                     Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--patch)
			[ $# -gt 1 ] || exp2_die "--patch requires value"
			PATCH_FILE="$2"
			shift 2
			;;
		--runtime-image)
			[ $# -gt 1 ] || exp2_die "--runtime-image requires value"
			RUNTIME_IMAGE="$2"
			shift 2
			;;
		--skip-latency)
			RUN_LATENCY=0
			shift
			;;
		--skip-discovery)
			RUN_DISCOVERY=0
			shift
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
		--tp-modes)
			[ $# -gt 1 ] || exp2_die "--tp-modes requires value"
			TP_MODES="$2"
			shift 2
			;;
		--tp-rates)
			[ $# -gt 1 ] || exp2_die "--tp-rates requires value"
			TP_RATES="$2"
			shift 2
			;;
		--tp-repeats)
			[ $# -gt 1 ] || exp2_die "--tp-repeats requires value"
			TP_REPEATS="$2"
			shift 2
			;;
		--tp-duration)
			[ $# -gt 1 ] || exp2_die "--tp-duration requires value"
			TP_DURATION="$2"
			shift 2
			;;
		--tp-progress-interval)
			[ $# -gt 1 ] || exp2_die "--tp-progress-interval requires value"
			TP_PROGRESS_INTERVAL="$2"
			shift 2
			;;
		--lat-modes)
			[ $# -gt 1 ] || exp2_die "--lat-modes requires value"
			LAT_MODES="$2"
			shift 2
			;;
		--lat-rates)
			[ $# -gt 1 ] || exp2_die "--lat-rates requires value"
			LAT_RATES="$2"
			shift 2
			;;
		--lat-repeats)
			[ $# -gt 1 ] || exp2_die "--lat-repeats requires value"
			LAT_REPEATS="$2"
			shift 2
			;;
		--lat-duration)
			[ $# -gt 1 ] || exp2_die "--lat-duration requires value"
			LAT_DURATION="$2"
			shift 2
			;;
		--lat-ping-interval)
			[ $# -gt 1 ] || exp2_die "--lat-ping-interval requires value"
			LAT_PING_INTERVAL="$2"
			shift 2
			;;
		--lat-progress-interval)
			[ $# -gt 1 ] || exp2_die "--lat-progress-interval requires value"
			LAT_PROGRESS_INTERVAL="$2"
			shift 2
			;;
		--discovery-rate)
			[ $# -gt 1 ] || exp2_die "--discovery-rate requires value"
			DISCOVERY_RATE="$2"
			shift 2
			;;
		--discovery-duration)
			[ $# -gt 1 ] || exp2_die "--discovery-duration requires value"
			DISCOVERY_DURATION="$2"
			shift 2
			;;
		--discovery-interval)
			[ $# -gt 1 ] || exp2_die "--discovery-interval requires value"
			DISCOVERY_INTERVAL="$2"
			shift 2
			;;
		--discovery-max-dump-lines)
			[ $# -gt 1 ] || exp2_die "--discovery-max-dump-lines requires value"
			DISCOVERY_MAX_DUMP_LINES="$2"
			shift 2
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
		exp2_log "stopping dual VMs after Exp2 run"
		if ! make -C "${ROOT_DIR}" dual-vm-stop >/dev/null 2>&1; then
			exp2_log "warning: failed to stop dual VMs; run manually: make dual-vm-stop"
		fi
	fi
}
trap cleanup_dual_vms EXIT

"${ROOT_DIR}/scripts/experiments/init-results-layout.sh"
if [ "${NO_VM_START}" -eq 0 ]; then
	exp2_log "starting dual VMs before required precheck"
	maybe_start_dual_vms 0
	STARTED_VMS_BY_SCRIPT=1
fi
"${EXP2_DIR}/precheck.sh" --require-vms
if [ "${NO_VM_SETUP}" -eq 0 ]; then
	vm_setup_args=()
	[ "${NO_VM_START}" -eq 1 ] && vm_setup_args+=(--no-vm-start)
	"${EXP2_DIR}/vm-setup.sh" "${vm_setup_args[@]}"
fi

"${EXP2_DIR}/prepare-source.sh" --runtime-image "${RUNTIME_IMAGE}"

build_args=(--runtime-image "${RUNTIME_IMAGE}")
if [ -n "${PATCH_FILE}" ]; then
	build_args+=(--patch "${PATCH_FILE}")
fi
oracle_output="$(${EXP2_DIR}/build-oracle.sh "${build_args[@]}")"
oracle_obj="$(printf '%s\n' "${oracle_output}" | awk -F= '/^ORACLE_OBJ=/{print $2}' | tail -n1)"
[ -n "${oracle_obj}" ] || exp2_die "failed to get ORACLE_OBJ from build-oracle"

smoke_args=(--oracle-obj "${oracle_obj}")
[ "${NO_VM_START}" -eq 1 ] && smoke_args+=(--no-vm-start)
"${EXP2_DIR}/test-smoke.sh" "${smoke_args[@]}"

if [ "${RUN_DISCOVERY}" -eq 1 ]; then
	discovery_args=()
	[ "${NO_VM_START}" -eq 1 ] && discovery_args+=(--no-vm-start)
	[ "${NO_VM_SETUP}" -eq 1 ] && discovery_args+=(--no-vm-setup)
	[ -n "${DISCOVERY_RATE}" ] && discovery_args+=(--rate-pps "${DISCOVERY_RATE}")
	[ -n "${DISCOVERY_DURATION}" ] && discovery_args+=(--duration "${DISCOVERY_DURATION}")
	[ -n "${DISCOVERY_INTERVAL}" ] && discovery_args+=(--interval "${DISCOVERY_INTERVAL}")
	[ -n "${DISCOVERY_MAX_DUMP_LINES}" ] && discovery_args+=(--max-dump-lines "${DISCOVERY_MAX_DUMP_LINES}")
	"${EXP2_DIR}/discovery.sh" "${discovery_args[@]}"
fi

throughput_args=(--oracle-obj "${oracle_obj}")
[ "${NO_VM_START}" -eq 1 ] && throughput_args+=(--no-vm-start)
[ "${NO_VM_SETUP}" -eq 1 ] && throughput_args+=(--no-vm-setup)
[ -n "${TP_MODES}" ] && throughput_args+=(--modes "${TP_MODES}")
[ -n "${TP_RATES}" ] && throughput_args+=(--rates "${TP_RATES}")
[ -n "${TP_REPEATS}" ] && throughput_args+=(--repeats "${TP_REPEATS}")
[ -n "${TP_DURATION}" ] && throughput_args+=(--duration "${TP_DURATION}")
[ -n "${TP_PROGRESS_INTERVAL}" ] && throughput_args+=(--progress-interval "${TP_PROGRESS_INTERVAL}")
"${EXP2_DIR}/run-throughput.sh" "${throughput_args[@]}"

if [ "${RUN_LATENCY}" -eq 1 ]; then
	latency_args=(--oracle-obj "${oracle_obj}")
	[ "${NO_VM_START}" -eq 1 ] && latency_args+=(--no-vm-start)
	[ "${NO_VM_SETUP}" -eq 1 ] && latency_args+=(--no-vm-setup)
	[ -n "${LAT_MODES}" ] && latency_args+=(--modes "${LAT_MODES}")
	[ -n "${LAT_RATES}" ] && latency_args+=(--rates "${LAT_RATES}")
	[ -n "${LAT_REPEATS}" ] && latency_args+=(--repeats "${LAT_REPEATS}")
	[ -n "${LAT_DURATION}" ] && latency_args+=(--duration "${LAT_DURATION}")
	[ -n "${LAT_PING_INTERVAL}" ] && latency_args+=(--ping-interval "${LAT_PING_INTERVAL}")
	[ -n "${LAT_PROGRESS_INTERVAL}" ] && latency_args+=(--progress-interval "${LAT_PROGRESS_INTERVAL}")
	"${EXP2_DIR}/run-latency.sh" "${latency_args[@]}"
fi

"${EXP2_DIR}/analyze.sh"

exp2_log "Exp2 pipeline complete"
