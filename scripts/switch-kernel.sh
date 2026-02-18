#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

LINUX_DIR="${ROOT_DIR}/linux"
LINUX_REPO_URL="https://github.com/torvalds/linux.git"
CONFIGS_ROOT="${ROOT_DIR}/linux-configs"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-dual-vm-zhengjie}"
TARGET_TAG=""
BASE_CONFIG=""

RUN_DOCKER_BUILD=1
FETCH_TAGS=1
RUN_DRYRUN_TEST=1
RUN_KERNEL_BUILD=1
RUN_QEMU_SSH_SMOKE=1
SAVE_CONFIG=1
FORCE_SAVE=0

SMOKE_SSH_PORT=62022
SMOKE_NET_PORT=62023
SMOKE_GDB_PORT=62110
SMOKE_TIMEOUT_SECS=180

log() {
	echo "[switch-kernel] $*"
}

die() {
	echo "[switch-kernel][error] $*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: $(basename "$0") --tag <linux-tag> [options]

Switch Linux kernel tag, migrate config with olddefconfig, validate dev flow,
and save the resulting working config.

Options:
  --tag <tag>             Target Linux tag (required), e.g. v6.18-rc1
  --linux-dir <path>      Linux source directory (default: ${LINUX_DIR})
  --linux-repo <url>      Linux git repo URL (default: ${LINUX_REPO_URL})
  --base-config <path>    Base config to migrate (default: linux/.config if present,
                          otherwise linux-configs/linux-config-6.17/.config)
  --image <name>          Docker image for kernel builds (default: ${RUNTIME_IMAGE})
  --skip-docker-build     Skip make docker (requires image to exist)
  --skip-fetch-tags       Skip git fetch --tags
  --skip-vm-dryrun        Skip tests/vm-linux-dev/run.sh
  --skip-kernel-build     Skip make vmlinux
  --skip-qemu-ssh         Skip live qemu+ssh smoke test
  --no-save-config        Do not save migrated config
  --force-save            Overwrite existing saved config file
  --smoke-ssh-port <n>    Host SSH port for smoke VM (default: ${SMOKE_SSH_PORT})
  --smoke-net-port <n>    Host NET port for smoke VM (default: ${SMOKE_NET_PORT})
  --smoke-gdb-port <n>    Host GDB port for smoke VM (default: ${SMOKE_GDB_PORT})
  --smoke-timeout <sec>   Timeout for qemu+ssh smoke (default: ${SMOKE_TIMEOUT_SECS})
  -h, --help              Show this help

Examples:
  $(basename "$0") --tag v6.18
  $(basename "$0") --tag v6.18-rc1 --skip-qemu-ssh
  $(basename "$0") --tag v6.18 --base-config ./linux-configs/linux-config-6.17/.config
EOF
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--tag)
				[ $# -gt 1 ] || die "--tag requires a value"
				TARGET_TAG="$2"
				shift 2
				;;
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
			--base-config)
				[ $# -gt 1 ] || die "--base-config requires a value"
				BASE_CONFIG="$2"
				shift 2
				;;
			--image)
				[ $# -gt 1 ] || die "--image requires a value"
				RUNTIME_IMAGE="$2"
				shift 2
				;;
			--skip-docker-build)
				RUN_DOCKER_BUILD=0
				shift
				;;
			--skip-fetch-tags)
				FETCH_TAGS=0
				shift
				;;
			--skip-vm-dryrun)
				RUN_DRYRUN_TEST=0
				shift
				;;
			--skip-kernel-build)
				RUN_KERNEL_BUILD=0
				shift
				;;
			--skip-qemu-ssh)
				RUN_QEMU_SSH_SMOKE=0
				shift
				;;
			--no-save-config)
				SAVE_CONFIG=0
				shift
				;;
			--force-save)
				FORCE_SAVE=1
				shift
				;;
			--smoke-ssh-port)
				[ $# -gt 1 ] || die "--smoke-ssh-port requires a value"
				SMOKE_SSH_PORT="$2"
				shift 2
				;;
			--smoke-net-port)
				[ $# -gt 1 ] || die "--smoke-net-port requires a value"
				SMOKE_NET_PORT="$2"
				shift 2
				;;
			--smoke-gdb-port)
				[ $# -gt 1 ] || die "--smoke-gdb-port requires a value"
				SMOKE_GDB_PORT="$2"
				shift 2
				;;
			--smoke-timeout)
				[ $# -gt 1 ] || die "--smoke-timeout requires a value"
				SMOKE_TIMEOUT_SECS="$2"
				shift 2
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

	[ -n "${TARGET_TAG}" ] || die "--tag is required"
}

ensure_prereqs() {
	require_cmd git
	require_cmd make
	require_cmd docker
	require_cmd ssh
	require_cmd timeout
	docker info >/dev/null 2>&1 || die "docker daemon is not reachable for current user"
}

ensure_linux_repo() {
	if [ -e "${LINUX_DIR}" ] && [ ! -d "${LINUX_DIR}" ]; then
		die "linux path exists and is not a directory: ${LINUX_DIR}"
	fi

	if [ ! -d "${LINUX_DIR}" ]; then
		log "linux repo missing, cloning ${LINUX_REPO_URL} into ${LINUX_DIR}"
		git clone "${LINUX_REPO_URL}" "${LINUX_DIR}"
	fi

	git -C "${LINUX_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		die "linux directory is not a git repository: ${LINUX_DIR}"
	}

	if [ -n "$(git -C "${LINUX_DIR}" status --porcelain)" ]; then
		die "linux repo has local changes; clean or commit before switching tags"
	fi
}

resolve_base_config() {
	if [ -n "${BASE_CONFIG}" ]; then
		[ -f "${BASE_CONFIG}" ] || die "base config not found: ${BASE_CONFIG}"
		return
	fi

	if [ -f "${LINUX_DIR}/.config" ]; then
		BASE_CONFIG="${LINUX_DIR}/.config"
		return
	fi

	if [ -f "${CONFIGS_ROOT}/linux-config-6.17/.config" ]; then
		BASE_CONFIG="${CONFIGS_ROOT}/linux-config-6.17/.config"
		return
	fi

	local fallback
	fallback="$(find "${CONFIGS_ROOT}" -maxdepth 2 -type f -name .config | LC_ALL=C sort | tail -n1 || true)"
	[ -n "${fallback}" ] || die "could not find a base config in ${CONFIGS_ROOT}"
	BASE_CONFIG="${fallback}"
}

run_make_target() {
	local target="$1"
	log "running make ${target}"
	make -C "${ROOT_DIR}" "${target}" LINUX="${LINUX_DIR}" RUNTIME_IMAGE="${RUNTIME_IMAGE}"
}

ensure_runtime_image() {
	if [ "${RUN_DOCKER_BUILD}" -eq 1 ]; then
		run_make_target docker
	else
		docker image inspect "${RUNTIME_IMAGE}" >/dev/null 2>&1 || {
			die "docker image '${RUNTIME_IMAGE}' missing; run without --skip-docker-build"
		}
	fi
}

checkout_target_tag() {
	if [ "${FETCH_TAGS}" -eq 1 ]; then
		log "fetching Linux tags"
		git -C "${LINUX_DIR}" fetch --tags
	fi

	log "checking out ${TARGET_TAG}"
	git -C "${LINUX_DIR}" checkout "${TARGET_TAG}"
}

migrate_config_olddefconfig() {
	local dest="${LINUX_DIR}/.config"
	log "using base config: ${BASE_CONFIG}"
	if [ -f "${dest}" ] && [ "$(realpath "${BASE_CONFIG}")" = "$(realpath "${dest}")" ]; then
		log "base config already at ${dest}"
	else
		cp "${BASE_CONFIG}" "${dest}"
	fi

	log "running olddefconfig in docker (non-interactive oldconfig)"
	docker run --rm \
		-v "${LINUX_DIR}:/linux" \
		-w /linux \
		"${RUNTIME_IMAGE}" \
		make olddefconfig
}

run_vm_dryrun_test() {
	[ "${RUN_DRYRUN_TEST}" -eq 1 ] || return 0
	log "running VM dry-run validation"
	"${ROOT_DIR}/tests/vm-linux-dev/run.sh"
}

run_kernel_build_test() {
	[ "${RUN_KERNEL_BUILD}" -eq 1 ] || return 0
	run_make_target vmlinux
}

run_qemu_ssh_smoke_test() {
	[ "${RUN_QEMU_SSH_SMOKE}" -eq 1 ] || return 0

	local qlog
	local slog
	local cname
	qlog="$(mktemp "${TMPDIR:-/tmp}/switch-kernel-qemu.XXXXXX")"
	slog="$(mktemp "${TMPDIR:-/tmp}/switch-kernel-ssh.XXXXXX")"
	cname="switch-kernel-smoke-$$-$(date +%s)"

	cleanup_smoke() {
		docker rm -f "${cname}" >/dev/null 2>&1 || true
		rm -f "${qlog}" "${slog}"
	}

	log "starting qemu smoke VM on ports ${SMOKE_SSH_PORT}/${SMOKE_NET_PORT}/${SMOKE_GDB_PORT}"
	docker run --name "${cname}" --privileged --rm \
		--device=/dev/kvm:/dev/kvm \
		-v "${ROOT_DIR}:/linux-dev-env" -v "${LINUX_DIR}:/linux" \
		-w /linux \
		-p "127.0.0.1:${SMOKE_SSH_PORT}:52222" \
		-p "127.0.0.1:${SMOKE_NET_PORT}:52223" \
		-p "127.0.0.1:${SMOKE_GDB_PORT}:1234" \
		"${RUNTIME_IMAGE}" \
		/linux-dev-env/q-script/yifei-q -s >"${qlog}" 2>&1 &

	local start_ts
	start_ts="$(date +%s)"
	local ok=0

	while true; do
		if ssh \
			-o "UserKnownHostsFile=/dev/null" \
			-o "StrictHostKeyChecking=no" \
			-o "ConnectTimeout=3" \
			-p "${SMOKE_SSH_PORT}" \
			root@127.0.0.1 \
			"echo KERNEL_SWITCH_SMOKE_OK && uname -r" >"${slog}" 2>&1; then
			ok=1
			break
		fi

		local now
		now="$(date +%s)"
		if [ $((now - start_ts)) -ge "${SMOKE_TIMEOUT_SECS}" ]; then
			break
		fi
		sleep 2
	done

	if [ "${ok}" -ne 1 ]; then
		echo "--- qemu smoke ssh output ---" >&2
		cat "${slog}" >&2 || true
		echo "--- qemu smoke log tail ---" >&2
		tail -n 120 "${qlog}" >&2 || true
		cleanup_smoke
		die "qemu+ssh smoke test failed"
	fi

	log "qemu+ssh smoke ok: $(tr '\n' ' ' < "${slog}")"
	cleanup_smoke
}

save_working_config() {
	[ "${SAVE_CONFIG}" -eq 1 ] || {
		log "config save skipped (--no-save-config)"
		return 0
	}

	local short_tag="${TARGET_TAG#v}"
	local dest_dir="${CONFIGS_ROOT}/linux-config-${short_tag}"
	local dest_config="${dest_dir}/.config"
	mkdir -p "${dest_dir}"

	if [ -f "${dest_config}" ] && [ "${FORCE_SAVE}" -ne 1 ]; then
		if cmp -s "${LINUX_DIR}/.config" "${dest_config}"; then
			log "saved config already up to date at ${dest_config}"
			return 0
		fi
		die "config already exists at ${dest_config}; rerun with --force-save to overwrite"
	fi

	cp "${LINUX_DIR}/.config" "${dest_config}"
	log "saved working config to ${dest_config}"
}

main() {
	parse_args "$@"
	ensure_prereqs
	ensure_linux_repo
	resolve_base_config
	ensure_runtime_image
	checkout_target_tag
	migrate_config_olddefconfig
	run_vm_dryrun_test
	run_kernel_build_test
	run_qemu_ssh_smoke_test
	save_working_config
	log "kernel switch complete: ${TARGET_TAG}"
}

main "$@"
