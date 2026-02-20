#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

BASE_SRC="${EXP2_BASE_SOURCE_DEFAULT}"
EXP2_SRC="${EXP2_SOURCE_DEFAULT}"
REF=""
UPDATE=0
RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"
BUILD=1

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Prepare isolated Exp2 Katran source tree and build its BPF object.

Options:
  --base-src <path>     Base source repo (default: ${BASE_SRC})
  --exp2-src <path>     Exp2 isolated source (default: ${EXP2_SRC})
  --ref <git-ref>       Checkout ref (default: base-src HEAD)
  --update              Fetch/update if exp2-src already exists
  --runtime-image <n>   Runtime image for build (default: ${RUNTIME_IMAGE})
  --skip-build          Only prepare source, skip BPF build
  -h, --help            Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--base-src)
			[ $# -gt 1 ] || exp2_die "--base-src requires value"
			BASE_SRC="$2"
			shift 2
			;;
		--exp2-src)
			[ $# -gt 1 ] || exp2_die "--exp2-src requires value"
			EXP2_SRC="$2"
			shift 2
			;;
		--ref)
			[ $# -gt 1 ] || exp2_die "--ref requires value"
			REF="$2"
			shift 2
			;;
		--update)
			UPDATE=1
			shift
			;;
		--runtime-image)
			[ $# -gt 1 ] || exp2_die "--runtime-image requires value"
			RUNTIME_IMAGE="$2"
			shift 2
			;;
		--skip-build)
			BUILD=0
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			exp2_die "unknown option: $1"
			;;
	esac
done

BASE_SRC="$(resolve_path_exp2 "${BASE_SRC}")"
EXP2_SRC="$(resolve_path_exp2 "${EXP2_SRC}")"

[ -d "${BASE_SRC}/.git" ] || exp2_die "base source is not a git repo: ${BASE_SRC}"

if [ -z "${REF}" ]; then
	REF="$(git -C "${BASE_SRC}" rev-parse HEAD)"
fi

repo_url="$(git -C "${BASE_SRC}" remote get-url origin 2>/dev/null || true)"
if [ -z "${repo_url}" ]; then
	repo_url="https://github.com/facebookincubator/katran.git"
fi

if [ ! -d "${EXP2_SRC}/.git" ]; then
	exp2_log "creating isolated Exp2 source at ${EXP2_SRC}"
	"${ROOT_DIR}/scripts/katran/clone-katran.sh" \
		--repo "${repo_url}" \
		--dest "${EXP2_SRC}" \
		--ref "${REF}" \
		--runtime-image "${RUNTIME_IMAGE}" \
		--skip-build
else
	exp2_log "isolated Exp2 source already exists: ${EXP2_SRC}"
	if [ "${UPDATE}" -eq 1 ]; then
		git -C "${EXP2_SRC}" fetch --all --tags
	fi
	git -C "${EXP2_SRC}" checkout "${REF}"
fi

if [ "${BUILD}" -eq 1 ]; then
	exp2_log "building Exp2 source object"
	"${ROOT_DIR}/scripts/katran/build-katran-host.sh" --src "${EXP2_SRC}" --runtime-image "${RUNTIME_IMAGE}" --force
fi

obj_path="${EXP2_SRC}/build/katran/lib/bpf/balancer.bpf.o"
if [ "${BUILD}" -eq 1 ]; then
	assert_file "${obj_path}"
fi

exp2_log "prepared Exp2 source at ${EXP2_SRC}"
echo "EXP2_SRC=${EXP2_SRC}"
echo "EXP2_REF=${REF}"
if [ -f "${obj_path}" ]; then
	echo "EXP2_OBJ=${obj_path}"
fi
