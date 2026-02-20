#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

MODES="baseline-no-katran katran-orig-bpf"
RATES="50000 100000 150000 200000 250000 300000 350000 400000 450000 500000 550000 600000 650000 700000 750000 800000 850000 900000 950000 1000000"
DURATION_SECS=30
REPEATS=3
LABEL="katran-suite"
CONTINUE_ON_ERROR=0
NO_PLOT=0
INTERACTIVE_PROGRESS=0
PROGRESS_INTERVAL_SECS=1
PROGRESS_FD=1

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run full mode/rate matrix and store suite artifacts under results/experiments.

Options:
  --modes "m1 m2"       Modes list (default: ${MODES})
  --rates "r1 r2"       Rates list in pps (default: ${RATES})
  --duration <sec>       Duration per run (default: ${DURATION_SECS})
  --repeats <n>          Repeats per (mode,rate) (default: ${REPEATS})
  --label <text>         Suite label (default: ${LABEL})
  --continue-on-error    Keep running next case after failure
  --progress-interval <n>  Progress refresh interval in seconds (default: ${PROGRESS_INTERVAL_SECS})
  --no-plot              Skip plot generation
  -h, --help             Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--modes)
			[ $# -gt 1 ] || die "--modes requires value"
			MODES="$2"
			shift 2
			;;
		--rates)
			[ $# -gt 1 ] || die "--rates requires value"
			RATES="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || die "--duration requires value"
			DURATION_SECS="$2"
			shift 2
			;;
		--repeats)
			[ $# -gt 1 ] || die "--repeats requires value"
			REPEATS="$2"
			shift 2
			;;
		--label)
			[ $# -gt 1 ] || die "--label requires value"
			LABEL="$2"
			shift 2
			;;
		--continue-on-error)
			CONTINUE_ON_ERROR=1
			shift
			;;
		--progress-interval)
			[ $# -gt 1 ] || die "--progress-interval requires value"
			PROGRESS_INTERVAL_SECS="$2"
			shift 2
			;;
		--no-plot)
			NO_PLOT=1
			shift
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

# Prefer writing progress to the controlling terminal so updates stay one-line
# even if stdout is wrapped by tools like make/IDE integrations.
if exec 3>/dev/tty 2>/dev/null; then
	PROGRESS_FD=3
	INTERACTIVE_PROGRESS=1
elif [ -t 1 ]; then
	PROGRESS_FD=1
	INTERACTIVE_PROGRESS=1
fi

case "${REPEATS}" in
	''|*[!0-9]*) die "--repeats must be a positive integer" ;;
	*) ;;
esac
[ "${REPEATS}" -ge 1 ] || die "--repeats must be >= 1"

case "${DURATION_SECS}" in
	''|*[!0-9]*) die "--duration must be a positive integer" ;;
	*) ;;
esac
[ "${DURATION_SECS}" -ge 1 ] || die "--duration must be >= 1"

case "${PROGRESS_INTERVAL_SECS}" in
	''|*[!0-9]*) die "--progress-interval must be a positive integer" ;;
	*) ;;
esac
[ "${PROGRESS_INTERVAL_SECS}" -ge 1 ] || die "--progress-interval must be >= 1"

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

median_of_values() {
	# Input: newline-separated numeric values on stdin.
	local values_file
	local samples
	local mid1
	local mid2
	local v1
	local v2
	values_file="$(mktemp)"
	cat >"${values_file}"
	samples="$(wc -l <"${values_file}" | awk '{print $1}')"
	if [ "${samples}" -eq 0 ]; then
		rm -f "${values_file}"
		echo ""
		return 0
	fi
	if [ $((samples % 2)) -eq 1 ]; then
		mid1=$(((samples + 1) / 2))
		sed -n "${mid1}p" "${values_file}"
	else
		mid1=$((samples / 2))
		mid2=$((mid1 + 1))
		v1="$(sed -n "${mid1}p" "${values_file}")"
		v2="$(sed -n "${mid2}p" "${values_file}")"
		awk -v a="${v1}" -v b="${v2}" 'BEGIN {if (((a + b) % 2) == 0) {printf "%.0f\n", (a + b) / 2} else {printf "%.1f\n", (a + b) / 2}}'
	fi
	rm -f "${values_file}"
}

stddev_of_values() {
	# Input: newline-separated numeric values on stdin.
	local values_file
	local samples
	values_file="$(mktemp)"
	cat >"${values_file}"
	samples="$(wc -l <"${values_file}" | awk '{print $1}')"
	if [ "${samples}" -le 1 ]; then
		rm -f "${values_file}"
		echo "0"
		return 0
	fi
	awk '{x=$1+0; n+=1; sum+=x; sumsq+=x*x} END {if (n<=1) {print "0"; exit} var=(sumsq - (sum*sum)/n)/(n-1); if (var < 0) var=0; printf "%.2f\n", sqrt(var)}' "${values_file}"
	rm -f "${values_file}"
}

write_medians_csv() {
	local out_csv="$1"
	{
		echo "mode,rate_pps,samples,median_pps,stdev_pps"
		for mode in ${MODES}; do
			for rate in ${RATES}; do
				values="$(awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r && $4=="ok" && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $5}' "${INDEX_CSV}" | sort -n)"
				samples="$(printf '%s\n' "${values}" | sed '/^$/d' | wc -l | awk '{print $1}')"
				if [ "${samples}" -gt 0 ]; then
					median_pps="$(printf '%s\n' "${values}" | median_of_values)"
					stdev_pps="$(printf '%s\n' "${values}" | stddev_of_values)"
				else
					median_pps=""
					stdev_pps=""
				fi
				echo "${mode},${rate},${samples},${median_pps},${stdev_pps}"
			done
		done
	} >"${out_csv}"
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
	local cc="${completed_cases:-0}"
	local ok="${ok_cases:-0}"
	local fail="${failed_cases:-0}"
	local total="${TOTAL_CASES:-0}"
	local start_epoch="${SUITE_START_EPOCH:-$(date +%s)}"

	now="$(date +%s)"
	elapsed=$((now - start_epoch))
	if [ "${cc}" -gt 0 ]; then
		avg_case=$((elapsed / cc))
	else
		# Use configured duration as first ETA seed before first sample completes.
		avg_case=$((DURATION_SECS + 10))
	fi
	if [ "${state}" = "running" ]; then
		shown=$((cc + 1))
	else
		shown=${cc}
	fi
	if [ "${shown}" -gt "${total}" ]; then
		shown="${total}"
	fi
	eta=$((avg_case * (total - cc)))
	if [ "${eta}" -lt 0 ]; then
		eta=0
	fi
	eta_str="$(fmt_secs "${eta}")"
	pct="$(awk -v c="${shown}" -v t="${total}" 'BEGIN {if (t>0) printf "%.1f", (100*c)/t; else printf "0.0"}')"
	if [ -n "${mode}" ]; then
		case_desc="mode=${mode} rate=${rate} rep=${rep}/${REPEATS}"
	else
		case_desc="idle"
	fi

	if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
		printf '\r[run-suite] %s %d/%d (%s%%) ok=%d fail=%d %s elapsed=%s eta=%s\033[K' \
			"${state}" "${shown}" "${total}" "${pct}" "${ok}" "${fail}" "${case_desc}" "$(fmt_secs "${elapsed}")" "${eta_str}" >&${PROGRESS_FD}
	else
		printf '[run-suite] %s %d/%d (%s%%) ok=%d fail=%d %s elapsed=%s eta=%s\n' \
			"${state}" "${shown}" "${total}" "${pct}" "${ok}" "${fail}" "${case_desc}" "$(fmt_secs "${elapsed}")" "${eta_str}"
	fi
}

MODE_COUNT="$(echo "${MODES}" | awk '{print NF}')"
RATE_COUNT="$(echo "${RATES}" | awk '{print NF}')"
TOTAL_CASES=$((MODE_COUNT * RATE_COUNT * REPEATS))
[ "${TOTAL_CASES}" -gt 0 ] || die "no cases to run"

SUITE_ID="$(new_run_id "${LABEL}")"
SUITE_DIR="${ROOT_DIR}/results/experiments/${SUITE_ID}"
SUITE_RUNS_DIR="${SUITE_DIR}/runs"
SUITE_CASE_LOGS_DIR="${SUITE_DIR}/logs-cases"
mkdir -p "${SUITE_DIR}" "${SUITE_RUNS_DIR}" "${SUITE_CASE_LOGS_DIR}"
INDEX_CSV="${SUITE_DIR}/suite-index.csv"
MEDIAN_CSV="${SUITE_DIR}/suite-medians.csv"
PLOT_SCRIPT="${SCRIPT_DIR}/plot-suite.sh"

{
	echo "mode,rate_pps,repeat,status,measured_pps,run_dir,log_file"
} >"${INDEX_CSV}"

SUITE_START_EPOCH="$(date +%s)"
completed_cases=0
ok_cases=0
failed_cases=0

for mode in ${MODES}; do
	for rate in ${RATES}; do
		rep=1
		while [ "${rep}" -le "${REPEATS}" ]; do
			if [ "${REPEATS}" -gt 1 ]; then
				case_label="${LABEL}-${mode}-${rate}-r${rep}"
			else
				case_label="${LABEL}-${mode}-${rate}"
			fi
			case_log="${SUITE_CASE_LOGS_DIR}/${case_label}.log"
			status="ok"
			run_dir=""
			measured_pps=""

			render_progress "running" "${mode}" "${rate}" "${rep}"
			"${SCRIPT_DIR}/run-experiment.sh" --mode "${mode}" --rate-pps "${rate}" --duration "${DURATION_SECS}" --label "${case_label}" --results-dir "${SUITE_RUNS_DIR}" >"${case_log}" 2>&1 &
			case_pid=$!
			if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
				last_progress_epoch="$(date +%s)"
				while kill -0 "${case_pid}" 2>/dev/null; do
					now_epoch="$(date +%s)"
					if [ $((now_epoch - last_progress_epoch)) -ge "${PROGRESS_INTERVAL_SECS}" ]; then
						render_progress "running" "${mode}" "${rate}" "${rep}"
						last_progress_epoch="${now_epoch}"
					fi
					sleep 1
				done
			fi
			if wait "${case_pid}"; then
				status="ok"
			else
				status="failed"
			fi

			run_dir="$(awk -F= '/^RUN_DIR=/{print $2}' "${case_log}" | tail -n1)"
			if [ -n "${run_dir}" ] && [ -f "${run_dir}/summary.csv" ]; then
				measured_pps="$(awk -F, 'NR==2{print $5}' "${run_dir}/summary.csv")"
			fi

			echo "${mode},${rate},${rep},${status},${measured_pps},${run_dir},${case_log}" >>"${INDEX_CSV}"
			completed_cases=$((completed_cases + 1))
			if [ "${status}" = "ok" ]; then
				ok_cases=$((ok_cases + 1))
				render_progress "done" "${mode}" "${rate}" "${rep}"
			else
				failed_cases=$((failed_cases + 1))
				render_progress "failed" "${mode}" "${rate}" "${rep}"
			fi

			if [ "${NO_PLOT}" -eq 0 ] && [ -x "${PLOT_SCRIPT}" ]; then
				"${PLOT_SCRIPT}" --suite-dir "${SUITE_DIR}" --quiet >/dev/null 2>&1 || true
			fi

			if [ "${status}" = "failed" ] && [ "${CONTINUE_ON_ERROR}" -ne 1 ]; then
				if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
					printf "\n" >&${PROGRESS_FD}
				fi
				echo "[run-suite] failed at mode=${mode} rate=${rate} repeat=${rep}; log=${case_log}" >&2
				exit 1
			fi

			rep=$((rep + 1))
		done
	done
done

if [ "${INTERACTIVE_PROGRESS}" -eq 1 ]; then
	printf "\n" >&${PROGRESS_FD}
fi
write_medians_csv "${MEDIAN_CSV}"

if [ "${NO_PLOT}" -eq 0 ] && [ -x "${PLOT_SCRIPT}" ]; then
	"${PLOT_SCRIPT}" --suite-dir "${SUITE_DIR}" >/dev/null 2>&1 || true
fi

{
	echo "# Suite Summary"
	echo
	echo "- suite_id: ${SUITE_ID}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- repeats: ${REPEATS}"
	echo "- ok_cases: ${ok_cases}"
	echo "- failed_cases: ${failed_cases}"
	echo "- index_csv: ${INDEX_CSV}"
	echo "- medians_csv: ${MEDIAN_CSV}"
	echo "- plots_dir: ${SUITE_DIR}/plots"
	echo "- runs_dir: ${SUITE_RUNS_DIR}"
	echo "- case_logs_dir: ${SUITE_CASE_LOGS_DIR}"
	echo
	echo "## Median Throughput"
	echo
	echo '```csv'
	cat "${MEDIAN_CSV}"
	echo '```'
} >"${SUITE_DIR}/suite-summary.md"

echo "[run-suite] suite complete: ${SUITE_DIR}"
