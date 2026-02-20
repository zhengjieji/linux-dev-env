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
THROUGHPUT_STATS_CSV="${OUT_DIR}/throughput-median-stdev.csv"
LOSS_STATS_CSV="${OUT_DIR}/loss-median.csv"
LAT_STATS_CSV="${OUT_DIR}/latency-medians.csv"
rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"
: >"${MODE_MAP}"

pairs="$(awk -F, 'NR>1 && $2 ~ /^[0-9]+([.][0-9]+)?$/ && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${TP_MEDIANS_CSV}")"

{
	echo "mode,rate_pps,median_pps,stdev_pps"
	if [ -n "${pairs}" ]; then
		while IFS=, read -r mode rate median_pps loss_rate; do
			[ -n "${mode}" ] || continue
			safe="$(safe_name "${mode}")"
			echo "${rate} ${median_pps}" >>"${DATA_DIR}/throughput-${safe}.median.dat"
			loss_pct="$(awk -v lr="${loss_rate}" 'BEGIN {printf "%.6f", lr * 100}')"
			echo "${rate} ${loss_pct}" >>"${DATA_DIR}/loss-${safe}.median.dat"
			if ! grep -q "^${safe}," "${MODE_MAP}" 2>/dev/null; then
				echo "${safe},${mode}" >>"${MODE_MAP}"
			fi
			if [ -f "${TP_INDEX_CSV}" ]; then
				values="$(awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r && $4=="ok" && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $5}' "${TP_INDEX_CSV}" | sort -n)"
				stdev_pps="$(printf '%s\n' "${values}" | stddev_of_values)"
			else
				stdev_pps="0"
			fi
			echo "${rate} ${median_pps} ${stdev_pps}" >>"${DATA_DIR}/throughput-${safe}.stdev.dat"
			echo "${mode},${rate},${median_pps},${stdev_pps}"
		done <<<"${pairs}"
	fi
} >"${THROUGHPUT_STATS_CSV}"

{
	echo "mode,rate_pps,loss_rate_pct"
	if [ -n "${pairs}" ]; then
		while IFS=, read -r mode rate _ loss_rate; do
			loss_pct="$(awk -v lr="${loss_rate}" 'BEGIN {printf "%.6f", lr * 100}')"
			echo "${mode},${rate},${loss_pct}"
		done <<<"${pairs}"
	fi
} >"${LOSS_STATS_CSV}"

if [ ! -s "${MODE_MAP}" ]; then
	info "[exp2-plot] no numeric data in ${TP_MEDIANS_CSV}; nothing to plot"
	exit 0
fi

for f in "${DATA_DIR}"/*.dat; do
	[ -f "${f}" ] || continue
	sort -n -k1,1 "${f}" -o "${f}"
done

TPLOT_EXPR=""
LPLOT_EXPR=""
while IFS=, read -r safe mode; do
	[ -n "${safe}" ] || continue
	med_file="${DATA_DIR}/throughput-${safe}.median.dat"
	std_file="${DATA_DIR}/throughput-${safe}.stdev.dat"
	loss_file="${DATA_DIR}/loss-${safe}.median.dat"
	if [ -s "${med_file}" ]; then
		if [ -n "${TPLOT_EXPR}" ]; then
			TPLOT_EXPR="${TPLOT_EXPR}, "
		fi
		TPLOT_EXPR="${TPLOT_EXPR}'${std_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${med_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
	fi
	if [ -s "${loss_file}" ]; then
		if [ -n "${LPLOT_EXPR}" ]; then
			LPLOT_EXPR="${LPLOT_EXPR}, "
		fi
		LPLOT_EXPR="${LPLOT_EXPR}'${loss_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode}'"
	fi
done < <(sort -u "${MODE_MAP}")

if [ -z "${TPLOT_EXPR}" ]; then
	exp2_die "no plottable throughput data"
fi

ANALYSIS_NAME="$(basename -- "${ANALYSIS_DIR}")"
TP_PNG="${OUT_DIR}/throughput-median-vs-rate.png"
TP_SVG="${OUT_DIR}/throughput-median-vs-rate.svg"
LOSS_PNG="${OUT_DIR}/loss-rate-vs-rate.png"
LOSS_SVG="${OUT_DIR}/loss-rate-vs-rate.svg"

# shellcheck disable=SC2016
"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${TP_PNG}'
set title 'Exp2 Throughput Median vs Offered Rate (${ANALYSIS_NAME})'
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
plot ${TPLOT_EXPR}
GNUPLOT

# shellcheck disable=SC2016
"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${TP_SVG}'
set title 'Exp2 Throughput Median vs Offered Rate (${ANALYSIS_NAME})'
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
plot ${TPLOT_EXPR}
GNUPLOT

if [ -n "${LPLOT_EXPR}" ]; then
	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${LOSS_PNG}'
set title 'Exp2 Loss Rate vs Offered Rate (${ANALYSIS_NAME})'
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
plot ${LPLOT_EXPR}
GNUPLOT

	# shellcheck disable=SC2016
	"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${LOSS_SVG}'
set title 'Exp2 Loss Rate vs Offered Rate (${ANALYSIS_NAME})'
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
plot ${LPLOT_EXPR}
GNUPLOT
fi

if [ -f "${LAT_INDEX_CSV}" ]; then
	{
		echo "mode,rate_pps,samples,avg_ms_median,p99_ms_median,p999_ms_median"
		pairs_lat="$(awk -F, 'NR>1 && $4=="ok" {print $1 "," $2}' "${LAT_INDEX_CSV}" | sort -u)"
		if [ -n "${pairs_lat}" ]; then
			while IFS=, read -r mode rate; do
				[ -n "${mode}" ] || continue
				safe="$(safe_name "${mode}")"
				avg_vals="$(awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r && $4=="ok" && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $5}' "${LAT_INDEX_CSV}" | sort -n)"
				p99_vals="$(awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r && $4=="ok" && $6 ~ /^[0-9]+([.][0-9]+)?$/ {print $6}' "${LAT_INDEX_CSV}" | sort -n)"
				p999_vals="$(awk -F, -v m="${mode}" -v r="${rate}" '$1==m && $2==r && $4=="ok" && $7 ~ /^[0-9]+([.][0-9]+)?$/ {print $7}' "${LAT_INDEX_CSV}" | sort -n)"
				samples="$(printf '%s\n' "${avg_vals}" | sed '/^$/d' | wc -l | awk '{print $1}')"
				if [ "${samples}" -gt 0 ]; then
					avg_med="$(printf '%s\n' "${avg_vals}" | median_of_values)"
					p99_med="$(printf '%s\n' "${p99_vals}" | median_of_values)"
					p999_med="$(printf '%s\n' "${p999_vals}" | median_of_values)"
					echo "${rate} ${avg_med}" >>"${DATA_DIR}/latency-${safe}.avg.dat"
					echo "${rate} ${p99_med}" >>"${DATA_DIR}/latency-${safe}.p99.dat"
					echo "${mode},${rate},${samples},${avg_med},${p99_med},${p999_med}"
				fi
			done <<<"${pairs_lat}"
		fi
	} >"${LAT_STATS_CSV}"

	for f in "${DATA_DIR}"/latency-*.dat; do
		[ -f "${f}" ] || continue
		sort -n -k1,1 "${f}" -o "${f}"
	done

	AVG_EXPR=""
	P99_EXPR=""
	while IFS=, read -r safe mode; do
		[ -n "${safe}" ] || continue
		avg_file="${DATA_DIR}/latency-${safe}.avg.dat"
		p99_file="${DATA_DIR}/latency-${safe}.p99.dat"
		if [ -s "${avg_file}" ]; then
			if [ -n "${AVG_EXPR}" ]; then
				AVG_EXPR="${AVG_EXPR}, "
			fi
			AVG_EXPR="${AVG_EXPR}'${avg_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode}'"
		fi
		if [ -s "${p99_file}" ]; then
			if [ -n "${P99_EXPR}" ]; then
				P99_EXPR="${P99_EXPR}, "
			fi
			P99_EXPR="${P99_EXPR}'${p99_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode}'"
		fi
	done < <(sort -u "${MODE_MAP}")

	if [ -n "${AVG_EXPR}" ]; then
		LAT_AVG_PNG="${OUT_DIR}/latency-avg-vs-rate.png"
		LAT_AVG_SVG="${OUT_DIR}/latency-avg-vs-rate.svg"
		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${LAT_AVG_PNG}'
set title 'Exp2 Latency Avg RTT Median vs Offered Rate (${ANALYSIS_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Avg RTT Median (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${AVG_EXPR}
GNUPLOT
		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${LAT_AVG_SVG}'
set title 'Exp2 Latency Avg RTT Median vs Offered Rate (${ANALYSIS_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel 'Avg RTT Median (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${AVG_EXPR}
GNUPLOT
	fi

	if [ -n "${P99_EXPR}" ]; then
		LAT_P99_PNG="${OUT_DIR}/latency-p99-vs-rate.png"
		LAT_P99_SVG="${OUT_DIR}/latency-p99-vs-rate.svg"
		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${LAT_P99_PNG}'
set title 'Exp2 Latency P99 RTT Median vs Offered Rate (${ANALYSIS_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel 'P99 RTT Median (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${P99_EXPR}
GNUPLOT
		# shellcheck disable=SC2016
		"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${LAT_P99_SVG}'
set title 'Exp2 Latency P99 RTT Median vs Offered Rate (${ANALYSIS_NAME})'
set xlabel 'Offered Rate (pps)'
set ylabel 'P99 RTT Median (ms)'
set xrange [0:*]
set yrange [0:*]
set grid xtics ytics
set key outside right top
set border linewidth 1
set tics out
set format y '%.2f'
set pointsize 1.1
plot ${P99_EXPR}
GNUPLOT
	fi
fi

info "[exp2-plot] using gnuplot: ${GNUPLOT_BIN}"
info "[exp2-plot] wrote ${OUT_DIR}"
info "[exp2-plot] throughput stats: ${THROUGHPUT_STATS_CSV}"
info "[exp2-plot] loss stats: ${LOSS_STATS_CSV}"
if [ -f "${LAT_STATS_CSV}" ]; then
	info "[exp2-plot] latency stats: ${LAT_STATS_CSV}"
fi
