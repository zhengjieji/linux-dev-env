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

qscript_text="$(cat "${ROOT_DIR}/q-script/yifei-q")"
assert_contains "${qscript_text}" "hostfwd=tcp::52222-:22"
assert_contains "${qscript_text}" "hostfwd=tcp::52223-:52223"
pass "qemu script keeps expected guest port forwarding"

echo "[PASS] vm-linux-dev dry-run suite completed (${PASS_COUNT} checks)"
