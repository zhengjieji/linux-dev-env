#!/usr/bin/env bash

set -euo pipefail

VIP="192.168.100.100"
BACKEND_PORT=8080
RS1_NS="rs1"
RS2_NS="rs2"
RS1_HOST_IP="10.200.1.1/24"
RS1_GUEST_IP="10.200.1.2/24"
RS2_HOST_IP="10.200.2.1/24"
RS2_GUEST_IP="10.200.2.2/24"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Prepare VM1 backend namespaces and VIP prerequisites.

Options:
  --vip <ip>         VIP (default: ${VIP})
  --backend-port <n> Backend UDP port (default: ${BACKEND_PORT})
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

install_bpftool_from_tree() {
	local candidate
	for candidate in \
		"/linux-dev-env/linux/tools/bpf/bpftool/bpftool" \
		"/linux/tools/bpf/bpftool/bpftool"; do
		if [ -x "${candidate}" ]; then
			install -m 0755 "${candidate}" /usr/local/sbin/bpftool
			return 0
		fi
	done
	return 1
}

ensure_cmd() {
	local cmd="$1"
	local pkg="$2"

	if command -v "${cmd}" >/dev/null 2>&1; then
		return 0
	fi

	echo "[vm1-setup] installing missing package: ${pkg}"
	apt-get update -y >/dev/null
	if ! DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" >/dev/null; then
		if [ "${cmd}" = "bpftool" ] && install_bpftool_from_tree; then
			echo "[vm1-setup] installed bpftool from kernel tree"
		else
			echo "[vm1-setup][error] failed to install ${cmd}" >&2
			return 1
		fi
	fi

	command -v "${cmd}" >/dev/null 2>&1 || {
		echo "[vm1-setup][error] command still missing: ${cmd}" >&2
		return 1
	}
}

ensure_cmd ipvsadm ipvsadm
ensure_cmd python3 python3
ensure_cmd bpftool bpftool

cleanup_ns() {
	local ns="$1"
	if ip netns list | grep -q "^${ns}\\b"; then
		ip netns exec "${ns}" bash -lc "if [ -f /tmp/${ns}-udp.pid ]; then kill \$(cat /tmp/${ns}-udp.pid) 2>/dev/null || true; fi" || true
		ip netns del "${ns}"
	fi
}

cleanup_ns "${RS1_NS}"
cleanup_ns "${RS2_NS}"
ip link del veth-rs1 2>/dev/null || true
ip link del veth-rs2 2>/dev/null || true

ip netns add "${RS1_NS}"
ip link add veth-rs1 type veth peer name eth0 netns "${RS1_NS}"
ip addr add "${RS1_HOST_IP}" dev veth-rs1
ip link set veth-rs1 up
ip -n "${RS1_NS}" addr add "${RS1_GUEST_IP}" dev eth0
ip -n "${RS1_NS}" link set lo up
ip -n "${RS1_NS}" link set eth0 up

ip netns add "${RS2_NS}"
ip link add veth-rs2 type veth peer name eth0 netns "${RS2_NS}"
ip addr add "${RS2_HOST_IP}" dev veth-rs2
ip link set veth-rs2 up
ip -n "${RS2_NS}" addr add "${RS2_GUEST_IP}" dev eth0
ip -n "${RS2_NS}" link set lo up
ip -n "${RS2_NS}" link set eth0 up

cat >/tmp/udp_sink.py <<'PY'
import socket
import sys

port = int(sys.argv[1])
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("0.0.0.0", port))
while True:
    data, _ = s.recvfrom(65535)
    if not data:
        continue
PY

ip netns exec "${RS1_NS}" bash -lc "nohup python3 /tmp/udp_sink.py ${BACKEND_PORT} >/tmp/${RS1_NS}-udp.log 2>&1 & echo \$! >/tmp/${RS1_NS}-udp.pid"
ip netns exec "${RS2_NS}" bash -lc "nohup python3 /tmp/udp_sink.py ${BACKEND_PORT} >/tmp/${RS2_NS}-udp.log 2>&1 & echo \$! >/tmp/${RS2_NS}-udp.pid"

ip link add vip0 type dummy 2>/dev/null || true
ip addr flush dev vip0 || true
ip addr add "${VIP}/32" dev vip0
ip link set vip0 up

sysctl -w net.ipv4.ip_forward=1 >/dev/null
sysctl -w net.ipv4.conf.all.rp_filter=0 >/dev/null

echo "[vm1-setup] prepared backends and VIP ${VIP}:${BACKEND_PORT}"
