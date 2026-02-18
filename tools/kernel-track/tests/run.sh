#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
KTRACK="${ROOT_DIR}/tools/kernel-track/ktrack.sh"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ktrack-test.XXXXXX")"
KERNEL_REPO="${TMP_ROOT}/linux"
CHECKPOINT_ROOT="${TMP_ROOT}/checkpoints"
PASS_COUNT=0

cleanup() {
	rm -rf "${TMP_ROOT}"
}
trap cleanup EXIT

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

assert_file_contains() {
	local file="$1"
	local needle="$2"
	grep -Fq "${needle}" "${file}" || fail "expected ${file} to contain: ${needle}"
}

assert_not_exists() {
	local path="$1"
	[ ! -e "${path}" ] || fail "expected path to not exist: ${path}"
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "required command missing: $1"
}

ktrack() {
	KTRACK_KERNEL_DIR="${KERNEL_REPO}" \
	KTRACK_CHECKPOINT_ROOT="${CHECKPOINT_ROOT}" \
	"${KTRACK}" "$@"
}

extract_checkpoint_id() {
	sed -n 's/^checkpoint created: \([^ ]*\).*/\1/p'
}

require_cmd git
require_cmd awk
require_cmd sed

[ -x "${KTRACK}" ] || fail "tool not executable: ${KTRACK}"

git init -q "${KERNEL_REPO}"
git -C "${KERNEL_REPO}" config user.name "ktrack-test"
git -C "${KERNEL_REPO}" config user.email "ktrack-test@example.com"

mkdir -p "${KERNEL_REPO}/kernel/trace"
cat >"${KERNEL_REPO}/.gitignore" <<'EOF'
*.o
*.cmd
EOF
cat >"${KERNEL_REPO}/kernel/trace/bpf_trace.c" <<'EOF'
int bpf_trace_test(void) { return 0; }
EOF

git -C "${KERNEL_REPO}" add .
git -C "${KERNEL_REPO}" commit -q -m "init kernel fixture"

status_out="$(ktrack status)"
assert_contains "${status_out}" "tracked changes: 0"
assert_contains "${status_out}" "latest checkpoint: <none>"
pass "status reports clean repository"

cat >"${KERNEL_REPO}/kernel/trace/bpf_trace.c" <<'EOF'
int bpf_trace_test(void) { return 1; }
EOF

checkpoint_out="$(ktrack checkpoint --label manual-1)"
checkpoint_id="$(printf '%s\n' "${checkpoint_out}" | extract_checkpoint_id)"
[ -n "${checkpoint_id}" ] || fail "could not parse checkpoint id from output"
[ -f "${CHECKPOINT_ROOT}/${checkpoint_id}/tracked.patch" ] || fail "tracked.patch missing"
[ -f "${CHECKPOINT_ROOT}/${checkpoint_id}/tracked-current.tar" ] || fail "tracked-current.tar missing"
[ -f "${CHECKPOINT_ROOT}/${checkpoint_id}/tracked-existing-files.txt" ] || fail "tracked-existing-files.txt missing"
[ -f "${CHECKPOINT_ROOT}/${checkpoint_id}/tracked-deleted-files.txt" ] || fail "tracked-deleted-files.txt missing"
pass "manual checkpoint created"

auto_out="$(ktrack auto-checkpoint --label auto-smoke)"
assert_contains "${auto_out}" "checkpoint skipped: no change since latest checkpoint"
pass "auto-checkpoint skips duplicate state"

cat >"${KERNEL_REPO}/kernel/trace/bpf_trace.c" <<'EOF'
int bpf_trace_test(void) { return 9; }
EOF

ktrack revert --last --apply >/dev/null
assert_file_contains "${KERNEL_REPO}/kernel/trace/bpf_trace.c" "return 1;"
pass "revert --last --apply restores tracked source snapshot"

cat >"${KERNEL_REPO}/kernel/trace/bpf_trace.c" <<'EOF'
int bpf_trace_test(void) { return 2; }
EOF

clean_out="$(ktrack checkpoint --label clean-target)"
clean_checkpoint_id="$(printf '%s\n' "${clean_out}" | extract_checkpoint_id)"
[ -n "${clean_checkpoint_id}" ] || fail "could not parse clean checkpoint id"

touch "${KERNEL_REPO}/kernel/trace/generated.o"
touch "${KERNEL_REPO}/kernel/trace/generated.cmd"

dry_clean_out="$(ktrack clean-build --id "${clean_checkpoint_id}")"
assert_contains "${dry_clean_out}" "dry-run: pass --apply"
[ -f "${KERNEL_REPO}/kernel/trace/generated.o" ] || fail "dry-run unexpectedly removed generated.o"

ktrack clean-build --id "${clean_checkpoint_id}" --apply >/dev/null
assert_not_exists "${KERNEL_REPO}/kernel/trace/generated.o"
assert_not_exists "${KERNEL_REPO}/kernel/trace/generated.cmd"
pass "clean-build removes ignored build artifacts in affected directories"

echo "[PASS] kernel-track suite completed (${PASS_COUNT} checks)"
