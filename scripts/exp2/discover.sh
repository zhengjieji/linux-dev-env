#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXP1_RUN_SCRIPT="${EXP2_EXP1_RUN_SCRIPT:-${ROOT_DIR}/scripts/exp1/run.sh}"
ANALYZE_SCRIPT="${EXP2_ANALYZE_SCRIPT:-${ROOT_DIR}/scripts/exp2/analyze-maps.py}"
RESULTS_BASE="${EXP2_RESULTS_BASE:-${ROOT_DIR}/results/exp2/discovery}"

WORKLOAD="${EXP2_STAGEA_WORKLOAD:-wrk2}" # wrk|wrk2
WRK_CONNECTIONS="${EXP2_STAGEA_WRK_CONNECTIONS:-256}"
WRK_THREADS="${EXP2_STAGEA_WRK_THREADS:-4}"
WRK2_RATE="${EXP2_STAGEA_WRK2_RATE:-250000}"
WRK2_CONNECTIONS="${EXP2_STAGEA_WRK2_CONNECTIONS:-256}"
WRK2_THREADS="${EXP2_STAGEA_WRK2_THREADS:-4}"
WORKLOAD_WARMUP_SECS="${EXP2_STAGEA_WORKLOAD_WARMUP_SECS:-5}"
MEASURE_TAIL_SECS="${EXP2_STAGEA_MEASURE_TAIL_SECS:-120}"

STEADY_WARMUP_SECS="${EXP2_STAGEA_STEADY_WARMUP_SECS:-30}"
SAMPLE_INTERVAL_SECS="${EXP2_STAGEA_SAMPLE_INTERVAL_SECS:-30}"
SAMPLE_COUNT="${EXP2_STAGEA_SAMPLE_COUNT:-10}"
SAMPLE_MAPS="${EXP2_STAGEA_MAPS:-ctl_array vip_map ch_rings reals server_id_map}"
BALANCER_PROG_NAME="${EXP2_STAGEA_BALANCER_PROG_NAME:-balancer_ingress}"
MAX_MAP_DUMP_ENTRIES="${EXP2_STAGEA_MAX_MAP_DUMP_ENTRIES:-1000000}"
SKIP_LARGE_MAP_DUMPS="${EXP2_STAGEA_SKIP_LARGE_MAP_DUMPS:-1}"
KEEP_INVARIANT_HASH_ONLY_DUMP="${EXP2_STAGEA_KEEP_INVARIANT_HASH_ONLY_DUMP:-1}"

VM1_SSH_PORT="${DUAL_VM1_SSH_PORT:-53022}"
VM2_SSH_PORT="${DUAL_VM2_SSH_PORT:-53122}"
SAMPLE_SSH_PORT="${EXP2_STAGEA_SAMPLE_SSH_PORT:-${VM1_SSH_PORT}}"
BPFTOOL_BIN="${EXP2_STAGEA_BPFTOOL_BIN:-bpftool}"
EXP1_SKIP_INSTALL="${EXP2_STAGEA_SKIP_INSTALL:-0}"
SSH_RETRIES="${EXP2_STAGEA_SSH_RETRIES:-4}"
SSH_RETRY_DELAY_SECS="${EXP2_STAGEA_SSH_RETRY_DELAY_SECS:-2}"
SSH_RECOVER_WAIT_SECS="${EXP2_STAGEA_SSH_RECOVER_WAIT_SECS:-20}"
EXP1_EXTRA_ARGS=()

RUN_ID=""
RUN_DIR=""
LOG_FILE=""
EXP1_PID=""
MEASURE_DURATION_SECS=0
VMS_STOPPED=0

usage() {
	cat <<'EOF_USAGE'
Usage: scripts/exp2/discover.sh [options]

Stage A discovery for Exp2:
  1) run vanilla-katran workload using exp1 harness
  2) periodically dump selected Katran BPF maps during steady window
  3) generate specialization spec (invariant map snapshot)

Options:
  --workload wrk|wrk2                    Workload protocol (default: wrk2)
  --wrk-connections "<list>"             wrk connection list for stage run (default: "256")
  --wrk-threads <n>                      wrk threads (default: 4)
  --wrk2-rate <n>                        wrk2 target rate for stage run (default: 250000)
  --wrk2-connections <n>                 wrk2 connections (default: 256)
  --wrk2-threads <n>                     wrk2 threads (default: 4)
  --workload-warmup-secs <n>             exp1 warmup before measure (default: 5)
  --measure-tail-secs <n>                extra exp1 measure tail to cover map sampling (default: 120)
  --steady-warmup-secs <n>               wait after measure starts (default: 30)
  --sample-interval-secs <n>             dump interval (default: 30)
  --sample-count <n>                     number of dumps (default: 10)
  --maps "<list>|all"                    map names to sample or all maps from balancer program
                                         (default: "ctl_array vip_map ch_rings reals server_id_map")
  --balancer-prog-name <name>            program name for --maps all (default: balancer_ingress)
  --max-map-dump-entries <n>             for large maps, switch to hash-only sampling above n (default: 1000000)
  --skip-large-map-dumps <0|1>           enable max_entries-based hash-only sampling (default: 1)
  --keep-invariant-hash-only-dump <0|1>  if hash-only map is invariant, keep one final full dump (default: 1)
  --results-base <path>                  discovery output base dir
  --vm1-ssh-port <port>                  vm1 ssh port (default: 53022)
  --vm2-ssh-port <port>                  vm2 ssh port (default: 53122)
  --sample-ssh-port <port>               ssh port of VM used for map sampling/bpftool (default: vm1 ssh port)
  --skip-install <0|1>                   pass through to exp1 (default: 0)
  --exp1-arg "<arg>"                     append one extra arg to exp1 run.sh (repeatable)
  --run-id <id>                          custom run id (default: utc timestamp)
  -h, --help

Example:
  scripts/exp2/discover.sh \
    --workload wrk2 \
    --wrk2-rate 300000 \
    --steady-warmup-secs 45 \
    --sample-interval-secs 30 \
    --sample-count 8
EOF_USAGE
}

log() {
	echo "[exp2-stageA] $*"
}

warn() {
	echo "[exp2-stageA][warn] $*" >&2
}

fail() {
	echo "[exp2-stageA][error] $*" >&2
	exit 1
}

is_pos_int() {
	local value="$1"
	[[ "${value}" =~ ^[0-9]+$ ]] && [ "${value}" -gt 0 ]
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

ssh_vm_port() {
	local port="$1"
	shift
	local rc=0
	local attempt=1
	while true; do
		ssh \
			-o ConnectTimeout=5 \
			-o UserKnownHostsFile=/dev/null \
			-o StrictHostKeyChecking=no \
			-o LogLevel=ERROR \
			-o ServerAliveInterval=5 \
			-o ServerAliveCountMax=3 \
			-o ControlMaster=auto \
			-o ControlPersist=120 \
			-o ControlPath=/tmp/exp2-ssh-%C \
			-p "${port}" \
			root@127.0.0.1 "$@"
		rc=$?
		if [ "${rc}" -eq 0 ]; then
			return 0
		fi
		if [ "${rc}" -ne 255 ] || [ "${attempt}" -ge "${SSH_RETRIES}" ]; then
			return "${rc}"
		fi
		sleep "${SSH_RETRY_DELAY_SECS}"
		attempt=$((attempt + 1))
	done
}

ssh_vm1() {
	ssh_vm_port "${SAMPLE_SSH_PORT}" "$@"
}

ssh_vm2() {
	ssh_vm_port "${VM2_SSH_PORT}" "$@"
}

scp_to_vm1() {
	local src="$1"
	local dst="$2"
	local rc=0
	local attempt=1
	while true; do
		if cat "${src}" | ssh_vm1 "cat > '${dst}'"; then
			return 0
		fi
		rc=$?
		if [ "${rc}" -eq 0 ]; then
			return 0
		fi
		if [ "${rc}" -ne 255 ] || [ "${attempt}" -ge "${SSH_RETRIES}" ]; then
			return "${rc}"
		fi
		sleep "${SSH_RETRY_DELAY_SECS}"
		attempt=$((attempt + 1))
	done
}

wait_vm1_ssh() {
	local timeout_secs="${1:-300}"
	local start_ts
	start_ts="$(date +%s)"
	while true; do
		if ssh_vm1 "true" >/dev/null 2>&1; then
			return 0
		fi
		local now_ts
		now_ts="$(date +%s)"
		if [ $((now_ts - start_ts)) -ge "${timeout_secs}" ]; then
			return 1
		fi
		sleep 2
	done
}

wait_workload_start() {
	local log_file="$1"
	local log_pattern="$2"
	local timeout_secs="${3:-180}"
	local start_ts
	start_ts="$(date +%s)"

	while true; do
		if [ -f "${log_file}" ] && grep -Fq -- "${log_pattern}" "${log_file}"; then
			return 0
		fi
		if [ -n "${EXP1_PID}" ] && ! kill -0 "${EXP1_PID}" >/dev/null 2>&1; then
			return 1
		fi
		local now_ts
		now_ts="$(date +%s)"
		if [ $((now_ts - start_ts)) -ge "${timeout_secs}" ]; then
			return 1
		fi
		sleep 1
	done
}

wait_for_log_pattern() {
	local file="$1"
	local pattern="$2"
	local timeout_secs="$3"
	local start_ts
	start_ts="$(date +%s)"
	while true; do
		if [ -f "${file}" ] && grep -Fq -- "${pattern}" "${file}"; then
			return 0
		fi
		if [ -n "${EXP1_PID}" ] && ! kill -0 "${EXP1_PID}" >/dev/null 2>&1; then
			return 1
		fi
		local now_ts
		now_ts="$(date +%s)"
		if [ $((now_ts - start_ts)) -ge "${timeout_secs}" ]; then
			return 1
		fi
		sleep 1
	done
}

stop_exp1_if_running() {
	if [ -n "${EXP1_PID}" ] && kill -0 "${EXP1_PID}" >/dev/null 2>&1; then
		log "requesting exp1 stop (pid=${EXP1_PID})"
		kill "${EXP1_PID}" >/dev/null 2>&1 || true
		wait "${EXP1_PID}" >/dev/null 2>&1 || true
		EXP1_PID=""
	fi
}

ensure_sample_vm_bpftool() {
	install_bpftool_from_host() {
		local host_bpftool=""
		local candidate=""
		for candidate in /usr/lib/linux-tools-*/bpftool; do
			if [ -x "${candidate}" ]; then
				host_bpftool="${candidate}"
				break
			fi
		done
		if [ -z "${host_bpftool}" ] && command -v bpftool >/dev/null 2>&1; then
			local resolved
			resolved="$(readlink -f "$(command -v bpftool)" 2>/dev/null || true)"
			if [ -n "${resolved}" ] && [ -x "${resolved}" ]; then
				host_bpftool="${resolved}"
			fi
		fi
		[ -n "${host_bpftool}" ] || return 1
		log "installing bpftool in sample VM from host binary: ${host_bpftool}"
		scp_to_vm1 "${host_bpftool}" /tmp/exp2-bpftool || return 1
		ssh_vm1 "install -m 0755 /tmp/exp2-bpftool /usr/local/sbin/bpftool && rm -f /tmp/exp2-bpftool" || return 1
		BPFTOOL_BIN="/usr/local/sbin/bpftool"
		return 0
	}

	if ssh_vm1 "command -v ${BPFTOOL_BIN} >/dev/null 2>&1"; then
		return 0
	fi
	if [ "${EXP1_SKIP_INSTALL}" -eq 1 ]; then
		fail "bpftool not found in sample VM (${BPFTOOL_BIN}) and --skip-install=1"
	fi
	log "bpftool not found in sample VM; installing via apt"
	local attempt=1
	local max_attempts=20
	while [ "${attempt}" -le "${max_attempts}" ]; do
		if ssh_vm1 "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq >/tmp/exp2-apt-bpftool.log 2>&1 && apt-get install -y -qq bpftool >>/tmp/exp2-apt-bpftool.log 2>&1"; then
			break
		fi
		local apt_tail
		apt_tail="$(ssh_vm1 "tail -n 80 /tmp/exp2-apt-bpftool.log 2>/dev/null || true" || true)"
		if echo "${apt_tail}" | grep -qi "Could not get lock"; then
			sleep 3
			attempt=$((attempt + 1))
			continue
		fi
		if echo "${apt_tail}" | grep -Eqi "no installation candidate|unable to locate package"; then
			if install_bpftool_from_host; then
				break
			fi
		fi
		echo "${apt_tail}" >&2
		fail "failed to install bpftool in sample VM"
	done
	if [ "${attempt}" -gt "${max_attempts}" ]; then
		ssh_vm1 "tail -n 120 /tmp/exp2-apt-bpftool.log 2>/dev/null || true" >&2 || true
		fail "timed out waiting apt lock while installing bpftool in sample VM"
	fi
	ssh_vm1 "command -v ${BPFTOOL_BIN} >/dev/null 2>&1" || \
		fail "bpftool still unavailable in sample VM after install"
}

stop_dual_vms() {
	[ "${VMS_STOPPED}" -eq 0 ] || return 0
	if ! command -v make >/dev/null 2>&1; then
		return 0
	fi
	make -C "${ROOT_DIR}" dual-vm-stop \
		DUAL_VM1_SSH_PORT="${VM1_SSH_PORT}" \
		DUAL_VM2_SSH_PORT="${VM2_SSH_PORT}" >/dev/null 2>&1 || true
	VMS_STOPPED=1
}

cleanup() {
	if [ -n "${EXP1_PID}" ] && kill -0 "${EXP1_PID}" >/dev/null 2>&1; then
		log "stopping background exp1 process (pid=${EXP1_PID})"
		kill "${EXP1_PID}" >/dev/null 2>&1 || true
	fi
	stop_dual_vms
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--workload)
				[ $# -gt 1 ] || fail "--workload requires value"
				WORKLOAD="$2"
				shift 2
				;;
			--wrk-connections)
				[ $# -gt 1 ] || fail "--wrk-connections requires value"
				WRK_CONNECTIONS="$2"
				shift 2
				;;
			--wrk-threads)
				[ $# -gt 1 ] || fail "--wrk-threads requires value"
				WRK_THREADS="$2"
				shift 2
				;;
			--wrk2-rate)
				[ $# -gt 1 ] || fail "--wrk2-rate requires value"
				WRK2_RATE="$2"
				shift 2
				;;
			--wrk2-connections)
				[ $# -gt 1 ] || fail "--wrk2-connections requires value"
				WRK2_CONNECTIONS="$2"
				shift 2
				;;
			--wrk2-threads)
				[ $# -gt 1 ] || fail "--wrk2-threads requires value"
				WRK2_THREADS="$2"
				shift 2
				;;
			--workload-warmup-secs)
				[ $# -gt 1 ] || fail "--workload-warmup-secs requires value"
				WORKLOAD_WARMUP_SECS="$2"
				shift 2
				;;
			--measure-tail-secs)
				[ $# -gt 1 ] || fail "--measure-tail-secs requires value"
				MEASURE_TAIL_SECS="$2"
				shift 2
				;;
			--steady-warmup-secs)
				[ $# -gt 1 ] || fail "--steady-warmup-secs requires value"
				STEADY_WARMUP_SECS="$2"
				shift 2
				;;
			--sample-interval-secs)
				[ $# -gt 1 ] || fail "--sample-interval-secs requires value"
				SAMPLE_INTERVAL_SECS="$2"
				shift 2
				;;
			--sample-count)
				[ $# -gt 1 ] || fail "--sample-count requires value"
				SAMPLE_COUNT="$2"
				shift 2
				;;
			--maps)
				[ $# -gt 1 ] || fail "--maps requires value"
				SAMPLE_MAPS="$2"
				shift 2
				;;
			--balancer-prog-name)
				[ $# -gt 1 ] || fail "--balancer-prog-name requires value"
				BALANCER_PROG_NAME="$2"
				shift 2
				;;
			--max-map-dump-entries)
				[ $# -gt 1 ] || fail "--max-map-dump-entries requires value"
				MAX_MAP_DUMP_ENTRIES="$2"
				shift 2
				;;
			--skip-large-map-dumps)
				[ $# -gt 1 ] || fail "--skip-large-map-dumps requires value"
				SKIP_LARGE_MAP_DUMPS="$2"
				shift 2
				;;
			--keep-invariant-hash-only-dump)
				[ $# -gt 1 ] || fail "--keep-invariant-hash-only-dump requires value"
				KEEP_INVARIANT_HASH_ONLY_DUMP="$2"
				shift 2
				;;
			--results-base)
				[ $# -gt 1 ] || fail "--results-base requires value"
				RESULTS_BASE="$2"
				shift 2
				;;
			--vm1-ssh-port)
				[ $# -gt 1 ] || fail "--vm1-ssh-port requires value"
				VM1_SSH_PORT="$2"
				shift 2
				;;
			--vm2-ssh-port)
				[ $# -gt 1 ] || fail "--vm2-ssh-port requires value"
				VM2_SSH_PORT="$2"
				shift 2
				;;
			--sample-ssh-port)
				[ $# -gt 1 ] || fail "--sample-ssh-port requires value"
				SAMPLE_SSH_PORT="$2"
				shift 2
				;;
			--skip-install)
				[ $# -gt 1 ] || fail "--skip-install requires value"
				EXP1_SKIP_INSTALL="$2"
				shift 2
				;;
			--exp1-arg)
				[ $# -gt 1 ] || fail "--exp1-arg requires value"
				EXP1_EXTRA_ARGS+=("$2")
				shift 2
				;;
			--run-id)
				[ $# -gt 1 ] || fail "--run-id requires value"
				RUN_ID="$2"
				shift 2
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				fail "unknown arg: $1"
				;;
		esac
	done
}

normalize_quoted() {
	local value="$1"
	while [ "${value#\"}" != "${value}" ] && [ "${value%\"}" != "${value}" ]; do
		value="${value#\"}"
		value="${value%\"}"
	done
	echo "${value}"
}

validate_args() {
	WORKLOAD="$(normalize_quoted "${WORKLOAD}")"
	WRK_CONNECTIONS="$(normalize_quoted "${WRK_CONNECTIONS}")"
	WRK_THREADS="$(normalize_quoted "${WRK_THREADS}")"
	WRK2_RATE="$(normalize_quoted "${WRK2_RATE}")"
	WRK2_CONNECTIONS="$(normalize_quoted "${WRK2_CONNECTIONS}")"
	WRK2_THREADS="$(normalize_quoted "${WRK2_THREADS}")"
	WORKLOAD_WARMUP_SECS="$(normalize_quoted "${WORKLOAD_WARMUP_SECS}")"
	MEASURE_TAIL_SECS="$(normalize_quoted "${MEASURE_TAIL_SECS}")"
	STEADY_WARMUP_SECS="$(normalize_quoted "${STEADY_WARMUP_SECS}")"
	SAMPLE_INTERVAL_SECS="$(normalize_quoted "${SAMPLE_INTERVAL_SECS}")"
	SAMPLE_COUNT="$(normalize_quoted "${SAMPLE_COUNT}")"
	VM1_SSH_PORT="$(normalize_quoted "${VM1_SSH_PORT}")"
	VM2_SSH_PORT="$(normalize_quoted "${VM2_SSH_PORT}")"
	SAMPLE_SSH_PORT="$(normalize_quoted "${SAMPLE_SSH_PORT}")"
	EXP1_SKIP_INSTALL="$(normalize_quoted "${EXP1_SKIP_INSTALL}")"
	SAMPLE_MAPS="$(normalize_quoted "${SAMPLE_MAPS}")"
	BALANCER_PROG_NAME="$(normalize_quoted "${BALANCER_PROG_NAME}")"
	MAX_MAP_DUMP_ENTRIES="$(normalize_quoted "${MAX_MAP_DUMP_ENTRIES}")"
	SKIP_LARGE_MAP_DUMPS="$(normalize_quoted "${SKIP_LARGE_MAP_DUMPS}")"
	KEEP_INVARIANT_HASH_ONLY_DUMP="$(normalize_quoted "${KEEP_INVARIANT_HASH_ONLY_DUMP}")"
	SSH_RETRIES="$(normalize_quoted "${SSH_RETRIES}")"
	SSH_RETRY_DELAY_SECS="$(normalize_quoted "${SSH_RETRY_DELAY_SECS}")"
	SSH_RECOVER_WAIT_SECS="$(normalize_quoted "${SSH_RECOVER_WAIT_SECS}")"

	case "${WORKLOAD}" in
		wrk|wrk2) ;;
		*) fail "--workload must be wrk or wrk2 (got '${WORKLOAD}')" ;;
	esac
	if [ "${SAMPLE_MAPS}" != "all" ] && [ -z "${SAMPLE_MAPS}" ]; then
		fail "--maps cannot be empty; use --maps all or provide map names"
	fi

	is_pos_int "${WORKLOAD_WARMUP_SECS}" || fail "--workload-warmup-secs must be positive int"
	is_pos_int "${MEASURE_TAIL_SECS}" || fail "--measure-tail-secs must be positive int"
	is_pos_int "${STEADY_WARMUP_SECS}" || fail "--steady-warmup-secs must be positive int"
	is_pos_int "${SAMPLE_INTERVAL_SECS}" || fail "--sample-interval-secs must be positive int"
	is_pos_int "${SAMPLE_COUNT}" || fail "--sample-count must be positive int"
	is_pos_int "${MAX_MAP_DUMP_ENTRIES}" || fail "--max-map-dump-entries must be positive int"
	is_pos_int "${VM1_SSH_PORT}" || fail "--vm1-ssh-port must be positive int"
	is_pos_int "${VM2_SSH_PORT}" || fail "--vm2-ssh-port must be positive int"
	is_pos_int "${SAMPLE_SSH_PORT}" || fail "--sample-ssh-port must be positive int"
	is_pos_int "${SSH_RETRIES}" || fail "ssh retries must be positive int"
	is_pos_int "${SSH_RETRY_DELAY_SECS}" || fail "ssh retry delay must be positive int"
	is_pos_int "${SSH_RECOVER_WAIT_SECS}" || fail "ssh recover wait must be positive int"
	case "${EXP1_SKIP_INSTALL}" in
		0|1) ;;
		*) fail "--skip-install must be 0 or 1" ;;
	esac
	case "${SKIP_LARGE_MAP_DUMPS}" in
		0|1) ;;
		*) fail "--skip-large-map-dumps must be 0 or 1" ;;
	esac
	case "${KEEP_INVARIANT_HASH_ONLY_DUMP}" in
		0|1) ;;
		*) fail "--keep-invariant-hash-only-dump must be 0 or 1" ;;
	esac

	if [ "${WORKLOAD}" = "wrk" ]; then
		is_pos_int "${WRK_THREADS}" || fail "--wrk-threads must be positive int"
		for c in ${WRK_CONNECTIONS}; do
			is_pos_int "${c}" || fail "invalid wrk connection value: ${c}"
		done
	fi
	if [ "${WORKLOAD}" = "wrk2" ]; then
		is_pos_int "${WRK2_RATE}" || fail "--wrk2-rate must be positive int"
		is_pos_int "${WRK2_THREADS}" || fail "--wrk2-threads must be positive int"
		is_pos_int "${WRK2_CONNECTIONS}" || fail "--wrk2-connections must be positive int"
	fi

	[ -x "${EXP1_RUN_SCRIPT}" ] || fail "exp1 run script not found/executable: ${EXP1_RUN_SCRIPT}"
	[ -f "${ANALYZE_SCRIPT}" ] || fail "analyze script not found: ${ANALYZE_SCRIPT}"
}

write_stage_config() {
	cat >"${RUN_DIR}/stageA-config.env" <<EOF_CFG
run_id=${RUN_ID}
workload=${WORKLOAD}
wrk_connections=${WRK_CONNECTIONS}
wrk_threads=${WRK_THREADS}
wrk2_rate=${WRK2_RATE}
wrk2_connections=${WRK2_CONNECTIONS}
wrk2_threads=${WRK2_THREADS}
workload_warmup_secs=${WORKLOAD_WARMUP_SECS}
measure_tail_secs=${MEASURE_TAIL_SECS}
steady_warmup_secs=${STEADY_WARMUP_SECS}
sample_interval_secs=${SAMPLE_INTERVAL_SECS}
sample_count=${SAMPLE_COUNT}
sample_maps=${SAMPLE_MAPS}
balancer_prog_name=${BALANCER_PROG_NAME}
max_map_dump_entries=${MAX_MAP_DUMP_ENTRIES}
skip_large_map_dumps=${SKIP_LARGE_MAP_DUMPS}
keep_invariant_hash_only_dump=${KEEP_INVARIANT_HASH_ONLY_DUMP}
vm1_ssh_port=${VM1_SSH_PORT}
vm2_ssh_port=${VM2_SSH_PORT}
sample_ssh_port=${SAMPLE_SSH_PORT}
ssh_retries=${SSH_RETRIES}
ssh_retry_delay_secs=${SSH_RETRY_DELAY_SECS}
ssh_recover_wait_secs=${SSH_RECOVER_WAIT_SECS}
measure_duration_secs=${MEASURE_DURATION_SECS}
EOF_CFG
}

collect_map_ids() {
	local map_show_json="${RUN_DIR}/map-show-start.json"
	local prog_show_json="${RUN_DIR}/prog-show-start.json"
	ssh_vm1 "${BPFTOOL_BIN} -j map show" >"${map_show_json}" || fail "failed to collect map show from sample VM"
	ssh_vm1 "${BPFTOOL_BIN} -j prog show" >"${prog_show_json}" || fail "failed to collect prog show from sample VM"

	python3 - "${map_show_json}" "${prog_show_json}" "${SAMPLE_MAPS}" "${BALANCER_PROG_NAME}" "${RUN_DIR}/map-ids.json" "${MAX_MAP_DUMP_ENTRIES}" "${SKIP_LARGE_MAP_DUMPS}" <<'PY'
import json
import pathlib
import sys

map_show_file = pathlib.Path(sys.argv[1])
prog_show_file = pathlib.Path(sys.argv[2])
sample_maps = sys.argv[3].strip()
balancer_prog_name = sys.argv[4]
out_file = pathlib.Path(sys.argv[5])
max_map_dump_entries = int(sys.argv[6])
skip_large_map_dumps = sys.argv[7] == "1"

maps = json.loads(map_show_file.read_text())
progs = json.loads(prog_show_file.read_text())
maps_by_id = {m.get("id"): m for m in maps if isinstance(m.get("id"), int)}
selected = {}
duplicates = {}
missing = []
selected_maps = []
selection_mode = "named"
balancer_prog = None
hash_only_maps = []

def map_info_for_id(map_id):
    return maps_by_id.get(map_id)

def add_selected(name, map_id, map_info):
    sampling_mode = "dump"
    policy_reason = ""
    if (
        skip_large_map_dumps
        and isinstance(map_info, dict)
        and isinstance(map_info.get("max_entries"), int)
        and map_info.get("max_entries") > max_map_dump_entries
    ):
        sampling_mode = "hash_only"
        policy_reason = f"max_entries>{max_map_dump_entries}"
        hash_only_maps.append(
            {
                "name": name,
                "id": map_id,
                "max_entries": map_info.get("max_entries"),
                "reason": policy_reason,
            }
        )
    selected_maps.append(
        {
            "name": name,
            "id": map_id,
            "map_info": map_info,
            "sampling_mode": sampling_mode,
            "policy_reason": policy_reason,
        }
    )

if sample_maps == "all":
    selection_mode = "all-from-program"
    candidates = [p for p in progs if p.get("name") == balancer_prog_name]
    if not candidates:
        candidates = [p for p in progs if "balancer" in str(p.get("name", ""))]
    if not candidates:
        print(f"unable to find balancer program '{balancer_prog_name}' in bpftool prog show", file=sys.stderr)
        sys.exit(3)

    prog = sorted(candidates, key=lambda p: int(p.get("id", 0)))[-1]
    balancer_prog = {
        "id": prog.get("id"),
        "name": prog.get("name"),
        "type": prog.get("type"),
        "tag": prog.get("tag"),
        "map_ids": prog.get("map_ids", []),
    }
    for map_id in prog.get("map_ids", []):
        if not isinstance(map_id, int):
            continue
        m = map_info_for_id(map_id)
        if not m:
            continue
        name = str(m.get("name", f"id_{map_id}"))
        if name in selected and selected[name] != map_id:
            duplicates.setdefault(name, []).append(map_id)
            continue
        selected[name] = map_id
        add_selected(name, map_id, m)
else:
    candidate_names = sample_maps.split()
    for name in candidate_names:
        ids = [m.get("id") for m in maps if m.get("name") == name and isinstance(m.get("id"), int)]
        if not ids:
            missing.append(name)
            continue
        ids = sorted(set(ids))
        selected[name] = ids[-1]
        if len(ids) > 1:
            duplicates[name] = ids[:-1]
        add_selected(name, selected[name], map_info_for_id(selected[name]))

selected_maps.sort(key=lambda x: (x["name"], int(x["id"])))

payload = {
    "selection_mode": selection_mode,
    "balancer_program": balancer_prog,
    "selected_map_ids": selected,
    "selected_maps": selected_maps,
    "duplicates": duplicates,
    "missing": missing,
    "dump_policy": {
        "skip_large_map_dumps": skip_large_map_dumps,
        "max_map_dump_entries": max_map_dump_entries,
        "hash_only_maps": hash_only_maps,
    },
}
out_file.write_text(json.dumps(payload, indent=2, sort_keys=True))

if not selected:
    print("no candidate maps found", file=sys.stderr)
    sys.exit(2)
PY

	local selected_count
	selected_count="$(python3 - "${RUN_DIR}/map-ids.json" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1]))
print(len(obj.get("selected_map_ids", {})))
PY
)"
	[ "${selected_count}" -gt 0 ] || fail "no selected map ids in ${RUN_DIR}/map-ids.json"

	local hash_only_count
	hash_only_count="$(python3 - "${RUN_DIR}/map-ids.json" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1]))
items = obj.get("selected_maps", [])
print(sum(1 for x in items if isinstance(x, dict) and x.get("sampling_mode") == "hash_only"))
PY
)"
	if [ "${hash_only_count}" -gt 0 ]; then
		log "using hash-only sampling for ${hash_only_count} large maps (max_entries>${MAX_MAP_DUMP_ENTRIES})"
	fi
}

hash_map_dump_vm1() {
	local map_id="$1"
	ssh_vm1 python3 - "${BPFTOOL_BIN}" "${map_id}" <<'PY'
import hashlib
import subprocess
import sys

bpftool = sys.argv[1]
map_id = sys.argv[2]
proc = subprocess.Popen([bpftool, "-j", "map", "dump", "id", map_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
h = hashlib.sha256()
assert proc.stdout is not None
assert proc.stderr is not None
while True:
    chunk = proc.stdout.read(1024 * 1024)
    if not chunk:
        break
    h.update(chunk)
stderr = proc.stderr.read()
rc = proc.wait()
if rc != 0:
    if stderr:
        sys.stderr.buffer.write(stderr)
    raise SystemExit(rc)
print(h.hexdigest())
PY
}

dump_one_sample() {
	local sample_index="$1"
	local sample_dir="${RUN_DIR}/samples/sample-$(printf '%03d' "${sample_index}")"
	mkdir -p "${sample_dir}"

	while IFS=$'\t' read -r map_name map_id sampling_mode; do
		[ -n "${map_name}" ] || continue
		if [ "${sampling_mode}" = "hash_only" ]; then
			local map_hash
			if map_hash="$(hash_map_dump_vm1 "${map_id}" 2>"${sample_dir}/${map_name}.hash.err")" && [[ "${map_hash}" =~ ^[0-9a-f]{64}$ ]]; then
				cat >"${sample_dir}/${map_name}.hash.json" <<EOF_HASH
{"map_id": ${map_id}, "hash": "${map_hash}", "method": "raw_json_sha256"}
EOF_HASH
				rm -f "${sample_dir}/${map_name}.hash.err"
			else
				warn "failed to hash map '${map_name}' (id=${map_id}) for sample ${sample_index}; marking sample as missing"
				cat >"${sample_dir}/${map_name}.hash.json" <<EOF_HASH_MISS
{"map_id": ${map_id}, "hash": "", "method": "raw_json_sha256", "error_file": "${map_name}.hash.err"}
EOF_HASH_MISS
			fi
		else
			ssh_vm1 "${BPFTOOL_BIN} -j map dump id ${map_id}" </dev/null >"${sample_dir}/${map_name}.json" || \
				fail "failed to dump map '${map_name}' (id=${map_id}) for sample ${sample_index}"
		fi
	done < <(python3 - "${RUN_DIR}/map-ids.json" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1]))
items = [x for x in obj.get("selected_maps", []) if isinstance(x, dict)]
items.sort(key=lambda x: (0 if x.get("sampling_mode", "dump") == "dump" else 1, str(x.get("name", ""))))
for item in items:
    if not isinstance(item, dict):
        continue
    name = item.get("name")
    map_id = item.get("id")
    mode = item.get("sampling_mode", "dump")
    if name is None or map_id is None:
        continue
    print(f"{name}\t{map_id}\t{mode}")
PY
	)

	ssh_vm1 "${BPFTOOL_BIN} -j map show" >"${sample_dir}/map-show.json" || true
}

capture_invariant_hash_only_dumps() {
	[ "${KEEP_INVARIANT_HASH_ONLY_DUMP}" -eq 1 ] || return 0

	local final_dump_dir="${RUN_DIR}/final-dumps"

	local targets
	targets="$(python3 - "${RUN_DIR}/specialization-spec.json" <<'PY'
import json, sys
spec = json.load(open(sys.argv[1]))
for m in spec.get("maps", []):
    if not isinstance(m, dict):
        continue
    if m.get("sampling_mode") != "hash_only":
        continue
    if not m.get("map_invariant"):
        continue
    name = m.get("name")
    map_id = m.get("map_id")
    if name is None or map_id is None:
        continue
    print(f"{name}\t{map_id}")
PY
)"

	if [ -z "${targets}" ]; then
		log "no invariant hash-only maps require retained full dump"
		return 0
	fi

	mkdir -p "${final_dump_dir}"

	local captured=0
	while IFS=$'\t' read -r map_name map_id; do
		[ -n "${map_name}" ] || continue
		log "capturing retained dump for invariant hash-only map: ${map_name} (id=${map_id})"
		ssh_vm1 "${BPFTOOL_BIN} -j map dump id ${map_id}" </dev/null >"${final_dump_dir}/${map_name}.json" || \
			fail "failed to capture retained dump for map '${map_name}' (id=${map_id})"
		captured=$((captured + 1))
	done <<<"${targets}"

	log "retained ${captured} full dump(s) for invariant hash-only maps in ${final_dump_dir}"
}

main() {
	parse_args "$@"
	validate_args
	require_cmd bash
	require_cmd python3
	require_cmd ssh

	if [ -z "${RUN_ID}" ]; then
		RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
	fi

	RUN_DIR="${RESULTS_BASE}/${RUN_ID}-stageA"
	mkdir -p "${RUN_DIR}/samples"
	LOG_FILE="${RUN_DIR}/exp1-stageA.log"

	MEASURE_DURATION_SECS=$((STEADY_WARMUP_SECS + SAMPLE_INTERVAL_SECS * (SAMPLE_COUNT - 1) + MEASURE_TAIL_SECS))
	write_stage_config

	trap cleanup EXIT

	local exp1_results_base="${RUN_DIR}/exp1-runs"
	mkdir -p "${exp1_results_base}"

	local exp1_cmd=(
		"${EXP1_RUN_SCRIPT}"
		--mode katran
		--results-base "${exp1_results_base}"
		--no-plot
		--keep-vms
		--skip-install
	)
	if [ "${EXP1_SKIP_INSTALL}" -ne 1 ]; then
		exp1_cmd=(
			"${EXP1_RUN_SCRIPT}"
			--mode katran
			--results-base "${exp1_results_base}"
			--no-plot
			--keep-vms
		)
	fi

	if [ "${WORKLOAD}" = "wrk2" ]; then
		exp1_cmd+=(
			--workloads wrk2
			--wrk2-rates "${WRK2_RATE}"
			--wrk2-threads "${WRK2_THREADS}"
			--wrk2-connections "${WRK2_CONNECTIONS}"
			--wrk2-warmup "${WORKLOAD_WARMUP_SECS}"
			--wrk2-duration "${MEASURE_DURATION_SECS}"
			--wrk2-repeats 1
		)
	else
		exp1_cmd+=(
			--workloads wrk
			--wrk-connections "${WRK_CONNECTIONS}"
			--wrk-threads "${WRK_THREADS}"
			--wrk-warmup "${WORKLOAD_WARMUP_SECS}"
			--wrk-duration "${MEASURE_DURATION_SECS}"
			--wrk-repeats 1
		)
	fi
	exp1_cmd+=("${EXP1_EXTRA_ARGS[@]}")

	log "run id: ${RUN_ID}"
	log "stageA output: ${RUN_DIR}"
	log "launching workload via exp1: ${WORKLOAD}, measure_duration=${MEASURE_DURATION_SECS}s"

	EXP1_ARCHIVE_OLD=0 "${exp1_cmd[@]}" >"${LOG_FILE}" 2>&1 &
	EXP1_PID="$!"
	echo "${EXP1_PID}" >"${RUN_DIR}/exp1.pid"

	local start_pattern="| wrk2 rate="
	if [ "${WORKLOAD}" = "wrk" ]; then
		start_pattern="| wrk c="
	fi

	if ! wait_workload_start "${LOG_FILE}" "${start_pattern}" 240; then
		wait "${EXP1_PID}" || true
		fail "could not detect workload start (vm2 process or log pattern '${start_pattern}')"
	fi

	log "workload started; waiting steady warmup ${STEADY_WARMUP_SECS}s"
	sleep "${STEADY_WARMUP_SECS}"
	if ! wait_vm1_ssh 120; then
		tail -n 120 "${LOG_FILE}" >&2 || true
		fail "sample VM ssh not reachable on port ${SAMPLE_SSH_PORT} when entering sampling window"
	fi
	ensure_sample_vm_bpftool

	log "collecting map ids from sample VM port ${SAMPLE_SSH_PORT} (${SAMPLE_MAPS})"
	collect_map_ids

	local sample_i
	for sample_i in $(seq 0 $((SAMPLE_COUNT - 1))); do
		if ! kill -0 "${EXP1_PID}" >/dev/null 2>&1; then
			wait "${EXP1_PID}" || true
			fail "exp1 workload exited before sampling finished (sample=${sample_i}/${SAMPLE_COUNT})"
		fi
		log "sampling map snapshots: $((sample_i + 1))/${SAMPLE_COUNT}"
		dump_one_sample "${sample_i}"
		date -u +"%Y-%m-%dT%H:%M:%SZ" >"${RUN_DIR}/samples/sample-$(printf '%03d' "${sample_i}")/timestamp.txt"
		if [ "${sample_i}" -lt $((SAMPLE_COUNT - 1)) ]; then
			sleep "${SAMPLE_INTERVAL_SECS}"
		fi
	done

	log "analyzing sampled dumps and generating specialization spec"
	python3 "${ANALYZE_SCRIPT}" \
		--samples-dir "${RUN_DIR}/samples" \
		--map-ids "${RUN_DIR}/map-ids.json" \
		--output-spec "${RUN_DIR}/specialization-spec.json" \
		--summary "${RUN_DIR}/invariant-summary.csv"

	capture_invariant_hash_only_dumps

	if [ -d "${RUN_DIR}/final-dumps" ]; then
		log "re-analyzing with retained final dumps for hash-only invariant maps"
		python3 "${ANALYZE_SCRIPT}" \
			--samples-dir "${RUN_DIR}/samples" \
			--map-ids "${RUN_DIR}/map-ids.json" \
			--output-spec "${RUN_DIR}/specialization-spec.json" \
			--summary "${RUN_DIR}/invariant-summary.csv" \
			--final-dumps-dir "${RUN_DIR}/final-dumps"
	fi

	# Stop exp1 after all VM-dependent post-processing has completed.
	stop_exp1_if_running

	stop_dual_vms

	log "stageA complete"
	log "artifacts: ${RUN_DIR}"
	log "spec: ${RUN_DIR}/specialization-spec.json"
}

main "$@"
