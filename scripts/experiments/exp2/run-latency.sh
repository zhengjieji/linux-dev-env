#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_MEASURE_LATENCY_ROOT_DEFAULT}"
MODES="baseline-no-katran katran-orig-bpf katran-oracle-bpf"
RATES="${EXP2_DEFAULT_RATES}"
REPEATS=3
DURATION_SECS=30
PING_INTERVAL_SECS="0.02"
PROGRESS_INTERVAL_SECS=1
LABEL="exp2-latency"
NO_VM_START=0
NO_VM_SETUP=0
DRY_RUN=0
ORACLE_OBJ="${EXP2_ORACLE_OBJ_DEFAULT}"
VIP="192.168.100.100"
VIP_PORT=80

INTERACTIVE_PROGRESS=0
PROGRESS_FD=1

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 latency sub-run under load.

Method:
  For each (mode,rate,repeat), run pktgen load and collect ICMP RTT samples to VIP in parallel.
  This is an under-load RTT proxy, not a direct per-packet LB service latency trace.

Options:
  --out-root <path>         Output root (default: ${OUT_ROOT})
  --modes "..."            Modes list (default: ${MODES})
  --rates "..."            Offered pps list (default: ${RATES})
  --repeats <n>             Repeats per (mode,rate) (default: ${REPEATS})
  --duration <sec>          Duration per case (default: ${DURATION_SECS})
  --ping-interval <sec>     Ping interval (default: ${PING_INTERVAL_SECS})
  --progress-interval <n>   Progress refresh interval in seconds (default: ${PROGRESS_INTERVAL_SECS})
  --label <text>            Label prefix (default: ${LABEL})
  --oracle-obj <path>       Oracle object path (default: ${ORACLE_OBJ})
  --vip <ip>                VIP for load/ping (default: ${VIP})
  --vip-port <n>            VIP port for load (default: ${VIP_PORT})
  --no-vm-start             Assume VMs already running
  --no-vm-setup             Skip vm setup scripts
  --dry-run                 Print steps only
  -h, --help                Show this help
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
		--ping-interval)
			[ $# -gt 1 ] || exp2_die "--ping-interval requires value"
			PING_INTERVAL_SECS="$2"
			shift 2
			;;
		--progress-interval)
			[ $# -gt 1 ] || exp2_die "--progress-interval requires value"
			PROGRESS_INTERVAL_SECS="$2"
			shift 2
			;;
		--label)
			[ $# -gt 1 ] || exp2_die "--label requires value"
			LABEL="$2"
			shift 2
			;;
		--oracle-obj)
			[ $# -gt 1 ] || exp2_die "--oracle-obj requires value"
			ORACLE_OBJ="$2"
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

case "${REPEATS}" in
	''|*[!0-9]*) exp2_die "--repeats must be a positive integer" ;;
	*) ;;
esac
[ "${REPEATS}" -ge 1 ] || exp2_die "--repeats must be >= 1"

case "${DURATION_SECS}" in
	''|*[!0-9]*) exp2_die "--duration must be a positive integer" ;;
	*) ;;
esac
[ "${DURATION_SECS}" -ge 1 ] || exp2_die "--duration must be >= 1"

case "${PROGRESS_INTERVAL_SECS}" in
	''|*[!0-9]*) exp2_die "--progress-interval must be a positive integer" ;;
	*) ;;
esac
[ "${PROGRESS_INTERVAL_SECS}" -ge 1 ] || exp2_die "--progress-interval must be >= 1"

if [ -t 1 ]; then
	INTERACTIVE_PROGRESS=1
fi

fmt_secs() {
	local total="$1"
	local h
	local m
	local s
	h=$((total / 3600))
	m=$(((total % 3600) / 60))
	s=$((total % 60))
	printf "%02d:%02d:%02d" "${h}" "${m}" "${s}"
}

render_progress() {
	local state="$1"
	local mode="$2"
	local rate="$3"
	local rep="$4"
	local now
	local elapsed
	local avg_case
	local eta
	local eta_str
	local shown
	local pct
	local case_desc

	now="$(date +%s)"
	elapsed=$((now - SUITE_START_EPOCH))
	if [ "${completed_cases}" -gt 0 ]; then
		avg_case=$((elapsed / completed_cases))
	else
		avg_case=$((DURATION_SECS + 10))
	fi
	if [ "${state}" = "running" ]; then
		shown=$((completed_cases + 1))
	else
		shown="${completed_cases}"
	fi
	if [ "${shown}" -gt "${TOTAL_CASES}" ]; then
		shown="${TOTAL_CASES}"
	fi
	eta=$((avg_case * (TOTAL_CASES - completed_cases)))
	if [ "${eta}" -lt 0 ]; then
		eta=0
	fi
	eta_str="$(fmt_secs "${eta}")"
	pct="$(awk -v c="${shown}" -v t="${TOTAL_CASES}" 'BEGIN {if (t>0) printf "%.1f", (100*c)/t; else printf "0.0"}')"
	if [ -n "${mode}" ]; then
		case_desc="mode=${mode} rate=${rate} rep=${rep}/${REPEATS}"
	else
		case_desc="idle"
	fi

	if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
		printf '\r[exp2-latency] %s %d/%d (%s%%) ok=%d fail=%d %s elapsed=%s eta=%s\033[K' \
			"${state}" "${shown}" "${TOTAL_CASES}" "${pct}" "${ok_cases}" "${failed_cases}" "${case_desc}" "$(fmt_secs "${elapsed}")" "${eta_str}" >&${PROGRESS_FD}
	else
		if [ "${state}" != "running" ]; then
			printf '[exp2-latency] %s %d/%d (%s%%) ok=%d fail=%d %s elapsed=%s eta=%s\n' \
				"${state}" "${shown}" "${TOTAL_CASES}" "${pct}" "${ok_cases}" "${failed_cases}" "${case_desc}" "$(fmt_secs "${elapsed}")" "${eta_str}"
		fi
	fi
}

wait_case_pid() {
	local pid="${1:?missing case pid}"
	local mode="${2:-}"
	local rate="${3:-}"
	local rep="${4:-}"
	local last_progress_epoch
	local now_epoch

	if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
		last_progress_epoch="$(date +%s)"
		while kill -0 "${pid}" 2>/dev/null; do
			now_epoch="$(date +%s)"
			if [ $((now_epoch - last_progress_epoch)) -ge "${PROGRESS_INTERVAL_SECS}" ]; then
				render_progress "running" "${mode}" "${rate}" "${rep}"
				last_progress_epoch="${now_epoch}"
			fi
			sleep 1
		done
	fi
	wait "${pid}"
}

OUT_ROOT="$(resolve_path_exp2 "${OUT_ROOT}")"
ORACLE_OBJ="$(resolve_path_exp2 "${ORACLE_OBJ}")"
mkdir -p "${OUT_ROOT}"

RUN_ID="$(new_exp2_id "${LABEL}")"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}/cases"
INDEX_CSV="${RUN_DIR}/latency-index.csv"
echo "mode,rate_pps,repeat,status,avg_ms,p99_ms,p999_ms,packet_loss_pct,run_dir" >"${INDEX_CSV}"

if [ "${DRY_RUN}" -eq 1 ]; then
	exp2_log "[dry-run] would run latency suite into ${RUN_DIR}"
	echo "RUN_DIR=${RUN_DIR}"
	exit 0
fi

assert_file "${ORACLE_OBJ}"
maybe_start_dual_vms "${NO_VM_START}"
if [ "${NO_VM_SETUP}" -eq 0 ]; then
	"${EXP2_DIR}/vm-setup.sh" --out-root "${RUN_DIR}/setup" --no-vm-start >"${RUN_DIR}/vm-setup.log" 2>&1
fi

compute_percentile() {
	local values_file="$1"
	local percentile="$2"
	local n
	n=$(wc -l <"${values_file}" | awk '{print $1}')
	if [ "${n}" -eq 0 ]; then
		echo ""
		return 0
	fi
	idx=$(awk -v n="${n}" -v p="${percentile}" 'BEGIN {v=int((p*n)+0.999999); if (v<1) v=1; if (v>n) v=n; print v}')
	sed -n "${idx}p" "${values_file}"
}

extract_rtt_values() {
	local ping_file="$1"
	local out_file="$2"
	# Parse RTT values from ping output without relying on ripgrep.
	awk '
		{
			for (i = 1; i <= NF; i++) {
				if ($i ~ /^time=[0-9.]+$/) {
					v = $i
					sub(/^time=/, "", v)
					print v
				}
			}
		}
	' "${ping_file}" 2>/dev/null | sort -n >"${out_file}" || true
}

MODE_COUNT="$(echo "${MODES}" | awk '{print NF}')"
RATE_COUNT="$(echo "${RATES}" | awk '{print NF}')"
TOTAL_CASES=$((MODE_COUNT * RATE_COUNT * REPEATS))
[ "${TOTAL_CASES}" -gt 0 ] || exp2_die "no latency cases to run"

SUITE_START_EPOCH="$(date +%s)"
completed_cases=0
ok_cases=0
failed_cases=0

for mode in ${MODES}; do
	for rate in ${RATES}; do
		rep=1
		while [ "${rep}" -le "${REPEATS}" ]; do
			case_id="${mode}-${rate}-r${rep}"
			case_dir="${RUN_DIR}/cases/${case_id}"
			mkdir -p "${case_dir}"
			status="ok"

			if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
				render_progress "running" "${mode}" "${rate}" "${rep}"
			else
				echo "[exp2-latency] running $((completed_cases + 1))/${TOTAL_CASES} mode=${mode} rate=${rate} rep=${rep}/${REPEATS}"
			fi

			if [ "${mode}" = "katran-oracle-bpf" ]; then
				(
					KATRAN_ORACLE_OBJ="${ORACLE_OBJ}" "${ROOT_DIR}/scripts/katran/run-experiment.sh" \
						--mode "${mode}" --rate-pps "${rate}" --duration "${DURATION_SECS}" --vip "${VIP}" --vip-port "${VIP_PORT}" \
						--label "exp2-lat-setup-${case_id}" --results-dir "${case_dir}/setup-run" --no-vm-start --no-vm-setup >"${case_dir}/setup.log" 2>&1
				) &
			else
				(
					"${ROOT_DIR}/scripts/katran/run-experiment.sh" \
						--mode "${mode}" --rate-pps "${rate}" --duration "${DURATION_SECS}" --vip "${VIP}" --vip-port "${VIP_PORT}" \
						--label "exp2-lat-setup-${case_id}" --results-dir "${case_dir}/setup-run" --no-vm-start --no-vm-setup >"${case_dir}/setup.log" 2>&1
				) &
			fi
			setup_pid=$!
			if ! wait_case_pid "${setup_pid}" "${mode}" "${rate}" "${rep}"; then
				status="failed"
			fi

			if [ "${status}" = "ok" ]; then
				REMOTE_WORKLOAD_OUT="/tmp/exp2-lat-workload-${RUN_ID}-${case_id}.txt"
				REMOTE_PING_OUT="/tmp/exp2-lat-ping-${RUN_ID}-${case_id}.txt"

				(
					ssh_vm vm2 "( /linux-dev-env/scripts/katran/vm2-run-workload.sh --vip ${VIP} --dport ${VIP_PORT} --rate-pps ${rate} --duration ${DURATION_SECS} --output ${REMOTE_WORKLOAD_OUT} >/tmp/exp2-lat-workload-bg-${RUN_ID}-${case_id}.log 2>&1 ) & ping -n -i ${PING_INTERVAL_SECS} -w ${DURATION_SECS} ${VIP} > ${REMOTE_PING_OUT} 2>&1; wait" >"${case_dir}/run.log" 2>&1
				) &
				run_pid=$!
				if ! wait_case_pid "${run_pid}" "${mode}" "${rate}" "${rep}"; then
					status="failed"
				fi

				if [ "${status}" = "ok" ]; then
					ssh_vm vm2 "cat ${REMOTE_PING_OUT}" >"${case_dir}/ping.txt" 2>/dev/null || true
					ssh_vm vm2 "cat ${REMOTE_WORKLOAD_OUT}" >"${case_dir}/workload.txt" 2>/dev/null || true
					extract_rtt_values "${case_dir}/ping.txt" "${case_dir}/rtt-ms.values"
					avg_ms="$(awk '{sum+=$1;n++} END{if(n>0) printf "%.3f", sum/n}' "${case_dir}/rtt-ms.values")"
					p99_ms="$(compute_percentile "${case_dir}/rtt-ms.values" 0.99)"
					p999_ms="$(compute_percentile "${case_dir}/rtt-ms.values" 0.999)"
					packet_loss_pct="$(sed -n 's/.*, \([0-9]\+\)% packet loss.*/\1/p' "${case_dir}/ping.txt" | tail -n1)"
				else
					avg_ms=""
					p99_ms=""
					p999_ms=""
					packet_loss_pct=""
				fi
			else
				avg_ms=""
				p99_ms=""
				p999_ms=""
				packet_loss_pct=""
			fi

			echo "${mode},${rate},${rep},${status},${avg_ms},${p99_ms},${p999_ms},${packet_loss_pct},${case_dir}" >>"${INDEX_CSV}"
			completed_cases=$((completed_cases + 1))
			if [ "${status}" = "ok" ]; then
				ok_cases=$((ok_cases + 1))
			else
				failed_cases=$((failed_cases + 1))
			fi
			render_progress "done" "${mode}" "${rate}" "${rep}"
			rep=$((rep + 1))
		done
	done
done

if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
	printf '\n'
fi

{
	echo "# Exp2 Latency Suite"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- run_dir: ${RUN_DIR}"
	echo "- index_csv: ${INDEX_CSV}"
	echo "- modes: ${MODES}"
	echo "- rates: ${RATES}"
	echo "- repeats: ${REPEATS}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- ping_interval_secs: ${PING_INTERVAL_SECS}"
	echo "- progress_interval_secs: ${PROGRESS_INTERVAL_SECS}"
} >"${RUN_DIR}/summary.md"

exp2_log "latency suite complete: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
