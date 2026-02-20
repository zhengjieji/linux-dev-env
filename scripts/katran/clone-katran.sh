#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

REPO_URL="https://github.com/facebookincubator/katran.git"
DEST_DIR="${ROOT_DIR}/source/katran"
REF="main"
UPDATE=0
BUILD=1
RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Clone Katran source into source/katran and checkout a pinned ref.

Options:
  --repo <url>         Katran repository URL (default: ${REPO_URL})
  --dest <path>        Destination directory (default: ${DEST_DIR})
  --ref <ref>          Git ref/tag/commit to checkout (default: ${REF})
  --update             If destination exists, fetch and update
  --runtime-image <n>  Runtime image for host BPF build (default: ${RUNTIME_IMAGE})
  --skip-build         Clone/update only; skip host BPF build
  -h, --help           Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--repo)
			[ $# -gt 1 ] || { echo "--repo requires value" >&2; exit 1; }
			REPO_URL="$2"
			shift 2
			;;
		--dest)
			[ $# -gt 1 ] || { echo "--dest requires value" >&2; exit 1; }
			DEST_DIR="$2"
			shift 2
			;;
		--ref)
			[ $# -gt 1 ] || { echo "--ref requires value" >&2; exit 1; }
			REF="$2"
			shift 2
			;;
		--update)
			UPDATE=1
			shift
			;;
		--runtime-image)
			[ $# -gt 1 ] || { echo "--runtime-image requires value" >&2; exit 1; }
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
			echo "unknown option: $1" >&2
			exit 1
			;;
	esac
done

mkdir -p "$(dirname -- "${DEST_DIR}")"

if [ ! -d "${DEST_DIR}/.git" ]; then
	echo "[clone-katran] cloning ${REPO_URL} -> ${DEST_DIR}"
	git clone "${REPO_URL}" "${DEST_DIR}"
else
	echo "[clone-katran] destination exists: ${DEST_DIR}"
	if [ "${UPDATE}" -eq 1 ]; then
		echo "[clone-katran] fetching updates"
		git -C "${DEST_DIR}" fetch --all --tags
	fi
fi

git -C "${DEST_DIR}" checkout "${REF}"

echo "[clone-katran] current commit: $(git -C "${DEST_DIR}" rev-parse --short HEAD)"
if [ "${BUILD}" -eq 1 ]; then
	echo "[clone-katran] building Katran BPF object on host"
	"${SCRIPT_DIR}/build-katran-host.sh" --src "${DEST_DIR}" --runtime-image "${RUNTIME_IMAGE}"
else
	echo "[clone-katran] skipped host BPF build"
fi

echo "[clone-katran] done"
