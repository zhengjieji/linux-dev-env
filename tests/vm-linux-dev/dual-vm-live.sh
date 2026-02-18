#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

RUN_DOCKER_BUILD=0
RUN_KERNEL_BUILD=0
KEEP_RUNNING=0
SSH_WAIT_SECS=180

VM1_SSH_PORT="${DUAL_VM1_SSH_PORT:-51122}"
VM1_NET_PORT="${DUAL_VM1_NET_PORT:-51123}"
VM1_GDB_PORT="${DUAL_VM1_GDB_PORT:-1211}"
VM2_SSH_PORT="${DUAL_VM2_SSH_PORT:-51222}"
VM2_NET_PORT="${DUAL_VM2_NET_PORT:-51223}"
VM2_GDB_PORT="${DUAL_VM2_GDB_PORT:-1212}"

PASS_COUNT=0

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Run live dual-VM integration checks:
  - host -> vm1/vm2 ssh
  - vm1 <-> vm2 ping over shared data-plane
  - vm1 -> host-side gateway ping over mgmt-plane
  - XDP attach/detach smoke on vm1 data interface

Options:
  --docker-build       Run: make docker
  --kernel-build       Run: make vmlinux
  --keep-running       Do not stop dual VMs at script exit
  --ssh-wait <sec>     SSH readiness timeout (default: ${SSH_WAIT_SECS})
  -h, --help           Show help
EOF
}

log() {
	echo "[dual-vm-live] $*"
}

fail() {
	echo "[dual-vm-live][FAIL] $*" >&2
	exit 1
}

pass() {
	PASS_COUNT=$((PASS_COUNT + 1))
	echo "[dual-vm-live][PASS] $*"
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

ssh_vm() {
	local vm="$1"
	shift
	local port
	case "${vm}" in
		vm1) port="${VM1_SSH_PORT}" ;;
		vm2) port="${VM2_SSH_PORT}" ;;
		*) fail "unknown vm: ${vm}" ;;
	esac
	ssh \
		-o UserKnownHostsFile=/dev/null \
		-o StrictHostKeyChecking=no \
		-o ConnectTimeout=5 \
		-p "${port}" \
		root@127.0.0.1 \
		"$@"
}

wait_ssh_vm() {
	local vm="$1"
	local timeout_secs="$2"
	local start_ts
	start_ts="$(date +%s)"
	while true; do
		if ssh_vm "${vm}" "echo ssh-ready" >/dev/null 2>&1; then
			return 0
		fi
		local now
		now="$(date +%s)"
		if [ $((now - start_ts)) -ge "${timeout_secs}" ]; then
			return 1
		fi
		sleep 2
	done
}

make_dual() {
	make -C "${ROOT_DIR}" "$1" \
		DUAL_VM1_SSH_PORT="${VM1_SSH_PORT}" \
		DUAL_VM1_NET_PORT="${VM1_NET_PORT}" \
		DUAL_VM1_GDB_PORT="${VM1_GDB_PORT}" \
		DUAL_VM2_SSH_PORT="${VM2_SSH_PORT}" \
		DUAL_VM2_NET_PORT="${VM2_NET_PORT}" \
		DUAL_VM2_GDB_PORT="${VM2_GDB_PORT}"
}

cleanup() {
	if [ "${KEEP_RUNNING}" -eq 1 ]; then
		log "--keep-running is set; dual VMs are left running"
		return 0
	fi
	make_dual dual-vm-stop >/dev/null 2>&1 || true
}

while [ $# -gt 0 ]; do
	case "$1" in
		--docker-build)
			RUN_DOCKER_BUILD=1
			shift
			;;
		--kernel-build)
			RUN_KERNEL_BUILD=1
			shift
			;;
		--keep-running)
			KEEP_RUNNING=1
			shift
			;;
		--ssh-wait)
			[ $# -gt 1 ] || fail "--ssh-wait requires a value"
			SSH_WAIT_SECS="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			fail "unknown option: $1"
			;;
	esac
done

trap cleanup EXIT

require_cmd make
require_cmd docker
require_cmd ssh

if [ "${RUN_DOCKER_BUILD}" -eq 1 ]; then
	make -C "${ROOT_DIR}" docker
	pass "docker image build completed"
fi

if [ "${RUN_KERNEL_BUILD}" -eq 1 ]; then
	make -C "${ROOT_DIR}" vmlinux
	pass "kernel build completed"
fi

log "cleaning previous dual-vm session"
make_dual dual-vm-stop >/dev/null 2>&1 || true

log "starting vm1 and vm2"
make_dual dual-vm1
make_dual dual-vm2

log "waiting for ssh readiness"
if ! wait_ssh_vm vm1 "${SSH_WAIT_SECS}"; then
	fail "vm1 ssh readiness timed out"
fi
if ! wait_ssh_vm vm2 "${SSH_WAIT_SECS}"; then
	fail "vm2 ssh readiness timed out"
fi

ssh_vm vm1 "echo VM1_OK && uname -r" >/dev/null
pass "host -> vm1 ssh works"

ssh_vm vm2 "echo VM2_OK && uname -r" >/dev/null
pass "host -> vm2 ssh works"

ssh_vm vm1 "ping -c 3 -W 2 192.168.100.2 >/dev/null"
pass "vm1 -> vm2 ping over data-plane works"

ssh_vm vm2 "ping -c 3 -W 2 192.168.100.1 >/dev/null"
pass "vm2 -> vm1 ping over data-plane works"

ssh_vm vm1 "ping -c 1 -W 2 10.0.2.2 >/dev/null"
pass "vm1 -> host gateway ping over management-plane works"

ssh_vm vm1 "
set -euo pipefail
iface=\$(ip -o link | grep -i '52:54:00:aa:00:11' | head -n1 | awk -F': ' '{print \$2}' | sed 's/@.*//')
[ -n \"\${iface}\" ] || { echo 'data interface for vm1 not found' >&2; exit 1; }
cat >/tmp/xdp_pass.c <<'EOF'
#include <linux/bpf.h>
#define SEC(NAME) __attribute__((section(NAME), used))
SEC(\"xdp\")
int xdp_pass(struct xdp_md *ctx) { return XDP_PASS; }
char _license[] SEC(\"license\") = \"GPL\";
EOF
clang -O2 -g -target bpf -D__TARGET_ARCH_x86 -I/linux/usr/include -c /tmp/xdp_pass.c -o /tmp/xdp_pass.o
ip -force link set dev \"\${iface}\" xdpgeneric obj /tmp/xdp_pass.o sec xdp
ip -details link show dev \"\${iface}\" | grep -q 'prog/xdp'
ip link set dev \"\${iface}\" xdpgeneric off
rm -f /tmp/xdp_pass.c /tmp/xdp_pass.o
"
pass "xdp attach/detach smoke works on vm1 data-plane interface"

echo "[dual-vm-live][PASS] completed (${PASS_COUNT} checks)"
