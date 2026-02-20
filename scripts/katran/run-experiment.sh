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
KATRAN_BALANCER_OBJ="${ROOT_DIR}/source/katran/build/katran/lib/bpf/balancer.bpf.o"
RESULTS_DIR="${ROOT_DIR}/results/experiments"

usage() {
	cat <<USAGE
Usage: $(basename "$0") --mode <mode> [options]

Run one benchmark experiment and store logs/metrics under <results-dir>/<run-id>/.

Modes:
  baseline-no-katran
  katran-orig-bpf

Options:
  --mode <name>         Experiment mode (required)
  --rate-pps <n>        Workload rate in pps (default: ${RATE_PPS})
  --duration <sec>      Workload duration seconds (default: ${DURATION_SECS})
  --vip <ip>            VIP address (default: ${VIP})
  --vip-port <n>        VIP port (default: ${VIP_PORT})
  --label <text>        Run label suffix
  --results-dir <path>  Parent directory for run folders (default: ${RESULTS_DIR})
  --no-vm-start         Assume VMs are already running
  --no-vm-setup         Skip vm1/vm2 setup scripts
  --xdp-sec <name>      Section name for Katran object attach
  -h, --help            Show this help
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
	baseline-no-katran|katran-orig-bpf) ;;
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

if [ -z "${LABEL}" ]; then
	LABEL="${MODE}-${RATE_PPS}pps-${DURATION_SECS}s"
fi

RESULTS_DIR="$(resolve_path "${RESULTS_DIR}")"
mkdir -p "${RESULTS_DIR}"

RUN_ID="$(new_run_id "${LABEL}")"
RUN_DIR="${RESULTS_DIR}/${RUN_ID}"
mkdir -p "${RUN_DIR}/logs-host" "${RUN_DIR}/logs-vm1" "${RUN_DIR}/logs-vm2" "${RUN_DIR}/metrics"

ensure_katran_obj_for_mode() {
	if [ "${MODE}" != "katran-orig-bpf" ]; then
		return 0
	fi
	if [ -f "${KATRAN_BALANCER_OBJ}" ]; then
		log "found Katran object: ${KATRAN_BALANCER_OBJ}"
		return 0
	fi
	log "Katran object missing; building on host"
	if ! "${SCRIPT_DIR}/build-katran-host.sh" >"${RUN_DIR}/logs-host/katran-host-build.log" 2>&1; then
		die "katran host build failed; see ${RUN_DIR}/logs-host/katran-host-build.log"
	fi
	[ -f "${KATRAN_BALANCER_OBJ}" ] || die "katran object still missing after build: ${KATRAN_BALANCER_OBJ}"
	log "Katran object ready"
}

ensure_katran_obj_for_mode

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
	echo "results_dir=${RESULTS_DIR}"
} >"${RUN_DIR}/meta.env"

log "run dir: ${RUN_DIR}"

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
if [ -n "${KATRAN_XDP_SEC}" ]; then
	ssh_vm vm1 "KATRAN_XDP_SEC=${KATRAN_XDP_SEC} /linux-dev-env/scripts/katran/vm1-run-mode.sh --mode ${MODE} --vip ${VIP} --vip-port ${VIP_PORT}" >"${RUN_DIR}/logs-vm1/mode.log" 2>&1
else
	ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-run-mode.sh --mode ${MODE} --vip ${VIP} --vip-port ${VIP_PORT}" >"${RUN_DIR}/logs-vm1/mode.log" 2>&1
fi

REMOTE_WORKLOAD_OUT="/tmp/katran-workload-${RUN_ID}.txt"
REMOTE_VM1_COLLECT="/tmp/katran-vm1-${RUN_ID}.txt"
REMOTE_VM2_COLLECT="/tmp/katran-vm2-${RUN_ID}.txt"

log "running workload on VM2"
ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-run-workload.sh --vip ${VIP} --dport ${VIP_PORT} --rate-pps ${RATE_PPS} --duration ${DURATION_SECS} --dst-mac ${DST_MAC} --output ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/logs-vm2/workload.log" 2>&1

log "collecting metrics"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-collect.sh --mode ${MODE} --output ${REMOTE_VM1_COLLECT}" >"${RUN_DIR}/logs-vm1/collect.log" 2>&1
ssh_vm vm1 "cat ${REMOTE_VM1_COLLECT}" >"${RUN_DIR}/metrics/vm1.txt"

ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-collect.sh --output ${REMOTE_VM2_COLLECT} --workload-output ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/logs-vm2/collect.log" 2>&1
ssh_vm vm2 "cat ${REMOTE_VM2_COLLECT}" >"${RUN_DIR}/metrics/vm2.txt"
ssh_vm vm2 "cat ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/metrics/vm2-workload.txt"

RESULT_LINE="$(grep -m1 '^Result:' "${RUN_DIR}/metrics/vm2-workload.txt" || true)"
PPS_LINE="$(grep -m1 '^[[:space:]]*[0-9][0-9]*pps[[:space:]]' "${RUN_DIR}/metrics/vm2-workload.txt" || true)"
MEASURED_PPS="$(echo "${PPS_LINE}" | sed -n 's/^[[:space:]]*\([0-9][0-9]*\)pps.*/\1/p')"

if [ -z "${MEASURED_PPS}" ]; then
	RESULT_USEC="$(echo "${RESULT_LINE}" | sed -n 's/.*OK: \([0-9][0-9]*\)(.*/\1/p')"
	RESULT_PKTS="$(echo "${RESULT_LINE}" | sed -n 's/.* usec, \([0-9][0-9]*\) (.*/\1/p')"
	if [ -n "${RESULT_USEC}" ] && [ -n "${RESULT_PKTS}" ] && [ "${RESULT_USEC}" -gt 0 ]; then
		MEASURED_PPS="$(awk -v pkts="${RESULT_PKTS}" -v usec="${RESULT_USEC}" 'BEGIN {printf "%.0f", (pkts * 1000000) / usec}')"
	fi
fi

{
	echo "run_id,mode,rate_pps,duration_secs,measured_pps,result_line"
	echo "${RUN_ID},${MODE},${RATE_PPS},${DURATION_SECS},${MEASURED_PPS},\"${RESULT_LINE//\"/\"\"}\""
} >"${RUN_DIR}/summary.csv"

{
	echo "# Experiment Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- mode: ${MODE}"
	echo "- rate_pps: ${RATE_PPS}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- measured_pps: ${MEASURED_PPS}"
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
