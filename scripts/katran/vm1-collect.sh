#!/usr/bin/env bash

set -euo pipefail

OUTPUT="/tmp/katran-vm1-metrics.txt"
MODE="unknown"
VM1_DATA_MAC="52:54:00:aa:00:11"
SNAPSHOT_ONLY=0
RS1_NS="rs1"
RS2_NS="rs2"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Collect VM1 metrics snapshot.

Options:
  --mode <name>      Mode label for metadata
  --output <path>    Output file path (default: ${OUTPUT})
  --snapshot-only    Write concise packet-counter snapshot only
  --rs1-ns <name>    Backend namespace #1 (default: ${RS1_NS})
  --rs2-ns <name>    Backend namespace #2 (default: ${RS2_NS})
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
		--snapshot-only)
			SNAPSHOT_ONLY=1
			shift
			;;
		--rs1-ns)
			[ $# -gt 1 ] || { echo "--rs1-ns requires value" >&2; exit 1; }
			RS1_NS="$2"
			shift 2
			;;
		--rs2-ns)
			[ $# -gt 1 ] || { echo "--rs2-ns requires value" >&2; exit 1; }
			RS2_NS="$2"
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

read_counter_safe() {
	local p="$1"
	if [ -r "${p}" ]; then
		cat "${p}" 2>/dev/null || true
	fi
}

read_ns_counter_safe() {
	local ns="$1"
	local p="$2"
	if ip netns list | grep -q "^${ns}\\b"; then
		ip netns exec "${ns}" cat "${p}" 2>/dev/null || true
	fi
}

VM1_RX_PKTS=""
RS1_RX_PKTS=""
RS2_RX_PKTS=""
BACKEND_RX_PKTS=""

if [ -n "${DATA_IFACE}" ]; then
	VM1_RX_PKTS="$(read_counter_safe "/sys/class/net/${DATA_IFACE}/statistics/rx_packets")"
fi
RS1_RX_PKTS="$(read_ns_counter_safe "${RS1_NS}" "/sys/class/net/eth0/statistics/rx_packets")"
RS2_RX_PKTS="$(read_ns_counter_safe "${RS2_NS}" "/sys/class/net/eth0/statistics/rx_packets")"

if [ -n "${RS1_RX_PKTS}" ] && [ -n "${RS2_RX_PKTS}" ] &&
	printf '%s\n' "${RS1_RX_PKTS}" | grep -Eq '^[0-9]+$' &&
	printf '%s\n' "${RS2_RX_PKTS}" | grep -Eq '^[0-9]+$'; then
	BACKEND_RX_PKTS=$((RS1_RX_PKTS + RS2_RX_PKTS))
fi

if [ "${SNAPSHOT_ONLY}" -eq 1 ]; then
	{
		echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
		echo "mode=${MODE}"
		echo "data_iface=${DATA_IFACE}"
		echo "vm1_rx_packets=${VM1_RX_PKTS}"
		echo "rs1_ns=${RS1_NS}"
		echo "rs1_rx_packets=${RS1_RX_PKTS}"
		echo "rs2_ns=${RS2_NS}"
		echo "rs2_rx_packets=${RS2_RX_PKTS}"
		echo "backend_rx_packets=${BACKEND_RX_PKTS}"
	} >"${OUTPUT}"
	echo "[vm1-collect] wrote snapshot ${OUTPUT}"
	exit 0
fi

{
	echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "mode=${MODE}"
	echo "data_iface=${DATA_IFACE}"
	echo "vm1_rx_packets=${VM1_RX_PKTS}"
	echo "rs1_ns=${RS1_NS}"
	echo "rs1_rx_packets=${RS1_RX_PKTS}"
	echo "rs2_ns=${RS2_NS}"
	echo "rs2_rx_packets=${RS2_RX_PKTS}"
	echo "backend_rx_packets=${BACKEND_RX_PKTS}"
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
