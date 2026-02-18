#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

RUN_DOCKER_BUILD=0
RUN_KERNEL_BUILD=0
RUN_QEMU_BOOT=0
RUN_DUAL_VM=0
DUAL_KEEP_RUNNING=0
DUAL_SSH_WAIT_SECS=180
QEMU_TIMEOUT_SECS=90

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --docker-build       Run: make docker
  --kernel-build       Run: make vmlinux
  --qemu-boot          Run: timeout <sec> make qemu-run
  --dual-vm            Run dual-vm live tests (ssh, ping, xdp smoke)
  --dual-keep-running  Keep dual-vm session alive after dual-vm test
  --dual-ssh-wait <s>  SSH readiness timeout for dual-vm test (default: ${DUAL_SSH_WAIT_SECS})
  --qemu-timeout <s>   Timeout for qemu-boot test (default: ${QEMU_TIMEOUT_SECS})
  -h, --help           Show this help

Examples:
  $(basename "$0") --docker-build
  $(basename "$0") --docker-build --kernel-build --qemu-boot --qemu-timeout 120
  $(basename "$0") --docker-build --kernel-build --dual-vm
EOF
}

fail() {
	echo "[FAIL] $*" >&2
	exit 1
}

pass() {
	echo "[PASS] $*"
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "required command missing: $1"
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
		--qemu-boot)
			RUN_QEMU_BOOT=1
			shift
			;;
		--dual-vm)
			RUN_DUAL_VM=1
			shift
			;;
		--dual-keep-running)
			DUAL_KEEP_RUNNING=1
			shift
			;;
		--dual-ssh-wait)
			[ $# -gt 1 ] || fail "--dual-ssh-wait requires a value"
			DUAL_SSH_WAIT_SECS="$2"
			shift 2
			;;
		--qemu-timeout)
			[ $# -gt 1 ] || fail "--qemu-timeout requires a value"
			QEMU_TIMEOUT_SECS="$2"
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

if [ "${RUN_DOCKER_BUILD}" -eq 0 ] && [ "${RUN_KERNEL_BUILD}" -eq 0 ] && [ "${RUN_QEMU_BOOT}" -eq 0 ] && [ "${RUN_DUAL_VM}" -eq 0 ]; then
	usage
	exit 1
fi

require_cmd make
require_cmd docker

if [ "${RUN_DOCKER_BUILD}" -eq 1 ]; then
	make -C "${ROOT_DIR}" docker
	pass "docker image build completed"
fi

if [ "${RUN_KERNEL_BUILD}" -eq 1 ]; then
	make -C "${ROOT_DIR}" vmlinux
	pass "kernel build completed"
fi

if [ "${RUN_QEMU_BOOT}" -eq 1 ]; then
	require_cmd timeout
	set +e
	timeout "${QEMU_TIMEOUT_SECS}" make -C "${ROOT_DIR}" qemu-run
	rc=$?
	set -e
	if [ "${rc}" -eq 0 ] || [ "${rc}" -eq 124 ]; then
		pass "qemu boot smoke test completed (rc=${rc})"
	else
		fail "qemu boot smoke test failed (rc=${rc})"
	fi
fi

if [ "${RUN_DUAL_VM}" -eq 1 ]; then
	dual_args=()
	[ "${DUAL_KEEP_RUNNING}" -eq 1 ] && dual_args+=(--keep-running)
	dual_args+=(--ssh-wait "${DUAL_SSH_WAIT_SECS}")
	"${SCRIPT_DIR}/dual-vm-live.sh" "${dual_args[@]}"
	pass "dual-vm live integration test completed"
fi
