#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

RESULTS_BASE="${EXP1_RESULTS_BASE:-${ROOT_DIR}/results/exp1}"
KEEP_VMS="${EXP1_KEEP_VMS:-0}"
SKIP_INSTALL="${EXP1_SKIP_INSTALL:-0}"
PLOT_ENABLED="${EXP1_PLOT:-1}"
ARCHIVE_OLD="${EXP1_ARCHIVE_OLD:-1}"
MODE="${EXP1_MODE:-both}"
WORKLOADS="${EXP1_WORKLOADS:-both}"

VM1_SSH_PORT="${DUAL_VM1_SSH_PORT:-53022}"
VM1_NET_PORT="${DUAL_VM1_NET_PORT:-53023}"
VM1_GDB_PORT="${DUAL_VM1_GDB_PORT:-1311}"
VM2_SSH_PORT="${DUAL_VM2_SSH_PORT:-53122}"
VM2_NET_PORT="${DUAL_VM2_NET_PORT:-53123}"
VM2_GDB_PORT="${DUAL_VM2_GDB_PORT:-1312}"
VM3_SSH_PORT="${DUAL_VM3_SSH_PORT:-53222}"
VM3_NET_PORT="${DUAL_VM3_NET_PORT:-53223}"
VM3_GDB_PORT="${DUAL_VM3_GDB_PORT:-1313}"
VM4_SSH_PORT="${DUAL_VM4_SSH_PORT:-53322}"
VM4_NET_PORT="${DUAL_VM4_NET_PORT:-53323}"
VM4_GDB_PORT="${DUAL_VM4_GDB_PORT:-1314}"
HOST_VM1_CPUSET="${DUAL_VM1_HOST_CPUSET:-auto}"
HOST_VM2_CPUSET="${DUAL_VM2_HOST_CPUSET:-auto}"
HOST_VM3_CPUSET="${DUAL_VM3_HOST_CPUSET:-auto}"
HOST_VM4_CPUSET="${DUAL_VM4_HOST_CPUSET:-auto}"
HOST_VM1_MEMORY_MB="${DUAL_VM1_MEMORY_MB:-4096}"
HOST_VM2_MEMORY_MB="${DUAL_VM2_MEMORY_MB:-4096}"
HOST_VM3_MEMORY_MB="${DUAL_VM3_MEMORY_MB:-4096}"
HOST_VM4_MEMORY_MB="${DUAL_VM4_MEMORY_MB:-4096}"
HOST_VM1_VCPUS="${DUAL_VM1_VCPUS:-4}"
HOST_VM2_VCPUS="${DUAL_VM2_VCPUS:-4}"
HOST_VM3_VCPUS="${DUAL_VM3_VCPUS:-4}"
HOST_VM4_VCPUS="${DUAL_VM4_VCPUS:-4}"

SERVER_IP="${EXP1_SERVER_IP:-192.168.100.1}"
SERVER_PORT="${EXP1_SERVER_PORT:-8080}"
SERVER_FILE="${EXP1_SERVER_FILE:-exp1-1k.txt}"
NGINX_CPUSET="${EXP1_NGINX_CPUSET:-0-3}"
WRK_CPUSET="${EXP1_WRK_CPUSET:-0-3}"
HTTPERF_CPUSET="${EXP1_HTTPERF_CPUSET:-0-3}"

KATRAN_VIP="${EXP1_KATRAN_VIP:-192.168.100.100}"
KATRAN_GRPC_PORT="${EXP1_KATRAN_GRPC_PORT:-50051}"
KATRAN_DEFAULT_MAC="${EXP1_KATRAN_DEFAULT_MAC:-52:54:00:aa:00:22}"
KATRAN_FORWARDING_CORES="${EXP1_KATRAN_FORWARDING_CORES:-0,1,2,3}"
KATRAN_LRU_SIZE="${EXP1_KATRAN_LRU_SIZE:-1000000}"
KATRAN_CPUSET="${EXP1_KATRAN_CPUSET:-0-3}"
KATRAN_SERVER_BIN_VM="${EXP1_KATRAN_SERVER_BIN:-/linux-dev-env/source/katran/_build/build/example_grpc/katran_server_grpc}"
KATRAN_BPF_OBJ_VM="${EXP1_KATRAN_BPF_OBJ:-/linux-dev-env/source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o}"
KATRAN_GOCLIENT_BIN_VM="${EXP1_KATRAN_GOCLIENT_BIN:-/linux-dev-env/source/katran/example_grpc/goclient/src/katranc/main/main}"
KATRAN_LIB_DIRS="${EXP1_KATRAN_LIB_DIRS:-/linux-dev-env/source/katran/_build/deps/lib:/linux-dev-env/source/katran/_build/deps/lib64}"
KATRAN_AUTO_BUILD="${EXP1_KATRAN_AUTO_BUILD:-1}"
KATRAN_BUILD_SCRIPT="${EXP1_KATRAN_BUILD_SCRIPT:-${SCRIPT_DIR}/build-katran.sh}"
KATRAN_REQUIRED_BPF_DEFINE="${EXP1_KATRAN_REQUIRED_BPF_DEFINE:-LOCAL_DELIVERY_OPTIMIZATION}"

WRK_THREADS="${EXP1_WRK_THREADS:-4}"
WRK_CONNECTIONS="${EXP1_WRK_CONNECTIONS:-1 2 4 8 16 32}"
WRK_WARMUP="${EXP1_WRK_WARMUP:-5}"
WRK_DURATION="${EXP1_WRK_DURATION:-20}"
WRK_REPEATS="${EXP1_WRK_REPEATS:-3}"
WRK2_THREADS="${EXP1_WRK2_THREADS:-${WRK_THREADS}}"
WRK2_CONNECTIONS="${EXP1_WRK2_CONNECTIONS:-256}"
WRK2_RATES="${EXP1_WRK2_RATES:-50000 100000 150000 200000 250000 300000 350000 400000 450000 500000}"
WRK2_WARMUP="${EXP1_WRK2_WARMUP:-${WRK_WARMUP}}"
WRK2_DURATION="${EXP1_WRK2_DURATION:-${WRK_DURATION}}"
WRK2_REPEATS="${EXP1_WRK2_REPEATS:-${WRK_REPEATS}}"
WRK2_CPUSET="${EXP1_WRK2_CPUSET:-${WRK_CPUSET}}"
WRK2_BIN="${EXP1_WRK2_BIN:-wrk2}"
WRK2_AUTO_BUILD="${EXP1_WRK2_AUTO_BUILD:-1}"
HTTPERF_RATES="${EXP1_HTTPERF_RATES:-5000 10000 20000 40000 80000 120000 160000 200000}"
HTTPERF_WARMUP="${EXP1_HTTPERF_WARMUP:-5}"
HTTPERF_DURATION="${EXP1_HTTPERF_DURATION:-20}"
HTTPERF_REPEATS="${EXP1_HTTPERF_REPEATS:-3}"
HTTPERF_TIMEOUT="${EXP1_HTTPERF_TIMEOUT:-5}"
HTTPERF_CLIENT_VMS="${EXP1_HTTPERF_CLIENT_VMS:-vm2}"
HTTPERF_WORKERS_PER_VM="${EXP1_HTTPERF_WORKERS_PER_VM:-1}"
HTTPERF_ULIMIT_NOFILE="${EXP1_HTTPERF_ULIMIT_NOFILE:-off}"
SANITY_CURL_MAX_TIME_SECS="${EXP1_SANITY_CURL_MAX_TIME_SECS:-5}"
SSH_RETRIES="${EXP1_SSH_RETRIES:-4}"
SSH_RETRY_DELAY_SECS="${EXP1_SSH_RETRY_DELAY_SECS:-2}"
SSH_RECOVER_WAIT_SECS="${EXP1_SSH_RECOVER_WAIT_SECS:-20}"

PLOT_SCRIPT="${SCRIPT_DIR}/plot.py"

SSH_OPTS=(
	-o UserKnownHostsFile=/dev/null
	-o StrictHostKeyChecking=no
	-o ConnectTimeout=5
	-o LogLevel=ERROR
	-o ServerAliveInterval=5
	-o ServerAliveCountMax=3
	-o ControlMaster=auto
	-o ControlPersist=120
	-o ControlPath=/tmp/exp1-ssh-%C
)

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
RESULT_DIR=""
RUN_KIND=""
RUN_RESULT_DIRS=()
RUN_KINDS=()
VMS_STARTED=0
KATRAN_ACTIVE=0
PROGRESS_TOTAL_STEPS=0
PROGRESS_DONE_STEPS=0
PROGRESS_START_TS=0
PROGRESS_EXPECTED_TOTAL_SECS=0
PROGRESS_USE_TTY=0
RUN_WRK=0
RUN_WRK2=0
RUN_HTTPERF=0
HTTPERF_CLIENT_VM_LIST=()
ACTIVE_CLIENT_VMS=()
ACTIVE_VMS=()
SANITY_CLIENT_VM="vm2"

usage() {
	cat <<EOF_USAGE
Usage: $(basename "$0") [options]

Run Experiment 1:
  - direct-nginx baseline (client vm(s) -> vm1 nginx)
  - vanilla-katran baseline (client vm(s) -> vm1 katran vip -> vm1 nginx)

Modes:
  --mode direct|katran|both   (default: ${MODE})
  --workloads wrk|wrk2|httperf|both|all (default: ${WORKLOADS}; both=wrk+wrk2, all=wrk+wrk2+httperf)

Options:
  --results-base <path>       Base output directory (default: ${RESULTS_BASE})
  --keep-vms                  Keep dual VMs running after script exits
  --skip-install              Skip apt package install on VMs
  --no-plot                   Skip plot generation

  --wrk-connections "<list>" Space-separated list (default: "${WRK_CONNECTIONS}")
  --wrk-threads <n>           wrk thread count (default: ${WRK_THREADS})
  --wrk-warmup <sec>          wrk warmup seconds (default: ${WRK_WARMUP})
  --wrk-duration <sec>        wrk measure seconds (default: ${WRK_DURATION})
  --wrk-repeats <n>           wrk repeats per point (default: ${WRK_REPEATS})
  --wrk2-rates "<list>"       Space-separated target rates req/s (default: "${WRK2_RATES}")
  --wrk2-threads <n>          wrk2 thread count (default: ${WRK2_THREADS})
  --wrk2-connections <n>      wrk2 connection count (default: ${WRK2_CONNECTIONS})
  --wrk2-warmup <sec>         wrk2 warmup seconds (default: ${WRK2_WARMUP})
  --wrk2-duration <sec>       wrk2 measure seconds (default: ${WRK2_DURATION})
  --wrk2-repeats <n>          wrk2 repeats per point (default: ${WRK2_REPEATS})
  --wrk2-bin <name/path>      wrk2 command in client VM (default: ${WRK2_BIN})
  --wrk2-auto-build <0|1>     Build wrk2 in client VM if missing (default: ${WRK2_AUTO_BUILD})
  --httperf-rates "<list>"    Space-separated offered rates req/s (default: "${HTTPERF_RATES}")
  --httperf-warmup <sec>      httperf warmup seconds (default: ${HTTPERF_WARMUP})
  --httperf-duration <sec>    httperf measure seconds (default: ${HTTPERF_DURATION})
  --httperf-repeats <n>       httperf repeats per point (default: ${HTTPERF_REPEATS})
  --httperf-timeout <sec>     httperf timeout seconds (default: ${HTTPERF_TIMEOUT})
  --httperf-client-vms "<list>" Space-separated client VMs for httperf (default: "${HTTPERF_CLIENT_VMS}", allowed: vm2 vm3 vm4)
  --httperf-workers-per-vm <n> Parallel httperf worker processes per client VM (default: ${HTTPERF_WORKERS_PER_VM})
  --httperf-ulimit-nofile <n|off> Set client-side nofile before each httperf run (default: ${HTTPERF_ULIMIT_NOFILE})

  --nginx-cpuset <spec>       vm1 nginx pinning (default: ${NGINX_CPUSET}; use 'off')
  --wrk-cpuset <spec>         vm2 wrk pinning (default: ${WRK_CPUSET}; use 'off')
  --wrk2-cpuset <spec>        vm2 wrk2 pinning (default: ${WRK2_CPUSET}; use 'off')
  --httperf-cpuset <spec>     httperf client vm(s) pinning (default: ${HTTPERF_CPUSET}; use 'off')
  --katran-cpuset <spec>      vm1 katran pinning (default: ${KATRAN_CPUSET}; use 'off')

  --katran-vip <ipv4>         VIP for Katran mode (default: ${KATRAN_VIP})
  --katran-auto-build <0|1>   Auto-build Katran artifacts if missing (default: ${KATRAN_AUTO_BUILD})

  -h, --help                  Show this help

Examples:
  $(basename "$0") --mode direct
  $(basename "$0") --mode both --workloads both
  $(basename "$0") --mode katran --katran-vip 192.168.100.100
EOF_USAGE
}

log() {
	echo "[exp1] $*"
}

fail() {
	echo "[exp1][error] $*" >&2
	exit 1
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

is_pos_int() {
	local value="$1"
	[[ "${value}" =~ ^[0-9]+$ ]] && [ "${value}" -gt 0 ]
}

is_bool_01() {
	case "$1" in
		0|1) return 0 ;;
		*) return 1 ;;
	esac
}

is_cpuset_spec() {
	local value="$1"
	[[ "${value}" =~ ^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$ ]]
}

is_cpuset_or_off() {
	local value="$1"
	[ "${value}" = "off" ] || is_cpuset_spec "${value}"
}

is_host_cpuset_mode() {
	local value="$1"
	[ "${value}" = "auto" ] || [ "${value}" = "off" ] || is_cpuset_spec "${value}"
}

is_vm_name() {
	case "$1" in
		vm1|vm2|vm3|vm4) return 0 ;;
		*) return 1 ;;
	esac
}

is_client_vm_name() {
	case "$1" in
		vm2|vm3|vm4) return 0 ;;
		*) return 1 ;;
	esac
}

normalize_vm_list() {
	local raw_list="$1"
	local allow_server="${2:-0}"
	local out=()
	local item
	for item in ${raw_list}; do
		if [ "${allow_server}" -eq 1 ]; then
			is_vm_name "${item}" || fail "invalid VM name '${item}' in list '${raw_list}' (allowed: vm1 vm2 vm3 vm4)"
		else
			is_client_vm_name "${item}" || fail "invalid client VM '${item}' in list '${raw_list}' (allowed: vm2 vm3 vm4)"
		fi
		if [[ " ${out[*]} " != *" ${item} "* ]]; then
			out+=("${item}")
		fi
	done
	[ "${#out[@]}" -gt 0 ] || fail "empty VM list is not allowed"
	printf '%s\n' "${out[@]}"
}

list_contains_word() {
	local needle="$1"
	shift || true
	local item
	for item in "$@"; do
		if [ "${item}" = "${needle}" ]; then
			return 0
		fi
	done
	return 1
}

is_ipv4() {
	local ip="$1"
	[[ "${ip}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
	awk -F. '
		{
			for (i = 1; i <= 4; i++) {
				if ($i < 0 || $i > 255) {
					exit 1
				}
			}
		}
	' <<<"${ip}"
}

validate_mode() {
	case "${MODE}" in
		direct|katran|both) ;;
		*) fail "--mode must be one of: direct, katran, both (got '${MODE}')" ;;
	esac
}

validate_workloads() {
	case "${WORKLOADS}" in
		wrk|wrk2|httperf|both|all) ;;
		*) fail "--workloads must be one of: wrk, wrk2, httperf, both, all (got '${WORKLOADS}')" ;;
	esac
}

resolve_workloads() {
	RUN_WRK=0
	RUN_WRK2=0
	RUN_HTTPERF=0
	case "${WORKLOADS}" in
		wrk)
			RUN_WRK=1
			;;
		wrk2)
			RUN_WRK2=1
			;;
		httperf)
			RUN_HTTPERF=1
			;;
		both)
			RUN_WRK=1
			RUN_WRK2=1
			;;
		all)
			RUN_WRK=1
			RUN_WRK2=1
			RUN_HTTPERF=1
			;;
	esac
}

resolve_vm_topology() {
	HTTPERF_CLIENT_VM_LIST=()
	ACTIVE_CLIENT_VMS=()
	ACTIVE_VMS=("vm1")
	SANITY_CLIENT_VM="vm2"

	if [ "${RUN_HTTPERF}" -eq 1 ]; then
		local vm
		while IFS= read -r vm; do
			[ -n "${vm}" ] || continue
			HTTPERF_CLIENT_VM_LIST+=("${vm}")
		done < <(normalize_vm_list "${HTTPERF_CLIENT_VMS}" 0)
		[ "${#HTTPERF_CLIENT_VM_LIST[@]}" -gt 0 ] || fail "httperf requires at least one client VM"
	fi

	if [ "${RUN_WRK}" -eq 1 ]; then
		ACTIVE_CLIENT_VMS+=("vm2")
	fi
	if [ "${RUN_WRK2}" -eq 1 ]; then
		if [[ " ${ACTIVE_CLIENT_VMS[*]} " != *" vm2 "* ]]; then
			ACTIVE_CLIENT_VMS+=("vm2")
		fi
	fi

	if [ "${RUN_HTTPERF}" -eq 1 ]; then
		local client_vm
		for client_vm in "${HTTPERF_CLIENT_VM_LIST[@]}"; do
			if [[ " ${ACTIVE_CLIENT_VMS[*]} " != *" ${client_vm} "* ]]; then
				ACTIVE_CLIENT_VMS+=("${client_vm}")
			fi
		done
	fi

	local active_vm
	for active_vm in "${ACTIVE_CLIENT_VMS[@]}"; do
		ACTIVE_VMS+=("${active_vm}")
	done

	if [ "${RUN_WRK}" -eq 1 ]; then
		SANITY_CLIENT_VM="vm2"
	elif [ "${RUN_WRK2}" -eq 1 ]; then
		SANITY_CLIENT_VM="vm2"
	elif [ "${RUN_HTTPERF}" -eq 1 ]; then
		SANITY_CLIENT_VM="${HTTPERF_CLIENT_VM_LIST[0]}"
	fi
}

result_dir_for_kind() {
	local kind="$1"
	echo "${RESULTS_BASE}/${RUN_ID}-${kind}"
}

resolve_vm_path_to_host_path() {
	local vm_path="$1"
	if [[ "${vm_path}" == /linux-dev-env/* ]]; then
		echo "${ROOT_DIR}${vm_path#/linux-dev-env}"
		return 0
	fi
	fail "Katran artifact path must be under /linux-dev-env: ${vm_path}"
}

validate_args() {
	if [ "${NGINX_CPUSET}" = "off" ]; then
		NGINX_CPUSET=""
	fi
	if [ "${WRK_CPUSET}" = "off" ]; then
		WRK_CPUSET=""
	fi
	if [ "${WRK2_CPUSET}" = "off" ]; then
		WRK2_CPUSET=""
	fi
	if [ "${HTTPERF_CPUSET}" = "off" ]; then
		HTTPERF_CPUSET=""
	fi
	if [ "${KATRAN_CPUSET}" = "off" ]; then
		KATRAN_CPUSET=""
	fi
	if [ "${HOST_VM1_CPUSET}" = "off" ]; then
		HOST_VM1_CPUSET=""
	fi
	if [ "${HOST_VM2_CPUSET}" = "off" ]; then
		HOST_VM2_CPUSET=""
	fi
	if [ "${HOST_VM3_CPUSET}" = "off" ]; then
		HOST_VM3_CPUSET=""
	fi
	if [ "${HOST_VM4_CPUSET}" = "off" ]; then
		HOST_VM4_CPUSET=""
	fi

	for value in \
		"${WRK_THREADS}" "${WRK_WARMUP}" "${WRK_DURATION}" "${WRK_REPEATS}" \
		"${WRK2_THREADS}" "${WRK2_CONNECTIONS}" "${WRK2_WARMUP}" "${WRK2_DURATION}" "${WRK2_REPEATS}" \
		"${HTTPERF_WARMUP}" "${HTTPERF_DURATION}" "${HTTPERF_REPEATS}" "${HTTPERF_TIMEOUT}" "${HTTPERF_WORKERS_PER_VM}" \
		"${SERVER_PORT}" "${KATRAN_GRPC_PORT}" "${KATRAN_LRU_SIZE}" "${SANITY_CURL_MAX_TIME_SECS}" \
		"${SSH_RETRIES}" "${SSH_RETRY_DELAY_SECS}" "${SSH_RECOVER_WAIT_SECS}" \
		"${HOST_VM1_MEMORY_MB}" "${HOST_VM2_MEMORY_MB}" "${HOST_VM3_MEMORY_MB}" "${HOST_VM4_MEMORY_MB}" \
		"${HOST_VM1_VCPUS}" "${HOST_VM2_VCPUS}" "${HOST_VM3_VCPUS}" "${HOST_VM4_VCPUS}"; do
		is_pos_int "${value}" || fail "expected positive integer, got '${value}'"
	done
	if [ "${HTTPERF_ULIMIT_NOFILE}" = "off" ]; then
		HTTPERF_ULIMIT_NOFILE=""
	fi
	if [ -n "${HTTPERF_ULIMIT_NOFILE}" ] && ! is_pos_int "${HTTPERF_ULIMIT_NOFILE}"; then
		fail "HTTPERF_ULIMIT_NOFILE must be positive integer or off (got '${HTTPERF_ULIMIT_NOFILE}')"
	fi

	case "${PLOT_ENABLED}" in
		0|1) ;;
		*) fail "PLOT flag must be 0 or 1 (got '${PLOT_ENABLED}')" ;;
	esac

	case "${ARCHIVE_OLD}" in
		0|1) ;;
		*) fail "ARCHIVE flag must be 0 or 1 (got '${ARCHIVE_OLD}')" ;;
	esac

	is_bool_01 "${KATRAN_AUTO_BUILD}" || fail "KATRAN_AUTO_BUILD must be 0 or 1"
	is_bool_01 "${WRK2_AUTO_BUILD}" || fail "WRK2_AUTO_BUILD must be 0 or 1"
	validate_mode
	validate_workloads

	local wrk2_rate_count=0
	local rate=""
	for rate in ${WRK2_RATES}; do
		is_pos_int "${rate}" || fail "wrk2 target rate must be positive integer: ${rate}"
		wrk2_rate_count=$((wrk2_rate_count + 1))
	done
	[ "${wrk2_rate_count}" -gt 0 ] || fail "WRK2_RATES must contain at least one target rate"

	local httperf_rate_count=0
	rate=""
	for rate in ${HTTPERF_RATES}; do
		is_pos_int "${rate}" || fail "httperf offered rate must be positive integer: ${rate}"
		httperf_rate_count=$((httperf_rate_count + 1))
	done
	[ "${httperf_rate_count}" -gt 0 ] || fail "HTTPERF_RATES must contain at least one offered rate"

	if [ -n "${NGINX_CPUSET}" ] && ! is_cpuset_or_off "${NGINX_CPUSET}"; then
		fail "invalid --nginx-cpuset '${NGINX_CPUSET}' (expected format like 0-3,8-11)"
	fi
	if [ -n "${WRK_CPUSET}" ] && ! is_cpuset_or_off "${WRK_CPUSET}"; then
		fail "invalid --wrk-cpuset '${WRK_CPUSET}' (expected format like 0-3,8-11)"
	fi
	if [ -n "${WRK2_CPUSET}" ] && ! is_cpuset_or_off "${WRK2_CPUSET}"; then
		fail "invalid --wrk2-cpuset '${WRK2_CPUSET}' (expected format like 0-3,8-11)"
	fi
	if [ -n "${HTTPERF_CPUSET}" ] && ! is_cpuset_or_off "${HTTPERF_CPUSET}"; then
		fail "invalid --httperf-cpuset '${HTTPERF_CPUSET}' (expected format like 0-3,8-11)"
	fi
	if [ -n "${KATRAN_CPUSET}" ] && ! is_cpuset_or_off "${KATRAN_CPUSET}"; then
		fail "invalid --katran-cpuset '${KATRAN_CPUSET}' (expected format like 0-3,8-11)"
	fi
	if [ -n "${HOST_VM1_CPUSET}" ] && ! is_host_cpuset_mode "${HOST_VM1_CPUSET}"; then
		fail "invalid DUAL_VM1_HOST_CPUSET '${HOST_VM1_CPUSET}' (expected auto/off or format like 0-3,8-11)"
	fi
	if [ -n "${HOST_VM2_CPUSET}" ] && ! is_host_cpuset_mode "${HOST_VM2_CPUSET}"; then
		fail "invalid DUAL_VM2_HOST_CPUSET '${HOST_VM2_CPUSET}' (expected auto/off or format like 0-3,8-11)"
	fi
	if [ -n "${HOST_VM3_CPUSET}" ] && ! is_host_cpuset_mode "${HOST_VM3_CPUSET}"; then
		fail "invalid DUAL_VM3_HOST_CPUSET '${HOST_VM3_CPUSET}' (expected auto/off or format like 0-3,8-11)"
	fi
	if [ -n "${HOST_VM4_CPUSET}" ] && ! is_host_cpuset_mode "${HOST_VM4_CPUSET}"; then
		fail "invalid DUAL_VM4_HOST_CPUSET '${HOST_VM4_CPUSET}' (expected auto/off or format like 0-3,8-11)"
	fi
	[ -n "${WRK2_BIN}" ] || fail "WRK2_BIN must not be empty"

	local normalized_httperf_clients
	normalized_httperf_clients="$(normalize_vm_list "${HTTPERF_CLIENT_VMS}" 0 | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
	[ -n "${normalized_httperf_clients}" ] || fail "HTTPERF_CLIENT_VMS must contain at least one client VM"
	HTTPERF_CLIENT_VMS="${normalized_httperf_clients}"

	is_ipv4 "${SERVER_IP}" || fail "invalid server IPv4 address: ${SERVER_IP}"
	is_ipv4 "${KATRAN_VIP}" || fail "invalid katran VIP IPv4 address: ${KATRAN_VIP}"
	[[ "${KATRAN_DEFAULT_MAC}" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]] || fail "invalid KATRAN_DEFAULT_MAC: ${KATRAN_DEFAULT_MAC}"
	[[ "${KATRAN_FORWARDING_CORES}" =~ ^[0-9]+(,[0-9]+)*$ ]] || fail "invalid KATRAN_FORWARDING_CORES: ${KATRAN_FORWARDING_CORES}"

	resolve_vm_path_to_host_path "${KATRAN_SERVER_BIN_VM}" >/dev/null
	resolve_vm_path_to_host_path "${KATRAN_BPF_OBJ_VM}" >/dev/null
	resolve_vm_path_to_host_path "${KATRAN_GOCLIENT_BIN_VM}" >/dev/null
}

count_items() {
	local items="$1"
	local count=0
	local item
	for item in ${items}; do
		count=$((count + 1))
	done
	echo "${count}"
}

format_secs() {
	local secs="${1:-0}"
	if [ "${secs}" -lt 0 ]; then
		secs=0
	fi
	printf "%02d:%02d:%02d" $((secs / 3600)) $(((secs % 3600) / 60)) $((secs % 60))
}

plan_progress() {
	local wrk_points=0
	local wrk2_points=0
	local httperf_points=0
	if [ "${RUN_WRK}" -eq 1 ]; then
		wrk_points="$(( $(count_items "${WRK_CONNECTIONS}") * WRK_REPEATS ))"
	fi
	if [ "${RUN_WRK2}" -eq 1 ]; then
		wrk2_points="$(( $(count_items "${WRK2_RATES}") * WRK2_REPEATS ))"
	fi
	if [ "${RUN_HTTPERF}" -eq 1 ]; then
		httperf_points="$(( $(count_items "${HTTPERF_RATES}") * HTTPERF_REPEATS ))"
	fi
	PROGRESS_TOTAL_STEPS=$((wrk_points + wrk2_points + httperf_points))
	PROGRESS_EXPECTED_TOTAL_SECS=$(( \
		wrk_points * (WRK_WARMUP + WRK_DURATION) + \
		wrk2_points * (WRK2_WARMUP + WRK2_DURATION) + \
		httperf_points * (HTTPERF_WARMUP + HTTPERF_DURATION) \
	))
}

progress_init() {
	PROGRESS_DONE_STEPS=0
	PROGRESS_START_TS="$(date +%s)"
	if [ -t 1 ]; then
		PROGRESS_USE_TTY=1
	else
		PROGRESS_USE_TTY=0
	fi
}

progress_render() {
	local label="$1"
	[ "${PROGRESS_TOTAL_STEPS}" -gt 0 ] || return 0

	local now
	now="$(date +%s)"
	local elapsed=$((now - PROGRESS_START_TS))
	local pct=$((PROGRESS_DONE_STEPS * 100 / PROGRESS_TOTAL_STEPS))

	local eta=-1
	if [ "${PROGRESS_DONE_STEPS}" -gt 0 ]; then
		local avg=$((elapsed / PROGRESS_DONE_STEPS))
		eta=$((avg * (PROGRESS_TOTAL_STEPS - PROGRESS_DONE_STEPS)))
	elif [ "${PROGRESS_EXPECTED_TOTAL_SECS}" -gt 0 ]; then
		eta="${PROGRESS_EXPECTED_TOTAL_SECS}"
	fi

	local eta_str="--:--:--"
	if [ "${eta}" -ge 0 ]; then
		eta_str="$(format_secs "${eta}")"
	fi

	local line="[exp1][${RUN_KIND}] progress ${PROGRESS_DONE_STEPS}/${PROGRESS_TOTAL_STEPS} (${pct}%) elapsed $(format_secs "${elapsed}") eta ${eta_str} | ${label}"
	if [ "${PROGRESS_USE_TTY}" -eq 1 ]; then
		printf "\r%-220s" "${line}"
	else
		echo "${line}"
	fi
}

progress_step_start() {
	progress_render "$1"
}

progress_step_done() {
	PROGRESS_DONE_STEPS=$((PROGRESS_DONE_STEPS + 1))
	progress_render "$1"
}

progress_finish() {
	if [ "${PROGRESS_USE_TTY}" -eq 1 ] && [ "${PROGRESS_TOTAL_STEPS}" -gt 0 ]; then
		printf "\n"
	fi
}

resolve_run_kinds() {
	case "${MODE}" in
		direct)
			RUN_KINDS=("direct-nginx")
			;;
		katran)
			RUN_KINDS=("vanilla-katran")
			;;
		both)
			RUN_KINDS=("direct-nginx" "vanilla-katran")
			;;
	esac
}

vm_ssh_port() {
	case "$1" in
		vm1) echo "${VM1_SSH_PORT}" ;;
		vm2) echo "${VM2_SSH_PORT}" ;;
		vm3) echo "${VM3_SSH_PORT}" ;;
		vm4) echo "${VM4_SSH_PORT}" ;;
		*) fail "unknown vm name: $1" ;;
	esac
}

ssh_vm() {
	local vm="$1"
	shift
	local port
	port="$(vm_ssh_port "${vm}")"
	local attempt=1
	local rc=0
	while true; do
		ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 "$@"
		rc=$?
		if [ "${rc}" -eq 0 ]; then
			return 0
		fi
		if [ "${rc}" -ne 255 ] || [ "${attempt}" -ge "${SSH_RETRIES}" ]; then
			return "${rc}"
		fi
		log "[warn] ssh ${vm} transport reset (attempt ${attempt}/${SSH_RETRIES}); waiting for recovery"
		wait_vm_ssh "${vm}" "${SSH_RECOVER_WAIT_SECS}" || true
		sleep "${SSH_RETRY_DELAY_SECS}"
		attempt=$((attempt + 1))
	done
}

ssh_vm_script() {
	local vm="$1"
	shift
	local port
	port="$(vm_ssh_port "${vm}")"
	local script_file
	script_file="$(mktemp)"
	cat >"${script_file}"
	local attempt=1
	local rc=0
	while true; do
		ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 bash -s -- "$@" <"${script_file}"
		rc=$?
		if [ "${rc}" -eq 0 ]; then
			rm -f "${script_file}"
			return 0
		fi
		if [ "${rc}" -ne 255 ] || [ "${attempt}" -ge "${SSH_RETRIES}" ]; then
			rm -f "${script_file}"
			return "${rc}"
		fi
		log "[warn] ssh ${vm} script transport reset (attempt ${attempt}/${SSH_RETRIES}); waiting for recovery"
		wait_vm_ssh "${vm}" "${SSH_RECOVER_WAIT_SECS}" || true
		sleep "${SSH_RETRY_DELAY_SECS}"
		attempt=$((attempt + 1))
	done
}

wait_vm_ssh() {
	local vm="$1"
	local timeout_secs="$2"
	local port
	port="$(vm_ssh_port "${vm}")"
	local start_ts
	start_ts="$(date +%s)"
	while true; do
		if ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 "echo ${vm}-ssh-ok" >/dev/null 2>&1; then
			return 0
		fi
		local now
		now="$(date +%s)"
		if [ $((now - start_ts)) -ge "${timeout_secs}" ]; then
			return 1
		fi
		sleep 2
	done
}

make_dual() {
	make -C "${ROOT_DIR}" "$1" \
		DUAL_VM1_SSH_PORT="${VM1_SSH_PORT}" \
		DUAL_VM1_NET_PORT="${VM1_NET_PORT}" \
		DUAL_VM1_GDB_PORT="${VM1_GDB_PORT}" \
		DUAL_VM2_SSH_PORT="${VM2_SSH_PORT}" \
		DUAL_VM2_NET_PORT="${VM2_NET_PORT}" \
		DUAL_VM2_GDB_PORT="${VM2_GDB_PORT}" \
		DUAL_VM3_SSH_PORT="${VM3_SSH_PORT}" \
		DUAL_VM3_NET_PORT="${VM3_NET_PORT}" \
		DUAL_VM3_GDB_PORT="${VM3_GDB_PORT}" \
		DUAL_VM4_SSH_PORT="${VM4_SSH_PORT}" \
		DUAL_VM4_NET_PORT="${VM4_NET_PORT}" \
		DUAL_VM4_GDB_PORT="${VM4_GDB_PORT}" \
		DUAL_VM1_HOST_CPUSET="${HOST_VM1_CPUSET}" \
		DUAL_VM2_HOST_CPUSET="${HOST_VM2_CPUSET}" \
		DUAL_VM3_HOST_CPUSET="${HOST_VM3_CPUSET}" \
		DUAL_VM4_HOST_CPUSET="${HOST_VM4_CPUSET}" \
		DUAL_VM1_MEMORY_MB="${HOST_VM1_MEMORY_MB}" \
		DUAL_VM2_MEMORY_MB="${HOST_VM2_MEMORY_MB}" \
		DUAL_VM3_MEMORY_MB="${HOST_VM3_MEMORY_MB}" \
		DUAL_VM4_MEMORY_MB="${HOST_VM4_MEMORY_MB}" \
		DUAL_VM1_VCPUS="${HOST_VM1_VCPUS}" \
		DUAL_VM2_VCPUS="${HOST_VM2_VCPUS}" \
		DUAL_VM3_VCPUS="${HOST_VM3_VCPUS}" \
		DUAL_VM4_VCPUS="${HOST_VM4_VCPUS}"
}

cleanup_katran_vm1() {
	if [ "${VMS_STARTED}" -ne 1 ]; then
		return 0
	fi
	ssh_vm_script vm1 "${KATRAN_VIP}" <<'EOF_VM1_KATRAN_CLEANUP'
set -euo pipefail
katran_vip="$1"
if [ -f /run/exp1-katran.pid ]; then
	pid="$(cat /run/exp1-katran.pid || true)"
	if [ -n "${pid}" ] && kill -0 "${pid}" >/dev/null 2>&1; then
		kill "${pid}" >/dev/null 2>&1 || true
		sleep 1
		kill -9 "${pid}" >/dev/null 2>&1 || true
	fi
	rm -f /run/exp1-katran.pid
fi
pkill -x katran_server_grpc >/dev/null 2>&1 || true
iface="$(ip -o link | grep -i '52:54:00:aa:00:11' | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"
if [ -n "${iface}" ]; then
	ip -force link set dev "${iface}" xdp off >/dev/null 2>&1 || true
	ip link set dev "${iface}" xdpgeneric off >/dev/null 2>&1 || true
fi
ip addr del "${katran_vip}/32" dev lo >/dev/null 2>&1 || true
EOF_VM1_KATRAN_CLEANUP
	KATRAN_ACTIVE=0
}

cleanup() {
	if [ "${KATRAN_ACTIVE}" -eq 1 ]; then
		cleanup_katran_vm1 || true
	fi
	if [ "${VMS_STARTED}" -ne 1 ]; then
		return 0
	fi
	if [ "${KEEP_VMS}" -eq 1 ]; then
		log "--keep-vms enabled, leaving dual VMs running"
		return 0
	fi
	log "stopping dual VMs"
	make_dual dual-vm-stop >/dev/null 2>&1 || true
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--results-base)
				[ $# -gt 1 ] || fail "--results-base requires a value"
				RESULTS_BASE="$2"
				shift 2
				;;
			--mode)
				[ $# -gt 1 ] || fail "--mode requires a value"
				MODE="$2"
				shift 2
				;;
			--workloads)
				[ $# -gt 1 ] || fail "--workloads requires a value"
				WORKLOADS="$2"
				shift 2
				;;
			--keep-vms)
				KEEP_VMS=1
				shift
				;;
			--skip-install)
				SKIP_INSTALL=1
				shift
				;;
			--no-plot)
				PLOT_ENABLED=0
				shift
				;;
			--wrk-connections)
				[ $# -gt 1 ] || fail "--wrk-connections requires a value"
				WRK_CONNECTIONS="$2"
				shift 2
				;;
			--wrk-threads)
				[ $# -gt 1 ] || fail "--wrk-threads requires a value"
				WRK_THREADS="$2"
				shift 2
				;;
			--wrk-warmup)
				[ $# -gt 1 ] || fail "--wrk-warmup requires a value"
				WRK_WARMUP="$2"
				shift 2
				;;
			--wrk-duration)
				[ $# -gt 1 ] || fail "--wrk-duration requires a value"
				WRK_DURATION="$2"
				shift 2
				;;
			--wrk-repeats)
				[ $# -gt 1 ] || fail "--wrk-repeats requires a value"
				WRK_REPEATS="$2"
				shift 2
				;;
			--wrk2-rates)
				[ $# -gt 1 ] || fail "--wrk2-rates requires a value"
				WRK2_RATES="$2"
				shift 2
				;;
			--wrk2-threads)
				[ $# -gt 1 ] || fail "--wrk2-threads requires a value"
				WRK2_THREADS="$2"
				shift 2
				;;
			--wrk2-connections)
				[ $# -gt 1 ] || fail "--wrk2-connections requires a value"
				WRK2_CONNECTIONS="$2"
				shift 2
				;;
			--wrk2-warmup)
				[ $# -gt 1 ] || fail "--wrk2-warmup requires a value"
				WRK2_WARMUP="$2"
				shift 2
				;;
			--wrk2-duration)
				[ $# -gt 1 ] || fail "--wrk2-duration requires a value"
				WRK2_DURATION="$2"
				shift 2
				;;
			--wrk2-repeats)
				[ $# -gt 1 ] || fail "--wrk2-repeats requires a value"
				WRK2_REPEATS="$2"
				shift 2
				;;
			--wrk2-bin)
				[ $# -gt 1 ] || fail "--wrk2-bin requires a value"
				WRK2_BIN="$2"
				shift 2
				;;
			--wrk2-auto-build)
				[ $# -gt 1 ] || fail "--wrk2-auto-build requires a value"
				WRK2_AUTO_BUILD="$2"
				shift 2
				;;
			--httperf-rates)
				[ $# -gt 1 ] || fail "--httperf-rates requires a value"
				HTTPERF_RATES="$2"
				shift 2
				;;
			--httperf-warmup)
				[ $# -gt 1 ] || fail "--httperf-warmup requires a value"
				HTTPERF_WARMUP="$2"
				shift 2
				;;
			--httperf-duration)
				[ $# -gt 1 ] || fail "--httperf-duration requires a value"
				HTTPERF_DURATION="$2"
				shift 2
				;;
			--httperf-repeats)
				[ $# -gt 1 ] || fail "--httperf-repeats requires a value"
				HTTPERF_REPEATS="$2"
				shift 2
				;;
			--httperf-timeout)
				[ $# -gt 1 ] || fail "--httperf-timeout requires a value"
				HTTPERF_TIMEOUT="$2"
				shift 2
				;;
			--httperf-client-vms)
				[ $# -gt 1 ] || fail "--httperf-client-vms requires a value"
				HTTPERF_CLIENT_VMS="$2"
				shift 2
				;;
			--httperf-workers-per-vm)
				[ $# -gt 1 ] || fail "--httperf-workers-per-vm requires a value"
				HTTPERF_WORKERS_PER_VM="$2"
				shift 2
				;;
			--httperf-ulimit-nofile)
				[ $# -gt 1 ] || fail "--httperf-ulimit-nofile requires a value"
				HTTPERF_ULIMIT_NOFILE="$2"
				shift 2
				;;
			--nginx-cpuset)
				[ $# -gt 1 ] || fail "--nginx-cpuset requires a value"
				NGINX_CPUSET="$2"
				shift 2
				;;
			--wrk-cpuset)
				[ $# -gt 1 ] || fail "--wrk-cpuset requires a value"
				WRK_CPUSET="$2"
				shift 2
				;;
			--wrk2-cpuset)
				[ $# -gt 1 ] || fail "--wrk2-cpuset requires a value"
				WRK2_CPUSET="$2"
				shift 2
				;;
			--httperf-cpuset)
				[ $# -gt 1 ] || fail "--httperf-cpuset requires a value"
				HTTPERF_CPUSET="$2"
				shift 2
				;;
			--katran-cpuset)
				[ $# -gt 1 ] || fail "--katran-cpuset requires a value"
				KATRAN_CPUSET="$2"
				shift 2
				;;
			--katran-vip)
				[ $# -gt 1 ] || fail "--katran-vip requires a value"
				KATRAN_VIP="$2"
				shift 2
				;;
			--katran-auto-build)
				[ $# -gt 1 ] || fail "--katran-auto-build requires a value"
				KATRAN_AUTO_BUILD="$2"
				shift 2
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				fail "unknown option: $1"
				;;
		esac
	done
}

write_run_config() {
	local target_ip="$1"
	mkdir -p "${RESULT_DIR}/metadata" "${RESULT_DIR}/raw"
	cat >"${RESULT_DIR}/metadata/run-config.env" <<EOF_CONFIG
run_id=${RUN_ID}
run_kind=${RUN_KIND}
mode=${MODE}
workloads=${WORKLOADS}
keep_vms=${KEEP_VMS}
skip_install=${SKIP_INSTALL}
plot_enabled=${PLOT_ENABLED}
archive_old=${ARCHIVE_OLD}
server_ip=${SERVER_IP}
server_port=${SERVER_PORT}
server_file=${SERVER_FILE}
katran_vip=${KATRAN_VIP}
katran_grpc_port=${KATRAN_GRPC_PORT}
katran_default_mac=${KATRAN_DEFAULT_MAC}
katran_forwarding_cores=${KATRAN_FORWARDING_CORES}
katran_lru_size=${KATRAN_LRU_SIZE}
katran_cpuset=${KATRAN_CPUSET}
katran_server_bin_vm=${KATRAN_SERVER_BIN_VM}
katran_bpf_obj_vm=${KATRAN_BPF_OBJ_VM}
katran_goclient_bin_vm=${KATRAN_GOCLIENT_BIN_VM}
katran_lib_dirs=${KATRAN_LIB_DIRS}
katran_auto_build=${KATRAN_AUTO_BUILD}
katran_required_bpf_define=${KATRAN_REQUIRED_BPF_DEFINE}
wrk_threads=${WRK_THREADS}
wrk_connections=${WRK_CONNECTIONS}
wrk_warmup=${WRK_WARMUP}
wrk_duration=${WRK_DURATION}
wrk_repeats=${WRK_REPEATS}
wrk2_threads=${WRK2_THREADS}
wrk2_connections=${WRK2_CONNECTIONS}
wrk2_rates=${WRK2_RATES}
wrk2_warmup=${WRK2_WARMUP}
wrk2_duration=${WRK2_DURATION}
wrk2_repeats=${WRK2_REPEATS}
wrk2_bin=${WRK2_BIN}
wrk2_auto_build=${WRK2_AUTO_BUILD}
httperf_rates=${HTTPERF_RATES}
httperf_warmup=${HTTPERF_WARMUP}
httperf_duration=${HTTPERF_DURATION}
httperf_repeats=${HTTPERF_REPEATS}
httperf_timeout=${HTTPERF_TIMEOUT}
httperf_client_vms=${HTTPERF_CLIENT_VMS}
httperf_workers_per_vm=${HTTPERF_WORKERS_PER_VM}
httperf_ulimit_nofile=${HTTPERF_ULIMIT_NOFILE:-off}
httperf_active_clients=${HTTPERF_CLIENT_VM_LIST[*]:-}
sanity_curl_max_time_secs=${SANITY_CURL_MAX_TIME_SECS}
ssh_retries=${SSH_RETRIES}
ssh_retry_delay_secs=${SSH_RETRY_DELAY_SECS}
ssh_recover_wait_secs=${SSH_RECOVER_WAIT_SECS}
nginx_cpuset=${NGINX_CPUSET}
wrk_cpuset=${WRK_CPUSET}
wrk2_cpuset=${WRK2_CPUSET}
httperf_cpuset=${HTTPERF_CPUSET}
host_vm1_cpuset=${HOST_VM1_CPUSET}
host_vm2_cpuset=${HOST_VM2_CPUSET}
host_vm3_cpuset=${HOST_VM3_CPUSET}
host_vm4_cpuset=${HOST_VM4_CPUSET}
host_vm1_memory_mb=${HOST_VM1_MEMORY_MB}
host_vm2_memory_mb=${HOST_VM2_MEMORY_MB}
host_vm3_memory_mb=${HOST_VM3_MEMORY_MB}
host_vm4_memory_mb=${HOST_VM4_MEMORY_MB}
host_vm1_vcpus=${HOST_VM1_VCPUS}
host_vm2_vcpus=${HOST_VM2_VCPUS}
host_vm3_vcpus=${HOST_VM3_VCPUS}
host_vm4_vcpus=${HOST_VM4_VCPUS}
vm1_ssh_port=${VM1_SSH_PORT}
vm2_ssh_port=${VM2_SSH_PORT}
vm3_ssh_port=${VM3_SSH_PORT}
vm4_ssh_port=${VM4_SSH_PORT}
wrk_target_ip=${target_ip}
httperf_target_ip=${target_ip}
sanity_client_vm=${SANITY_CLIENT_VM}
EOF_CONFIG
	git -C "${ROOT_DIR}" rev-parse HEAD >"${RESULT_DIR}/metadata/git-head.txt"
}

start_vms() {
	log "resetting any previous dual-vm session"
	make_dual dual-vm-stop >/dev/null 2>&1 || true
	VMS_STARTED=1
	local vm
	local target
	for vm in "${ACTIVE_VMS[@]}"; do
		case "${vm}" in
			vm1) target="dual-vm1" ;;
			vm2) target="dual-vm2" ;;
			vm3) target="dual-vm3" ;;
			vm4) target="dual-vm4" ;;
			*) fail "unsupported VM in active set: ${vm}" ;;
		esac
		log "starting ${vm}"
		make_dual "${target}"
	done
}

prepare_server_vm1() {
	log "[${RUN_KIND}] preparing vm1 server (nginx)"
	ssh_vm_script vm1 "${SERVER_PORT}" "${SERVER_FILE}" "${SKIP_INSTALL}" "${NGINX_CPUSET}" <<'EOF_VM1'
set -euo pipefail

server_port="$1"
server_file="$2"
skip_install="$3"
nginx_cpuset="$4"

ensure_packages() {
	missing=()
	for pkg in "$@"; do
		if ! dpkg -s "${pkg}" >/dev/null 2>&1; then
			missing+=("${pkg}")
		fi
	done
	if [ "${#missing[@]}" -gt 0 ]; then
		reclaim_disk_space
		recover_dpkg_state
		export DEBIAN_FRONTEND=noninteractive
		apt_log="/tmp/exp1-apt-install.log"
		echo "installing packages: ${missing[*]}" >&2
		if ! apt-get update -qq >"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		if ! apt-get install -y -qq "${missing[@]}" >>"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		apt-get clean >/dev/null 2>&1 || true
		rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb >/dev/null 2>&1 || true
	fi
}

reclaim_disk_space() {
	mkdir -p /var/log/nginx /var/log/apt /var/cache/apt/archives/partial /var/lib/apt/lists/partial
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/exp1-* >/dev/null 2>&1 || true
	find /var/log -type f \( -name '*.gz' -o -regex '.*\.[0-9]$' -o -name '*.old' \) -delete >/dev/null 2>&1 || true
	journalctl --rotate >/dev/null 2>&1 || true
	journalctl --vacuum-time=1s >/dev/null 2>&1 || true
	for f in \
		/var/log/dpkg.log \
		/var/log/apt/history.log \
		/var/log/apt/term.log \
		/var/log/syslog \
		/var/log/kern.log \
		/var/log/auth.log \
		/var/log/nginx/access.log \
		/var/log/nginx/error.log \
		/var/log/nginx/exp1_access.log \
		/var/log/nginx/exp1_error.log; do
		[ -f "${f}" ] && : >"${f}" || true
	done
}

recover_dpkg_state() {
	dpkg --configure -a >/dev/null 2>&1 || true
}

reclaim_disk_space
if [ "${skip_install}" -ne 1 ]; then
	ensure_packages nginx curl iproute2 util-linux
fi

mkdir -p /var/www/html
mkdir -p /var/log/nginx
touch /var/log/nginx/error.log /var/log/nginx/access.log
touch /var/log/nginx/exp1_error.log /var/log/nginx/exp1_access.log
: >/var/log/nginx/error.log
: >/var/log/nginx/access.log
: >/var/log/nginx/exp1_error.log
: >/var/log/nginx/exp1_access.log
head -c 1024 /dev/zero | tr '\0' 'A' >"/var/www/html/${server_file}"

cat >/etc/nginx/conf.d/exp1.conf <<CONF
server {
	listen ${server_port};
	server_name _;
	access_log off;
	error_log /var/log/nginx/exp1_error.log warn;

	location = /healthz {
		add_header Content-Type text/plain;
		return 200 "ok\\n";
	}

	location / {
		root /var/www/html;
	}
}
CONF

rm -f /etc/nginx/sites-enabled/default
nginx -t
nginx -s stop >/dev/null 2>&1 || true
if [ -n "${nginx_cpuset}" ]; then
	command -v taskset >/dev/null 2>&1 || { echo "taskset missing in vm1 but nginx pinning requested" >&2; exit 1; }
	taskset -c "${nginx_cpuset}" nginx
else
	nginx
fi
curl -fsS "http://127.0.0.1:${server_port}/healthz" >/dev/null
EOF_VM1
}

prepare_client_vm() {
	local vm="$1"
	local run_wrk_vm="$2"
	local run_httperf_vm="$3"
	local run_wrk2_vm="$4"
	log "preparing ${vm} client tools"
	local packages=(curl iproute2 wrk httperf util-linux)

	ssh_vm_script "${vm}" "${SKIP_INSTALL}" "${run_wrk_vm}" "${run_httperf_vm}" "${run_wrk2_vm}" "${WRK_CPUSET}" "${HTTPERF_CPUSET}" "${WRK2_CPUSET}" "${WRK2_BIN}" "${WRK2_AUTO_BUILD}" "${vm}" "${packages[@]}" <<'EOF_VM2'
set -euo pipefail

skip_install="$1"
run_wrk="$2"
run_httperf="$3"
run_wrk2="$4"
wrk_cpuset="$5"
httperf_cpuset="$6"
wrk2_cpuset="$7"
wrk2_bin="$8"
wrk2_auto_build="$9"
vm_name="${10}"
shift 10

ensure_packages() {
	missing=()
	for pkg in "$@"; do
		if ! dpkg -s "${pkg}" >/dev/null 2>&1; then
			missing+=("${pkg}")
		fi
	done
	if [ "${#missing[@]}" -gt 0 ]; then
		reclaim_disk_space
		recover_dpkg_state
		export DEBIAN_FRONTEND=noninteractive
		apt_log="/tmp/exp1-apt-install.log"
		echo "installing packages: ${missing[*]}" >&2
		if ! apt-get update -qq >"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		if ! apt-get install -y -qq "${missing[@]}" >>"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		apt-get clean >/dev/null 2>&1 || true
		rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb >/dev/null 2>&1 || true
	fi
}

reclaim_disk_space() {
	mkdir -p /var/log/apt /var/cache/apt/archives/partial /var/lib/apt/lists/partial
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/exp1-* >/dev/null 2>&1 || true
	find /var/log -type f \( -name '*.gz' -o -regex '.*\.[0-9]$' -o -name '*.old' \) -delete >/dev/null 2>&1 || true
	journalctl --rotate >/dev/null 2>&1 || true
	journalctl --vacuum-time=1s >/dev/null 2>&1 || true
	for f in /var/log/dpkg.log /var/log/apt/history.log /var/log/apt/term.log /var/log/syslog /var/log/kern.log /var/log/auth.log; do
		[ -f "${f}" ] && : >"${f}" || true
	done
}

recover_dpkg_state() {
	dpkg --configure -a >/dev/null 2>&1 || true
}

has_rate_flag() {
	bin="$1"
	help_text="$("${bin}" --help 2>&1 || true)"
	case "${help_text}" in
		*"-R"*) return 0 ;;
		*) return 1 ;;
	esac
}

print_help_snippet() {
	bin="$1"
	help_text="$("${bin}" --help 2>&1 || true)"
	printf '%s\n' "${help_text}" | sed -n '1,40p' >&2
}

if [ "${skip_install}" -ne 1 ]; then
	reclaim_disk_space
	ensure_packages "$@"
fi

command -v curl >/dev/null 2>&1
if [ "${run_wrk}" -eq 1 ]; then
	command -v wrk >/dev/null 2>&1
	if [ -n "${wrk_cpuset}" ]; then
		command -v taskset >/dev/null 2>&1 || { echo "taskset missing in ${vm_name} but wrk pinning requested" >&2; exit 1; }
	fi
fi
if [ "${run_httperf}" -eq 1 ]; then
	command -v httperf >/dev/null 2>&1
	if [ -n "${httperf_cpuset}" ]; then
		command -v taskset >/dev/null 2>&1 || { echo "taskset missing in ${vm_name} but httperf pinning requested" >&2; exit 1; }
	fi
fi
if [ "${run_wrk2}" -eq 1 ]; then
	need_wrk2_build=0
	if ! command -v "${wrk2_bin}" >/dev/null 2>&1; then
		if command -v wrk >/dev/null 2>&1 && has_rate_flag "wrk"; then
			ln -sf "$(command -v wrk)" /usr/local/bin/wrk2 || true
			wrk2_bin="wrk2"
		else
			need_wrk2_build=1
		fi
	fi

	if [ "${need_wrk2_build}" -ne 1 ] && command -v "${wrk2_bin}" >/dev/null 2>&1; then
		if ! has_rate_flag "${wrk2_bin}"; then
			need_wrk2_build=1
		fi
	fi

	if [ "${need_wrk2_build}" -eq 1 ]; then
		if [ "${wrk2_auto_build}" -ne 1 ]; then
			echo "wrk2 missing/invalid in ${vm_name} and WRK2_AUTO_BUILD=0; install wrk2 with -R support or set EXP1_WRK2_AUTO_BUILD=1" >&2
			exit 1
		fi
		if [ "${skip_install}" -eq 1 ]; then
			echo "wrk2 missing/invalid in ${vm_name}; cannot auto-build with --skip-install" >&2
			exit 1
		fi
		ensure_packages build-essential git libssl-dev zlib1g-dev ca-certificates
		src_dir="/opt/exp1-wrk2"
		build_log="/tmp/exp1-wrk2-build.log"
		if [ -d "${src_dir}/.git" ]; then
			if ! git -C "${src_dir}" fetch --depth 1 origin >"${build_log}" 2>&1; then
				tail -n 80 "${build_log}" >&2 || true
				exit 1
			fi
			if ! git -C "${src_dir}" reset --hard origin/master >>"${build_log}" 2>&1; then
				tail -n 80 "${build_log}" >&2 || true
				exit 1
			fi
		else
			rm -rf "${src_dir}" >/dev/null 2>&1 || true
			if ! git clone --depth 1 https://github.com/giltene/wrk2.git "${src_dir}" >"${build_log}" 2>&1; then
				tail -n 80 "${build_log}" >&2 || true
				exit 1
			fi
		fi
		if ! make -C "${src_dir}" -j"$(nproc)" >>"${build_log}" 2>&1; then
			tail -n 80 "${build_log}" >&2 || true
			exit 1
		fi
		if ! install -m 0755 "${src_dir}/wrk" /usr/local/bin/wrk2 >>"${build_log}" 2>&1; then
			tail -n 80 "${build_log}" >&2 || true
			exit 1
		fi
		wrk2_bin="wrk2"
	fi
	command -v "${wrk2_bin}" >/dev/null 2>&1 || { echo "wrk2 binary not found in ${vm_name}: ${wrk2_bin}" >&2; exit 1; }
	if ! has_rate_flag "${wrk2_bin}"; then
		echo "wrk2 binary in ${vm_name} does not support -R: ${wrk2_bin}" >&2
		print_help_snippet "${wrk2_bin}"
		exit 1
	fi
	if [ -n "${wrk2_cpuset}" ]; then
		command -v taskset >/dev/null 2>&1 || { echo "taskset missing in ${vm_name} but wrk2 pinning requested" >&2; exit 1; }
	fi
fi
EOF_VM2
}

ensure_katran_artifacts() {
	local katran_server_bin_host
	local katran_bpf_obj_host
	local katran_goclient_bin_host
	local katran_build_dir_host
	local bpf_define_marker_host
	local need_build=0
	local build_reason=""
	katran_server_bin_host="$(resolve_vm_path_to_host_path "${KATRAN_SERVER_BIN_VM}")"
	katran_bpf_obj_host="$(resolve_vm_path_to_host_path "${KATRAN_BPF_OBJ_VM}")"
	katran_goclient_bin_host="$(resolve_vm_path_to_host_path "${KATRAN_GOCLIENT_BIN_VM}")"
	katran_build_dir_host="$(dirname "$(dirname "$(dirname "$(dirname "${katran_bpf_obj_host}")")")")"
	bpf_define_marker_host="${katran_build_dir_host}/.exp1_bpf_defines"

	if [ ! -x "${katran_server_bin_host}" ] || [ ! -f "${katran_bpf_obj_host}" ] || [ ! -x "${katran_goclient_bin_host}" ]; then
		need_build=1
		build_reason="artifacts missing"
	elif [ -n "${KATRAN_REQUIRED_BPF_DEFINE}" ]; then
		if [ ! -f "${bpf_define_marker_host}" ] || ! grep -qw -- "${KATRAN_REQUIRED_BPF_DEFINE}" "${bpf_define_marker_host}"; then
			need_build=1
			build_reason="bpf missing required define '${KATRAN_REQUIRED_BPF_DEFINE}'"
		fi
	fi

	if [ "${need_build}" -eq 0 ]; then
		return 0
	fi

	if [ "${KATRAN_AUTO_BUILD}" -ne 1 ]; then
		fail "Katran artifacts missing/outdated (${build_reason}). Run: make exp1-katran-build"
	fi

	[ -x "${KATRAN_BUILD_SCRIPT}" ] || fail "katran build script missing or not executable: ${KATRAN_BUILD_SCRIPT}"
	log "Katran artifacts missing/outdated (${build_reason}); running one-time build"
	if [ -n "${KATRAN_REQUIRED_BPF_DEFINE}" ]; then
		EXP1_KATRAN_BPF_DEFINES="-D${KATRAN_REQUIRED_BPF_DEFINE}" "${KATRAN_BUILD_SCRIPT}"
	else
		"${KATRAN_BUILD_SCRIPT}"
	fi

	[ -x "${katran_server_bin_host}" ] || fail "missing katran server binary after build: ${katran_server_bin_host}"
	[ -f "${katran_bpf_obj_host}" ] || fail "missing katran bpf object after build: ${katran_bpf_obj_host}"
	[ -x "${katran_goclient_bin_host}" ] || fail "missing katran gRPC client after build: ${katran_goclient_bin_host}"
	if [ -n "${KATRAN_REQUIRED_BPF_DEFINE}" ]; then
		[ -f "${bpf_define_marker_host}" ] || fail "missing katran bpf define marker after build: ${bpf_define_marker_host}"
		grep -qw -- "${KATRAN_REQUIRED_BPF_DEFINE}" "${bpf_define_marker_host}" || \
			fail "katran bpf define marker missing '${KATRAN_REQUIRED_BPF_DEFINE}': ${bpf_define_marker_host}"
	fi
}

prepare_katran_vm1() {
	log "[${RUN_KIND}] preparing vm1 vanilla-katran"
	ssh_vm_script vm1 \
		"${SERVER_IP}" \
		"${SERVER_PORT}" \
		"${KATRAN_VIP}" \
		"${KATRAN_DEFAULT_MAC}" \
		"${KATRAN_GRPC_PORT}" \
		"${KATRAN_FORWARDING_CORES}" \
		"${KATRAN_LRU_SIZE}" \
		"${KATRAN_SERVER_BIN_VM}" \
		"${KATRAN_BPF_OBJ_VM}" \
		"${KATRAN_GOCLIENT_BIN_VM}" \
		"${KATRAN_LIB_DIRS}" \
		"${KATRAN_CPUSET}" \
		"${SKIP_INSTALL}" <<'EOF_VM1_KATRAN'
set -euo pipefail

server_ip="$1"
server_port="$2"
katran_vip="$3"
default_mac="$4"
grpc_port="$5"
forwarding_cores="$6"
lru_size="$7"
katran_server_bin="$8"
katran_bpf_obj="$9"
katran_goclient_bin="${10}"
katran_lib_dirs="${11}"
katran_cpuset="${12}"
skip_install="${13}"

ensure_packages() {
	missing=()
	for pkg in "$@"; do
		if ! dpkg -s "${pkg}" >/dev/null 2>&1; then
			missing+=("${pkg}")
		fi
	done
	if [ "${#missing[@]}" -gt 0 ]; then
		reclaim_disk_space
		recover_dpkg_state
		export DEBIAN_FRONTEND=noninteractive
		apt_log="/tmp/exp1-apt-install.log"
		echo "installing packages: ${missing[*]}" >&2
		if ! apt-get update -qq >"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		if ! apt-get install -y -qq "${missing[@]}" >>"${apt_log}" 2>&1; then
			tail -n 80 "${apt_log}" >&2 || true
			exit 1
		fi
		apt-get clean >/dev/null 2>&1 || true
		rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb >/dev/null 2>&1 || true
	fi
}

reclaim_disk_space() {
	mkdir -p /var/log/nginx /var/log/apt /var/cache/apt/archives/partial /var/lib/apt/lists/partial
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/exp1-* >/dev/null 2>&1 || true
	find /var/log -type f \( -name '*.gz' -o -regex '.*\.[0-9]$' -o -name '*.old' \) -delete >/dev/null 2>&1 || true
	journalctl --rotate >/dev/null 2>&1 || true
	journalctl --vacuum-time=1s >/dev/null 2>&1 || true
	for f in \
		/var/log/dpkg.log \
		/var/log/apt/history.log \
		/var/log/apt/term.log \
		/var/log/syslog \
		/var/log/kern.log \
		/var/log/auth.log \
		/var/log/nginx/access.log \
		/var/log/nginx/error.log \
		/var/log/nginx/exp1_access.log \
		/var/log/nginx/exp1_error.log; do
		[ -f "${f}" ] && : >"${f}" || true
	done
}

recover_dpkg_state() {
	dpkg --configure -a >/dev/null 2>&1 || true
}

if [ "${skip_install}" -ne 1 ]; then
	reclaim_disk_space
	# Runtime libs required by katran_server_grpc when running inside vm1.
	ensure_packages \
		libgoogle-glog-dev \
		libgflags-dev \
		libfmt-dev \
		libdouble-conversion-dev \
		libevent-dev \
		libboost-program-options-dev
fi

for path in "${katran_server_bin}" "${katran_goclient_bin}"; do
	[ -x "${path}" ] || { echo "missing executable: ${path}" >&2; exit 1; }
done
[ -f "${katran_bpf_obj}" ] || { echo "missing balancer.bpf.o: ${katran_bpf_obj}" >&2; exit 1; }

iface="$(ip -o link | grep -i '52:54:00:aa:00:11' | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"
[ -n "${iface}" ] || { echo "failed to detect vm1 data-plane interface" >&2; exit 1; }

if [ -f /run/exp1-katran.pid ]; then
	old_pid="$(cat /run/exp1-katran.pid || true)"
	if [ -n "${old_pid}" ] && kill -0 "${old_pid}" >/dev/null 2>&1; then
		kill "${old_pid}" >/dev/null 2>&1 || true
		sleep 1
		kill -9 "${old_pid}" >/dev/null 2>&1 || true
	fi
	rm -f /run/exp1-katran.pid
fi
pkill -x katran_server_grpc >/dev/null 2>&1 || true
ip -force link set dev "${iface}" xdp off >/dev/null 2>&1 || true
ip link set dev "${iface}" xdpgeneric off >/dev/null 2>&1 || true

modprobe ipip >/dev/null 2>&1 || true
modprobe ip6_tunnel >/dev/null 2>&1 || true
ip link add name ipip0 type ipip external >/dev/null 2>&1 || true
ip link add name ipip60 type ip6tnl external >/dev/null 2>&1 || true
if ip link show dev ipip0 >/dev/null 2>&1; then
	ip link set up dev ipip0 >/dev/null 2>&1 || true
	ip addr add 127.0.0.42/32 dev ipip0 >/dev/null 2>&1 || true
fi
if ip link show dev ipip60 >/dev/null 2>&1; then
	ip link set up dev ipip60 >/dev/null 2>&1 || true
fi
ip addr add "${katran_vip}/32" dev lo >/dev/null 2>&1 || true

for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
	echo 0 >"${f}" || true
done

export LD_LIBRARY_PATH="${katran_lib_dirs}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
katran_log="/var/log/exp1_katran_server.log"
: >"${katran_log}"

start_cmd="\"${katran_server_bin}\" -server=127.0.0.1:${grpc_port} -balancer_prog=${katran_bpf_obj} -intf=${iface} -hc_forwarding=false -default_mac=${default_mac} -forwarding_cores=${forwarding_cores} -lru_size=${lru_size}"
if [ -n "${katran_cpuset}" ]; then
	command -v taskset >/dev/null 2>&1 || { echo "taskset missing in vm1 but katran pinning requested" >&2; exit 1; }
	start_cmd="taskset -c ${katran_cpuset} ${start_cmd}"
fi

nohup bash -lc "${start_cmd}" >>"${katran_log}" 2>&1 &
katran_pid="$!"
echo "${katran_pid}" >/run/exp1-katran.pid

ready=0
for _ in $(seq 1 30); do
	if "${katran_goclient_bin}" -server "127.0.0.1:${grpc_port}" -list_mac >/tmp/exp1-katran-list-mac.log 2>&1; then
		ready=1
		break
	fi
	sleep 1
done
if [ "${ready}" -ne 1 ]; then
	tail -n 80 "${katran_log}" >&2 || true
	echo "katran gRPC server did not become ready" >&2
	exit 1
fi

"${katran_goclient_bin}" -server "127.0.0.1:${grpc_port}" -C >/tmp/exp1-katran-clear.log 2>&1 || true
"${katran_goclient_bin}" -server "127.0.0.1:${grpc_port}" -A -t "${katran_vip}:${server_port}" -vf LOCAL_VIP >/tmp/exp1-katran-add-vip.log 2>&1
"${katran_goclient_bin}" -server "127.0.0.1:${grpc_port}" -a -t "${katran_vip}:${server_port}" -r "${server_ip}" -rf LOCAL_REAL >/tmp/exp1-katran-add-real.log 2>&1
"${katran_goclient_bin}" -server "127.0.0.1:${grpc_port}" -l >/tmp/exp1-katran-list.log 2>&1
EOF_VM1_KATRAN
	KATRAN_ACTIVE=1
}

run_sanity_checks() {
	local target_ip="$1"
	local target_url="http://${target_ip}:${SERVER_PORT}/${SERVER_FILE}"
	local expected_bytes
	local payload_bytes

	log "[${RUN_KIND}] running sanity checks"
	ssh_vm "${SANITY_CLIENT_VM}" "ping -c 2 -W 2 ${target_ip} >/dev/null"

	expected_bytes="$(ssh_vm vm1 "wc -c < /var/www/html/${SERVER_FILE}" | tr -d '[:space:]')"
	[ -n "${expected_bytes}" ] || fail "sanity check failed: unable to read vm1 file size for ${SERVER_FILE}"

	payload_bytes="$(ssh_vm "${SANITY_CLIENT_VM}" "curl -fsS --connect-timeout 2 --max-time ${SANITY_CURL_MAX_TIME_SECS} ${target_url} | wc -c" | tr -d '[:space:]')" || \
		fail "sanity check failed: curl to ${target_url} timed out/failed (max ${SANITY_CURL_MAX_TIME_SECS}s)"
	[ "${payload_bytes}" = "${expected_bytes}" ] || \
		fail "sanity check failed: payload bytes mismatch for ${target_url} (got ${payload_bytes}, expected ${expected_bytes})"
	if [ "${RUN_KIND}" = "direct-nginx" ]; then
		ssh_vm "${SANITY_CLIENT_VM}" "curl -fsS --connect-timeout 2 --max-time ${SANITY_CURL_MAX_TIME_SECS} http://${SERVER_IP}:${SERVER_PORT}/healthz >/dev/null" || \
			fail "sanity check failed: direct healthz check timed out/failed (max ${SANITY_CURL_MAX_TIME_SECS}s)"
	else
		ssh_vm "${SANITY_CLIENT_VM}" "curl -fsS --connect-timeout 2 --max-time ${SANITY_CURL_MAX_TIME_SECS} http://${target_ip}:${SERVER_PORT}/healthz >/dev/null" || \
			fail "sanity check failed: katran VIP healthz timed out/failed (max ${SANITY_CURL_MAX_TIME_SECS}s)"
	fi
}

latency_to_ms() {
	local token="${1:-}"
	if [ -z "${token}" ]; then
		echo ""
		return 0
	fi
	awk -v tok="${token}" '
	function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
	BEGIN {
		tok = trim(tok)
		if (tok ~ /us$/) { sub(/us$/, "", tok); printf "%.6f", tok / 1000; exit }
		if (tok ~ /ms$/) { sub(/ms$/, "", tok); printf "%.6f", tok; exit }
		if (tok ~ /s$/)  { sub(/s$/,  "", tok); printf "%.6f", tok * 1000; exit }
		if (tok ~ /m$/)  { sub(/m$/,  "", tok); printf "%.6f", tok * 60000; exit }
		if (tok ~ /^[0-9.]+$/) { printf "%.6f", tok; exit }
		printf ""
	}'
}

extract_wrk_p99_token() {
	local raw_file="$1"
	awk '
		/^[[:space:]]*[0-9]+(\.[0-9]+)?%[[:space:]]+[0-9.]+[a-z]+/ {
			pct = $1
			gsub(/%/, "", pct)
			pct_num = pct + 0
			if (pct_num >= 99 && pct_num < 100) {
				print $2
				exit
			}
		}
	' "${raw_file}"
}

vm_cpu_stat_line() {
	local vm="$1"
	ssh_vm "${vm}" "grep '^cpu ' /proc/stat | head -n1"
}

vm_cpu_stat_line_retry() {
	local vm="$1"
	local attempts="${2:-${SSH_RETRIES}}"
	local i
	local line=""
	for i in $(seq 1 "${attempts}"); do
		line="$(vm_cpu_stat_line "${vm}" 2>/dev/null || true)"
		if [[ "${line}" =~ ^cpu[[:space:]] ]]; then
			printf '%s\n' "${line}"
			return 0
		fi
		wait_vm_ssh "${vm}" "${SSH_RECOVER_WAIT_SECS}" >/dev/null 2>&1 || true
		sleep "${SSH_RETRY_DELAY_SECS}"
	done
	return 1
}

cpu_util_pct_from_stats() {
	local before="$1"
	local after="$2"
	awk -v before="${before}" -v after="${after}" '
	function parse_cpu(line, out,     n, i, val, parts, total, idle) {
		n = split(line, parts, /[[:space:]]+/)
		total = 0
		idle = 0
		for (i = 2; i <= n; i++) {
			if (parts[i] == "") {
				continue
			}
			val = parts[i] + 0
			total += val
			if (i == 5 || i == 6) {
				idle += val
			}
		}
		out["total"] = total
		out["idle"] = idle
	}
	BEGIN {
		parse_cpu(before, b)
		parse_cpu(after, a)
		delta_total = a["total"] - b["total"]
		delta_idle = a["idle"] - b["idle"]
		if (delta_total <= 0) {
			print ""
			exit
		}
		util = (delta_total - delta_idle) * 100.0 / delta_total
		if (util < 0) {
			util = 0
		}
		if (util > 100) {
			util = 100
		}
		printf "%.6f", util
	}'
}

collect_metadata() {
	log "[${RUN_KIND}] collecting metadata"
	make_dual dual-vm-status >"${RESULT_DIR}/metadata/dual-vm-status.txt" || true
	ssh_vm vm1 "uname -a; ip -4 addr; ss -lntp | head -n 80" >"${RESULT_DIR}/metadata/vm1-system.txt"
	local client_vm
	for client_vm in "${ACTIVE_CLIENT_VMS[@]}"; do
		ssh_vm "${client_vm}" "uname -a; ip -4 addr; ss -s" >"${RESULT_DIR}/metadata/${client_vm}-system.txt"
	done

	if [ "${RUN_KIND}" = "vanilla-katran" ]; then
		ssh_vm vm1 "iface=\$(ip -o link | grep -i '52:54:00:aa:00:11' | head -n1 | awk -F': ' '{print \$2}' | sed 's/@.*//'); echo \"iface=\${iface}\"; ip -details link show dev \"\${iface}\"; ss -lntp | grep -E ':${KATRAN_GRPC_PORT}[[:space:]]' || true" >"${RESULT_DIR}/metadata/vm1-katran-runtime.txt"
		ssh_vm vm1 "cp /var/log/exp1_katran_server.log /tmp/exp1_katran_server.log.copy 2>/dev/null || true; tail -n 200 /tmp/exp1_katran_server.log.copy 2>/dev/null || true" >"${RESULT_DIR}/metadata/vm1-katran-log-tail.txt" || true
		ssh_vm vm1 "cat /tmp/exp1-katran-list.log 2>/dev/null || true" >"${RESULT_DIR}/metadata/vm1-katran-list.txt" || true
	fi
}

archive_old_runs() {
	[ "${ARCHIVE_OLD}" -eq 1 ] || return 0

	local kind="${1:-${RUN_KIND}}"
	local keep_name="${2:-$(basename "${RESULT_DIR}")}"
	[ -n "${kind}" ] || fail "archive_old_runs requires run kind"
	[ -n "${keep_name}" ] || fail "archive_old_runs requires keep directory name"

	local archive_dir="${RESULTS_BASE}/archive/${kind}"
	mkdir -p "${archive_dir}"

	local candidates=()
	mapfile -t candidates < <(find "${RESULTS_BASE}" -mindepth 1 -maxdepth 1 -type d -name "*-${kind}" -printf '%f\n' | LC_ALL=C sort)

	local archived=0
	local run_name
	for run_name in "${candidates[@]}"; do
		[ "${run_name}" = "${keep_name}" ] && continue

		local src_dir="${RESULTS_BASE}/${run_name}"
		[ -d "${src_dir}" ] || continue

		local archive_file="${archive_dir}/${run_name}.tar.gz"
		local idx=1
		while [ -e "${archive_file}" ]; do
			archive_file="${archive_dir}/${run_name}.${idx}.tar.gz"
			idx=$((idx + 1))
		done

		tar -C "${RESULTS_BASE}" -czf "${archive_file}" "${run_name}"
		rm -rf "${src_dir}"
		archived=$((archived + 1))
	done

	if [ "${archived}" -gt 0 ]; then
		log "archived ${archived} old ${kind} run(s) under ${archive_dir}"
	fi
}

generate_plots() {
	[ "${PLOT_ENABLED}" -eq 1 ] || {
		log "[${RUN_KIND}] plot generation skipped (--no-plot)"
		return 0
	}
	[ -f "${PLOT_SCRIPT}" ] || fail "plot script missing: ${PLOT_SCRIPT}"

	log "[${RUN_KIND}] generating plots"
	if ! MPLCONFIGDIR="/tmp/mplconfig-exp1-${RUN_ID}-${RUN_KIND}" \
		python3 "${PLOT_SCRIPT}" --run-dir "${RESULT_DIR}" >"${RESULT_DIR}/metadata/plot.log" 2>&1; then
		fail "plot generation failed (see ${RESULT_DIR}/metadata/plot.log)"
	fi
}

generate_compare_plot_if_needed() {
	[ "${PLOT_ENABLED}" -eq 1 ] || return 0
	[ "${MODE}" = "both" ] || return 0
	[ "${#RUN_RESULT_DIRS[@]}" -eq 2 ] || return 0

	local direct_dir="${RUN_RESULT_DIRS[0]}"
	local katran_dir="${RUN_RESULT_DIRS[1]}"
	local compare_dir="${RESULTS_BASE}/${RUN_ID}-comparison"
	mkdir -p "${compare_dir}/metadata"

	log "generating direct-vs-katran comparison plot"
	if ! MPLCONFIGDIR="/tmp/mplconfig-exp1-compare-${RUN_ID}" \
		python3 "${PLOT_SCRIPT}" \
			--compare-direct-dir "${direct_dir}" \
			--compare-katran-dir "${katran_dir}" \
			--compare-out-dir "${compare_dir}" >"${compare_dir}/metadata/plot.log" 2>&1; then
		fail "comparison plot generation failed (see ${compare_dir}/metadata/plot.log)"
	fi

	archive_old_runs "comparison" "$(basename "${compare_dir}")"
	RUN_RESULT_DIRS+=("${compare_dir}")
}

aggregate_wrk_summary() {
	local summary_csv="$1"
	local agg_csv="$2"
	awk -F, '
		NR == 1 { next }
		{
			c = $2
			count[c] += 1
			rps[c] += $4
			p99[c] += $7
			if ($10 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm1cpu[c] += $10
				vm1cnt[c] += 1
			}
			if ($11 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm2cpu[c] += $11
				vm2cnt[c] += 1
			}
		}
		END {
			print "connections,repeats,rps_mean,p99_ms_mean,vm1_cpu_util_pct_mean,vm2_cpu_util_pct_mean"
			for (c in count) {
				vm1mean = "NA"
				vm2mean = "NA"
				if (vm1cnt[c] > 0) {
					vm1mean = sprintf("%.6f", vm1cpu[c] / vm1cnt[c])
				}
				if (vm2cnt[c] > 0) {
					vm2mean = sprintf("%.6f", vm2cpu[c] / vm2cnt[c])
				}
				printf "%s,%d,%.6f,%.6f,%s,%s\n", c, count[c], rps[c] / count[c], p99[c] / count[c], vm1mean, vm2mean
			}
		}
	' "${summary_csv}" | sort -t, -k1,1n >"${agg_csv}"
}

aggregate_wrk2_summary() {
	local summary_csv="$1"
	local agg_csv="$2"
	awk -F, '
		NR == 1 { next }
		{
			r = $2
			count[r] += 1
			rps[r] += $4
			p99[r] += $7
			if ($10 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm1cpu[r] += $10
				vm1cnt[r] += 1
			}
			if ($11 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm2cpu[r] += $11
				vm2cnt[r] += 1
			}
		}
		END {
			print "target_rate,repeats,rps_mean,p99_ms_mean,vm1_cpu_util_pct_mean,vm2_cpu_util_pct_mean"
			for (r in count) {
				vm1mean = "NA"
				vm2mean = "NA"
				if (vm1cnt[r] > 0) {
					vm1mean = sprintf("%.6f", vm1cpu[r] / vm1cnt[r])
				}
				if (vm2cnt[r] > 0) {
					vm2mean = sprintf("%.6f", vm2cpu[r] / vm2cnt[r])
				}
				printf "%s,%d,%.6f,%.6f,%s,%s\n", r, count[r], rps[r] / count[r], p99[r] / count[r], vm1mean, vm2mean
			}
		}
	' "${summary_csv}" | sort -t, -k1,1n >"${agg_csv}"
}

aggregate_httperf_summary() {
	local summary_csv="$1"
	local agg_csv="$2"
	awk -F, '
		NR == 1 { next }
		{
			r = $2
			count[r] += 1
			req_rate[r] += $5
			resp_ms[r] += $7
			err_total[r] += $8
			non2xx[r] += $9
			sock_to[r] += $10
			if ($11 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm1cpu[r] += $11
				vm1cnt[r] += 1
			}
			if ($12 ~ /^[0-9]+(\.[0-9]+)?$/) {
				vm2cpu[r] += $12
				vm2cnt[r] += 1
			}
		}
		END {
			print "offered_rate,repeats,request_rate_mean,response_time_ms_mean,errors_total_mean,non2xx_mean,socket_timeouts_mean,vm1_cpu_util_pct_mean,vm2_cpu_util_pct_mean"
			for (r in count) {
				vm1mean = "NA"
				vm2mean = "NA"
				if (vm1cnt[r] > 0) {
					vm1mean = sprintf("%.6f", vm1cpu[r] / vm1cnt[r])
				}
				if (vm2cnt[r] > 0) {
					vm2mean = sprintf("%.6f", vm2cpu[r] / vm2cnt[r])
				}
				printf "%s,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%s,%s\n", \
					r, count[r], req_rate[r] / count[r], resp_ms[r] / count[r], \
					err_total[r] / count[r], non2xx[r] / count[r], sock_to[r] / count[r], vm1mean, vm2mean
			}
		}
	' "${summary_csv}" | sort -t, -k1,1n >"${agg_csv}"
}

run_wrk() {
	local target_ip="$1"
	local target_url="http://${target_ip}:${SERVER_PORT}/${SERVER_FILE}"
	local base_dir="${RESULT_DIR}/raw/wrk"
	local summary_csv="${RESULT_DIR}/wrk-summary.csv"
	local agg_csv="${RESULT_DIR}/wrk-summary-agg.csv"
	local wrk_prefix=""
	if [ -n "${WRK_CPUSET}" ]; then
		wrk_prefix="taskset -c ${WRK_CPUSET} "
	fi

	mkdir -p "${base_dir}"
	echo "timestamp,connections,repeat,requests_per_sec,latency_avg_ms,latency_stdev_ms,p99_ms,non2xx_responses,socket_timeouts,vm1_cpu_util_pct,vm2_cpu_util_pct" >"${summary_csv}"

	for conn in ${WRK_CONNECTIONS}; do
		is_pos_int "${conn}" || fail "wrk connection value must be positive integer: ${conn}"
		local conn_dir="${base_dir}/c${conn}"
		mkdir -p "${conn_dir}"
		for repeat in $(seq 1 "${WRK_REPEATS}"); do
			local run_threads="${WRK_THREADS}"
			if [ "${run_threads}" -gt "${conn}" ]; then
				run_threads="${conn}"
			fi
				local step_label="wrk c=${conn} t=${run_threads} repeat=${repeat}/${WRK_REPEATS}"
				progress_step_start "${step_label}"
				if [ "${WRK_WARMUP}" -gt 0 ]; then
					ssh_vm vm2 "${wrk_prefix}wrk -t ${run_threads} -c ${conn} -d ${WRK_WARMUP}s --latency ${target_url} >/tmp/exp1-wrk-warmup.log 2>&1 || true" || \
						fail "wrk warmup failed at c=${conn}, repeat=${repeat}"
				fi

			local raw_file="${conn_dir}/run-${repeat}.txt"
				local vm1_cpu_before
				local vm2_cpu_before
				local vm1_cpu_after
				local vm2_cpu_after
				local vm1_cpu_util
				local vm2_cpu_util
				vm1_cpu_before="$(vm_cpu_stat_line_retry vm1 || true)"
				vm2_cpu_before="$(vm_cpu_stat_line_retry vm2 || true)"
				printf '%s\n' "${vm1_cpu_before}" >"${conn_dir}/vm1-cpu-before-${repeat}.txt"
				printf '%s\n' "${vm2_cpu_before}" >"${conn_dir}/vm2-cpu-before-${repeat}.txt"
				ssh_vm vm1 "date -u +%Y-%m-%dT%H:%M:%SZ; cat /proc/loadavg" >"${conn_dir}/vm1-pre-run-${repeat}.txt" || \
					fail "failed to capture vm1 pre-run metadata (c=${conn}, repeat=${repeat})"
				ssh_vm vm2 "${wrk_prefix}wrk -t ${run_threads} -c ${conn} -d ${WRK_DURATION}s --latency ${target_url}" >"${raw_file}" || \
					fail "wrk measurement failed at c=${conn}, repeat=${repeat} (ssh/vm transient or wrk error)"
				vm1_cpu_after="$(vm_cpu_stat_line_retry vm1 || true)"
				vm2_cpu_after="$(vm_cpu_stat_line_retry vm2 || true)"
				printf '%s\n' "${vm1_cpu_after}" >"${conn_dir}/vm1-cpu-after-${repeat}.txt"
				printf '%s\n' "${vm2_cpu_after}" >"${conn_dir}/vm2-cpu-after-${repeat}.txt"
				if [ -n "${vm1_cpu_before}" ] && [ -n "${vm1_cpu_after}" ]; then
					vm1_cpu_util="$(cpu_util_pct_from_stats "${vm1_cpu_before}" "${vm1_cpu_after}")"
				else
					vm1_cpu_util=""
				fi
				if [ -n "${vm2_cpu_before}" ] && [ -n "${vm2_cpu_after}" ]; then
					vm2_cpu_util="$(cpu_util_pct_from_stats "${vm2_cpu_before}" "${vm2_cpu_after}")"
				else
					vm2_cpu_util=""
				fi
				if [ -z "${vm1_cpu_util}" ] || [ -z "${vm2_cpu_util}" ]; then
					log "[warn] cpu utilization unavailable at c=${conn}, repeat=${repeat}; recording NA"
				fi
				vm1_cpu_util="${vm1_cpu_util:-NA}"
				vm2_cpu_util="${vm2_cpu_util:-NA}"

			local rps
			local lat_avg_token
			local lat_stdev_token
			local p99_token
			local non2xx
			local socket_timeouts
			rps="$(awk '/Requests\/sec:/ { print $2; exit }' "${raw_file}")"
			lat_avg_token="$(awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+[a-z]+/ { print $2; exit }' "${raw_file}")"
			lat_stdev_token="$(awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+[a-z]+/ { print $3; exit }' "${raw_file}")"
			p99_token="$(extract_wrk_p99_token "${raw_file}")"
			non2xx="$(sed -n 's/.*Non-2xx or 3xx responses: \([0-9]\+\).*/\1/p' "${raw_file}" | head -n1)"
			socket_timeouts="$(sed -n 's/.*timeout \([0-9]\+\).*/\1/p' "${raw_file}" | head -n1)"
			non2xx="${non2xx:-0}"
			socket_timeouts="${socket_timeouts:-0}"

			local lat_avg_ms
			local lat_stdev_ms
			local p99_ms
			lat_avg_ms="$(latency_to_ms "${lat_avg_token}")"
			lat_stdev_ms="$(latency_to_ms "${lat_stdev_token}")"
			p99_ms="$(latency_to_ms "${p99_token}")"

			printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
				"$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
				"${conn}" \
				"${repeat}" \
				"${rps}" \
				"${lat_avg_ms}" \
				"${lat_stdev_ms}" \
				"${p99_ms}" \
				"${non2xx}" \
				"${socket_timeouts}" \
				"${vm1_cpu_util}" \
				"${vm2_cpu_util}" >>"${summary_csv}"
			progress_step_done "${step_label}"
		done
	done

	aggregate_wrk_summary "${summary_csv}" "${agg_csv}"
}

run_wrk2() {
	local target_ip="$1"
	local target_url="http://${target_ip}:${SERVER_PORT}/${SERVER_FILE}"
	local base_dir="${RESULT_DIR}/raw/wrk2"
	local summary_csv="${RESULT_DIR}/wrk2-summary.csv"
	local agg_csv="${RESULT_DIR}/wrk2-summary-agg.csv"
	local wrk2_prefix=""
	if [ -n "${WRK2_CPUSET}" ]; then
		wrk2_prefix="taskset -c ${WRK2_CPUSET} "
	fi

	mkdir -p "${base_dir}"
	echo "timestamp,target_rate,repeat,requests_per_sec,latency_avg_ms,latency_stdev_ms,p99_ms,non2xx_responses,socket_timeouts,vm1_cpu_util_pct,vm2_cpu_util_pct" >"${summary_csv}"

	for rate in ${WRK2_RATES}; do
		is_pos_int "${rate}" || fail "wrk2 target rate must be positive integer: ${rate}"
		local rate_dir="${base_dir}/r${rate}"
		mkdir -p "${rate_dir}"
		for repeat in $(seq 1 "${WRK2_REPEATS}"); do
			local run_threads="${WRK2_THREADS}"
			if [ "${run_threads}" -gt "${WRK2_CONNECTIONS}" ]; then
				run_threads="${WRK2_CONNECTIONS}"
			fi
			local step_label="wrk2 rate=${rate} c=${WRK2_CONNECTIONS} t=${run_threads} repeat=${repeat}/${WRK2_REPEATS}"
			progress_step_start "${step_label}"
			if [ "${WRK2_WARMUP}" -gt 0 ]; then
				ssh_vm vm2 "${wrk2_prefix}${WRK2_BIN} -t ${run_threads} -c ${WRK2_CONNECTIONS} -d ${WRK2_WARMUP}s -R ${rate} --latency ${target_url} >/tmp/exp1-wrk2-warmup.log 2>&1 || true" || \
					fail "wrk2 warmup failed at rate=${rate}, repeat=${repeat}"
			fi

			local raw_file="${rate_dir}/run-${repeat}.txt"
			local vm1_cpu_before
			local vm2_cpu_before
			local vm1_cpu_after
			local vm2_cpu_after
			local vm1_cpu_util
			local vm2_cpu_util
			vm1_cpu_before="$(vm_cpu_stat_line_retry vm1 || true)"
			vm2_cpu_before="$(vm_cpu_stat_line_retry vm2 || true)"
			printf '%s\n' "${vm1_cpu_before}" >"${rate_dir}/vm1-cpu-before-${repeat}.txt"
			printf '%s\n' "${vm2_cpu_before}" >"${rate_dir}/vm2-cpu-before-${repeat}.txt"
			ssh_vm vm1 "date -u +%Y-%m-%dT%H:%M:%SZ; cat /proc/loadavg" >"${rate_dir}/vm1-pre-run-${repeat}.txt" || \
				fail "failed to capture vm1 pre-run metadata (rate=${rate}, repeat=${repeat})"
			ssh_vm vm2 "${wrk2_prefix}${WRK2_BIN} -t ${run_threads} -c ${WRK2_CONNECTIONS} -d ${WRK2_DURATION}s -R ${rate} --latency ${target_url}" >"${raw_file}" || \
				fail "wrk2 measurement failed at rate=${rate}, repeat=${repeat} (ssh/vm transient or wrk2 error)"
			vm1_cpu_after="$(vm_cpu_stat_line_retry vm1 || true)"
			vm2_cpu_after="$(vm_cpu_stat_line_retry vm2 || true)"
			printf '%s\n' "${vm1_cpu_after}" >"${rate_dir}/vm1-cpu-after-${repeat}.txt"
			printf '%s\n' "${vm2_cpu_after}" >"${rate_dir}/vm2-cpu-after-${repeat}.txt"
			if [ -n "${vm1_cpu_before}" ] && [ -n "${vm1_cpu_after}" ]; then
				vm1_cpu_util="$(cpu_util_pct_from_stats "${vm1_cpu_before}" "${vm1_cpu_after}")"
			else
				vm1_cpu_util=""
			fi
			if [ -n "${vm2_cpu_before}" ] && [ -n "${vm2_cpu_after}" ]; then
				vm2_cpu_util="$(cpu_util_pct_from_stats "${vm2_cpu_before}" "${vm2_cpu_after}")"
			else
				vm2_cpu_util=""
			fi
			if [ -z "${vm1_cpu_util}" ] || [ -z "${vm2_cpu_util}" ]; then
				log "[warn] cpu utilization unavailable at wrk2 rate=${rate}, repeat=${repeat}; recording NA"
			fi
			vm1_cpu_util="${vm1_cpu_util:-NA}"
			vm2_cpu_util="${vm2_cpu_util:-NA}"

			local rps
			local lat_avg_token
			local lat_stdev_token
			local p99_token
			local non2xx
			local socket_timeouts
			rps="$(awk '/Requests\/sec:/ { print $2; exit }' "${raw_file}")"
			lat_avg_token="$(awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+[a-z]+/ { print $2; exit }' "${raw_file}")"
			lat_stdev_token="$(awk '/^[[:space:]]*Latency[[:space:]]+[0-9.]+[a-z]+/ { print $3; exit }' "${raw_file}")"
			p99_token="$(extract_wrk_p99_token "${raw_file}")"
			non2xx="$(sed -n 's/.*Non-2xx or 3xx responses: \([0-9]\+\).*/\1/p' "${raw_file}" | head -n1)"
			socket_timeouts="$(sed -n 's/.*timeout \([0-9]\+\).*/\1/p' "${raw_file}" | head -n1)"
			non2xx="${non2xx:-0}"
			socket_timeouts="${socket_timeouts:-0}"

			local lat_avg_ms
			local lat_stdev_ms
			local p99_ms
			lat_avg_ms="$(latency_to_ms "${lat_avg_token}")"
			lat_stdev_ms="$(latency_to_ms "${lat_stdev_token}")"
			p99_ms="$(latency_to_ms "${p99_token}")"

			printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
				"$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
				"${rate}" \
				"${repeat}" \
				"${rps}" \
				"${lat_avg_ms}" \
				"${lat_stdev_ms}" \
				"${p99_ms}" \
				"${non2xx}" \
				"${socket_timeouts}" \
				"${vm1_cpu_util}" \
				"${vm2_cpu_util}" >>"${summary_csv}"
			progress_step_done "${step_label}"
		done
	done

	aggregate_wrk2_summary "${summary_csv}" "${agg_csv}"
}

run_httperf() {
	local target_ip="$1"
	local uri_path="/${SERVER_FILE#/}"
	local base_dir="${RESULT_DIR}/raw/httperf"
	local summary_csv="${RESULT_DIR}/httperf-summary.csv"
	local agg_csv="${RESULT_DIR}/httperf-summary-agg.csv"
	local httperf_prefix=""
	local httperf_ulimit_prefix=""
	local client_count="${#HTTPERF_CLIENT_VM_LIST[@]}"
	local worker_count="${HTTPERF_WORKERS_PER_VM}"
	[ "${client_count}" -gt 0 ] || fail "httperf workload selected but no client VMs resolved"
	[ "${worker_count}" -gt 0 ] || fail "httperf worker count must be positive"
	if [ -n "${HTTPERF_CPUSET}" ]; then
		httperf_prefix="taskset -c ${HTTPERF_CPUSET} "
	fi
	if [ -n "${HTTPERF_ULIMIT_NOFILE}" ]; then
		httperf_ulimit_prefix="ulimit -n ${HTTPERF_ULIMIT_NOFILE} >/dev/null 2>&1 || true; "
	fi

	mkdir -p "${base_dir}"
	echo "timestamp,offered_rate,repeat,num_conns,request_rate,reply_rate_avg,response_time_ms,errors_total,non2xx_responses,socket_timeouts,vm1_cpu_util_pct,vm2_cpu_util_pct" >"${summary_csv}"

	for rate in ${HTTPERF_RATES}; do
		is_pos_int "${rate}" || fail "httperf offered rate must be positive integer: ${rate}"
		[ "${rate}" -ge "${client_count}" ] || fail "httperf offered rate ${rate} must be >= client count ${client_count}"
		local rate_dir="${base_dir}/r${rate}"
		mkdir -p "${rate_dir}"
		for repeat in $(seq 1 "${HTTPERF_REPEATS}"); do
			local per_client_rates=()
			local rate_base=$((rate / client_count))
			local rate_rem=$((rate % client_count))
			local idx=0
			for _ in "${HTTPERF_CLIENT_VM_LIST[@]}"; do
				local assigned_rate="${rate_base}"
				if [ "${idx}" -lt "${rate_rem}" ]; then
					assigned_rate=$((assigned_rate + 1))
				fi
				per_client_rates+=("${assigned_rate}")
				idx=$((idx + 1))
			done

			local warmup_conns_total=0
			local num_conns_total=0
			for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
				local client_rate="${per_client_rates[${idx}]}"
				local worker_rate_base=$((client_rate / worker_count))
				local worker_rate_rem=$((client_rate % worker_count))
				local worker_idx
				for ((worker_idx = 1; worker_idx <= worker_count; worker_idx++)); do
					local worker_rate="${worker_rate_base}"
					if [ "${worker_idx}" -le "${worker_rate_rem}" ]; then
						worker_rate=$((worker_rate + 1))
					fi
					[ "${worker_rate}" -gt 0 ] || continue
					local warmup_conns_i=$((worker_rate * HTTPERF_WARMUP))
					local num_conns_i=$((worker_rate * HTTPERF_DURATION))
					[ "${warmup_conns_i}" -lt 1 ] && warmup_conns_i=1
					[ "${num_conns_i}" -lt 1 ] && num_conns_i=1
					warmup_conns_total=$((warmup_conns_total + warmup_conns_i))
					num_conns_total=$((num_conns_total + num_conns_i))
				done
			done

			local step_label="httperf rate=${rate} repeat=${repeat}/${HTTPERF_REPEATS}"
			progress_step_start "${step_label}"
			if [ "${HTTPERF_WARMUP}" -gt 0 ]; then
				local warmup_pids=()
				local warmup_labels=()
				for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
					local client_vm="${HTTPERF_CLIENT_VM_LIST[${idx}]}"
					local client_rate="${per_client_rates[${idx}]}"
					local worker_rate_base=$((client_rate / worker_count))
					local worker_rate_rem=$((client_rate % worker_count))
					local worker_idx
					for ((worker_idx = 1; worker_idx <= worker_count; worker_idx++)); do
						local worker_rate="${worker_rate_base}"
						if [ "${worker_idx}" -le "${worker_rate_rem}" ]; then
							worker_rate=$((worker_rate + 1))
						fi
						[ "${worker_rate}" -gt 0 ] || continue
						local warmup_conns_i=$((worker_rate * HTTPERF_WARMUP))
						[ "${warmup_conns_i}" -lt 1 ] && warmup_conns_i=1
						ssh_vm "${client_vm}" "${httperf_ulimit_prefix}${httperf_prefix}httperf --hog --server ${target_ip} --port ${SERVER_PORT} --uri ${uri_path} --rate ${worker_rate} --num-conns ${warmup_conns_i} --timeout ${HTTPERF_TIMEOUT} >/tmp/exp1-httperf-warmup.log 2>&1 || true" &
						warmup_pids+=("$!")
						warmup_labels+=("${client_vm}/w${worker_idx}")
					done
				done
				for idx in "${!warmup_pids[@]}"; do
					if ! wait "${warmup_pids[${idx}]}"; then
						fail "httperf warmup failed at rate=${rate}, repeat=${repeat}, worker=${warmup_labels[${idx}]}"
					fi
				done
			fi

			local vm1_cpu_before
			local vm1_cpu_after
			local vm1_cpu_util
			local vm2_cpu_util
			local client_cpu_before_lines=()
			local client_cpu_after_lines=()
			local raw_files=()
			local measure_pids=()
			local measure_labels=()
			vm1_cpu_before="$(vm_cpu_stat_line_retry vm1 || true)"
			printf '%s\n' "${vm1_cpu_before}" >"${rate_dir}/vm1-cpu-before-${repeat}.txt"
			for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
				local client_vm="${HTTPERF_CLIENT_VM_LIST[${idx}]}"
				local client_before
				client_before="$(vm_cpu_stat_line_retry "${client_vm}" || true)"
				client_cpu_before_lines+=("${client_before}")
				printf '%s\n' "${client_before}" >"${rate_dir}/${client_vm}-cpu-before-${repeat}.txt"
			done
			ssh_vm vm1 "date -u +%Y-%m-%dT%H:%M:%SZ; cat /proc/loadavg" >"${rate_dir}/vm1-pre-run-${repeat}.txt" || \
				fail "failed to capture vm1 pre-run metadata (rate=${rate}, repeat=${repeat})"
			for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
				local client_vm="${HTTPERF_CLIENT_VM_LIST[${idx}]}"
				local client_rate="${per_client_rates[${idx}]}"
				local worker_rate_base=$((client_rate / worker_count))
				local worker_rate_rem=$((client_rate % worker_count))
				local worker_idx
				for ((worker_idx = 1; worker_idx <= worker_count; worker_idx++)); do
					local worker_rate="${worker_rate_base}"
					if [ "${worker_idx}" -le "${worker_rate_rem}" ]; then
						worker_rate=$((worker_rate + 1))
					fi
					[ "${worker_rate}" -gt 0 ] || continue
					local num_conns_i=$((worker_rate * HTTPERF_DURATION))
					[ "${num_conns_i}" -lt 1 ] && num_conns_i=1
					local raw_file=""
					if [ "${client_count}" -eq 1 ] && [ "${client_vm}" = "vm2" ] && [ "${worker_count}" -eq 1 ]; then
						raw_file="${rate_dir}/run-${repeat}.txt"
					elif [ "${worker_count}" -eq 1 ]; then
						raw_file="${rate_dir}/run-${repeat}-${client_vm}.txt"
					else
						raw_file="${rate_dir}/run-${repeat}-${client_vm}-w${worker_idx}.txt"
					fi
					raw_files+=("${raw_file}")
					ssh_vm "${client_vm}" "${httperf_ulimit_prefix}${httperf_prefix}httperf --hog --server ${target_ip} --port ${SERVER_PORT} --uri ${uri_path} --rate ${worker_rate} --num-conns ${num_conns_i} --timeout ${HTTPERF_TIMEOUT}" >"${raw_file}" &
					measure_pids+=("$!")
					measure_labels+=("${client_vm}/w${worker_idx}")
				done
			done
			[ "${#measure_pids[@]}" -gt 0 ] || fail "no httperf workers scheduled (rate=${rate}, repeat=${repeat}); increase rate or reduce workers-per-vm"
			for idx in "${!measure_pids[@]}"; do
				if ! wait "${measure_pids[${idx}]}"; then
					fail "httperf measurement failed at rate=${rate}, repeat=${repeat}, worker=${measure_labels[${idx}]} (ssh/vm transient or httperf error)"
				fi
			done
			vm1_cpu_after="$(vm_cpu_stat_line_retry vm1 || true)"
			printf '%s\n' "${vm1_cpu_after}" >"${rate_dir}/vm1-cpu-after-${repeat}.txt"
			for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
				local client_vm="${HTTPERF_CLIENT_VM_LIST[${idx}]}"
				local client_after
				client_after="$(vm_cpu_stat_line_retry "${client_vm}" || true)"
				client_cpu_after_lines+=("${client_after}")
				printf '%s\n' "${client_after}" >"${rate_dir}/${client_vm}-cpu-after-${repeat}.txt"
			done
			if [ -n "${vm1_cpu_before}" ] && [ -n "${vm1_cpu_after}" ]; then
				vm1_cpu_util="$(cpu_util_pct_from_stats "${vm1_cpu_before}" "${vm1_cpu_after}")"
			else
				vm1_cpu_util=""
			fi
			local client_cpu_util_sum="0.000000"
			local client_cpu_util_cnt=0
			for idx in "${!HTTPERF_CLIENT_VM_LIST[@]}"; do
				local client_before="${client_cpu_before_lines[${idx}]}"
				local client_after="${client_cpu_after_lines[${idx}]}"
				local client_util=""
				if [ -n "${client_before}" ] && [ -n "${client_after}" ]; then
					client_util="$(cpu_util_pct_from_stats "${client_before}" "${client_after}")"
				fi
				if [ -n "${client_util}" ]; then
					client_cpu_util_sum="$(awk -v a="${client_cpu_util_sum}" -v b="${client_util}" 'BEGIN { printf "%.6f", a + b }')"
					client_cpu_util_cnt=$((client_cpu_util_cnt + 1))
				fi
			done
			if [ "${client_cpu_util_cnt}" -gt 0 ]; then
				vm2_cpu_util="$(awk -v sum="${client_cpu_util_sum}" -v cnt="${client_cpu_util_cnt}" 'BEGIN { printf "%.6f", sum / cnt }')"
			else
				vm2_cpu_util=""
			fi
			if [ -z "${vm1_cpu_util}" ] || [ -z "${vm2_cpu_util}" ]; then
				log "[warn] cpu utilization unavailable at rate=${rate}, repeat=${repeat}; recording NA"
			fi
			vm1_cpu_util="${vm1_cpu_util:-NA}"
			vm2_cpu_util="${vm2_cpu_util:-NA}"

			local request_rate="0.000000"
			local reply_rate_avg="0.000000"
			local response_weighted_sum="0.000000"
			local errors_total=0
			local socket_timeouts=0
			local non2xx=0
			for idx in "${!raw_files[@]}"; do
				local raw_file="${raw_files[${idx}]}"
				local req_i
				local reply_i
				local resp_i
				local err_i
				local sock_to_i
				local replies_total_i
				local replies_2xx_i
				local non2xx_i

				req_i="$(awk '/^Request rate:/ { print $3; exit }' "${raw_file}")"
				reply_i="$(awk '/^Reply rate \[replies\/s\]:/ {for(i=1;i<=NF;i++) if($i=="avg"){print $(i+1); exit}}' "${raw_file}")"
				resp_i="$(awk '/^Reply time \[ms\]:/ {for(i=1;i<=NF;i++) if($i=="response"){print $(i+1); exit}}' "${raw_file}")"
				err_i="$(awk '/^Errors:/ {for(i=1;i<=NF;i++) if($i=="total"){print $(i+1); exit}}' "${raw_file}")"
				sock_to_i="$(awk '/^Errors:/ {for(i=1;i<=NF;i++) if($i=="socket-timo"){print $(i+1); exit}}' "${raw_file}")"
				replies_total_i="$(awk '/^Total:/ {for(i=1;i<=NF;i++) if($i=="replies"){print $(i+1); exit}}' "${raw_file}")"
				replies_2xx_i="$(awk '/^Reply status:/ {for(i=1;i<=NF;i++) if($i ~ /^2xx=/){split($i,a,"="); print a[2]; exit}}' "${raw_file}")"

				[ -n "${req_i}" ] || fail "failed to parse httperf request rate (rate=${rate}, repeat=${repeat}, file=${raw_file})"
				[ -n "${resp_i}" ] || fail "failed to parse httperf response time (rate=${rate}, repeat=${repeat}, file=${raw_file})"
				reply_i="${reply_i:-${req_i}}"
				err_i="${err_i:-0}"
				sock_to_i="${sock_to_i:-0}"
				replies_total_i="${replies_total_i:-0}"
				replies_2xx_i="${replies_2xx_i:-0}"
				non2xx_i=$((replies_total_i - replies_2xx_i))
				if [ "${non2xx_i}" -lt 0 ]; then
					non2xx_i=0
				fi

				request_rate="$(awk -v a="${request_rate}" -v b="${req_i}" 'BEGIN { printf "%.6f", a + b }')"
				reply_rate_avg="$(awk -v a="${reply_rate_avg}" -v b="${reply_i}" 'BEGIN { printf "%.6f", a + b }')"
				response_weighted_sum="$(awk -v a="${response_weighted_sum}" -v r="${resp_i}" -v w="${req_i}" 'BEGIN { printf "%.6f", a + (r * w) }')"
				errors_total=$((errors_total + err_i))
				socket_timeouts=$((socket_timeouts + sock_to_i))
				non2xx=$((non2xx + non2xx_i))
			done

			local response_time_ms
			if awk -v v="${request_rate}" 'BEGIN { exit !(v > 0) }'; then
				response_time_ms="$(awk -v weighted="${response_weighted_sum}" -v total="${request_rate}" 'BEGIN { printf "%.6f", weighted / total }')"
			else
				response_time_ms="0.000000"
			fi

			printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
				"$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
				"${rate}" \
				"${repeat}" \
				"${num_conns_total}" \
				"${request_rate}" \
				"${reply_rate_avg}" \
				"${response_time_ms}" \
				"${errors_total}" \
				"${non2xx}" \
				"${socket_timeouts}" \
				"${vm1_cpu_util}" \
				"${vm2_cpu_util}" >>"${summary_csv}"
			progress_step_done "${step_label}"
		done
	done

	aggregate_httperf_summary "${summary_csv}" "${agg_csv}"
}

run_single_kind() {
	local kind="$1"
	local target_ip="${SERVER_IP}"

	RUN_KIND="${kind}"
	RESULT_DIR="$(result_dir_for_kind "${RUN_KIND}")"
	mkdir -p "${RESULT_DIR}"

	if [ "${RUN_KIND}" = "direct-nginx" ]; then
		target_ip="${SERVER_IP}"
	elif [ "${RUN_KIND}" = "vanilla-katran" ]; then
		target_ip="${KATRAN_VIP}"
	else
		fail "unsupported run kind: ${RUN_KIND}"
	fi

	write_run_config "${target_ip}"
	plan_progress
	prepare_server_vm1
	if [ "${RUN_KIND}" = "vanilla-katran" ]; then
		prepare_katran_vm1
	fi
	run_sanity_checks "${target_ip}"
	collect_metadata
	progress_init
	if [ "${RUN_WRK}" -eq 1 ]; then
		run_wrk "${target_ip}"
	fi
	if [ "${RUN_WRK2}" -eq 1 ]; then
		run_wrk2 "${target_ip}"
	fi
	if [ "${RUN_HTTPERF}" -eq 1 ]; then
		run_httperf "${target_ip}"
	fi
	progress_finish
	generate_plots
	archive_old_runs
	if [ "${RUN_KIND}" = "vanilla-katran" ]; then
		cleanup_katran_vm1
	fi

	RUN_RESULT_DIRS+=("${RESULT_DIR}")
	log "[${RUN_KIND}] complete"
	log "[${RUN_KIND}] artifacts: ${RESULT_DIR}"
}

main() {
	parse_args "$@"
	resolve_workloads
	validate_args
	resolve_vm_topology
	resolve_run_kinds

	require_cmd make
	require_cmd ssh
	[ "${PLOT_ENABLED}" -eq 0 ] || require_cmd python3
	[ "${ARCHIVE_OLD}" -eq 0 ] || require_cmd tar

	trap cleanup EXIT

	log "run id: ${RUN_ID}"
	log "mode: ${MODE}"
	log "workloads: ${WORKLOADS}"
	log "run kinds: ${RUN_KINDS[*]}"
	log "active VMs: ${ACTIVE_VMS[*]}"
	local httperf_clients_label="none"
	if [ "${#HTTPERF_CLIENT_VM_LIST[@]}" -gt 0 ]; then
		httperf_clients_label="${HTTPERF_CLIENT_VM_LIST[*]}"
	fi
	local httperf_ulimit_label="off"
	if [ -n "${HTTPERF_ULIMIT_NOFILE}" ]; then
		httperf_ulimit_label="${HTTPERF_ULIMIT_NOFILE}"
	fi
	log "httperf clients: ${httperf_clients_label} (workers_per_vm=${HTTPERF_WORKERS_PER_VM}, ulimit_nofile=${httperf_ulimit_label})"
	log "vm shape: vm1(vcpus=${HOST_VM1_VCPUS}, mem_mb=${HOST_VM1_MEMORY_MB}), vm2(vcpus=${HOST_VM2_VCPUS}, mem_mb=${HOST_VM2_MEMORY_MB}), vm3(vcpus=${HOST_VM3_VCPUS}, mem_mb=${HOST_VM3_MEMORY_MB}), vm4(vcpus=${HOST_VM4_VCPUS}, mem_mb=${HOST_VM4_MEMORY_MB})"
	if [ -n "${HOST_VM1_CPUSET}" ] || [ -n "${HOST_VM2_CPUSET}" ] || [ -n "${HOST_VM3_CPUSET}" ] || [ -n "${HOST_VM4_CPUSET}" ] || [ -n "${NGINX_CPUSET}" ] || [ -n "${WRK_CPUSET}" ] || [ -n "${WRK2_CPUSET}" ] || [ -n "${HTTPERF_CPUSET}" ] || [ -n "${KATRAN_CPUSET}" ]; then
		log "cpu pinning: host(vm1=${HOST_VM1_CPUSET:-none}, vm2=${HOST_VM2_CPUSET:-none}, vm3=${HOST_VM3_CPUSET:-none}, vm4=${HOST_VM4_CPUSET:-none}), guest(nginx=${NGINX_CPUSET:-none}, wrk=${WRK_CPUSET:-none}, wrk2=${WRK2_CPUSET:-none}, httperf=${HTTPERF_CPUSET:-none}, katran=${KATRAN_CPUSET:-none})"
	fi
	if [ "${MODE}" != "direct" ]; then
		ensure_katran_artifacts
	fi

	start_vms
	local client_vm
	for client_vm in "${ACTIVE_CLIENT_VMS[@]}"; do
		local run_wrk_vm=0
		local run_httperf_vm=0
		local run_wrk2_vm=0
		if [ "${RUN_WRK}" -eq 1 ] && [ "${client_vm}" = "vm2" ]; then
			run_wrk_vm=1
		fi
		if [ "${RUN_WRK2}" -eq 1 ] && [ "${client_vm}" = "vm2" ]; then
			run_wrk2_vm=1
		fi
		if [ "${RUN_HTTPERF}" -eq 1 ] && list_contains_word "${client_vm}" "${HTTPERF_CLIENT_VM_LIST[@]}"; then
			run_httperf_vm=1
		fi
		prepare_client_vm "${client_vm}" "${run_wrk_vm}" "${run_httperf_vm}" "${run_wrk2_vm}"
	done

	local kind
	for kind in "${RUN_KINDS[@]}"; do
		run_single_kind "${kind}"
	done

	generate_compare_plot_if_needed

	log "experiment complete"
	local dir
	for dir in "${RUN_RESULT_DIRS[@]}"; do
		log "artifacts: ${dir}"
	done
}

main "$@"
