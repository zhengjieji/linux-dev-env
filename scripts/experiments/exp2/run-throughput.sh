#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_MEASURE_THROUGHPUT_ROOT_DEFAULT}"
MODES="${EXP2_DEFAULT_MODES_THROUGHPUT}"
RATES="${EXP2_DEFAULT_RATES}"
REPEATS="${EXP2_DEFAULT_REPEATS}"
DURATION_SECS="${EXP2_DEFAULT_DURATION}"
LABEL="exp2-throughput"
PROGRESS_INTERVAL=1
ORACLE_OBJ="${EXP2_ORACLE_OBJ_DEFAULT}"
NO_VM_START=0
NO_VM_SETUP=0
DRY_RUN=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 throughput suite (baseline/orig/oracle) with Exp1-consistent matrix.

Options:
  --out-root <path>       Throughput suite root (default: ${OUT_ROOT})
  --modes "..."          Modes list (default: ${MODES})
  --rates "..."          Offered pps list (default: Exp1 matrix)
  --repeats <n>           Repeats per (mode,rate) (default: ${REPEATS})
  --duration <sec>        Duration per run (default: ${DURATION_SECS})
  --label <text>          Suite label (default: ${LABEL})
  --progress-interval <n> Progress refresh interval (default: ${PROGRESS_INTERVAL})
  --oracle-obj <path>     Oracle object path (default: ${ORACLE_OBJ})
  --no-vm-start           Assume VMs already running
  --no-vm-setup           Skip vm setup scripts
  --dry-run               Print command only
  -h, --help              Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
			;;
		--modes)
			[ $# -gt 1 ] || exp2_die "--modes requires value"
			MODES="$2"
			shift 2
			;;
		--rates)
			[ $# -gt 1 ] || exp2_die "--rates requires value"
			RATES="$2"
			shift 2
			;;
		--repeats)
			[ $# -gt 1 ] || exp2_die "--repeats requires value"
			REPEATS="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || exp2_die "--duration requires value"
			DURATION_SECS="$2"
			shift 2
			;;
		--label)
			[ $# -gt 1 ] || exp2_die "--label requires value"
			LABEL="$2"
			shift 2
			;;
		--progress-interval)
			[ $# -gt 1 ] || exp2_die "--progress-interval requires value"
			PROGRESS_INTERVAL="$2"
			shift 2
			;;
		--oracle-obj)
			[ $# -gt 1 ] || exp2_die "--oracle-obj requires value"
			ORACLE_OBJ="$2"
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
ORACLE_OBJ="$(resolve_path_exp2 "${ORACLE_OBJ}")"
mkdir -p "${OUT_ROOT}"

if [ "${DRY_RUN}" -eq 1 ]; then
	dry_no_vm_start=""
	dry_no_vm_setup=""
	[ "${NO_VM_START}" -eq 1 ] && dry_no_vm_start=" --no-vm-start"
	[ "${NO_VM_SETUP}" -eq 1 ] && dry_no_vm_setup=" --no-vm-setup"
	echo "KATRAN_ORACLE_OBJ=${ORACLE_OBJ} ${ROOT_DIR}/scripts/katran/run-suite.sh --modes \"${MODES}\" --rates \"${RATES}\" --repeats ${REPEATS} --duration ${DURATION_SECS} --label ${LABEL} --progress-interval ${PROGRESS_INTERVAL} --results-dir ${OUT_ROOT}${dry_no_vm_start}${dry_no_vm_setup}"
	exit 0
fi

assert_file "${ORACLE_OBJ}"

args=(--modes "${MODES}" --rates "${RATES}" --repeats "${REPEATS}" --duration "${DURATION_SECS}" --label "${LABEL}" --progress-interval "${PROGRESS_INTERVAL}" --results-dir "${OUT_ROOT}")
[ "${NO_VM_START}" -eq 1 ] && args+=(--no-vm-start)
[ "${NO_VM_SETUP}" -eq 1 ] && args+=(--no-vm-setup)

exp2_log "running throughput suite with oracle obj: ${ORACLE_OBJ}"
KATRAN_ORACLE_OBJ="${ORACLE_OBJ}" "${ROOT_DIR}/scripts/katran/run-suite.sh" "${args[@]}"
