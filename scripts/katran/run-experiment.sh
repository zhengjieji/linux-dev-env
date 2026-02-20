#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

MODE=""
RATE_PPS=200000
DURATION_SECS=30
VIP="192.168.100.100"
VIP_PORT=80
LABEL=""
NO_VM_START=0
NO_VM_SETUP=0
KATRAN_XDP_SEC="${KATRAN_XDP_SEC:-}"
DST_MAC="52:54:00:aa:00:11"
KATRAN_SRC="${ROOT_DIR}/source/katran"
KATRAN_ORACLE_SRC="${ROOT_DIR}/source/katran-exp2"
KATRAN_ORIG_OBJ="${KATRAN_BALANCER_OBJ:-${ROOT_DIR}/source/katran/build/katran/lib/bpf/balancer.bpf.o}"
KATRAN_ORACLE_OBJ="${KATRAN_ORACLE_OBJ:-${ROOT_DIR}/source/katran-exp2/build/katran/lib/bpf/balancer.bpf.o}"
RESULTS_DIR="${ROOT_DIR}/results/experiments"

usage() {
	cat <<USAGE
Usage: $(basename "$0") --mode <mode> [options]

Run one benchmark experiment and store logs/metrics under <results-dir>/<run-id>/. 

Modes:
  baseline-no-katran
  katran-orig-bpf
  katran-oracle-bpf

Options:
  --mode <name>              Experiment mode (required)
  --rate-pps <n>             Workload rate in pps (default: ${RATE_PPS})
  --duration <sec>           Workload duration seconds (default: ${DURATION_SECS})
  --vip <ip>                 VIP address (default: ${VIP})
  --vip-port <n>             VIP port (default: ${VIP_PORT})
  --label <text>             Run label suffix
  --results-dir <path>       Parent directory for run folders (default: ${RESULTS_DIR})
  --no-vm-start              Assume VMs are already running
  --no-vm-setup              Skip vm1/vm2 setup scripts
  --xdp-sec <name>           Section name for Katran object attach
  --katran-src <path>        Source root for original Katran build (default: ${KATRAN_SRC})
  --katran-obj <path>        Explicit object path for katran-orig-bpf
  --katran-oracle-src <path> Source root for oracle Katran build (default: ${KATRAN_ORACLE_SRC})
  --katran-oracle-obj <path> Explicit object path for katran-oracle-bpf
  -h, --help                 Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--mode)
			[ $# -gt 1 ] || die "--mode requires value"
			MODE="$2"
			shift 2
			;;
		--rate-pps)
			[ $# -gt 1 ] || die "--rate-pps requires value"
			RATE_PPS="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || die "--duration requires value"
			DURATION_SECS="$2"
			shift 2
			;;
		--vip)
			[ $# -gt 1 ] || die "--vip requires value"
			VIP="$2"
			shift 2
			;;
		--vip-port)
			[ $# -gt 1 ] || die "--vip-port requires value"
			VIP_PORT="$2"
			shift 2
			;;
		--label)
			[ $# -gt 1 ] || die "--label requires value"
			LABEL="$2"
			shift 2
			;;
		--results-dir)
			[ $# -gt 1 ] || die "--results-dir requires value"
			RESULTS_DIR="$2"
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
		--xdp-sec)
			[ $# -gt 1 ] || die "--xdp-sec requires value"
			KATRAN_XDP_SEC="$2"
			shift 2
			;;
		--katran-src)
			[ $# -gt 1 ] || die "--katran-src requires value"
			KATRAN_SRC="$2"
			shift 2
			;;
		--katran-obj)
			[ $# -gt 1 ] || die "--katran-obj requires value"
			KATRAN_ORIG_OBJ="$2"
			shift 2
			;;
		--katran-oracle-src)
			[ $# -gt 1 ] || die "--katran-oracle-src requires value"
			KATRAN_ORACLE_SRC="$2"
			shift 2
			;;
		--katran-oracle-obj)
			[ $# -gt 1 ] || die "--katran-oracle-obj requires value"
			KATRAN_ORACLE_OBJ="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			die "unknown option: $1"
			;;
	esac
done

[ -n "${MODE}" ] || { usage; exit 1; }
case "${MODE}" in
	baseline-no-katran|katran-orig-bpf|katran-oracle-bpf) ;;
	*) die "unsupported mode: ${MODE}" ;;
esac

require_cmd make
require_cmd awk

resolve_path() {
	case "$1" in
		/*) printf '%s\n' "$1" ;;
		*) printf '%s/%s\n' "${ROOT_DIR}" "$1" ;;
	esac
}

to_vm_repo_path() {
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

if [ -z "${LABEL}" ]; then
	LABEL="${MODE}-${RATE_PPS}pps-${DURATION_SECS}s"
fi

RESULTS_DIR="$(resolve_path "${RESULTS_DIR}")"
KATRAN_SRC="$(resolve_path "${KATRAN_SRC}")"
KATRAN_ORACLE_SRC="$(resolve_path "${KATRAN_ORACLE_SRC}")"
KATRAN_ORIG_OBJ="$(resolve_path "${KATRAN_ORIG_OBJ}")"
KATRAN_ORACLE_OBJ="$(resolve_path "${KATRAN_ORACLE_OBJ}")"
mkdir -p "${RESULTS_DIR}"

RUN_ID="$(new_run_id "${LABEL}")"
RUN_DIR="${RESULTS_DIR}/${RUN_ID}"
mkdir -p "${RUN_DIR}/logs-host" "${RUN_DIR}/logs-vm1" "${RUN_DIR}/logs-vm2" "${RUN_DIR}/metrics"

REMOTE_WORKLOAD_OUT="/tmp/katran-vm2-workload-${RUN_ID}.txt"
REMOTE_VM1_COLLECT="/tmp/katran-vm1-metrics-${RUN_ID}.txt"
REMOTE_VM2_COLLECT="/tmp/katran-vm2-metrics-${RUN_ID}.txt"

obj_for_mode() {
	case "$1" in
		katran-orig-bpf) printf '%s\n' "${KATRAN_ORIG_OBJ}" ;;
		katran-oracle-bpf) printf '%s\n' "${KATRAN_ORACLE_OBJ}" ;;
		*) printf '%s\n' "" ;;
	esac
}

src_for_mode() {
	case "$1" in
		katran-orig-bpf) printf '%s\n' "${KATRAN_SRC}" ;;
		katran-oracle-bpf) printf '%s\n' "${KATRAN_ORACLE_SRC}" ;;
		*) printf '%s\n' "" ;;
	esac
}

ensure_katran_obj_for_mode() {
	local mode="$1"
	local obj
	local src
	local default_obj
	obj="$(obj_for_mode "${mode}")"
	src="$(src_for_mode "${mode}")"
	if [ -z "${obj}" ]; then
		return 0
	fi
	if [ -f "${obj}" ]; then
		log "found object for ${mode}: ${obj}"
		return 0
	fi
	if [ -z "${src}" ] || [ ! -d "${src}/.git" ]; then
		die "object missing for ${mode}: ${obj} (source missing: ${src})"
	fi
	log "object missing for ${mode}; building from ${src}"
	if ! "${SCRIPT_DIR}/build-katran-host.sh" --src "${src}" >"${RUN_DIR}/logs-host/katran-host-build-${mode}.log" 2>&1; then
		die "katran host build failed for ${mode}; see ${RUN_DIR}/logs-host/katran-host-build-${mode}.log"
	fi
	default_obj="${src}/build/katran/lib/bpf/balancer.bpf.o"
	if [ ! -f "${obj}" ] && [ -f "${default_obj}" ] && [ "${obj}" != "${default_obj}" ]; then
		mkdir -p "$(dirname -- "${obj}")"
		cp -f "${default_obj}" "${obj}"
	fi
	[ -f "${obj}" ] || die "object still missing for ${mode}: ${obj}"
}

ensure_katran_obj_for_mode "${MODE}"

ACTIVE_KATRAN_OBJ="$(obj_for_mode "${MODE}")"
ACTIVE_KATRAN_OBJ_VM=""
if [ -n "${ACTIVE_KATRAN_OBJ}" ]; then
	ACTIVE_KATRAN_OBJ_VM="$(to_vm_repo_path "${ACTIVE_KATRAN_OBJ}" || true)"
	[ -n "${ACTIVE_KATRAN_OBJ_VM}" ] || die "cannot map object path to VM repo path: ${ACTIVE_KATRAN_OBJ}"
fi

{
	echo "run_id=${RUN_ID}"
	echo "mode=${MODE}"
	echo "rate_pps=${RATE_PPS}"
	echo "duration_secs=${DURATION_SECS}"
	echo "vip=${VIP}"
	echo "vip_port=${VIP_PORT}"
	echo "label=${LABEL}"
	echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "katran_xdp_sec=${KATRAN_XDP_SEC}"
	echo "katran_src=${KATRAN_SRC}"
	echo "katran_oracle_src=${KATRAN_ORACLE_SRC}"
	echo "katran_orig_obj=${KATRAN_ORIG_OBJ}"
	echo "katran_oracle_obj=${KATRAN_ORACLE_OBJ}"
	echo "active_katran_obj=${ACTIVE_KATRAN_OBJ}"
	echo "active_katran_obj_vm=${ACTIVE_KATRAN_OBJ_VM}"
	echo "results_dir=${RESULTS_DIR}"
} >"${RUN_DIR}/meta.env"

log "run dir: ${RUN_DIR}"

read_meta_value() {
	# Args: file key
	local f="$1"
	local key="$2"
	if [ -f "${f}" ]; then
		sed -n "s/^${key}=//p" "${f}" | head -n1
	fi
}

calc_pps_from_delta() {
	# Args: before after duration
	local before="$1"
	local after="$2"
	local duration="$3"
	if printf '%s\n' "${before}" | grep -Eq '^[0-9]+$' &&
		printf '%s\n' "${after}" | grep -Eq '^[0-9]+$' &&
		printf '%s\n' "${duration}" | grep -Eq '^[0-9]+$' &&
		[ "${duration}" -gt 0 ] && [ "${after}" -ge "${before}" ]; then
		awk -v b="${before}" -v a="${after}" -v d="${duration}" 'BEGIN {printf "%.3f", (a - b) / d}'
	fi
}

if [ "${NO_VM_START}" -eq 0 ]; then
	log "ensuring dual VMs are running"
	make -C "${ROOT_DIR}" dual-vm1 >"${RUN_DIR}/logs-host/dual-vm1.log" 2>&1
	make -C "${ROOT_DIR}" dual-vm2 >"${RUN_DIR}/logs-host/dual-vm2.log" 2>&1
fi

if [ "${NO_VM_SETUP}" -eq 0 ]; then
	log "running VM setup scripts"
	ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-setup.sh --vip ${VIP}" >"${RUN_DIR}/logs-vm1/setup.log" 2>&1
	ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-setup.sh" >"${RUN_DIR}/logs-vm2/setup.log" 2>&1
fi

log "applying mode ${MODE} on VM1"
MODE_CMD="/linux-dev-env/scripts/katran/vm1-run-mode.sh --mode ${MODE} --vip ${VIP} --vip-port ${VIP_PORT}"
if [ -n "${ACTIVE_KATRAN_OBJ_VM}" ]; then
	MODE_CMD="${MODE_CMD} --bpf-obj ${ACTIVE_KATRAN_OBJ_VM}"
fi
if [ -n "${KATRAN_XDP_SEC}" ]; then
	ssh_vm vm1 "KATRAN_XDP_SEC=${KATRAN_XDP_SEC} ${MODE_CMD}" >"${RUN_DIR}/logs-vm1/mode.log" 2>&1
else
	ssh_vm vm1 "${MODE_CMD}" >"${RUN_DIR}/logs-vm1/mode.log" 2>&1
fi

REMOTE_VM1_SNAP_BEFORE="/tmp/katran-vm1-snapshot-before-${RUN_ID}.env"
REMOTE_VM1_SNAP_AFTER="/tmp/katran-vm1-snapshot-after-${RUN_ID}.env"

log "capturing VM1 counters before workload"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-collect.sh --mode ${MODE} --snapshot-only --output ${REMOTE_VM1_SNAP_BEFORE}" >"${RUN_DIR}/logs-vm1/snapshot-before.log" 2>&1
ssh_vm vm1 "cat ${REMOTE_VM1_SNAP_BEFORE}" >"${RUN_DIR}/metrics/vm1-snapshot-before.env"

log "running workload on VM2"
ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-run-workload.sh --vip ${VIP} --dport ${VIP_PORT} --rate-pps ${RATE_PPS} --duration ${DURATION_SECS} --dst-mac ${DST_MAC} --output ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/logs-vm2/workload.log" 2>&1

log "capturing VM1 counters after workload"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-collect.sh --mode ${MODE} --snapshot-only --output ${REMOTE_VM1_SNAP_AFTER}" >"${RUN_DIR}/logs-vm1/snapshot-after.log" 2>&1
ssh_vm vm1 "cat ${REMOTE_VM1_SNAP_AFTER}" >"${RUN_DIR}/metrics/vm1-snapshot-after.env"

VM1_DATA_IFACE="$(read_meta_value "${RUN_DIR}/metrics/vm1-snapshot-after.env" data_iface)"
VM1_RX_BEFORE="$(read_meta_value "${RUN_DIR}/metrics/vm1-snapshot-before.env" vm1_rx_packets)"
VM1_RX_AFTER="$(read_meta_value "${RUN_DIR}/metrics/vm1-snapshot-after.env" vm1_rx_packets)"
BACKEND_RX_BEFORE="$(read_meta_value "${RUN_DIR}/metrics/vm1-snapshot-before.env" backend_rx_packets)"
BACKEND_RX_AFTER="$(read_meta_value "${RUN_DIR}/metrics/vm1-snapshot-after.env" backend_rx_packets)"
VM1_RX_PPS="$(calc_pps_from_delta "${VM1_RX_BEFORE}" "${VM1_RX_AFTER}" "${DURATION_SECS}")"
BACKEND_DELIVERED_PPS="$(calc_pps_from_delta "${BACKEND_RX_BEFORE}" "${BACKEND_RX_AFTER}" "${DURATION_SECS}")"

log "collecting metrics"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-collect.sh --mode ${MODE} --output ${REMOTE_VM1_COLLECT}" >"${RUN_DIR}/logs-vm1/collect.log" 2>&1
ssh_vm vm1 "cat ${REMOTE_VM1_COLLECT}" >"${RUN_DIR}/metrics/vm1.txt"

ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-collect.sh --output ${REMOTE_VM2_COLLECT} --workload-output ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/logs-vm2/collect.log" 2>&1
ssh_vm vm2 "cat ${REMOTE_VM2_COLLECT}" >"${RUN_DIR}/metrics/vm2.txt"
ssh_vm vm2 "cat ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/metrics/vm2-workload.txt"

RESULT_LINE="$(grep -m1 '^Result:' "${RUN_DIR}/metrics/vm2-workload.txt" || true)"
PPS_LINE="$(grep -m1 '^[[:space:]]*[0-9][0-9]*pps[[:space:]]' "${RUN_DIR}/metrics/vm2-workload.txt" || true)"
MEASURED_PPS_NNNPPS="$(echo "${PPS_LINE}" | sed -n 's/^[[:space:]]*\([0-9][0-9]*\)pps.*/\1/p')"

RESULT_USEC="$(echo "${RESULT_LINE}" | sed -n 's/.*OK: \([0-9][0-9]*\)(.*/\1/p')"
RESULT_PKTS="$(echo "${RESULT_LINE}" | sed -n 's/.* usec, \([0-9][0-9]*\) (.*/\1/p')"
MEASURED_PPS_RESULT=""
if [ -n "${RESULT_USEC}" ] && [ -n "${RESULT_PKTS}" ] && [ "${RESULT_USEC}" -gt 0 ]; then
	MEASURED_PPS_RESULT="$(awk -v pkts="${RESULT_PKTS}" -v usec="${RESULT_USEC}" 'BEGIN {printf "%.0f", (pkts * 1000000) / usec}')"
fi

# Backward-compatible effective value: prefer explicit NNNpps, fallback to packets/usec.
MEASURED_PPS=""
MEASURED_PPS_SOURCE="missing"
MEASUREMENT_NOTE="missing_nnnpps_and_result"
if [ -n "${MEASURED_PPS_NNNPPS}" ]; then
	MEASURED_PPS="${MEASURED_PPS_NNNPPS}"
	MEASURED_PPS_SOURCE="nnnpps"
	if [ -n "${MEASURED_PPS_RESULT}" ]; then
		if [ "${MEASURED_PPS_RESULT}" = "${MEASURED_PPS_NNNPPS}" ]; then
			MEASUREMENT_NOTE="both_present_match"
		else
			MEASUREMENT_NOTE="both_present_diff"
		fi
	else
		MEASUREMENT_NOTE="nnnpps_only"
	fi
elif [ -n "${MEASURED_PPS_RESULT}" ]; then
	MEASURED_PPS="${MEASURED_PPS_RESULT}"
	MEASURED_PPS_SOURCE="result"
	MEASUREMENT_NOTE="fallback_result"
fi

{
	echo "run_id,mode,rate_pps,duration_secs,measured_pps,measured_pps_source,measured_pps_nnnpps,measured_pps_result,result_usec,result_packets,measurement_note,result_line,vm1_data_iface,vm1_rx_packets_before,vm1_rx_packets_after,vm1_rx_pps,backend_rx_packets_before,backend_rx_packets_after,backend_delivered_pps"
	echo "${RUN_ID},${MODE},${RATE_PPS},${DURATION_SECS},${MEASURED_PPS},${MEASURED_PPS_SOURCE},${MEASURED_PPS_NNNPPS},${MEASURED_PPS_RESULT},${RESULT_USEC},${RESULT_PKTS},${MEASUREMENT_NOTE},\"${RESULT_LINE//\"/\"\"}\",${VM1_DATA_IFACE},${VM1_RX_BEFORE},${VM1_RX_AFTER},${VM1_RX_PPS},${BACKEND_RX_BEFORE},${BACKEND_RX_AFTER},${BACKEND_DELIVERED_PPS}"
} >"${RUN_DIR}/summary.csv"

{
	echo "# Experiment Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- mode: ${MODE}"
	echo "- rate_pps: ${RATE_PPS}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- measured_pps: ${MEASURED_PPS}"
	echo "- measured_pps_source: ${MEASURED_PPS_SOURCE}"
	echo "- measured_pps_nnnpps: ${MEASURED_PPS_NNNPPS}"
	echo "- measured_pps_result: ${MEASURED_PPS_RESULT}"
	echo "- measurement_note: ${MEASUREMENT_NOTE}"
	echo "- vm1_data_iface: ${VM1_DATA_IFACE}"
	echo "- vm1_rx_packets_before: ${VM1_RX_BEFORE}"
	echo "- vm1_rx_packets_after: ${VM1_RX_AFTER}"
	echo "- vm1_rx_pps: ${VM1_RX_PPS}"
	echo "- backend_rx_packets_before: ${BACKEND_RX_BEFORE}"
	echo "- backend_rx_packets_after: ${BACKEND_RX_AFTER}"
	echo "- backend_delivered_pps: ${BACKEND_DELIVERED_PPS}"
	echo "- active_katran_obj: ${ACTIVE_KATRAN_OBJ}"
	if [ "${MEASURED_PPS_SOURCE}" = "missing" ]; then
		echo "- warning: both throughput sources are missing in workload output"
	fi
	echo
	echo "## pktgen Result"
	echo
	echo '```'
	echo "${RESULT_LINE}"
	if [ -n "${PPS_LINE}" ]; then
		echo "${PPS_LINE}"
	fi
	echo '```'
} >"${RUN_DIR}/summary.md"

log "completed run ${RUN_ID}"
echo "RUN_DIR=${RUN_DIR}"
