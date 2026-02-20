#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

ANALYSIS_ROOT="${EXP2_ANALYSIS_ROOT_DEFAULT:-${ROOT_DIR}/results/exp2/analysis}"
ANALYSIS_DIR=""
OUT_DIR=""
GNUPLOT_BIN="${GNUPLOT_BIN:-}"
INSTALL_GNUPLOT_USER=0
QUIET=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Generate Exp2 plots from analysis outputs.

Options:
  --analysis-root <path>      Analysis root containing run directories
  --analysis-dir <path>       Explicit analysis directory
  --out-dir <path>            Plot output directory (default: <analysis-dir>/plots)
  --gnuplot-bin <path>        Explicit gnuplot binary
  --install-gnuplot-user      Auto-install gnuplot in user space if missing
  --quiet                     Suppress informational output
  -h, --help                  Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--analysis-root)
			[ $# -gt 1 ] || exp2_die "--analysis-root requires value"
			ANALYSIS_ROOT="$2"
			shift 2
			;;
		--analysis-dir)
			[ $# -gt 1 ] || exp2_die "--analysis-dir requires value"
			ANALYSIS_DIR="$2"
			shift 2
			;;
		--out-dir)
			[ $# -gt 1 ] || exp2_die "--out-dir requires value"
			OUT_DIR="$2"
			shift 2
			;;
		--gnuplot-bin)
			[ $# -gt 1 ] || exp2_die "--gnuplot-bin requires value"
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
			exp2_die "unknown option: $1"
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
			"${ROOT_DIR}/scripts/katran/install-gnuplot-user.sh" --quiet >/dev/null 2>&1 || true
		else
			"${ROOT_DIR}/scripts/katran/install-gnuplot-user.sh" || true
		fi
		if [ -x "${user_gnuplot}" ]; then
			GNUPLOT_BIN="${user_gnuplot}"
			return 0
		fi
	fi
	return 1
}

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
		awk -v a="${v1}" -v b="${v2}" 'BEGIN {printf "%.6f\n", (a + b) / 2}'
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
	awk '{x=$1+0; n+=1; sum+=x; sumsq+=x*x} END {if (n<=1) {print "0"; exit} var=(sumsq - (sum*sum)/n)/(n-1); if (var < 0) var=0; printf "%.6f\n", sqrt(var)}' "${values_file}"
	rm -f "${values_file}"
}

ANALYSIS_ROOT="$(resolve_path_exp2 "${ANALYSIS_ROOT}")"
if [ -n "${ANALYSIS_DIR}" ]; then
	ANALYSIS_DIR="$(resolve_path_exp2 "${ANALYSIS_DIR}")"
else
	ANALYSIS_DIR="$(latest_dir_with_file "${ANALYSIS_ROOT}" "throughput-loss-medians.csv" || true)"
fi

[ -n "${ANALYSIS_DIR}" ] || exp2_die "analysis directory not found"
TP_MEDIANS_CSV="${ANALYSIS_DIR}/throughput-loss-medians.csv"
TP_INDEX_CSV="${ANALYSIS_DIR}/throughput-index.csv"
LAT_INDEX_CSV="${ANALYSIS_DIR}/latency-index.csv"
assert_file "${TP_MEDIANS_CSV}"

if [ -z "${OUT_DIR}" ]; then
	OUT_DIR="${ANALYSIS_DIR}/plots"
else
	OUT_DIR="$(resolve_path_exp2 "${OUT_DIR}")"
fi
mkdir -p "${OUT_DIR}"

if ! resolve_gnuplot; then
	cat >"${OUT_DIR}/README.txt" <<TXT
Plot generation skipped: 'gnuplot' is not installed on host.
Install without sudo:
  ${ROOT_DIR}/scripts/katran/install-gnuplot-user.sh
Then rerun:
  ${EXP2_DIR}/plot.sh --analysis-dir ${ANALYSIS_DIR}
Or auto-install during plotting:
  ${EXP2_DIR}/plot.sh --analysis-dir ${ANALYSIS_DIR} --install-gnuplot-user
TXT
	info "[exp2-plot] gnuplot not found; wrote ${OUT_DIR}/README.txt"
	exit 0
fi
rm -f "${OUT_DIR}/README.txt"

DATA_DIR="${OUT_DIR}/data"
MODE_MAP="${OUT_DIR}/modes.csv"
TP_MEDIANS_NNN_CSV="${ANALYSIS_DIR}/throughput-loss-medians-nnnpps.csv"
TP_MEDIANS_RESULT_CSV="${ANALYSIS_DIR}/throughput-loss-medians-result.csv"
THROUGHPUT_STATS_NNN_CSV="${OUT_DIR}/throughput-median-stdev-nnnpps.csv"
THROUGHPUT_STATS_RESULT_CSV="${OUT_DIR}/throughput-median-stdev-result.csv"
LOSS_STATS_NNN_CSV="${OUT_DIR}/loss-median-nnnpps.csv"
LOSS_STATS_RESULT_CSV="${OUT_DIR}/loss-median-result.csv"
THROUGHPUT_SOURCE_SUMMARY_CSV="${OUT_DIR}/throughput-source-summary.csv"
LAT_STATS_CSV="/latency-peak-time.csv"
VM1_RX_STATS_CSV="/vm1-rx-pps-median-stdev.csv"
BACKEND_DELIVERED_STATS_CSV="/backend-delivered-pps-median-stdev.csv"

# Backward-compatible aliases used in final logs.
THROUGHPUT_STATS_CSV="${THROUGHPUT_STATS_NNN_CSV}"
LOSS_STATS_CSV="${LOSS_STATS_NNN_CSV}"

if [ ! -f "${TP_MEDIANS_NNN_CSV}" ] && [ -f "${TP_MEDIANS_CSV}" ]; then
	TP_MEDIANS_NNN_CSV="${TP_MEDIANS_CSV}"
fi
if [ ! -f "${TP_MEDIANS_RESULT_CSV}" ] && [ -f "${TP_MEDIANS_CSV}" ]; then
	TP_MEDIANS_RESULT_CSV="${TP_MEDIANS_CSV}"
fi

rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"
: >"${MODE_MAP}"
ANALYSIS_NAME="$(basename -- "${ANALYSIS_DIR}")"

col_idx_by_name() {
	local csv="$1"
	local name="$2"
	awk -F, -v n="${name}" 'NR==1 {for (i=1;i<=NF;i++) if ($i==n) {print i; exit}}' "${csv}"
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
		END {printf "%d,%d,%d\n", ok+0, present+0, missing+0}
	' "${TP_INDEX_CSV}"
}

plot_one_throughput_source() {
	# Args: medians_csv throughput_stats_csv loss_stats_csv index_col_idx suffix source_label
	local medians_csv="$1"
	local throughput_stats_csv="$2"
	local loss_stats_csv="$3"
	local index_col_idx="$4"
	local suffix="$5"
	local source_label="$6"
	local mode_map_source="${OUT_DIR}/modes-${suffix}.csv"
	local pairs
	local mode
	local rate
	local median_pps
	local loss_rate
	local stdev_pps
	local values
	local safe
	local med_file
	local std_file
	local loss_file
	local tplot_expr=""
	local lplot_expr=""
	local tp_png
	local tp_svg
	local loss_png
	local loss_svg
	local f

	[ -f "${medians_csv}" ] || return 1

	: >"${mode_map_source}"
	pairs="$(awk -F, 'NR>1 && $2 ~ /^[0-9]+([.][0-9]+)?$/ && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${medians_csv}")"

	{
		echo "mode,rate_pps,median_pps,stdev_pps"
		if [ -n "${pairs}" ]; then
			while IFS=, read -r mode rate median_pps loss_rate; do
				[ -n "${mode}" ] || continue
				safe="$(safe_name "${mode}")"
				echo "${rate} ${median_pps}" >>"${DATA_DIR}/throughput-${suffix}-${safe}.median.dat"
				loss_pct="$(awk -v lr="${loss_rate}" 'BEGIN {printf "%.6f", lr * 100}')"
				echo "${rate} ${loss_pct}" >>"${DATA_DIR}/loss-${suffix}-${safe}.median.dat"
				if ! grep -q "^${safe}," "${mode_map_source}" 2>/dev/null; then
					echo "${safe},${mode}" >>"${mode_map_source}"
				fi
				if ! grep -q "^${safe}," "${MODE_MAP}" 2>/dev/null; then
					echo "${safe},${mode}" >>"${MODE_MAP}"
				fi
				if [ -f "${TP_INDEX_CSV}" ]; then
					values="$(awk -F, -v m="${mode}" -v r="${rate}" -v c="${index_col_idx}" 'NR>1 && $1==m && $2==r && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $c}' "${TP_INDEX_CSV}" | sort -n)"
					stdev_pps="$(printf '%s\n' "${values}" | stddev_of_values)"
				else
					stdev_pps="0"
				fi
				echo "${rate} ${median_pps} ${stdev_pps}" >>"${DATA_DIR}/throughput-${suffix}-${safe}.stdev.dat"
				echo "${mode},${rate},${median_pps},${stdev_pps}"
			done <<<"${pairs}"
		fi
	} >"${throughput_stats_csv}"

	{
		echo "mode,rate_pps,loss_rate_pct"
		if [ -n "${pairs}" ]; then
			while IFS=, read -r mode rate _ loss_rate; do
				loss_pct="$(awk -v lr="${loss_rate}" 'BEGIN {printf "%.6f", lr * 100}')"
				echo "${mode},${rate},${loss_pct}"
			done <<<"${pairs}"
		fi
	} >"${loss_stats_csv}"

	for f in "${DATA_DIR}/${suffix}-"*.dat "${DATA_DIR}/throughput-${suffix}-"*.dat "${DATA_DIR}/loss-${suffix}-"*.dat; do
		[ -f "${f}" ] || continue
		sort -n -k1,1 "${f}" -o "${f}"
	done

	while IFS=, read -r safe mode; do
		[ -n "${safe}" ] || continue
		med_file="${DATA_DIR}/throughput-${suffix}-${safe}.median.dat"
		std_file="${DATA_DIR}/throughput-${suffix}-${safe}.stdev.dat"
		loss_file="${DATA_DIR}/loss-${suffix}-${safe}.median.dat"
		if [ -s "${med_file}" ]; then
			if [ -n "${tplot_expr}" ]; then
				tplot_expr="${tplot_expr}, "
			fi
			tplot_expr="${tplot_expr}'${std_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${med_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
		fi
		if [ -s "${loss_file}" ]; then
			if [ -n "${lplot_expr}" ]; then
				lplot_expr="${lplot_expr}, "
			fi
			lplot_expr="${lplot_expr}'${loss_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode}'"
		fi
	done < <(sort -u "${mode_map_source}")

	if [ -z "${tplot_expr}" ]; then
		info "[exp2-plot] no plottable throughput data for ${source_label}"
		return 1
	fi

	tp_png="${OUT_DIR}/throughput-median-vs-rate-${suffix}.png"
	tp_svg="${OUT_DIR}/throughput-median-vs-rate-${suffix}.svg"
	loss_png="${OUT_DIR}/loss-rate-vs-rate-${suffix}.png"
	loss_svg="${OUT_DIR}/loss-rate-vs-rate-${suffix}.svg"

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${tp_png}'
set title 'Exp2 Throughput Median vs Offered Rate (${ANALYSIS_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Measured Throughput Median (pps)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.0f'
set pointsize 1.1
plot ${tplot_expr}
GNUPLOT

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${tp_svg}'
set title 'Exp2 Throughput Median vs Offered Rate (${ANALYSIS_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Measured Throughput Median (pps)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.0f'
set pointsize 1.1
plot ${tplot_expr}
GNUPLOT

	if [ -n "${lplot_expr}" ]; then
		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${loss_png}'
set title 'Exp2 Loss Rate vs Offered Rate (${ANALYSIS_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Median Loss Rate (%)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${lplot_expr}
GNUPLOT

		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${loss_svg}'
set title 'Exp2 Loss Rate vs Offered Rate (${ANALYSIS_NAME}, ${source_label})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Median Loss Rate (%)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${lplot_expr}
GNUPLOT
	fi


plot_metric_from_index() {
	# Args: metric_label index_col suffix y_label stats_csv
	local metric_label="$1"
	local col_idx="$2"
	local suffix="$3"
	local y_label="$4"
	local stats_csv="$5"
	local mode_map="${OUT_DIR}/modes-${suffix}.csv"
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
	local plot_expr=""
	local png_out="${OUT_DIR}/${suffix}-vs-rate.png"
	local svg_out="${OUT_DIR}/${suffix}-vs-rate.svg"
	local f

	if [ -z "${col_idx}" ] || [ "${col_idx}" = "0" ]; then
		info "[exp2-plot] column missing for ${metric_label}; skip"
		return 1
	fi

	: >"${mode_map}"
	{
		echo "mode,rate_pps,samples,median,stdev"
		pairs="$(awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2}' "${TP_INDEX_CSV}" | sort -u)"
		if [ -n "${pairs}" ]; then
			while IFS=, read -r mode rate; do
				[ -n "${mode}" ] || continue
				values="$(awk -F, -v m="${mode}" -v r="${rate}" -v c="${col_idx}" 'NR>1 && $1==m && $2==r && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $c}' "${TP_INDEX_CSV}" | sort -n)"
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
	} >"${stats_csv}"

	awk -F, -v c="${col_idx}" 'NR>1 && $4=="ok" && c>0 && $c ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $3 "," $c}' "${TP_INDEX_CSV}" | \
	while IFS=, read -r mode rate rep value; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${value} ${rep}" >>"${DATA_DIR}/${suffix}-${safe}.samples.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	awk -F, 'NR>1 && $3 ~ /^[0-9]+$/ && $3>0 && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${stats_csv}" | \
	while IFS=, read -r mode rate median stdev; do
		safe="$(safe_name "${mode}")"
		echo "${rate} ${median} ${stdev}" >>"${DATA_DIR}/${suffix}-${safe}.median.dat"
		if ! grep -q "^${safe}," "${mode_map}" 2>/dev/null; then
			echo "${safe},${mode}" >>"${mode_map}"
		fi
	done

	if [ ! -s "${mode_map}" ]; then
		info "[exp2-plot] no numeric data for ${metric_label}; skip"
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
		info "[exp2-plot] no plottable data for ${metric_label}"
		return 1
	fi

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${png_out}'
set title '${metric_label} vs Offered Rate (${ANALYSIS_NAME})'
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
set title '${metric_label} vs Offered Rate (${ANALYSIS_NAME})'
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

	info "[exp2-plot] wrote ${png_out}"
	info "[exp2-plot] wrote ${svg_out}"
	info "[exp2-plot] wrote ${stats_csv}"
	return 0
}
	return 0
}

NNN_COL_IDX="$(col_idx_by_name "${TP_INDEX_CSV}" measured_pps_nnnpps || true)"
RESULT_COL_IDX="$(col_idx_by_name "${TP_INDEX_CSV}" measured_pps_result || true)"
EFFECTIVE_COL_IDX="$(col_idx_by_name "${TP_INDEX_CSV}" measured_pps || true)"
if [ -z "${NNN_COL_IDX}" ]; then
	NNN_COL_IDX="${EFFECTIVE_COL_IDX}"
fi
if [ -z "${RESULT_COL_IDX}" ]; then
	RESULT_COL_IDX="${EFFECTIVE_COL_IDX}"
fi

stats_nnn="$(source_counts "${NNN_COL_IDX:-0}")"
stats_res="$(source_counts "${RESULT_COL_IDX:-0}")"
IFS=, read -r n_ok n_present n_missing <<<"${stats_nnn}"
IFS=, read -r r_ok r_present r_missing <<<"${stats_res}"
{
	echo "source,column,ok_cases,with_value,missing_value"
	echo "nnnpps,measured_pps_nnnpps,${n_ok},${n_present},${n_missing}"
	echo "result,measured_pps_result,${r_ok},${r_present},${r_missing}"
} >"${THROUGHPUT_SOURCE_SUMMARY_CSV}"

nnn_plotted=0
res_plotted=0
if plot_one_throughput_source "${TP_MEDIANS_NNN_CSV}" "${THROUGHPUT_STATS_NNN_CSV}" "${LOSS_STATS_NNN_CSV}" "${NNN_COL_IDX:-0}" "nnnpps" "NNNpps line"; then
	nnn_plotted=1
fi
if plot_one_throughput_source "${TP_MEDIANS_RESULT_CSV}" "${THROUGHPUT_STATS_RESULT_CSV}" "${LOSS_STATS_RESULT_CSV}" "${RESULT_COL_IDX:-0}" "result" "Result packets/usec"; then
	res_plotted=1
fi

if [ "${nnn_plotted}" -eq 0 ] && [ "${res_plotted}" -eq 0 ]; then
	exp2_die "no plottable throughput data for nnnpps or result source"
fi

# Compatibility aliases for historical docs/automation.
if [ "${nnn_plotted}" -eq 1 ]; then
	cp -f "${OUT_DIR}/throughput-median-vs-rate-nnnpps.png" "${OUT_DIR}/throughput-median-vs-rate.png"
	cp -f "${OUT_DIR}/throughput-median-vs-rate-nnnpps.svg" "${OUT_DIR}/throughput-median-vs-rate.svg"
	cp -f "${OUT_DIR}/loss-rate-vs-rate-nnnpps.png" "${OUT_DIR}/loss-rate-vs-rate.png" 2>/dev/null || true
	cp -f "${OUT_DIR}/loss-rate-vs-rate-nnnpps.svg" "${OUT_DIR}/loss-rate-vs-rate.svg" 2>/dev/null || true
	THROUGHPUT_STATS_CSV="${THROUGHPUT_STATS_NNN_CSV}"
	LOSS_STATS_CSV="${LOSS_STATS_NNN_CSV}"
elif [ "${res_plotted}" -eq 1 ]; then
	cp -f "${OUT_DIR}/throughput-median-vs-rate-result.png" "${OUT_DIR}/throughput-median-vs-rate.png"
	cp -f "${OUT_DIR}/throughput-median-vs-rate-result.svg" "${OUT_DIR}/throughput-median-vs-rate.svg"
	cp -f "${OUT_DIR}/loss-rate-vs-rate-result.png" "${OUT_DIR}/loss-rate-vs-rate.png" 2>/dev/null || true
	cp -f "${OUT_DIR}/loss-rate-vs-rate-result.svg" "${OUT_DIR}/loss-rate-vs-rate.svg" 2>/dev/null || true
	THROUGHPUT_STATS_CSV="${THROUGHPUT_STATS_RESULT_CSV}"
	LOSS_STATS_CSV="${LOSS_STATS_RESULT_CSV}"
fi
if [ -f "${LAT_INDEX_CSV}" ]; then
	LAT_RAW_CSV="${OUT_DIR}/latency-peak-per-second-raw.csv"
	echo "mode,rate_pps,repeat,elapsed_sec,peak_ms" >"${LAT_RAW_CSV}"
	echo "mode,rate_pps,elapsed_sec,samples,peak_ms_median" >"${LAT_STATS_CSV}"

	run_dir_col="$(awk -F, 'NR==1 {for(i=1;i<=NF;i++) if ($i=="run_dir") {print i; exit}}' "${LAT_INDEX_CSV}")"
	if [ -z "${run_dir_col}" ]; then
		run_dir_col="$(awk -F, 'NR==1 {print NF}' "${LAT_INDEX_CSV}")"
	fi

	while IFS=, read -r mode rate rep status run_dir; do
		[ "${status}" = "ok" ] || continue
		[ -n "${run_dir}" ] || continue
		series_file="${run_dir}/rtt-time-series.csv"
		if [ ! -f "${series_file}" ] && [ -f "${run_dir}/ping.txt" ]; then
			series_file="$(mktemp)"
			suite_dir="$(dirname "$(dirname "${run_dir}")")"
			ping_interval="1"
			if [ -f "${suite_dir}/summary.md" ]; then
				interval_val="$(sed -n 's/^- ping_interval_secs: //p' "${suite_dir}/summary.md" | head -n1)"
				if printf '%s\n' "${interval_val}" | awk 'BEGIN{ok=0} /^[0-9]+([.][0-9]+)?$/ {ok=1} END{exit !ok}'; then
					ping_interval="${interval_val}"
				fi
			fi
			awk -v interval="${ping_interval}" '
				BEGIN {
					start = -1
					print "elapsed_sec,rtt_ms"
				}
				{
					ts = ""
					seq = ""
					rtt = ""
					if ($1 ~ /^\[[0-9]+\.[0-9]+\]$/) {
						ts = $1
						sub(/^\[/, "", ts)
						sub(/\]$/, "", ts)
					}
					for (i = 1; i <= NF; i++) {
						if ($i ~ /^icmp_seq=[0-9]+$/) {
							seq = $i
							sub(/^icmp_seq=/, "", seq)
						}
						if ($i ~ /^time=[0-9.]+$/) {
							rtt = $i
							sub(/^time=/, "", rtt)
						}
					}
					if (rtt != "") {
						if (ts != "") {
							ts_num = ts + 0
							if (start < 0) start = ts_num
							printf "%.6f,%.3f\n", ts_num - start, rtt + 0
						} else if (seq != "") {
							printf "%.6f,%.3f\n", (seq - 1) * interval, rtt + 0
						}
					}
				}
			' "${run_dir}/ping.txt" >"${series_file}" 2>/dev/null || true
		fi
		if [ -f "${series_file}" ]; then
			awk -F, -v mode="${mode}" -v rate="${rate}" -v rep="${rep}" '
				NR>1 && $1 ~ /^[0-9]+([.][0-9]+)?$/ && $2 ~ /^[0-9]+([.][0-9]+)?$/ {
					sec = int($1)
					val = $2 + 0
					if (!(sec in max) || val > max[sec]) {
						max[sec] = val
					}
				}
				END {
					for (sec in max) {
						printf "%s,%s,%s,%d,%.6f\n", mode, rate, rep, sec, max[sec]
					}
				}
			' "${series_file}" >>"${LAT_RAW_CSV}"
		fi
		if [ "${series_file}" != "${run_dir}/rtt-time-series.csv" ] && [ -f "${series_file}" ]; then
			rm -f "${series_file}"
		fi
	done < <(awk -F, -v rc="${run_dir_col}" 'NR>1 {print $1 "," $2 "," $3 "," $4 "," $rc}' "${LAT_INDEX_CSV}")

	if [ "$(wc -l <"${LAT_RAW_CSV}" | awk '{print $1}')" -gt 1 ]; then
		sort -t, -k1,1 -k2,2n -k4,4n -k5,5n "${LAT_RAW_CSV}" | awk -F, '
			NR==1 {next}
			function flush_group() {
				if (count == 0) return
				if (count % 2 == 1) {
					med = vals[(count + 1) / 2]
				} else {
					med = (vals[count / 2] + vals[count / 2 + 1]) / 2
				}
				printf "%s,%s,%s,%d,%.6f\n", mode_cur, rate_cur, sec_cur, count, med
			}
			{
				key = $1 FS $2 FS $4
				if (NR == 2) {
					key_cur = key
					mode_cur = $1
					rate_cur = $2
					sec_cur = $4
					count = 0
				}
				if (key != key_cur) {
					flush_group()
					delete vals
					count = 0
					key_cur = key
					mode_cur = $1
					rate_cur = $2
					sec_cur = $4
				}
				vals[++count] = $5 + 0
			}
			END {
				flush_group()
			}
		' >>"${LAT_STATS_CSV}"

		pairs_lat="$(awk -F, 'NR>1 {print $1 "," $2}' "${LAT_STATS_CSV}" | sort -u)"
		if [ -n "${pairs_lat}" ]; then
			while IFS=, read -r mode rate; do
				[ -n "${mode}" ] || continue
				safe="$(safe_name "${mode}")"
				lat_file="${DATA_DIR}/latency-peak-time-${safe}-${rate}.dat"
				awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r {print $3 " " $5}' "${LAT_STATS_CSV}" | sort -n -k1,1 >"${lat_file}"
			done <<<"${pairs_lat}"
		fi

		rates_lat="$(awk -F, 'NR>1 {print $2}' "${LAT_STATS_CSV}" | sort -n -u)"
		for rate in ${rates_lat}; do
			LAT_PLOT_EXPR=""
			while IFS=, read -r safe mode; do
				[ -n "${safe}" ] || continue
				lat_file="${DATA_DIR}/latency-peak-time-${safe}-${rate}.dat"
				if [ -s "${lat_file}" ]; then
					if [ -n "${LAT_PLOT_EXPR}" ]; then
						LAT_PLOT_EXPR="${LAT_PLOT_EXPR}, "
					fi
					LAT_PLOT_EXPR="${LAT_PLOT_EXPR}'${lat_file}' using 1:2 with lines lw 2 title '${mode}'"
				fi
			done < <(sort -u "${MODE_MAP}")

			if [ -n "${LAT_PLOT_EXPR}" ]; then
				LAT_PEAK_PNG="${OUT_DIR}/latency-peak-vs-time-rate-${rate}.png"
				LAT_PEAK_SVG="${OUT_DIR}/latency-peak-vs-time-rate-${rate}.svg"
				# shellcheck disable=SC2016
				"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${LAT_PEAK_PNG}'
set title 'Exp2 Peak Latency vs Time (rate=${rate} pps, ${ANALYSIS_NAME})'
set xlabel 'Time (s)'
set ylabel 'Peak RTT (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${LAT_PLOT_EXPR}
GNUPLOT
				# shellcheck disable=SC2016
				"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${LAT_PEAK_SVG}'
set title 'Exp2 Peak Latency vs Time (rate=${rate} pps, ${ANALYSIS_NAME})'
set xlabel 'Time (s)'
set ylabel 'Peak RTT (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${LAT_PLOT_EXPR}
GNUPLOT
			fi
		done
	fi
fi
info "[exp2-plot] using gnuplot: ${GNUPLOT_BIN}"
info "[exp2-plot] wrote ${OUT_DIR}"
info "[exp2-plot] source summary: ${THROUGHPUT_SOURCE_SUMMARY_CSV}"
if [ -f "${THROUGHPUT_STATS_NNN_CSV}" ]; then
	info "[exp2-plot] throughput stats (nnnpps): ${THROUGHPUT_STATS_NNN_CSV}"
fi
if [ -f "${THROUGHPUT_STATS_RESULT_CSV}" ]; then
	info "[exp2-plot] throughput stats (result): ${THROUGHPUT_STATS_RESULT_CSV}"
fi
if [ -f "${LOSS_STATS_NNN_CSV}" ]; then
	info "[exp2-plot] loss stats (nnnpps): ${LOSS_STATS_NNN_CSV}"
fi
if [ -f "${LOSS_STATS_RESULT_CSV}" ]; then
	info "[exp2-plot] loss stats (result): ${LOSS_STATS_RESULT_CSV}"
fi
if [ -f "${LAT_STATS_CSV}" ]; then
	info "[exp2-plot] latency stats: ${LAT_STATS_CSV}"
fi
