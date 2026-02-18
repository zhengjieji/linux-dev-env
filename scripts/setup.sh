#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LINUX_DIR="${ROOT_DIR}/linux"
LINUX_REPO_URL="https://github.com/torvalds/linux.git"
LINUX_TAG="v6.17"
CONFIG_FILE="${ROOT_DIR}/linux-configs/linux-config-6.17/.config"

RUN_DOCKER_BUILD=1
RUN_DEP_BUILDS=1
RUN_KERNEL_BUILD=1
RUN_TOOLS_BUILD=1
FORCE_CONFIG=0

log() {
	echo "[setup] $*"
}

die() {
	echo "[setup][error] $*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Bootstrap this Linux dev environment without sudo.

Options:
  --linux-dir <path>      Linux source directory (default: ${LINUX_DIR})
  --linux-repo <url>      Linux git repo URL (default: ${LINUX_REPO_URL})
  --linux-tag <tag>       Linux tag to checkout (default: ${LINUX_TAG})
  --config <path>         Kernel .config source file (default: ${CONFIG_FILE})
  --force-config          Overwrite existing linux/.config even if different
  --skip-docker-build     Skip building runtime docker image
  --skip-dep-builds       Skip headers/modules install builds
  --skip-kernel-build     Skip bzImage build
  --skip-tools-build      Skip libbpf/bpftool build
  -h, --help              Show this help

Examples:
  $(basename "$0")
  $(basename "$0") --linux-tag v6.18-rc1 --skip-tools-build
EOF
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--linux-dir)
				[ $# -gt 1 ] || die "--linux-dir requires a value"
				LINUX_DIR="$2"
				shift 2
				;;
			--linux-repo)
				[ $# -gt 1 ] || die "--linux-repo requires a value"
				LINUX_REPO_URL="$2"
				shift 2
				;;
			--linux-tag)
				[ $# -gt 1 ] || die "--linux-tag requires a value"
				LINUX_TAG="$2"
				shift 2
				;;
			--config)
				[ $# -gt 1 ] || die "--config requires a value"
				CONFIG_FILE="$2"
				shift 2
				;;
			--force-config)
				FORCE_CONFIG=1
				shift
				;;
			--skip-docker-build)
				RUN_DOCKER_BUILD=0
				shift
				;;
			--skip-dep-builds)
				RUN_DEP_BUILDS=0
				shift
				;;
			--skip-kernel-build)
				RUN_KERNEL_BUILD=0
				shift
				;;
			--skip-tools-build)
				RUN_TOOLS_BUILD=0
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
}

ensure_prereqs() {
	require_cmd git
	require_cmd make
	require_cmd docker
	require_cmd nproc
	docker info >/dev/null 2>&1 || die "docker daemon is not reachable for current user"
}

prepare_linux_repo() {
	if [ -e "${LINUX_DIR}" ] && [ ! -d "${LINUX_DIR}" ]; then
		die "linux path exists and is not a directory: ${LINUX_DIR}"
	fi

	if [ ! -d "${LINUX_DIR}" ]; then
		log "cloning linux repo into ${LINUX_DIR}"
		git clone "${LINUX_REPO_URL}" "${LINUX_DIR}"
	else
		log "linux directory exists, reusing ${LINUX_DIR}"
	fi

	git -C "${LINUX_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		die "linux directory is not a git repository: ${LINUX_DIR}"
	}

	if [ -n "$(git -C "${LINUX_DIR}" status --porcelain)" ]; then
		die "linux repo has local changes; clean or commit before setup checkout"
	fi

	log "fetching tags"
	git -C "${LINUX_DIR}" fetch --tags

	log "checking out ${LINUX_TAG}"
	git -C "${LINUX_DIR}" checkout "${LINUX_TAG}"
}

sync_config() {
	[ -f "${CONFIG_FILE}" ] || die "config file not found: ${CONFIG_FILE}"
	local dest="${LINUX_DIR}/.config"

	if [ -f "${dest}" ] && ! cmp -s "${CONFIG_FILE}" "${dest}" && [ "${FORCE_CONFIG}" -ne 1 ]; then
		die "existing ${dest} differs; rerun with --force-config to overwrite"
	fi

	if [ ! -f "${dest}" ] || ! cmp -s "${CONFIG_FILE}" "${dest}"; then
		log "copying kernel config to ${dest}"
		cp "${CONFIG_FILE}" "${dest}"
	else
		log "kernel config already up to date"
	fi
}

run_make_target() {
	local target="$1"
	log "running make ${target}"
	make -C "${ROOT_DIR}" "${target}" LINUX="${LINUX_DIR}"
}

main() {
	parse_args "$@"
	ensure_prereqs
	prepare_linux_repo
	sync_config

	if [ "${RUN_DOCKER_BUILD}" -eq 1 ]; then
		run_make_target docker
	fi

	if [ "${RUN_DEP_BUILDS}" -eq 1 ]; then
		run_make_target headers-install
		run_make_target modules-install
	fi

	if [ "${RUN_KERNEL_BUILD}" -eq 1 ]; then
		run_make_target vmlinux
	fi

	if [ "${RUN_TOOLS_BUILD}" -eq 1 ]; then
		run_make_target libbpf
		run_make_target bpftool
	fi

	log "setup complete"
	log "next step (single VM): make -C ${ROOT_DIR} qemu-run"
	log "next step (dual VM): make -C ${ROOT_DIR} dual-vm1 && make -C ${ROOT_DIR} dual-vm2"
}

main "$@"
