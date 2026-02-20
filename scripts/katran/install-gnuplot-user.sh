#!/usr/bin/env bash

set -euo pipefail

PREFIX="${KATRAN_GNUPLOT_PREFIX:-${HOME}/.local/opt/gnuplot}"
MAMBA_ROOT_PREFIX="${PREFIX}/mamba-root"
MICROMAMBA_BIN="${PREFIX}/bin/micromamba"
ENV_PREFIX="${PREFIX}/env"
FORCE=0
QUIET=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Install gnuplot in user space (no sudo) using micromamba.

Options:
  --prefix <path>    Install prefix (default: ${PREFIX})
  --force            Reinstall micromamba/gnuplot environment
  --quiet            Suppress informational output
  -h, --help         Show this help
USAGE
}

info() {
	if [ "${QUIET}" -eq 0 ]; then
		echo "$*"
	fi
}

die() {
	echo "[plot-tool][error] $*" >&2
	exit 1
}

download_to_stdout() {
	local url="$1"
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL "${url}"
	elif command -v wget >/dev/null 2>&1; then
		wget -qO- "${url}"
	else
		die "missing downloader: install curl or wget"
	fi
}

run_micromamba() {
	if [ "${QUIET}" -eq 1 ]; then
		MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX}" "${MICROMAMBA_BIN}" "$@" >/dev/null
	else
		MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX}" "${MICROMAMBA_BIN}" "$@"
	fi
}

while [ $# -gt 0 ]; do
	case "$1" in
		--prefix)
			[ $# -gt 1 ] || die "--prefix requires value"
			PREFIX="$2"
			MAMBA_ROOT_PREFIX="${PREFIX}/mamba-root"
			MICROMAMBA_BIN="${PREFIX}/bin/micromamba"
			ENV_PREFIX="${PREFIX}/env"
			shift 2
			;;
		--force)
			FORCE=1
			shift
			;;
		--quiet)
			QUIET=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			die "unknown option: $1"
			;;
	esac
done

if [ "$(uname -s)" != "Linux" ]; then
	die "this installer currently supports Linux only"
fi

install -d "${PREFIX}/bin" "${MAMBA_ROOT_PREFIX}"

if [ ! -x "${MICROMAMBA_BIN}" ] || [ "${FORCE}" -eq 1 ]; then
	case "$(uname -m)" in
		x86_64|amd64)
			MM_ARCH="linux-64"
			;;
		aarch64|arm64)
			MM_ARCH="linux-aarch64"
			;;
		*)
			die "unsupported architecture: $(uname -m)"
			;;
	esac
	MM_URL="https://micro.mamba.pm/api/micromamba/${MM_ARCH}/latest"
	TMP_DIR="$(mktemp -d)"
	cleanup_tmp() {
		rm -rf "${TMP_DIR}"
	}
	trap cleanup_tmp EXIT
	info "[plot-tool] downloading micromamba (${MM_ARCH})"
	download_to_stdout "${MM_URL}" | tar -xj -C "${TMP_DIR}" bin/micromamba
	install -m 0755 "${TMP_DIR}/bin/micromamba" "${MICROMAMBA_BIN}"
	cleanup_tmp
	trap - EXIT
fi

if [ -x "${ENV_PREFIX}/bin/gnuplot" ] && [ "${FORCE}" -ne 1 ]; then
	info "[plot-tool] gnuplot already installed at ${ENV_PREFIX}/bin/gnuplot"
else
	info "[plot-tool] installing gnuplot into ${ENV_PREFIX}"
	run_micromamba create -y -p "${ENV_PREFIX}" -c conda-forge gnuplot
fi

ln -sfn "${ENV_PREFIX}/bin/gnuplot" "${PREFIX}/bin/gnuplot"

if ! "${PREFIX}/bin/gnuplot" --version >/dev/null 2>&1; then
	die "gnuplot binary installed but failed to execute: ${PREFIX}/bin/gnuplot"
fi

info "[plot-tool] ready: ${PREFIX}/bin/gnuplot"
info "[plot-tool] add to PATH if needed: export PATH=${PREFIX}/bin:\$PATH"
