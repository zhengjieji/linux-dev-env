#!/usr/bin/env bash

set -euo pipefail

OUTPUT="/tmp/katran-vm2-metrics.txt"
WORKLOAD_OUTPUT=""
VM2_DATA_MAC="52:54:00:aa:00:22"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Collect VM2 metrics snapshot.

Options:
  --output <path>             Output file (default: ${OUTPUT})
  --workload-output <path>    Existing workload output to embed
  -h, --help                  Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--output)
			[ $# -gt 1 ] || { echo "--output requires value" >&2; exit 1; }
			OUTPUT="$2"
			shift 2
			;;
		--workload-output)
			[ $# -gt 1 ] || { echo "--workload-output requires value" >&2; exit 1; }
			WORKLOAD_OUTPUT="$2"
			shift 2
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

DATA_IFACE="$(ip -o link | grep -i "${VM2_DATA_MAC}" | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"

{
	echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "data_iface=${DATA_IFACE}"
	echo
	echo "[ip-brief]"
	ip -brief addr
	echo
	echo "[iface-counters]"
	[ -n "${DATA_IFACE}" ] && ip -s link show dev "${DATA_IFACE}" || true
	echo
	echo "[softnet-stat]"
	cat /proc/net/softnet_stat
	echo
	if [ -n "${WORKLOAD_OUTPUT}" ] && [ -f "${WORKLOAD_OUTPUT}" ]; then
		echo "[workload-output]"
		cat "${WORKLOAD_OUTPUT}"
	fi
} >"${OUTPUT}"

echo "[vm2-collect] wrote ${OUTPUT}"
