#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

THROUGHPUT_ROOT="${EXP2_MEASURE_THROUGHPUT_ROOT_DEFAULT}"
LATENCY_ROOT="${EXP2_MEASURE_LATENCY_ROOT_DEFAULT}"
OUT_ROOT="${EXP2_ANALYSIS_ROOT_DEFAULT}"
THROUGHPUT_SUITE_DIR=""
LATENCY_SUITE_DIR=""

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Analyze Exp2 outputs and produce merged summaries.

Options:
  --throughput-root <path>    Throughput suites root (default: ${THROUGHPUT_ROOT})
  --latency-root <path>       Latency suites root (default: ${LATENCY_ROOT})
  --throughput-suite <path>   Explicit throughput suite dir
  --latency-suite <path>      Explicit latency suite dir
  --out-root <path>           Analysis output root (default: ${OUT_ROOT})
  -h, --help                  Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--throughput-root)
			[ $# -gt 1 ] || exp2_die "--throughput-root requires value"
			THROUGHPUT_ROOT="$2"
			shift 2
			;;
		--latency-root)
			[ $# -gt 1 ] || exp2_die "--latency-root requires value"
			LATENCY_ROOT="$2"
			shift 2
			;;
		--throughput-suite)
			[ $# -gt 1 ] || exp2_die "--throughput-suite requires value"
			THROUGHPUT_SUITE_DIR="$2"
			shift 2
			;;
		--latency-suite)
			[ $# -gt 1 ] || exp2_die "--latency-suite requires value"
			LATENCY_SUITE_DIR="$2"
			shift 2
			;;
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
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

THROUGHPUT_ROOT="$(resolve_path_exp2 "${THROUGHPUT_ROOT}")"
LATENCY_ROOT="$(resolve_path_exp2 "${LATENCY_ROOT}")"
OUT_ROOT="$(resolve_path_exp2 "${OUT_ROOT}")"
mkdir -p "${OUT_ROOT}"

latest_dir_with_file() {
	local root="$1"
	local marker="$2"
	local d
	for d in $(ls -1dt "${root}"/* 2>/dev/null || true); do
		if [ -f "${d}/${marker}" ]; then
			printf "%s\n" "${d}"
			return 0
		fi
	done
	return 1
}

col_idx_by_name() {
	local csv="$1"
	local name="$2"
	awk -F, -v n="${name}" 'NR==1 {for(i=1;i<=NF;i++) if ($i==n) {print i; exit}}' "${csv}"
}

source_counts() {
	local csv="$1"
	local col_idx="$2"
	awk -F, -v c="${col_idx}" '
		NR>1 && $4=="ok" {
			ok += 1
			if (c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/) {
				present += 1
			} else {
				missing += 1
			}
		}
		END {printf "%d,%d,%d\n", ok+0, present+0, missing+0}
	' "${csv}"
}

build_source_outputs() {
	# Args: source_label col_idx suffix
	local source_label="$1"
	local col_idx="$2"
	local suffix="$3"
	local loss_csv="${RUN_DIR}/loss-index-${suffix}.csv"
	local med_csv="${RUN_DIR}/throughput-loss-medians-${suffix}.csv"

	{
		echo "mode,rate_pps,repeat,status,measured_pps,loss_pps,loss_rate"
		awk -F, -v c="${col_idx}" '
			NR>1 {
				if (c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/) {
					offered = $2 + 0
					measured = $c + 0
					if (measured < 0) measured = 0
					loss = offered - measured
					if (loss < 0) loss = 0
					lr = (offered > 0 ? loss / offered : 0)
					printf "%s,%s,%s,%s,%.0f,%.0f,%.6f\n", $1, $2, $3, $4, measured, loss, lr
				} else {
					printf "%s,%s,%s,%s,,,\n", $1, $2, $3, $4
				}
			}
		' "${INDEX_CSV}"
	} >"${loss_csv}"

	{
		echo "mode,rate_pps,samples,median_pps,median_loss_rate"
		awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $c}' "${INDEX_CSV}" | sort -t, -k1,1 -k2,2n -k3,3n | awk -F, '
			{
				key=$1 FS $2
				vals[key,++n[key]]=$3
			}
			END {
				for (k in n) {
					split(k,a,FS)
					m=n[k]
					if (m%2==1) med=vals[k,(m+1)/2]; else med=(vals[k,m/2]+vals[k,m/2+1])/2
					loss=(a[2]-med)
					if (loss<0) loss=0
					lr=(a[2]>0?loss/a[2]:0)
					printf "%s,%s,%d,%.3f,%.6f\n", a[1],a[2],m,med,lr
				}
			}' | sort -t, -k1,1 -k2,2n
	} >"${med_csv}"

	echo "${source_label}:${loss_csv}:${med_csv}"
}

if [ -z "${THROUGHPUT_SUITE_DIR}" ]; then
	THROUGHPUT_SUITE_DIR="$(latest_dir_with_file "${THROUGHPUT_ROOT}" "suite-index.csv" || true)"
fi
if [ -n "${THROUGHPUT_SUITE_DIR}" ]; then
	THROUGHPUT_SUITE_DIR="$(resolve_path_exp2 "${THROUGHPUT_SUITE_DIR}")"
fi

if [ -z "${LATENCY_SUITE_DIR}" ]; then
	LATENCY_SUITE_DIR="$(latest_dir_with_file "${LATENCY_ROOT}" "latency-index.csv" || true)"
fi
if [ -n "${LATENCY_SUITE_DIR}" ]; then
	LATENCY_SUITE_DIR="$(resolve_path_exp2 "${LATENCY_SUITE_DIR}")"
fi

[ -n "${THROUGHPUT_SUITE_DIR}" ] || exp2_die "throughput suite not found"
INDEX_CSV="${THROUGHPUT_SUITE_DIR}/suite-index.csv"
assert_file "${INDEX_CSV}"

RUN_ID="$(new_exp2_id analysis)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
mkdir -p "${RUN_DIR}"

cp -f "${INDEX_CSV}" "${RUN_DIR}/throughput-index.csv"

NNN_COL_IDX="$(col_idx_by_name "${INDEX_CSV}" measured_pps_nnnpps || true)"
RESULT_COL_IDX="$(col_idx_by_name "${INDEX_CSV}" measured_pps_result || true)"
EFFECTIVE_COL_IDX="$(col_idx_by_name "${INDEX_CSV}" measured_pps || true)"

# Legacy fallback: if source columns do not exist, use effective column for both labels.
if [ -z "${NNN_COL_IDX}" ]; then
	NNN_COL_IDX="${EFFECTIVE_COL_IDX}"
fi
if [ -z "${RESULT_COL_IDX}" ]; then
	RESULT_COL_IDX="${EFFECTIVE_COL_IDX}"
fi

build_source_outputs "nnnpps" "${NNN_COL_IDX:-0}" "nnnpps" >/dev/null
build_source_outputs "result" "${RESULT_COL_IDX:-0}" "result" >/dev/null

# Backward-compatible defaults: prefer NNNpps if it has data rows, else Result.
if [ "$(awk -F, 'NR>1 {n++} END {print n+0}' "${RUN_DIR}/throughput-loss-medians-nnnpps.csv")" -gt 0 ]; then
	cp -f "${RUN_DIR}/throughput-loss-medians-nnnpps.csv" "${RUN_DIR}/throughput-loss-medians.csv"
	cp -f "${RUN_DIR}/loss-index-nnnpps.csv" "${RUN_DIR}/loss-index.csv"
else
	cp -f "${RUN_DIR}/throughput-loss-medians-result.csv" "${RUN_DIR}/throughput-loss-medians.csv"
	cp -f "${RUN_DIR}/loss-index-result.csv" "${RUN_DIR}/loss-index.csv"
fi

latency_index=""
if [ -n "${LATENCY_SUITE_DIR}" ] && [ -f "${LATENCY_SUITE_DIR}/latency-index.csv" ]; then
	latency_index="${LATENCY_SUITE_DIR}/latency-index.csv"
	cp -f "${latency_index}" "${RUN_DIR}/latency-index.csv"
fi

stats_nnn="$(source_counts "${INDEX_CSV}" "${NNN_COL_IDX:-0}")"
stats_res="$(source_counts "${INDEX_CSV}" "${RESULT_COL_IDX:-0}")"
IFS=, read -r n_ok n_present n_missing <<<"${stats_nnn}"
IFS=, read -r r_ok r_present r_missing <<<"${stats_res}"

{
	echo "source,column,ok_cases,with_value,missing_value"
	echo "nnnpps,measured_pps_nnnpps,${n_ok},${n_present},${n_missing}"
	echo "result,measured_pps_result,${r_ok},${r_present},${r_missing}"
} >"${RUN_DIR}/throughput-source-summary.csv"

{
	echo "# Exp2 Analysis Summary"
	echo
	echo "- analysis_id: ${RUN_ID}"
	echo "- throughput_suite: ${THROUGHPUT_SUITE_DIR}"
	echo "- throughput_index: ${INDEX_CSV}"
	echo "- throughput_source_summary_csv: ${RUN_DIR}/throughput-source-summary.csv"
	echo "- throughput_loss_medians_nnnpps_csv: ${RUN_DIR}/throughput-loss-medians-nnnpps.csv"
	echo "- throughput_loss_medians_result_csv: ${RUN_DIR}/throughput-loss-medians-result.csv"
	echo "- throughput_loss_medians_csv (compat): ${RUN_DIR}/throughput-loss-medians.csv"
	if [ -n "${latency_index}" ]; then
		echo "- latency_suite: ${LATENCY_SUITE_DIR}"
		echo "- latency_index: ${latency_index}"
	else
		echo "- latency_suite: (not found)"
	fi
	echo
	echo "## Throughput Source Completeness"
	echo
	echo '```csv'
	cat "${RUN_DIR}/throughput-source-summary.csv"
	echo '```'
	echo
	echo "## High-Load (600k-1000k) Median Throughput: NNNpps Only"
	echo
	echo '```csv'
	awk -F, 'NR==1 || ($2+0)>=600000' "${RUN_DIR}/throughput-loss-medians-nnnpps.csv"
	echo '```'
	echo
	echo "## High-Load (600k-1000k) Median Throughput: Result packets/usec Only"
	echo
	echo '```csv'
	awk -F, 'NR==1 || ($2+0)>=600000' "${RUN_DIR}/throughput-loss-medians-result.csv"
	echo '```'
} >"${RUN_DIR}/summary.md"

exp2_log "analysis complete: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
