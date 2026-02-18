#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
PASS_COUNT=0

fail() {
	echo "[FAIL] $*" >&2
	exit 1
}

pass() {
	PASS_COUNT=$((PASS_COUNT + 1))
	echo "[PASS] $*"
}

assert_contains() {
	local haystack="$1"
	local needle="$2"
	[[ "${haystack}" == *"${needle}"* ]] || fail "expected output to contain: ${needle}"
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "required command missing: $1"
}

require_cmd make

[ -f "${ROOT_DIR}/Makefile" ] || fail "Makefile missing"
[ -f "${ROOT_DIR}/Dockerfile" ] || fail "Dockerfile missing"
[ -f "${ROOT_DIR}/q-script/yifei-q" ] || fail "qemu script missing"
[ -x "${ROOT_DIR}/scripts/dual-vm.sh" ] || fail "dual-vm script missing or not executable"
[ -x "${ROOT_DIR}/tools/kernel-track/ktrack.sh" ] || fail "ktrack tool missing or not executable"

vmlinux_plan="$(make -C "${ROOT_DIR}" -n vmlinux)"
assert_contains "${vmlinux_plan}" "ktrack.sh auto-checkpoint --label vmlinux"
assert_contains "${vmlinux_plan}" "make -j\`nproc\` bzImage"
pass "vmlinux pipeline includes auto-checkpoint + kernel build"

headers_plan="$(make -C "${ROOT_DIR}" -n headers-install)"
assert_contains "${headers_plan}" "ktrack.sh auto-checkpoint --label headers-install"
assert_contains "${headers_plan}" "headers_install"
pass "headers-install pipeline includes auto-checkpoint"

modules_plan="$(make -C "${ROOT_DIR}" -n modules-install)"
assert_contains "${modules_plan}" "ktrack.sh auto-checkpoint --label modules-install"
assert_contains "${modules_plan}" "modules_install"
pass "modules-install pipeline includes auto-checkpoint"

qemu_plan="$(make -C "${ROOT_DIR}" -n qemu-run)"
assert_contains "${qemu_plan}" "--device=/dev/kvm:/dev/kvm"
assert_contains "${qemu_plan}" "/linux-dev-env/q-script/yifei-q -s"
assert_contains "${qemu_plan}" ":52222"
assert_contains "${qemu_plan}" ":52223"
assert_contains "${qemu_plan}" ":1234"
pass "qemu-run pipeline exposes expected KVM and forwarded ports"

dual_vm1_plan="$(make -C "${ROOT_DIR}" -n dual-vm1)"
assert_contains "${dual_vm1_plan}" "scripts/dual-vm.sh start vm1"
assert_contains "${dual_vm1_plan}" "DUAL_VM1_SSH_PORT"
assert_contains "${dual_vm1_plan}" "DUAL_VM2_SSH_PORT"
pass "dual-vm1 target wires through dual-vm script and shared port config"

dual_vm2_plan="$(make -C "${ROOT_DIR}" -n dual-vm2)"
assert_contains "${dual_vm2_plan}" "scripts/dual-vm.sh start vm2"
pass "dual-vm2 target wires through dual-vm script"

dual_stop_plan="$(make -C "${ROOT_DIR}" -n dual-vm-stop)"
assert_contains "${dual_stop_plan}" "scripts/dual-vm.sh stop all"
pass "dual-vm-stop target tears down full dual-vm session"

qscript_text="$(cat "${ROOT_DIR}/q-script/yifei-q")"
assert_contains "${qscript_text}" 'hostfwd=tcp::${SSH_FWD_PORT}-:22'
assert_contains "${qscript_text}" 'hostfwd=tcp::${NET_FWD_PORT}-:52223'
assert_contains "${qscript_text}" "Q_SSH_FWD_PORT"
assert_contains "${qscript_text}" "Q_GDB_PORT"
pass "qemu script keeps expected default forwarding and supports port overrides"

echo "[PASS] vm-linux-dev dry-run suite completed (${PASS_COUNT} checks)"
