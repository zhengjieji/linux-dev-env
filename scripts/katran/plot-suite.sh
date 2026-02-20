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

Generate suite result plots from suite-index.csv.

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
MODE_MAP="${OUT_DIR}/modes.csv"
MEDIAN_CSV="${OUT_DIR}/suite-medians-live.csv"
rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}"
: >"${MODE_MAP}"

pairs="$(awk -F, 'NR>1 && $4=="ok" && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2}' "${INDEX_CSV}" | sort -u)"

{
	echo "mode,rate_pps,samples,median_pps,stdev_pps"
	if [ -n "${pairs}" ]; then
		while IFS=, read -r mode rate; do
			[ -n "${mode}" ] || continue
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
		done <<<"${pairs}"
	fi
} >"${MEDIAN_CSV}"

awk -F, 'NR>1 && $4=="ok" && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $3 "," $5}' "${INDEX_CSV}" | \
while IFS=, read -r mode rate rep pps; do
	safe="$(safe_name "${mode}")"
	echo "${rate} ${pps} ${rep}" >>"${DATA_DIR}/${safe}.samples.dat"
	if ! grep -q "^${safe}," "${MODE_MAP}" 2>/dev/null; then
		echo "${safe},${mode}" >>"${MODE_MAP}"
	fi
done

awk -F, 'NR>1 && $3 ~ /^[0-9]+$/ && $3>0 && $4 ~ /^[0-9]+([.][0-9]+)?$/ && $5 ~ /^[0-9]+([.][0-9]+)?$/ {print $1 "," $2 "," $4 "," $5}' "${MEDIAN_CSV}" | \
while IFS=, read -r mode rate median stdev; do
	safe="$(safe_name "${mode}")"
	echo "${rate} ${median} ${stdev}" >>"${DATA_DIR}/${safe}.median.dat"
	if ! grep -q "^${safe}," "${MODE_MAP}" 2>/dev/null; then
		echo "${safe},${mode}" >>"${MODE_MAP}"
	fi
done

if [ ! -s "${MODE_MAP}" ]; then
	info "[plot-suite] no numeric successful data in ${INDEX_CSV}; nothing to plot"
	exit 0
fi

for f in "${DATA_DIR}"/*.dat; do
	[ -f "${f}" ] || continue
	sort -n -k1,1 "${f}" -o "${f}"
done

PLOT_EXPR=""
while IFS=, read -r safe mode; do
	[ -n "${safe}" ] || continue
	samples_file="${DATA_DIR}/${safe}.samples.dat"
	median_file="${DATA_DIR}/${safe}.median.dat"
	[ -s "${median_file}" ] || continue
	if [ -n "${PLOT_EXPR}" ]; then
		PLOT_EXPR="${PLOT_EXPR}, "
	fi
	if [ -s "${samples_file}" ]; then
		PLOT_EXPR="${PLOT_EXPR}'${samples_file}' using 1:2 with points pt 7 ps 0.8 title '${mode} samples', '${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
	else
		PLOT_EXPR="${PLOT_EXPR}'${median_file}' using 1:2:3 with yerrorbars pt 0 lw 1 title '${mode} stdev', '${median_file}' using 1:2 with linespoints lw 2 pt 5 title '${mode} median'"
	fi
done < <(sort -u "${MODE_MAP}")

if [ -z "${PLOT_EXPR}" ]; then
	info "[plot-suite] no plottable data found"
	exit 0
fi

SUITE_NAME="$(basename -- "${SUITE_DIR}")"
PNG_OUT="${OUT_DIR}/throughput-vs-rate.png"
SVG_OUT="${OUT_DIR}/throughput-vs-rate.svg"

# shellcheck disable=SC2016
"${GNUPLOT_BIN}" <<GNUPLOT
set terminal pngcairo size 1400,900 enhanced
set output '${PNG_OUT}'
set title 'Katran Throughput vs Offered Rate (${SUITE_NAME})'
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
plot ${PLOT_EXPR}
GNUPLOT

# shellcheck disable=SC2016
"${GNUPLOT_BIN}" <<GNUPLOT
set terminal svg size 1400,900 dynamic enhanced
set output '${SVG_OUT}'
set title 'Katran Throughput vs Offered Rate (${SUITE_NAME})'
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
plot ${PLOT_EXPR}
GNUPLOT

info "[plot-suite] using gnuplot: ${GNUPLOT_BIN}"
info "[plot-suite] wrote ${PNG_OUT}"
info "[plot-suite] wrote ${SVG_OUT}"
info "[plot-suite] wrote ${MEDIAN_CSV}"
