#!/usr/bin/env bash

set -euo pipefail

VM2_DATA_MAC="52:54:00:aa:00:22"

ensure_pktgen() {
	modprobe pktgen 2>/dev/null || true
	if [ ! -e /proc/net/pktgen/pgctrl ]; then
		echo "pktgen not available: enable CONFIG_NET_PKTGEN=y (or m), rebuild kernel, and reboot dual VMs" >&2
		exit 1
	fi
}

ensure_pktgen
sysctl -w net.core.wmem_max=33554432 >/dev/null
sysctl -w net.core.rmem_max=33554432 >/dev/null

DATA_IFACE="$(ip -o link | grep -i "${VM2_DATA_MAC}" | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//')"
[ -n "${DATA_IFACE}" ] || { echo "data iface not found" >&2; exit 1; }
ip link set dev "${DATA_IFACE}" up

echo "[vm2-setup] pktgen ready on iface ${DATA_IFACE}"
