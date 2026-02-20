#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_PRECHECK_ROOT_DEFAULT}"
REQUIRE_VMS=0
STRICT=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 prechecks on host (and optionally VM reachability).

Options:
  --out-root <path>  Output root for precheck runs (default: ${OUT_ROOT})
  --require-vms      Treat VM SSH/connectivity checks as required
  --strict           Fail on warnings too
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
		--require-vms)
			REQUIRE_VMS=1
			shift
			;;
		--strict)
			STRICT=1
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
RUN_ID="$(new_exp2_id precheck)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

errors=0
warnings=0

check_cmd() {
	local cmd="$1"
	local required="$2"
	if command -v "${cmd}" >/dev/null 2>&1; then
		echo "ok,cmd,${cmd}" >>"${RUN_DIR}/checks.csv"
	else
		if [ "${required}" -eq 1 ]; then
			echo "error,cmd,${cmd}" >>"${RUN_DIR}/checks.csv"
			errors=$((errors + 1))
		else
			echo "warn,cmd,${cmd}" >>"${RUN_DIR}/checks.csv"
			warnings=$((warnings + 1))
		fi
	fi
}

check_path() {
	local path="$1"
	local required="$2"
	if [ -e "${path}" ]; then
		echo "ok,path,${path}" >>"${RUN_DIR}/checks.csv"
	else
		if [ "${required}" -eq 1 ]; then
			echo "error,path,${path}" >>"${RUN_DIR}/checks.csv"
			errors=$((errors + 1))
		else
			echo "warn,path,${path}" >>"${RUN_DIR}/checks.csv"
			warnings=$((warnings + 1))
		fi
	fi
}

check_kconfig_flag() {
	local flag="$1"
	local required="$2"
	if grep -Eq "^${flag}=y|^${flag}=m" "${ROOT_DIR}/linux/.config" 2>/dev/null; then
		echo "ok,kconfig,${flag}" >>"${RUN_DIR}/checks.csv"
	else
		if [ "${required}" -eq 1 ]; then
			echo "error,kconfig,${flag}" >>"${RUN_DIR}/checks.csv"
			errors=$((errors + 1))
		else
			echo "warn,kconfig,${flag}" >>"${RUN_DIR}/checks.csv"
			warnings=$((warnings + 1))
		fi
	fi
}

: >"${RUN_DIR}/checks.csv"

echo "status,type,item" >>"${RUN_DIR}/checks.csv"

check_cmd git 1
check_cmd make 1
check_cmd docker 1
check_cmd awk 1
check_cmd sed 1
check_cmd sha256sum 1
check_cmd ssh 1
check_cmd timeout 0

check_path "${ROOT_DIR}/linux/.config" 1
check_path "${ROOT_DIR}/scripts/dual-vm.sh" 1
check_path "${EXP2_BASE_SOURCE_DEFAULT}/.git" 1
check_path "${ROOT_DIR}/scripts/katran/build-katran-host.sh" 1

if [ -f "${ROOT_DIR}/linux/.config" ]; then
	check_kconfig_flag CONFIG_BPF 1
	check_kconfig_flag CONFIG_BPF_SYSCALL 1
	check_kconfig_flag CONFIG_BPF_JIT 1
	check_kconfig_flag CONFIG_NET_PKTGEN 1
	check_kconfig_flag CONFIG_XDP_SOCKETS 0
fi

if [ "${REQUIRE_VMS}" -eq 1 ]; then
	if ssh_vm vm1 "true" >/dev/null 2>&1; then
		echo "ok,vm,vm1-ssh" >>"${RUN_DIR}/checks.csv"
	else
		echo "error,vm,vm1-ssh" >>"${RUN_DIR}/checks.csv"
		errors=$((errors + 1))
	fi
	if ssh_vm vm2 "true" >/dev/null 2>&1; then
		echo "ok,vm,vm2-ssh" >>"${RUN_DIR}/checks.csv"
	else
		echo "error,vm,vm2-ssh" >>"${RUN_DIR}/checks.csv"
		errors=$((errors + 1))
	fi
else
	if ssh_vm vm1 "true" >/dev/null 2>&1; then
		echo "ok,vm,vm1-ssh" >>"${RUN_DIR}/checks.csv"
	else
		echo "warn,vm,vm1-ssh" >>"${RUN_DIR}/checks.csv"
		warnings=$((warnings + 1))
	fi
	if ssh_vm vm2 "true" >/dev/null 2>&1; then
		echo "ok,vm,vm2-ssh" >>"${RUN_DIR}/checks.csv"
	else
		echo "warn,vm,vm2-ssh" >>"${RUN_DIR}/checks.csv"
		warnings=$((warnings + 1))
	fi
fi

{
	echo "run_id=${RUN_ID}"
	echo "run_dir=${RUN_DIR}"
	echo "errors=${errors}"
	echo "warnings=${warnings}"
	echo "require_vms=${REQUIRE_VMS}"
	echo "strict=${STRICT}"
	echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${RUN_DIR}/summary.env"

{
	echo "# Exp2 Precheck Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- errors: ${errors}"
	echo "- warnings: ${warnings}"
	echo "- checks_csv: ${RUN_DIR}/checks.csv"
	echo
	echo "## Status Counts"
	echo
	echo "\`\`\`"
	awk -F, 'NR>1{c[$1]++} END{for (k in c) print k "=" c[k]}' "${RUN_DIR}/checks.csv" | sort
	echo "\`\`\`"
} >"${RUN_DIR}/summary.md"

exp2_log "precheck complete: ${RUN_DIR}"

if [ "${errors}" -gt 0 ]; then
	exp2_die "precheck failed with ${errors} error(s)"
fi
if [ "${STRICT}" -eq 1 ] && [ "${warnings}" -gt 0 ]; then
	exp2_die "precheck strict-mode failed with ${warnings} warning(s)"
fi

echo "RUN_DIR=${RUN_DIR}"
