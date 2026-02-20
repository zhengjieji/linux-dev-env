#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

SUITE_DIR=""
INDEX_CSV=""
OUT_DIR=""
QUIET=0
INSTALL_GNUPLOT_USER=0
GNUPLOT_BIN="${GNUPLOT_BIN:-}"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Generate suite throughput plots from suite-index.csv.

Options:
  --suite-dir <path>          Suite directory containing suite-index.csv
  --index-csv <path>          Path to suite-index.csv (alternative to --suite-dir)
  --out-dir <path>            Plot output directory (default: <suite-dir>/plots)
  --gnuplot-bin <path>        Explicit gnuplot binary
  --install-gnuplot-user      Auto-install gnuplot in user space if missing
  --quiet                     Suppress informational output
  -h, --help                  Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--suite-dir)
			[ $# -gt 1 ] || { echo "--suite-dir requires value" >&2; exit 1; }
			SUITE_DIR="$2"
			shift 2
			;;
		--index-csv)
			[ $# -gt 1 ] || { echo "--index-csv requires value" >&2; exit 1; }
			INDEX_CSV="$2"
			shift 2
			;;
		--out-dir)
			[ $# -gt 1 ] || { echo "--out-dir requires value" >&2; exit 1; }
			OUT_DIR="$2"
			shift 2
			;;
		--gnuplot-bin)
			[ $# -gt 1 ] || { echo "--gnuplot-bin requires value" >&2; exit 1; }
			GNUPLOT_BIN="$2"
			shift 2
			;;
		--install-gnuplot-user)
			INSTALL_GNUPLOT_USER=1
			shift
			;;
		--quiet)
			QUIET=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "unknown option: $1" >&2
			exit 1
			;;
	esac
done

info() {
	if [ "${QUIET}" -eq 0 ]; then
		echo "$*"
	fi
}

safe_name() {
	local raw="$1"
	local cleaned
	cleaned="$(printf '%s' "${raw}" | tr -cs '[:alnum:]._-' '_')"
	cleaned="${cleaned#_}"
	cleaned="${cleaned%_}"
	if [ -z "${cleaned}" ]; then
		cleaned="mode"
	fi
	printf '%s\n' "${cleaned}"
}

median_of_values() {
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

resolve_gnuplot() {
	local user_gnuplot
	if [ -n "${GNUPLOT_BIN}" ]; then
		[ -x "${GNUPLOT_BIN}" ] || return 1
		return 0
	fi
	if command -v gnuplot >/dev/null 2>&1; then
		GNUPLOT_BIN="$(command -v gnuplot)"
		return 0
	fi
	user_gnuplot="${HOME}/.local/opt/gnuplot/bin/gnuplot"
	if [ -x "${user_gnuplot}" ]; then
		GNUPLOT_BIN="${user_gnuplot}"
		return 0
	fi
	if [ "${INSTALL_GNUPLOT_USER}" -eq 1 ]; then
		if [ "${QUIET}" -eq 1 ]; then
			"${SCRIPT_DIR}/install-gnuplot-user.sh" --quiet >/dev/null 2>&1 || true
		else
			"${SCRIPT_DIR}/install-gnuplot-user.sh" || true
		fi
		if [ -x "${user_gnuplot}" ]; then
			GNUPLOT_BIN="${user_gnuplot}"
			return 0
		fi
	fi
	return 1
}

col_idx_by_name() {
	local name="$1"
	awk -F, -v n="${name}" 'NR==1 {for (i=1;i<=NF;i++) if ($i==n) {print i; exit}}' "${INDEX_CSV}"
}

source_counts() {
	# Output: ok_cases,with_value,missing_value
	local col_idx="$1"
	awk -F, -v c="${col_idx}" '
		NR>1 && $4=="ok" {
			ok += 1
			if (c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/) {
				present += 1
			} else {
				missing += 1
			}
		}
		END {
			printf "%d,%d,%d\n", ok+0, present+0, missing+0
		}
	' "${INDEX_CSV}"
}

plot_one_source() {
	# Args: source_label col_idx suffix
	local source_label="$1"
	local col_idx="$2"
	local suffix="$3"
	local mode_map="${OUT_DIR}/modes-${suffix}.csv"
	local median_csv="${OUT_DIR}/suite-medians-live-${suffix}.csv"
	local plot_expr=""
	local pairs
	local f
	local mode
	local rate
	local values
	local samples
	local median_pps
	local stdev_pps
	local safe
	local samples_file
	local median_file
	local png_out
	local svg_out

	: >"${mode_map}"
	{
		echo "mode,rate_pps,samples,median_pps,stdev_pps"
		pairs="$(awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2}' "${INDEX_CSV}" | sort -u)"
		if [ -n "${pairs}" ]; then
			while IFS=, read -r mode rate; do
				[ -n "${mode}" ] || continue
				values="$(awk -F, -v m="${mode}" -v r="${rate}" -v c="${col_idx}" 'NR>1 && $1==m && $2==r && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $c}' "${INDEX_CSV}" | sort -n)"
				samples="$(printf '%s\n' "${values}" | sed '/^$/d' | wc -l | awk '{print $1}')"
				if [ "${samples}" -gt 0 ]; then
					median_pps="$(printf '%s\n' "${values}" | median_of_values)"
					stdev_pps="$(printf '%s\n' "${values}" | stddev_of_values)"
				else
					median_pps=""
					stdev_pps=""
				fi
				echo "${mode},${rate},${samples},${median_pps},${stdev_pps}"
			done <<<"${pairs}"
		fi
	} >"${median_csv}"

	awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $3 "," $c}' "${INDEX_CSV}" | \
	while IFS=, read -r mode rate rep pps; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${pps} ${rep}" >>"${DATA_DIR}/${suffix}-${safe}.samples.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	awk -F, 'NR>1 && $3 ~ /^[0-9]+$/ && $3>0 && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${median_csv}" | \
	while IFS=, read -r mode rate median stdev; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${median} ${stdev}" >>"${DATA_DIR}/${suffix}-${safe}.median.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	if [ ! -s "${mode_map}" ]; then
		info "[plot-suite] no numeric successful ${source_label} data in ${INDEX_CSV}; skip ${suffix} plot"
		return 1
	fi

	for f in "${DATA_DIR}/${suffix}-"*.dat; do
		[ -f "${f}" ] || continue
		sort -n -k1,1 "${f}" -o "${f}"
	done

	while IFS=, read -r safe mode; do
		[ -n "${safe}" ] || continue
		samples_file="${DATA_DIR}/${suffix}-${safe}.samples.dat"
		median_file="${DATA_DIR}/${suffix}-${safe}.median.dat"
		[ -s "${median_file}" ] || continue
		if [ -n "${plot_expr}" ]; then
			plot_expr="${plot_expr}, "
		fi
		if [ -s "${samples_file}" ]; then
			plot_expr="${plot_expr}'${samples_file}' using 1:2 with points pt 7 ps 0.8 title '${mode} samples', '${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
		else
			plot_expr="${plot_expr}'${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
		fi
	done < <(sort -u "${mode_map}")

	if [ -z "${plot_expr}" ]; then
		info "[plot-suite] no plottable ${source_label} data"
		return 1
	fi

	png_out="${OUT_DIR}/throughput-vs-rate-${suffix}.png"
	svg_out="${OUT_DIR}/throughput-vs-rate-${suffix}.svg"

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${png_out}'
set title 'Katran Throughput vs Offered Rate (${SUITE_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Measured Throughput (pps)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.0f'
set pointsize 1.1
plot ${plot_expr}
GNUPLOT

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${svg_out}'
set title 'Katran Throughput vs Offered Rate (${SUITE_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Measured Throughput (pps)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.0f'
set pointsize 1.1
plot ${plot_expr}
GNUPLOT

	info "[plot-suite] wrote ${png_out}"
	info "[plot-suite] wrote ${svg_out}"
	info "[plot-suite] wrote ${median_csv}"
	return 0
}

plot_metric_from_index() {
	# Args: metric_label index_col suffix y_label
	local metric_label="$1"
	local col_idx="$2"
	local suffix="$3"
	local y_label="$4"
	local mode_map="${OUT_DIR}/modes-${suffix}.csv"
	local median_csv="${OUT_DIR}/${suffix}-median-stdev.csv"
	local plot_expr=""
	local pairs
	local mode
	local rate
	local values
	local samples
	local median_val
	local stdev_val
	local safe
	local samples_file
	local median_file
	local png_out="${OUT_DIR}/${suffix}-vs-rate.png"
	local svg_out="${OUT_DIR}/${suffix}-vs-rate.svg"
	local f

	if [ -z "${col_idx}" ] || [ "${col_idx}" = "0" ]; then
		info "[plot-suite] column missing for ${metric_label}; skip"
		return 1
	fi

	: >"${mode_map}"
	{
		echo "mode,rate_pps,samples,median,stdev"
		pairs="$(awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2}' "${INDEX_CSV}" | sort -u)"
		if [ -n "${pairs}" ]; then
			while IFS=, read -r mode rate; do
				[ -n "${mode}" ] || continue
				values="$(awk -F, -v m="${mode}" -v r="${rate}" -v c="${col_idx}" 'NR>1 && $1==m && $2==r && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $c}' "${INDEX_CSV}" | sort -n)"
				samples="$(printf '%s\n' "${values}" | sed '/^$/d' | wc -l | awk '{print $1}')"
				if [ "${samples}" -gt 0 ]; then
					median_val="$(printf '%s\n' "${values}" | median_of_values)"
					stdev_val="$(printf '%s\n' "${values}" | stddev_of_values)"
				else
					median_val=""
					stdev_val=""
				fi
				echo "${mode},${rate},${samples},${median_val},${stdev_val}"
			done <<<"${pairs}"
		fi
	} >"${median_csv}"

	awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $3 "," $c}' "${INDEX_CSV}" | \
	while IFS=, read -r mode rate rep value; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${value} ${rep}" >>"${DATA_DIR}/${suffix}-${safe}.samples.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	awk -F, 'NR>1 && $3 ~ /^[0-9]+$/ && $3>0 && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${median_csv}" | \
	while IFS=, read -r mode rate median stdev; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${median} ${stdev}" >>"${DATA_DIR}/${suffix}-${safe}.median.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	if [ ! -s "${mode_map}" ]; then
		info "[plot-suite] no numeric data for ${metric_label}; skip"
		return 1
	fi

	for f in "${DATA_DIR}/${suffix}-"*.dat; do
		[ -f "${f}" ] || continue
		sort -n -k1,1 "${f}" -o "${f}"
	done

	while IFS=, read -r safe mode; do
		[ -n "${safe}" ] || continue
		samples_file="${DATA_DIR}/${suffix}-${safe}.samples.dat"
		median_file="${DATA_DIR}/${suffix}-${safe}.median.dat"
		[ -s "${median_file}" ] || continue
		if [ -n "${plot_expr}" ]; then
			plot_expr="${plot_expr}, "
		fi
		if [ -s "${samples_file}" ]; then
			plot_expr="${plot_expr}'${samples_file}' using 1:2 with points pt 7 ps 0.8 title '${mode} samples', '${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
		else
			plot_expr="${plot_expr}'${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
		fi
	done < <(sort -u "${mode_map}")

	if [ -z "${plot_expr}" ]; then
		info "[plot-suite] no plottable data for ${metric_label}"
		return 1
	fi

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${png_out}'
set title '${metric_label} vs Offered Rate (${SUITE_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel '${y_label}'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set pointsize 1.1
plot ${plot_expr}
GNUPLOT

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${svg_out}'
set title '${metric_label} vs Offered Rate (${SUITE_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel '${y_label}'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set pointsize 1.1
plot ${plot_expr}
GNUPLOT

	info "[plot-suite] wrote ${png_out}"
	info "[plot-suite] wrote ${svg_out}"
	info "[plot-suite] wrote ${median_csv}"
	return 0
}

if [ -z "${SUITE_DIR}" ] && [ -z "${INDEX_CSV}" ]; then
	INDEX_CSV="$(ls -1t "${ROOT_DIR}"/results/experiments/*/suite-index.csv 2>/dev/null | head -n1 || true)"
	if [ -n "${INDEX_CSV}" ]; then
		SUITE_DIR="$(cd -- "$(dirname -- "${INDEX_CSV}")" && pwd)"
	fi
fi

if [ -n "${SUITE_DIR}" ] && [ -z "${INDEX_CSV}" ]; then
	INDEX_CSV="${SUITE_DIR}/suite-index.csv"
fi

if [ -z "${INDEX_CSV}" ] || [ ! -f "${INDEX_CSV}" ]; then
	echo "[plot-suite] suite-index.csv not found" >&2
	exit 1
fi

if [ -z "${SUITE_DIR}" ]; then
	SUITE_DIR="$(cd -- "$(dirname -- "${INDEX_CSV}")" && pwd)"
fi

if [ -z "${OUT_DIR}" ]; then
	OUT_DIR="${SUITE_DIR}/plots"
fi
mkdir -p "${OUT_DIR}"

if ! resolve_gnuplot; then
	cat >"${OUT_DIR}/README.txt" <<TXT
Plot generation skipped: 'gnuplot' is not installed on host.
Install without sudo:
  ${SCRIPT_DIR}/install-gnuplot-user.sh
Then rerun:
  ${SCRIPT_DIR}/plot-suite.sh --suite-dir ${SUITE_DIR}
Or auto-install during plotting:
  ${SCRIPT_DIR}/plot-suite.sh --suite-dir ${SUITE_DIR} --install-gnuplot-user
TXT
	info "[plot-suite] gnuplot not found; wrote ${OUT_DIR}/README.txt"
	exit 0
fi
rm -f "${OUT_DIR}/README.txt"

DATA_DIR="${OUT_DIR}/data"
SOURCE_SUMMARY_CSV="${OUT_DIR}/throughput-source-summary.csv"
rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"

SUITE_NAME="$(basename -- "${SUITE_DIR}")"
NNN_COL_IDX="$(col_idx_by_name measured_pps_nnnpps || true)"
RESULT_COL_IDX="$(col_idx_by_name measured_pps_result || true)"
EFFECTIVE_COL_IDX="$(col_idx_by_name measured_pps || true)"
NNN_SOURCE_NAME="measured_pps_nnnpps"
RESULT_SOURCE_NAME="measured_pps_result"
if [ -z "${NNN_COL_IDX}" ]; then
	NNN_COL_IDX="${EFFECTIVE_COL_IDX}"
	NNN_SOURCE_NAME="measured_pps (legacy)"
fi
if [ -z "${RESULT_COL_IDX}" ]; then
	RESULT_COL_IDX="${EFFECTIVE_COL_IDX}"
	RESULT_SOURCE_NAME="measured_pps (legacy)"
fi

: >"${SOURCE_SUMMARY_CSV}"
echo "source,column,ok_cases,with_value,missing_value" >"${SOURCE_SUMMARY_CSV}"

stats_nnn="$(source_counts "${NNN_COL_IDX:-0}")"
stats_res="$(source_counts "${RESULT_COL_IDX:-0}")"
IFS=, read -r n_ok n_present n_missing <<<"${stats_nnn}"
IFS=, read -r r_ok r_present r_missing <<<"${stats_res}"
echo "nnnpps,${NNN_SOURCE_NAME},${n_ok},${n_present},${n_missing}" >>"${SOURCE_SUMMARY_CSV}"
echo "result,${RESULT_SOURCE_NAME},${r_ok},${r_present},${r_missing}" >>"${SOURCE_SUMMARY_CSV}"

nnn_ok_plot=0
res_ok_plot=0
if plot_one_source "NNNpps line" "${NNN_COL_IDX:-0}" "nnnpps"; then
	nnn_ok_plot=1
fi
if plot_one_source "Result packets/usec" "${RESULT_COL_IDX:-0}" "result"; then
	res_ok_plot=1
fi

if [ "${nnn_ok_plot}" -eq 0 ] && [ "${res_ok_plot}" -eq 0 ]; then
	info "[plot-suite] no plottable throughput data for either source"
	exit 0
fi

# Backward-compatibility aliases:
# - prefer NNNpps output as default throughput-vs-rate.*
# - if NNNpps missing, fallback to Result source.
if [ "${nnn_ok_plot}" -eq 1 ]; then
	cp -f "${OUT_DIR}/throughput-vs-rate-nnnpps.png" "${OUT_DIR}/throughput-vs-rate.png"
	cp -f "${OUT_DIR}/throughput-vs-rate-nnnpps.svg" "${OUT_DIR}/throughput-vs-rate.svg"
	cp -f "${OUT_DIR}/suite-medians-live-nnnpps.csv" "${OUT_DIR}/suite-medians-live.csv"
elif [ "${res_ok_plot}" -eq 1 ]; then
	cp -f "${OUT_DIR}/throughput-vs-rate-result.png" "${OUT_DIR}/throughput-vs-rate.png"
	cp -f "${OUT_DIR}/throughput-vs-rate-result.svg" "${OUT_DIR}/throughput-vs-rate.svg"
	cp -f "${OUT_DIR}/suite-medians-live-result.csv" "${OUT_DIR}/suite-medians-live.csv"
fi

VM1_RX_COL_IDX="$(col_idx_by_name vm1_rx_pps || true)"
BACKEND_DELIVERED_COL_IDX="$(col_idx_by_name backend_delivered_pps || true)"
VM1_RX_PLOT_OK=0
BACKEND_DELIVERED_PLOT_OK=0
if plot_metric_from_index "VM1 RX PPS" "${VM1_RX_COL_IDX:-0}" "vm1-rx-pps" "VM1 RX (pps)"; then
	VM1_RX_PLOT_OK=1
fi
if plot_metric_from_index "Backend Delivered PPS" "${BACKEND_DELIVERED_COL_IDX:-0}" "backend-delivered-pps" "Backend Delivered (pps)"; then
	BACKEND_DELIVERED_PLOT_OK=1
fi

info "[plot-suite] using gnuplot: ${GNUPLOT_BIN}"
info "[plot-suite] wrote ${SOURCE_SUMMARY_CSV}"
