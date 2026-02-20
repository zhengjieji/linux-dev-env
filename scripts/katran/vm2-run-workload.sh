#!/usr/bin/env bash

set -euo pipefail

VIP="192.168.100.100"
DST_MAC="52:54:00:aa:00:11"
VM2_DATA_MAC="52:54:00:aa:00:22"
DPORT=80
RATE_PPS=200000
DURATION_SECS=30
PKT_SIZE=64
OUTPUT="/tmp/katran-vm2-workload.txt"
IFACE=""

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run UDP workload from VM2 with pktgen.

Options:
  --vip <ip>         Destination VIP (default: ${VIP})
  --dst-mac <mac>    Destination MAC (default: ${DST_MAC})
  --dport <n>        Destination UDP port (default: ${DPORT})
  --rate-pps <n>     Target packets per second (default: ${RATE_PPS})
  --duration <sec>   Duration in seconds (default: ${DURATION_SECS})
  --pkt-size <n>     Packet size bytes (default: ${PKT_SIZE})
  --iface <name>     Explicit interface (default: auto by MAC)
  --output <path>    Output file (default: ${OUTPUT})
  -h, --help         Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--vip)
			[ $# -gt 1 ] || { echo "--vip requires value" >&2; exit 1; }
			VIP="$2"
			shift 2
			;;
		--dst-mac)
			[ $# -gt 1 ] || { echo "--dst-mac requires value" >&2; exit 1; }
			DST_MAC="$2"
			shift 2
			;;
		--dport)
			[ $# -gt 1 ] || { echo "--dport requires value" >&2; exit 1; }
			DPORT="$2"
			shift 2
			;;
		--rate-pps)
			[ $# -gt 1 ] || { echo "--rate-pps requires value" >&2; exit 1; }
			RATE_PPS="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || { echo "--duration requires value" >&2; exit 1; }
			DURATION_SECS="$2"
			shift 2
			;;
		--pkt-size)
			[ $# -gt 1 ] || { echo "--pkt-size requires value" >&2; exit 1; }
			PKT_SIZE="$2"
			shift 2
			;;
		--iface)
			[ $# -gt 1 ] || { echo "--iface requires value" >&2; exit 1; }
			IFACE="$2"
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

modprobe pktgen 2>/dev/null || true
[ -e /proc/net/pktgen/pgctrl ] || { echo "pktgen unavailable: enable CONFIG_NET_PKTGEN=y (or m), rebuild kernel, and reboot dual VMs" >&2; exit 1; }

if [ -z "${IFACE}" ]; then
	IFACE="$(ip -o link | grep -i "${VM2_DATA_MAC}" | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"
fi
[ -n "${IFACE}" ] || { echo "unable to find workload iface" >&2; exit 1; }

PACKETS=$((RATE_PPS * DURATION_SECS))
DELAY_NS=$((1000000000 / RATE_PPS))
if [ "${DELAY_NS}" -lt 1 ]; then
	DELAY_NS=1
fi

PG_THREAD="/proc/net/pktgen/kpktgend_0"
PG_DEV="/proc/net/pktgen/${IFACE}"

[ -e "${PG_THREAD}" ] || { echo "missing ${PG_THREAD}" >&2; exit 1; }

echo "rem_device_all" >"${PG_THREAD}"
echo "add_device ${IFACE}" >"${PG_THREAD}"

[ -e "${PG_DEV}" ] || { echo "missing ${PG_DEV}" >&2; exit 1; }

echo "count ${PACKETS}" >"${PG_DEV}"
echo "clone_skb 0" >"${PG_DEV}"
echo "pkt_size ${PKT_SIZE}" >"${PG_DEV}"
echo "delay ${DELAY_NS}" >"${PG_DEV}"
echo "dst ${VIP}" >"${PG_DEV}"
echo "dst_mac ${DST_MAC}" >"${PG_DEV}"
echo "udp_dst_min ${DPORT}" >"${PG_DEV}"
echo "udp_dst_max ${DPORT}" >"${PG_DEV}"
echo "udp_src_min 1025" >"${PG_DEV}"
echo "udp_src_max 65535" >"${PG_DEV}"

echo "start" >/proc/net/pktgen/pgctrl

for _ in $(seq 1 $((DURATION_SECS + 30))); do
	if grep -q '^Result:' "${PG_DEV}" 2>/dev/null; then
		break
	fi
	sleep 1
done

cat "${PG_DEV}" >"${OUTPUT}"

echo "[vm2-workload] iface=${IFACE} vip=${VIP}:${DPORT} rate_pps=${RATE_PPS} duration=${DURATION_SECS}"
grep -m1 '^Result:' "${OUTPUT}" || true
echo "[vm2-workload] wrote ${OUTPUT}"
