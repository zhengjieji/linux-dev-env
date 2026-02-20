#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

SRC_DIR="${ROOT_DIR}/source/katran"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"
FORCE_REBUILD=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Build Katran balancer BPF object on host via docker runtime image.

Options:
  --src <path>            Katran source directory (default: ${SRC_DIR})
  --runtime-image <name>  Runtime docker image (default: ${RUNTIME_IMAGE})
  --force                 Rebuild even if object already exists
  -h, --help              Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--src)
			[ $# -gt 1 ] || { echo "--src requires value" >&2; exit 1; }
			SRC_DIR="$2"
			shift 2
			;;
		--runtime-image)
			[ $# -gt 1 ] || { echo "--runtime-image requires value" >&2; exit 1; }
			RUNTIME_IMAGE="$2"
			shift 2
			;;
		--force)
			FORCE_REBUILD=1
			shift
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

if ! command -v docker >/dev/null 2>&1; then
	echo "[katran-build][error] docker not found" >&2
	exit 1
fi

if [ ! -d "${SRC_DIR}/.git" ]; then
	echo "[katran-build][error] Katran repo not found at ${SRC_DIR}; run scripts/katran/clone-katran.sh first" >&2
	exit 1
fi

if ! docker image inspect "${RUNTIME_IMAGE}" >/dev/null 2>&1; then
	echo "[katran-build][error] docker image '${RUNTIME_IMAGE}' not found; run 'make docker' first" >&2
	exit 1
fi

OBJ_PATH="${SRC_DIR}/build/katran/lib/bpf/balancer.bpf.o"
mkdir -p "$(dirname -- "${OBJ_PATH}")"

if [ "${FORCE_REBUILD}" -eq 0 ] && [ -f "${OBJ_PATH}" ]; then
	echo "[katran-build] existing object found: ${OBJ_PATH}"
	echo "[katran-build] skip build (use --force to rebuild)"
	exit 0
fi

echo "[katran-build] building balancer.bpf.o using image ${RUNTIME_IMAGE}"
docker run --rm \
	-v "${SRC_DIR}:/katran" \
	-w /katran \
	"${RUNTIME_IMAGE}" \
	bash -lc '
		set -euo pipefail
		SRC_DIR=/katran
		BUILD_DIR=/katran/build
		STAGE_DIR="${BUILD_DIR}/deps/bpfprog"
		OUT_OBJ="${BUILD_DIR}/katran/lib/bpf/balancer.bpf.o"

		CLANG_BIN="$(command -v clang || command -v clang-18 || command -v clang-17 || true)"
		LLC_BIN="$(command -v llc || command -v llc-18 || command -v llc-17 || true)"

		if [ -z "${CLANG_BIN}" ]; then
			echo "[katran-build][error] clang not found in runtime image" >&2
			exit 1
		fi
		if [ -z "${LLC_BIN}" ]; then
			echo "[katran-build][error] llc not found in runtime image" >&2
			exit 1
		fi

		rm -rf "${STAGE_DIR}"
		mkdir -p "${STAGE_DIR}/include" "${STAGE_DIR}/usr" "${STAGE_DIR}/katran/lib/bpf"
		ln -sfn ../include "${STAGE_DIR}/usr/include"

		cp "${SRC_DIR}/katran/lib/Makefile-bpf" "${STAGE_DIR}/Makefile"
		cp -r "${SRC_DIR}/katran/lib/bpf" "${STAGE_DIR}/katran/lib/"
		cp -r "${SRC_DIR}/katran/lib/linux_includes" "${STAGE_DIR}/katran/lib/linux_includes"
		cp -r "${SRC_DIR}/katran/decap/bpf" "${STAGE_DIR}/"
		cp "${SRC_DIR}"/katran/lib/linux_includes/* "${STAGE_DIR}/include/"

		make -C "${STAGE_DIR}" bpf/balancer.bpf.o CLANG="${CLANG_BIN}" LLC="${LLC_BIN}"

		test -f "${STAGE_DIR}/bpf/balancer.bpf.o"
		mkdir -p "$(dirname -- "${OUT_OBJ}")"
		cp "${STAGE_DIR}/bpf/balancer.bpf.o" "${OUT_OBJ}"
	'

test -f "${OBJ_PATH}" || {
	echo "[katran-build][error] build completed but object missing: ${OBJ_PATH}" >&2
	exit 1
}

echo "[katran-build] built: ${OBJ_PATH}"
sha256sum "${OBJ_PATH}" | awk '{print "[katran-build] sha256=" $1}'
