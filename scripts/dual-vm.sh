#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LINUX_DIR="${LINUX_DIR:-${ROOT_DIR}/linux}"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-dual-vm-zhengjie}"
SESSION_NAME="${DUAL_VM_SESSION_NAME:-dual-vm-session}"
BRIDGE_NAME="${DUAL_VM_BRIDGE_NAME:-br-dual}"

VM1_HOST_SSH_PORT="${DUAL_VM1_SSH_PORT:-53022}"
VM1_HOST_NET_PORT="${DUAL_VM1_NET_PORT:-53023}"
VM1_HOST_GDB_PORT="${DUAL_VM1_GDB_PORT:-1311}"
VM2_HOST_SSH_PORT="${DUAL_VM2_SSH_PORT:-53122}"
VM2_HOST_NET_PORT="${DUAL_VM2_NET_PORT:-53123}"
VM2_HOST_GDB_PORT="${DUAL_VM2_GDB_PORT:-1312}"

VM1_INNER_SSH_PORT=52222
VM1_INNER_NET_PORT=52223
VM1_INNER_GDB_PORT=1234
VM1_SERIAL_PORT=1235
VM1_TAP=tap-dual-vm1
VM1_MAC=52:54:00:aa:00:11
VM1_DATA_IP=192.168.100.1/24

VM2_INNER_SSH_PORT=52322
VM2_INNER_NET_PORT=52323
VM2_INNER_GDB_PORT=1237
VM2_SERIAL_PORT=1236
VM2_TAP=tap-dual-vm2
VM2_MAC=52:54:00:aa:00:22
VM2_DATA_IP=192.168.100.2/24

DEFAULT_WAIT_TIMEOUT=120

SSH_OPTS=(
	-o UserKnownHostsFile=/dev/null
	-o StrictHostKeyChecking=no
	-o ConnectTimeout=3
)

IMAGE_REF=""

log() {
	echo "[dual-vm] $*"
}

die() {
	echo "[dual-vm][error] $*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  start vm1|vm2                Start one VM (and shared session container if needed)
  stop vm1|vm2|all             Stop one VM or tear down full dual-vm session
  status                       Show status for session container and both VMs
  ssh vm1|vm2 [command...]     SSH into a VM (or run one remote command)
  wait-ssh vm1|vm2 [timeout]   Wait until SSH is ready (default timeout: ${DEFAULT_WAIT_TIMEOUT}s)
  logs vm1|vm2 [tail_lines]    Show VM log tail from session container

Environment:
  LINUX_DIR                    Linux source dir (default: ${LINUX_DIR})
  RUNTIME_IMAGE                Docker image name (default: ${RUNTIME_IMAGE})
  DUAL_VM1_SSH_PORT            Host SSH port for vm1 (default: ${VM1_HOST_SSH_PORT})
  DUAL_VM2_SSH_PORT            Host SSH port for vm2 (default: ${VM2_HOST_SSH_PORT})
EOF
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

resolve_image_ref() {
	if docker image inspect "${RUNTIME_IMAGE}:latest" >/dev/null 2>&1; then
		IMAGE_REF="${RUNTIME_IMAGE}:latest"
		return
	fi
	if docker image inspect "${RUNTIME_IMAGE}" >/dev/null 2>&1; then
		IMAGE_REF="${RUNTIME_IMAGE}"
		return
	fi
	die "docker image '${RUNTIME_IMAGE}' not found. Run: make docker"
}

container_exists() {
	docker ps -a --filter "name=^/${SESSION_NAME}$" --format '{{.Names}}' | grep -qx "${SESSION_NAME}"
}

container_running() {
	docker ps --filter "name=^/${SESSION_NAME}$" --format '{{.Names}}' | grep -qx "${SESSION_NAME}"
}

vm_host_ssh_port() {
	case "$1" in
		vm1) echo "${VM1_HOST_SSH_PORT}" ;;
		vm2) echo "${VM2_HOST_SSH_PORT}" ;;
		*) die "unknown vm: $1" ;;
	esac
}

vm_tap_name() {
	case "$1" in
		vm1) echo "${VM1_TAP}" ;;
		vm2) echo "${VM2_TAP}" ;;
		*) die "unknown vm: $1" ;;
	esac
}

vm_data_mac() {
	case "$1" in
		vm1) echo "${VM1_MAC}" ;;
		vm2) echo "${VM2_MAC}" ;;
		*) die "unknown vm: $1" ;;
	esac
}

vm_data_ip() {
	case "$1" in
		vm1) echo "${VM1_DATA_IP}" ;;
		vm2) echo "${VM2_DATA_IP}" ;;
		*) die "unknown vm: $1" ;;
	esac
}

vm_ports() {
	case "$1" in
		vm1) echo "${VM1_INNER_SSH_PORT} ${VM1_INNER_NET_PORT} ${VM1_INNER_GDB_PORT} ${VM1_SERIAL_PORT}" ;;
		vm2) echo "${VM2_INNER_SSH_PORT} ${VM2_INNER_NET_PORT} ${VM2_INNER_GDB_PORT} ${VM2_SERIAL_PORT}" ;;
		*) die "unknown vm: $1" ;;
	esac
}

ensure_prereqs() {
	require_cmd docker
	require_cmd ssh
	[ -x "${ROOT_DIR}/q-script/yifei-q" ] || die "missing qemu launcher: ${ROOT_DIR}/q-script/yifei-q"
	[ -d "${LINUX_DIR}" ] || die "linux directory missing: ${LINUX_DIR}"
	[ -f "${LINUX_DIR}/.config" ] || die "linux .config missing: ${LINUX_DIR}/.config"
	[ -f "${LINUX_DIR}/arch/x86/boot/bzImage" ] || die "kernel image missing: ${LINUX_DIR}/arch/x86/boot/bzImage"
	docker info >/dev/null 2>&1 || die "docker daemon is not reachable for current user"
}

ensure_session_container() {
	if container_running; then
		return
	fi

	if container_exists; then
		log "removing stale session container '${SESSION_NAME}'"
		docker rm -f "${SESSION_NAME}" >/dev/null
	fi

	resolve_image_ref
	log "starting session container '${SESSION_NAME}'"
	docker run -d --name "${SESSION_NAME}" --privileged --rm \
		--device=/dev/kvm:/dev/kvm \
		-v "${ROOT_DIR}:/linux-dev-env" \
		-v "${LINUX_DIR}:/linux" \
		-w /linux \
		-p "127.0.0.1:${VM1_HOST_SSH_PORT}:${VM1_INNER_SSH_PORT}" \
		-p "127.0.0.1:${VM1_HOST_NET_PORT}:${VM1_INNER_NET_PORT}" \
		-p "127.0.0.1:${VM1_HOST_GDB_PORT}:${VM1_INNER_GDB_PORT}" \
		-p "127.0.0.1:${VM2_HOST_SSH_PORT}:${VM2_INNER_SSH_PORT}" \
		-p "127.0.0.1:${VM2_HOST_NET_PORT}:${VM2_INNER_NET_PORT}" \
		-p "127.0.0.1:${VM2_HOST_GDB_PORT}:${VM2_INNER_GDB_PORT}" \
		"${IMAGE_REF}" \
		sleep infinity >/dev/null
}

exec_in_container() {
	local script="$1"
	docker exec "${SESSION_NAME}" bash -lc "${script}"
}

ensure_bridge() {
	exec_in_container "
set -euo pipefail
if ! ip link show ${BRIDGE_NAME} >/dev/null 2>&1; then
	ip link add ${BRIDGE_NAME} type bridge
fi
ip link set ${BRIDGE_NAME} up
if ! ip -4 addr show dev ${BRIDGE_NAME} | grep -q '192.168.100.254/24'; then
	ip addr add 192.168.100.254/24 dev ${BRIDGE_NAME} || true
fi
"
}

ensure_tap() {
	local tap_name="$1"
	exec_in_container "
set -euo pipefail
if ! ip link show ${tap_name} >/dev/null 2>&1; then
	ip tuntap add dev ${tap_name} mode tap
fi
ip link set ${tap_name} master ${BRIDGE_NAME}
ip link set ${tap_name} up
"
}

vm_pid_in_container() {
	local vm="$1"
	docker exec "${SESSION_NAME}" bash -lc "
set -euo pipefail
pid_file=/tmp/${vm}.pid
if [ -f \"\${pid_file}\" ] && kill -0 \"\$(cat \"\${pid_file}\")\" 2>/dev/null; then
	cat \"\${pid_file}\"
fi
"
}

wait_ssh() {
	local vm="$1"
	local timeout_secs="${2:-${DEFAULT_WAIT_TIMEOUT}}"
	local port
	port="$(vm_host_ssh_port "${vm}")"
	local start_ts
	start_ts="$(date +%s)"

	while true; do
		if ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 "echo ${vm}-ssh-ok" >/dev/null 2>&1; then
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

configure_data_iface() {
	local vm="$1"
	local mac
	local data_ip
	mac="$(vm_data_mac "${vm}")"
	data_ip="$(vm_data_ip "${vm}")"
	local port
	port="$(vm_host_ssh_port "${vm}")"

	ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 "
set -euo pipefail
iface=\$(ip -o link | grep -i '${mac}' | head -n1 | awk -F': ' '{print \$2}' | sed 's/@.*//')
[ -n \"\${iface}\" ] || { echo 'data interface not found for mac ${mac}' >&2; exit 1; }
ip link set dev \"\${iface}\" up
ip addr flush dev \"\${iface}\"
ip addr add ${data_ip} dev \"\${iface}\"
"
}

start_vm() {
	local vm="$1"
	local tap_name
	local mac
	local inner_ssh
	local inner_net
	local inner_gdb
	local serial_port
	tap_name="$(vm_tap_name "${vm}")"
	mac="$(vm_data_mac "${vm}")"
	read -r inner_ssh inner_net inner_gdb serial_port < <(vm_ports "${vm}")

	ensure_session_container
	ensure_bridge
	ensure_tap "${tap_name}"

	docker exec \
		-e VM_NAME="${vm}" \
		-e TAP_NAME="${tap_name}" \
		-e VM_MAC="${mac}" \
		-e VM_INNER_SSH="${inner_ssh}" \
		-e VM_INNER_NET="${inner_net}" \
		-e VM_INNER_GDB="${inner_gdb}" \
		-e VM_SERIAL="${serial_port}" \
		"${SESSION_NAME}" \
		bash -lc '
set -euo pipefail
pid_file="/tmp/${VM_NAME}.pid"
if [ -f "${pid_file}" ] && kill -0 "$(cat "${pid_file}")" 2>/dev/null; then
	exit 0
fi
rm -f "${pid_file}"
qargs="-netdev tap,id=data0,ifname=${TAP_NAME},script=no,downscript=no -device virtio-net-pci,netdev=data0,mac=${VM_MAC}"
cd /linux
Q_SSH_FWD_PORT="${VM_INNER_SSH}" \
Q_NET_FWD_PORT="${VM_INNER_NET}" \
Q_SERIAL_TCP_PORT="${VM_SERIAL}" \
Q_GDB_PORT="${VM_INNER_GDB}" \
/linux-dev-env/q-script/yifei-q -s -q "${qargs}" >"/tmp/${VM_NAME}.log" 2>&1 &
echo $! > "${pid_file}"
'

	log "started ${vm}; waiting for SSH on localhost:$(vm_host_ssh_port "${vm}")"
	if ! wait_ssh "${vm}" "${DEFAULT_WAIT_TIMEOUT}"; then
		log "failed waiting SSH for ${vm}; recent log:"
		docker exec "${SESSION_NAME}" bash -lc "tail -n 120 /tmp/${vm}.log || true" || true
		die "${vm} did not become reachable over SSH"
	fi
	configure_data_iface "${vm}"
	log "${vm} is ready"
}

stop_vm() {
	local vm="$1"
	local tap_name
	tap_name="$(vm_tap_name "${vm}")"

	if ! container_running; then
		log "session container '${SESSION_NAME}' is not running"
		return 0
	fi

	docker exec \
		-e VM_NAME="${vm}" \
		-e TAP_NAME="${tap_name}" \
		"${SESSION_NAME}" \
		bash -lc '
set -euo pipefail
pid_file="/tmp/${VM_NAME}.pid"
if [ -f "${pid_file}" ]; then
	pid="$(cat "${pid_file}")"
	if kill -0 "${pid}" 2>/dev/null; then
		kill "${pid}" || true
		for _ in $(seq 1 20); do
			if ! kill -0 "${pid}" 2>/dev/null; then
				break
			fi
			sleep 0.5
		done
		if kill -0 "${pid}" 2>/dev/null; then
			kill -9 "${pid}" || true
		fi
	fi
	rm -f "${pid_file}"
fi
ip link del "${TAP_NAME}" 2>/dev/null || true
'
	log "stopped ${vm}"
}

stop_all() {
	if container_running; then
		stop_vm vm1 || true
		stop_vm vm2 || true
		log "removing session container '${SESSION_NAME}'"
		docker rm -f "${SESSION_NAME}" >/dev/null 2>&1 || true
	elif container_exists; then
		log "removing stale session container '${SESSION_NAME}'"
		docker rm -f "${SESSION_NAME}" >/dev/null 2>&1 || true
	else
		log "nothing to stop"
	fi
}

show_status() {
	if ! container_running; then
		log "session: stopped"
		return 0
	fi

	log "session: running (${SESSION_NAME})"
	for vm in vm1 vm2; do
		local pid
		pid="$(vm_pid_in_container "${vm}" || true)"
		if [ -n "${pid}" ]; then
			echo "  - ${vm}: running (pid ${pid}, ssh localhost:$(vm_host_ssh_port "${vm}"))"
		else
			echo "  - ${vm}: stopped"
		fi
	done
}

ssh_vm() {
	local vm="$1"
	shift || true
	local port
	port="$(vm_host_ssh_port "${vm}")"
	if [ $# -eq 0 ]; then
		ssh "${SSH_OPTS[@]}" -t -p "${port}" root@127.0.0.1
	else
		ssh "${SSH_OPTS[@]}" -p "${port}" root@127.0.0.1 "$@"
	fi
}

show_logs() {
	local vm="$1"
	local lines="${2:-120}"
	if ! container_running; then
		die "session container '${SESSION_NAME}' is not running"
	fi
	docker exec "${SESSION_NAME}" bash -lc "tail -n ${lines} /tmp/${vm}.log"
}

main() {
	require_cmd docker
	[ $# -gt 0 ] || {
		usage
		exit 1
	}

	local cmd="$1"
	shift || true

	case "${cmd}" in
		start)
			[ $# -eq 1 ] || die "usage: $(basename "$0") start vm1|vm2"
			case "$1" in
				vm1|vm2) ;;
				*) die "unknown vm: $1" ;;
			esac
			ensure_prereqs
			start_vm "$1"
			;;
		stop)
			[ $# -eq 1 ] || die "usage: $(basename "$0") stop vm1|vm2|all"
			case "$1" in
				vm1|vm2)
					stop_vm "$1"
					;;
				all)
					stop_all
					;;
				*)
					die "unknown stop target: $1"
					;;
			esac
			;;
		status)
			show_status
			;;
		ssh)
			[ $# -ge 1 ] || die "usage: $(basename "$0") ssh vm1|vm2 [command...]"
			case "$1" in
				vm1|vm2) ;;
				*) die "unknown vm: $1" ;;
			esac
			ssh_vm "$@"
			;;
		wait-ssh)
			[ $# -ge 1 ] || die "usage: $(basename "$0") wait-ssh vm1|vm2 [timeout]"
			case "$1" in
				vm1|vm2) ;;
				*) die "unknown vm: $1" ;;
			esac
			if wait_ssh "$1" "${2:-${DEFAULT_WAIT_TIMEOUT}}"; then
				log "$1 ssh ready"
			else
				die "$1 ssh wait timed out"
			fi
			;;
		logs)
			[ $# -ge 1 ] || die "usage: $(basename "$0") logs vm1|vm2 [tail_lines]"
			case "$1" in
				vm1|vm2) ;;
				*) die "unknown vm: $1" ;;
			esac
			show_logs "$1" "${2:-120}"
			;;
		-h|--help|help)
			usage
			;;
		*)
			die "unknown command: ${cmd}"
			;;
	esac
}

main "$@"
