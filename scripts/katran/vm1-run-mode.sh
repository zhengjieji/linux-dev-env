#!/usr/bin/env bash

set -euo pipefail

MODE=""
VIP="192.168.100.100"
VIP_PORT=80
BACKEND_PORT=8080
RS1_IP="10.200.1.2"
RS2_IP="10.200.2.2"
VM1_DATA_MAC="52:54:00:aa:00:11"

usage() {
	cat <<USAGE
Usage: $(basename "$0") --mode <mode> [options]

Apply VM1 dataplane mode.

Modes:
  baseline-no-katran
  katran-orig-bpf

Options:
  --mode <mode>      Mode to apply
  --vip <ip>         VIP (default: ${VIP})
  --vip-port <n>     VIP port (default: ${VIP_PORT})
  --backend-port <n> Backend port (default: ${BACKEND_PORT})
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
		--vip)
			[ $# -gt 1 ] || { echo "--vip requires value" >&2; exit 1; }
			VIP="$2"
			shift 2
			;;
		--vip-port)
			[ $# -gt 1 ] || { echo "--vip-port requires value" >&2; exit 1; }
			VIP_PORT="$2"
			shift 2
			;;
		--backend-port)
			[ $# -gt 1 ] || { echo "--backend-port requires value" >&2; exit 1; }
			BACKEND_PORT="$2"
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

[ -n "${MODE}" ] || { usage; exit 1; }

if ! command -v ipvsadm >/dev/null 2>&1; then
	apt-get update -y >/dev/null
	DEBIAN_FRONTEND=noninteractive apt-get install -y ipvsadm >/dev/null
fi

find_data_iface() {
	ip -o link | grep -i "${VM1_DATA_MAC}" | head -n1 | awk -F': ' '{print $2}' | sed 's/@.*//'
}

DATA_IFACE="$(find_data_iface)"
[ -n "${DATA_IFACE}" ] || { echo "data iface not found" >&2; exit 1; }

detach_xdp() {
	ip link set dev "${DATA_IFACE}" xdpgeneric off 2>/dev/null || true
	ip link set dev "${DATA_IFACE}" xdp off 2>/dev/null || true
}

configure_ipvs_baseline() {
	modprobe ip_vs 2>/dev/null || true
	modprobe ip_vs_rr 2>/dev/null || true
	ipvsadm -C || true
	ipvsadm -A -u "${VIP}:${VIP_PORT}" -s rr
	ipvsadm -a -u "${VIP}:${VIP_PORT}" -r "${RS1_IP}:${BACKEND_PORT}" -m
	ipvsadm -a -u "${VIP}:${VIP_PORT}" -r "${RS2_IP}:${BACKEND_PORT}" -m
}

find_katran_obj() {
	local candidate
	for candidate in \
		"/linux-dev-env/source/katran/katran/lib/bpf/balancer.bpf.o" \
		"/linux-dev-env/source/katran/build/katran/lib/bpf/balancer.bpf.o" \
		"/linux-dev-env/source/katran/_build/katran/lib/bpf/balancer.bpf.o" \
		"/linux-dev-env/source/katran/lib/bpf/balancer.bpf.o"; do
		if [ -f "${candidate}" ]; then
			echo "${candidate}"
			return 0
		fi
	done
	return 1
}

attach_katran_bpf() {
	local obj
	local sec
	obj="$(find_katran_obj)" || {
		echo "katran bpf object not found under /linux-dev-env/source/katran" >&2
		exit 1
	}
	sec="${KATRAN_XDP_SEC:-xdp}"
	if ip -force link set dev "${DATA_IFACE}" xdpgeneric obj "${obj}" sec "${sec}"; then
		echo "[vm1-run-mode] attached katran object ${obj} sec ${sec}"
		return 0
	fi
	ip -force link set dev "${DATA_IFACE}" xdpgeneric obj "${obj}"
	echo "[vm1-run-mode] attached katran object ${obj} (default section)"
}

case "${MODE}" in
	baseline-no-katran)
		detach_xdp
		configure_ipvs_baseline
		;;
	katran-orig-bpf)
		configure_ipvs_baseline
		attach_katran_bpf
		;;
	*)
		echo "unsupported mode: ${MODE}" >&2
		exit 1
		;;
esac

echo "[vm1-run-mode] mode=${MODE} iface=${DATA_IFACE} vip=${VIP}:${VIP_PORT}"
ipvsadm -Ln
ip -d link show dev "${DATA_IFACE}" | sed -n '1,3p'
