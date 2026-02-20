#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_SMOKE_ROOT_DEFAULT}"
RATE_PPS=100000
DURATION_SECS=5
NO_VM_START=0
DRY_RUN=0
ORACLE_OBJ="${EXP2_ORACLE_OBJ_DEFAULT}"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 functionality smoke tests before full experiment runs.

Options:
  --out-root <path>     Output root (default: ${OUT_ROOT})
  --rate-pps <n>        Smoke workload rate (default: ${RATE_PPS})
  --duration <sec>      Smoke workload duration (default: ${DURATION_SECS})
  --oracle-obj <path>   Oracle object path (default: ${ORACLE_OBJ})
  --no-vm-start         Assume VMs are already running
  --dry-run             Print steps only
  -h, --help            Show this help
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
		--oracle-obj)
			[ $# -gt 1 ] || exp2_die "--oracle-obj requires value"
			ORACLE_OBJ="$2"
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
ORACLE_OBJ="$(resolve_path_exp2 "${ORACLE_OBJ}")"
mkdir -p "${OUT_ROOT}"
RUN_ID="$(new_exp2_id smoke)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

exp1_obj="${EXP1_ORIG_OBJ_DEFAULT}"
sha_before=""
if [ -f "${exp1_obj}" ]; then
	sha_before="$(sha256sum "${exp1_obj}" | awk '{print $1}')"
fi

if [ "${DRY_RUN}" -eq 1 ]; then
	exp2_log "[dry-run] precheck + vm-setup + baseline/orig/oracle short runs"
	echo "RUN_DIR=${RUN_DIR}"
	exit 0
fi

"${EXP2_DIR}/precheck.sh" --require-vms >"${RUN_DIR}/precheck.log" 2>&1
vm_setup_args=(--out-root "${RUN_DIR}/vm-setup")
[ "${NO_VM_START}" -eq 1 ] && vm_setup_args+=(--no-vm-start)
"${EXP2_DIR}/vm-setup.sh" "${vm_setup_args[@]}" >"${RUN_DIR}/vm-setup.log" 2>&1

run_case() {
	local mode="$1"
	local label="$2"
	local extra_env=( )
	if [ "${mode}" = "katran-oracle-bpf" ]; then
		assert_file "${ORACLE_OBJ}"
		extra_env+=("KATRAN_ORACLE_OBJ=${ORACLE_OBJ}")
	fi
	if [ ${#extra_env[@]} -gt 0 ]; then
		env "${extra_env[@]}" "${ROOT_DIR}/scripts/katran/run-experiment.sh" \
			--mode "${mode}" --rate-pps "${RATE_PPS}" --duration "${DURATION_SECS}" \
			--label "exp2-smoke-${label}" --results-dir "${RUN_DIR}/runs" >"${RUN_DIR}/${label}.log" 2>&1
	else
		"${ROOT_DIR}/scripts/katran/run-experiment.sh" \
			--mode "${mode}" --rate-pps "${RATE_PPS}" --duration "${DURATION_SECS}" \
			--label "exp2-smoke-${label}" --results-dir "${RUN_DIR}/runs" >"${RUN_DIR}/${label}.log" 2>&1
	fi
	local run_path
	run_path="$(awk -F= '/^RUN_DIR=/{print $2}' "${RUN_DIR}/${label}.log" | tail -n1)"
	[ -n "${run_path}" ] || exp2_die "missing RUN_DIR for ${label}"
	assert_file "${run_path}/summary.csv"
	echo "${label}=${run_path}" >>"${RUN_DIR}/runs.env"
}

run_case baseline-no-katran baseline
run_case katran-orig-bpf orig
run_case katran-oracle-bpf oracle

sha_after=""
if [ -f "${exp1_obj}" ]; then
	sha_after="$(sha256sum "${exp1_obj}" | awk '{print $1}')"
fi

if [ -n "${sha_before}" ] && [ -n "${sha_after}" ] && [ "${sha_before}" != "${sha_after}" ]; then
	exp2_die "Exp1 original object checksum changed during smoke run"
fi

{
	echo "run_id=${RUN_ID}"
	echo "run_dir=${RUN_DIR}"
	echo "rate_pps=${RATE_PPS}"
	echo "duration_secs=${DURATION_SECS}"
	echo "oracle_obj=${ORACLE_OBJ}"
	echo "exp1_obj_sha_before=${sha_before}"
	echo "exp1_obj_sha_after=${sha_after}"
} >"${RUN_DIR}/summary.env"

{
	echo "# Exp2 Smoke Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- rate_pps: ${RATE_PPS}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- exp1_obj_sha_before: ${sha_before}"
	echo "- exp1_obj_sha_after: ${sha_after}"
	echo
	echo "Smoke cases completed: baseline, orig, oracle"
} >"${RUN_DIR}/summary.md"

exp2_log "smoke tests passed: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
