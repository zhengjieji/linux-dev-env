#!/usr/bin/env bash

set -euo pipefail

EXP2_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../katran/common.sh
source "${EXP2_SCRIPT_DIR}/../../katran/common.sh"

EXP2_RESULTS_ROOT_DEFAULT="${ROOT_DIR}/results/exp2"
EXP2_PRECHECK_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/precheck"
EXP2_SETUP_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/setup"
EXP2_SMOKE_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/smoke"
EXP2_DISCOVERY_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/discovery"
EXP2_MEASURE_THROUGHPUT_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/measurement/throughput"
EXP2_MEASURE_LATENCY_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/measurement/latency"
EXP2_ANALYSIS_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/analysis"
EXP2_ORACLE_BUILD_ROOT_DEFAULT="${EXP2_RESULTS_ROOT_DEFAULT}/oracle-builds"

EXP2_BASE_SOURCE_DEFAULT="${ROOT_DIR}/source/katran"
EXP2_SOURCE_DEFAULT="${ROOT_DIR}/source/katran-exp2"
EXP2_ORACLE_OBJ_DEFAULT="${EXP2_SOURCE_DEFAULT}/build/katran/lib/bpf/balancer.bpf.o"
EXP1_ORIG_OBJ_DEFAULT="${ROOT_DIR}/source/katran/build/katran/lib/bpf/balancer.bpf.o"

EXP2_DEFAULT_RATES="50000 100000 150000 200000 250000 300000 350000 400000 450000 500000 550000 600000 650000 700000 750000 800000 850000 900000 950000 1000000"
EXP2_DEFAULT_MODES_THROUGHPUT="baseline-no-katran katran-orig-bpf katran-oracle-bpf"
EXP2_DEFAULT_REPEATS=3
EXP2_DEFAULT_DURATION=30

exp2_log() {
	echo "[exp2] $*"
}

exp2_die() {
	echo "[exp2][error] $*" >&2
	exit 1
}

resolve_path_exp2() {
	case "$1" in
		/*) printf '%s\n' "$1" ;;
		*) printf '%s/%s\n' "${ROOT_DIR}" "$1" ;;
	esac
}

new_exp2_id() {
	local label
	label="$(safe_label "$1")"
	echo "$(date -u +%Y%m%dT%H%M%SZ)-${label}"
}

host_path_to_vm_repo_path() {
	local p="$1"
	case "${p}" in
		"${ROOT_DIR}"/*)
			printf '/linux-dev-env/%s\n' "${p#${ROOT_DIR}/}"
			;;
		/linux-dev-env/*)
			printf '%s\n' "${p}"
			;;
		*)
			return 1
			;;
	esac
}

assert_file() {
	local p="$1"
	[ -f "${p}" ] || exp2_die "missing file: ${p}"
}

ensure_exp2_results_layout() {
	mkdir -p \
		"${EXP2_RESULTS_ROOT_DEFAULT}" \
		"${EXP2_PRECHECK_ROOT_DEFAULT}" \
		"${EXP2_SETUP_ROOT_DEFAULT}" \
		"${EXP2_SMOKE_ROOT_DEFAULT}" \
		"${EXP2_DISCOVERY_ROOT_DEFAULT}" \
		"${EXP2_MEASURE_THROUGHPUT_ROOT_DEFAULT}" \
		"${EXP2_MEASURE_LATENCY_ROOT_DEFAULT}" \
		"${EXP2_ORACLE_BUILD_ROOT_DEFAULT}" \
		"${EXP2_ANALYSIS_ROOT_DEFAULT}"
}

maybe_start_dual_vms() {
	local no_vm_start="$1"
	if [ "${no_vm_start}" -eq 1 ]; then
		return 0
	fi
	make -C "${ROOT_DIR}" dual-vm1 >/dev/null
	make -C "${ROOT_DIR}" dual-vm2 >/dev/null
}
