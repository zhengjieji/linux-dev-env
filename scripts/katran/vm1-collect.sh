#!/usr/bin/env bash

set -euo pipefail

OUTPUT="/tmp/katran-vm1-metrics.txt"
MODE="unknown"
VM1_DATA_MAC="52:54:00:aa:00:11"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Collect VM1 metrics snapshot.

Options:
  --mode <name>      Mode label for metadata
  --output <path>    Output file path (default: ${OUTPUT})
  -h, --help         Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--mode)
			[ $# -gt 1 ] || { echo "--mode requires value" >&2; exit 1; }
			MODE="$2"
			shift 2
			;;
		--output)
			[ $# -gt 1 ] || { echo "--output requires value" >&2; exit 1; }
			OUTPUT="$2"
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

DATA_IFACE="$(ip -o link | grep -i "${VM1_DATA_MAC}" | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"

{
	echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "mode=${MODE}"
	echo "data_iface=${DATA_IFACE}"
	echo
	echo "[uname]"
	uname -a
	echo
	echo "[ip-brief]"
	ip -brief addr
	echo
	echo "[ipvs-stats]"
	ipvsadm -Ln --stats 2>/dev/null || true
	echo
	echo "[iface-counters]"
	[ -n "${DATA_IFACE}" ] && ip -s link show dev "${DATA_IFACE}" || true
	echo
	echo "[bpftool-net]"
	if command -v bpftool >/dev/null 2>&1; then
		bpftool net show 2>/dev/null || true
		bpftool prog show 2>/dev/null || true
	else
		echo "bpftool not found"
	fi
} >"${OUTPUT}"

echo "[vm1-collect] wrote ${OUTPUT}"
