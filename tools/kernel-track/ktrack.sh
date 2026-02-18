#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
KERNEL_DIR="${KTRACK_KERNEL_DIR:-${WORKSPACE_DIR}/linux}"
CHECKPOINT_ROOT="${KTRACK_CHECKPOINT_ROOT:-${SCRIPT_DIR}/checkpoints}"
KTRACK_RETENTION="${KTRACK_RETENTION:-50}"

usage() {
	cat <<'EOF'
Kernel change tracker

Usage:
  ktrack.sh status
  ktrack.sh auto-checkpoint [--label <name>] [--keep-untracked]
  ktrack.sh checkpoint [--label <name>] [--with-untracked]
  ktrack.sh list
  ktrack.sh show --id <checkpoint-id>
  ktrack.sh revert (--id <checkpoint-id> | --last) [--apply] [--force-head]
  ktrack.sh clean-build (--id <checkpoint-id> | --last) [--apply]
  ktrack.sh reset (--id <checkpoint-id> | --last) [--apply] [--force-head]

Notes:
  - revert/clean-build/reset are dry-run unless --apply is passed.
  - auto-checkpoint skips when there are no tracked changes.
  - checkpoints are stored under tools/kernel-track/checkpoints/.
EOF
}

die() {
	echo "error: $*" >&2
	exit 1
}

ensure_kernel_repo() {
	git -C "${KERNEL_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		die "kernel repo not found at '${KERNEL_DIR}'"
	}
}

ensure_checkpoint_root() {
	mkdir -p "${CHECKPOINT_ROOT}"
}

count_file_lines() {
	local file="$1"
	[ -f "${file}" ] || {
		echo 0
		return
	}
	awk 'END { print NR }' "${file}"
}

sha256_file() {
	local file="$1"
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "${file}" | awk '{print $1}'
	else
		shasum -a 256 "${file}" | awk '{print $1}'
	fi
}

latest_checkpoint_id() {
	[ -d "${CHECKPOINT_ROOT}" ] || return 1
	local latest
	latest="$(find "${CHECKPOINT_ROOT}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort -r | head -n1)"
	[ -n "${latest}" ] || return 1
	echo "${latest}"
}

resolve_checkpoint_dir() {
	local id="${1:-}"
	local mode="${2:-id}"
	local checkpoint_id=""

	if [ "${mode}" = "last" ]; then
		checkpoint_id="$(latest_checkpoint_id || true)"
		[ -n "${checkpoint_id}" ] || die "no checkpoints found"
		echo "${CHECKPOINT_ROOT}/${checkpoint_id}"
		return
	fi

	[ -n "${id}" ] || die "missing checkpoint id"

	if [ -d "${CHECKPOINT_ROOT}/${id}" ]; then
		echo "${CHECKPOINT_ROOT}/${id}"
		return
	fi

	local matches
	matches="$(find "${CHECKPOINT_ROOT}" -mindepth 1 -maxdepth 1 -type d -name "${id}*" -printf '%f\n' | LC_ALL=C sort)"
	local match_count
	match_count="$(printf '%s\n' "${matches}" | sed '/^$/d' | wc -l | tr -d ' ')"

	[ "${match_count}" -gt 0 ] || die "checkpoint '${id}' not found"
	[ "${match_count}" -eq 1 ] || die "checkpoint id '${id}' is ambiguous"

	echo "${CHECKPOINT_ROOT}/$(printf '%s\n' "${matches}")"
}

sanitize_label() {
	local raw="${1:-checkpoint}"
	local safe
	safe="$(printf '%s' "${raw}" | tr -cs '[:alnum:]._-' '-')"
	safe="${safe#-}"
	safe="${safe%-}"
	[ -n "${safe}" ] || safe="checkpoint"
	echo "${safe}"
}

next_checkpoint_id() {
	local label="${1}"
	local ts
	ts="$(date -u +%Y%m%dT%H%M%SZ)"
	local id="${ts}-${label}"
	local idx=1
	while [ -e "${CHECKPOINT_ROOT}/${id}" ]; do
		id="${ts}-${label}-${idx}"
		idx=$((idx + 1))
	done
	echo "${id}"
}

write_metadata() {
	local out_file="$1"
	local id="$2"
	local label="$3"
	local reason="$4"
	local patch_sha="$5"
	local tracked_count="$6"
	local untracked_count="$7"
	local tracked_existing_count="$8"
	local tracked_deleted_count="$9"
	local head
	head="$(git -C "${KERNEL_DIR}" rev-parse HEAD)"
	cat >"${out_file}" <<EOF
id=${id}
label=${label}
created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
kernel_dir=${KERNEL_DIR}
kernel_head=${head}
reason=${reason}
patch_sha256=${patch_sha}
tracked_count=${tracked_count}
untracked_count=${untracked_count}
tracked_existing_count=${tracked_existing_count}
tracked_deleted_count=${tracked_deleted_count}
EOF
}

prune_old_checkpoints() {
	local keep="${KTRACK_RETENTION}"
	[[ "${keep}" =~ ^[0-9]+$ ]] || keep=50
	[ "${keep}" -gt 0 ] || return

	local total
	total="$(find "${CHECKPOINT_ROOT}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
	[ "${total}" -gt "${keep}" ] || return 0

	local remove_count=$((total - keep))
	find "${CHECKPOINT_ROOT}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
		| LC_ALL=C sort \
		| head -n "${remove_count}" \
		| while read -r old_id; do
			[ -n "${old_id}" ] || continue
			rm -rf "${CHECKPOINT_ROOT:?}/${old_id}"
		done
}

create_checkpoint() {
	local label="$1"
	local include_untracked="$2"
	local reason="$3"
	local allow_empty="$4"
	local skip_if_duplicate="$5"

	ensure_kernel_repo
	ensure_checkpoint_root

	local tracked_list
	tracked_list="$(mktemp "${TMPDIR:-/tmp}/ktrack-tracked.XXXXXX")"
	local untracked_list
	untracked_list="$(mktemp "${TMPDIR:-/tmp}/ktrack-untracked.XXXXXX")"
	local patch_file
	patch_file="$(mktemp "${TMPDIR:-/tmp}/ktrack-patch.XXXXXX")"
	local tracked_existing_list
	tracked_existing_list="$(mktemp "${TMPDIR:-/tmp}/ktrack-tracked-existing.XXXXXX")"
	local tracked_deleted_list
	tracked_deleted_list="$(mktemp "${TMPDIR:-/tmp}/ktrack-tracked-deleted.XXXXXX")"

	git -C "${KERNEL_DIR}" diff --name-only --diff-filter=ACDMRTUXB HEAD > "${tracked_list}"
	local tracked_count
	tracked_count="$(count_file_lines "${tracked_list}")"
	: > "${tracked_existing_list}"
	: > "${tracked_deleted_list}"

	while IFS= read -r relpath; do
		[ -n "${relpath}" ] || continue
		if [ -e "${KERNEL_DIR}/${relpath}" ] || [ -L "${KERNEL_DIR}/${relpath}" ]; then
			printf '%s\n' "${relpath}" >> "${tracked_existing_list}"
		else
			printf '%s\n' "${relpath}" >> "${tracked_deleted_list}"
		fi
	done < "${tracked_list}"

	local tracked_existing_count
	tracked_existing_count="$(count_file_lines "${tracked_existing_list}")"
	local tracked_deleted_count
	tracked_deleted_count="$(count_file_lines "${tracked_deleted_list}")"

	if [ "${include_untracked}" = "1" ]; then
		git -C "${KERNEL_DIR}" ls-files --others --exclude-standard > "${untracked_list}"
	else
		: > "${untracked_list}"
	fi
	local untracked_count
	untracked_count="$(count_file_lines "${untracked_list}")"

	git -C "${KERNEL_DIR}" diff --binary HEAD > "${patch_file}"
	local patch_sha
	patch_sha="$(sha256_file "${patch_file}")"

	if [ "${allow_empty}" != "1" ] && [ "${tracked_count}" -eq 0 ] && [ "${untracked_count}" -eq 0 ]; then
		echo "no tracked changes to checkpoint"
		rm -f "${tracked_list}" "${untracked_list}" "${patch_file}" "${tracked_existing_list}" "${tracked_deleted_list}"
		return 2
	fi

	if [ "${skip_if_duplicate}" = "1" ]; then
		local last_id
		last_id="$(latest_checkpoint_id || true)"
		if [ -n "${last_id}" ] && [ -f "${CHECKPOINT_ROOT}/${last_id}/meta.env" ]; then
			local last_sha
			last_sha="$(grep '^patch_sha256=' "${CHECKPOINT_ROOT}/${last_id}/meta.env" | cut -d= -f2-)"
			local last_head
			last_head="$(grep '^kernel_head=' "${CHECKPOINT_ROOT}/${last_id}/meta.env" | cut -d= -f2-)"
			local now_head
			now_head="$(git -C "${KERNEL_DIR}" rev-parse HEAD)"
			if [ "${patch_sha}" = "${last_sha}" ] && [ "${now_head}" = "${last_head}" ]; then
				echo "checkpoint skipped: no change since latest checkpoint (${last_id})"
				rm -f "${tracked_list}" "${untracked_list}" "${patch_file}" "${tracked_existing_list}" "${tracked_deleted_list}"
				return 2
			fi
		fi
	fi

	local id
	id="$(next_checkpoint_id "$(sanitize_label "${label}")")"
	local checkpoint_dir="${CHECKPOINT_ROOT}/${id}"
	mkdir -p "${checkpoint_dir}"

	cp "${patch_file}" "${checkpoint_dir}/tracked.patch"
	cp "${tracked_list}" "${checkpoint_dir}/changed-files.txt"
	cp "${tracked_existing_list}" "${checkpoint_dir}/tracked-existing-files.txt"
	cp "${tracked_deleted_list}" "${checkpoint_dir}/tracked-deleted-files.txt"
	cp "${untracked_list}" "${checkpoint_dir}/untracked-files.txt"

	if [ "${tracked_existing_count}" -gt 0 ]; then
		tar -C "${KERNEL_DIR}" -cf "${checkpoint_dir}/tracked-current.tar" -T "${tracked_existing_list}"
	fi

	if [ "${include_untracked}" = "1" ] && [ "${untracked_count}" -gt 0 ]; then
		tar -C "${KERNEL_DIR}" -cf "${checkpoint_dir}/untracked.tar" -T "${untracked_list}"
	fi

	write_metadata \
		"${checkpoint_dir}/meta.env" \
		"${id}" \
		"$(sanitize_label "${label}")" \
		"${reason}" \
		"${patch_sha}" \
		"${tracked_count}" \
		"${untracked_count}" \
		"${tracked_existing_count}" \
		"${tracked_deleted_count}"

	rm -f "${tracked_list}" "${untracked_list}" "${patch_file}" "${tracked_existing_list}" "${tracked_deleted_list}"
	prune_old_checkpoints
	echo "checkpoint created: ${id} (tracked=${tracked_count}, untracked=${untracked_count})"
}

cmd_status() {
	ensure_kernel_repo
	ensure_checkpoint_root

	local tracked_count
	tracked_count="$(git -C "${KERNEL_DIR}" diff --name-only --diff-filter=ACDMRTUXB HEAD | wc -l | tr -d ' ')"
	local untracked_count
	untracked_count="$(git -C "${KERNEL_DIR}" ls-files --others --exclude-standard | wc -l | tr -d ' ')"
	local current_head
	current_head="$(git -C "${KERNEL_DIR}" rev-parse --short HEAD)"

	echo "kernel: ${KERNEL_DIR}"
	echo "head: ${current_head}"
	echo "tracked changes: ${tracked_count}"
	echo "untracked files: ${untracked_count}"

	local latest
	latest="$(latest_checkpoint_id || true)"
	if [ -n "${latest}" ]; then
		echo "latest checkpoint: ${latest}"
	else
		echo "latest checkpoint: <none>"
	fi
}

cmd_auto_checkpoint() {
	local label="auto"
	local include_untracked=0

	while [ $# -gt 0 ]; do
		case "$1" in
			--label)
				[ $# -gt 1 ] || die "--label requires a value"
				label="$2"
				shift 2
				;;
			--keep-untracked)
				include_untracked=1
				shift
				;;
			*)
				die "unknown option for auto-checkpoint: $1"
				;;
		esac
	done

	create_checkpoint "${label}" "${include_untracked}" "auto-build" 0 1 || true
}

cmd_checkpoint() {
	local label="manual"
	local include_untracked=0

	while [ $# -gt 0 ]; do
		case "$1" in
			--label)
				[ $# -gt 1 ] || die "--label requires a value"
				label="$2"
				shift 2
				;;
			--with-untracked)
				include_untracked=1
				shift
				;;
			*)
				die "unknown option for checkpoint: $1"
				;;
		esac
	done

	create_checkpoint "${label}" "${include_untracked}" "manual" 0 0
}

cmd_list() {
	ensure_checkpoint_root
	local ids
	ids="$(find "${CHECKPOINT_ROOT}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort -r)"
	[ -n "${ids}" ] || {
		echo "no checkpoints found"
		return 0
	}

	while read -r id; do
		[ -n "${id}" ] || continue
		local meta="${CHECKPOINT_ROOT}/${id}/meta.env"
		local created="<unknown>"
		local label="<unknown>"
		local tracked="<unknown>"
		if [ -f "${meta}" ]; then
			created="$(grep '^created_at=' "${meta}" | cut -d= -f2-)"
			label="$(grep '^label=' "${meta}" | cut -d= -f2-)"
			tracked="$(grep '^tracked_count=' "${meta}" | cut -d= -f2-)"
		fi
		echo "${id}  label=${label}  tracked=${tracked}  created=${created}"
	done <<< "${ids}"
}

cmd_show() {
	local id=""
	while [ $# -gt 0 ]; do
		case "$1" in
			--id)
				[ $# -gt 1 ] || die "--id requires a value"
				id="$2"
				shift 2
				;;
			*)
				die "unknown option for show: $1"
				;;
		esac
	done
	[ -n "${id}" ] || die "show requires --id"

	local checkpoint_dir
	checkpoint_dir="$(resolve_checkpoint_dir "${id}" id)"
	echo "checkpoint: $(basename "${checkpoint_dir}")"
	echo "path: ${checkpoint_dir}"
	[ -f "${checkpoint_dir}/meta.env" ] && cat "${checkpoint_dir}/meta.env"
}

collect_dirs_from_checkpoint() {
	local checkpoint_dir="$1"
	local changed_file="${checkpoint_dir}/changed-files.txt"
	[ -f "${changed_file}" ] || return 0

	awk '
		{
			n = split($0, parts, "/");
			if (n > 1) {
				dir = parts[1];
				for (i = 2; i < n; i++) {
					dir = dir "/" parts[i];
				}
				print dir;
			} else {
				print ".";
			}
		}
	' "${changed_file}" | LC_ALL=C sort -u
}

clean_build_from_checkpoint() {
	local checkpoint_dir="$1"
	local apply="$2"
	local changed_count
	changed_count="$(count_file_lines "${checkpoint_dir}/changed-files.txt")"

	if [ "${changed_count}" -eq 0 ]; then
		echo "no changed files recorded in checkpoint"
		return 0
	fi

	local dirs
	dirs="$(collect_dirs_from_checkpoint "${checkpoint_dir}")"
	[ -n "${dirs}" ] || return 0

	echo "build cleanup scope ($(basename "${checkpoint_dir}")):"
	while read -r dir; do
		[ -n "${dir}" ] || continue
		echo "  - ${dir}"
	done <<< "${dirs}"

	if [ "${apply}" != "1" ]; then
		echo "dry-run: pass --apply to clean ignored build files"
		return 0
	fi

	while read -r dir; do
		[ -n "${dir}" ] || continue
		git -C "${KERNEL_DIR}" clean -fdX -e .config -- "${dir}"
	done <<< "${dirs}"
}

cmd_clean_build() {
	local checkpoint_mode="id"
	local checkpoint_id=""
	local apply=0

	while [ $# -gt 0 ]; do
		case "$1" in
			--id)
				[ $# -gt 1 ] || die "--id requires a value"
				checkpoint_id="$2"
				checkpoint_mode="id"
				shift 2
				;;
			--last)
				checkpoint_mode="last"
				shift
				;;
			--apply)
				apply=1
				shift
				;;
			*)
				die "unknown option for clean-build: $1"
				;;
		esac
	done

	ensure_kernel_repo
	ensure_checkpoint_root
	local checkpoint_dir
	checkpoint_dir="$(resolve_checkpoint_dir "${checkpoint_id}" "${checkpoint_mode}")"
	clean_build_from_checkpoint "${checkpoint_dir}" "${apply}"
}

cmd_revert() {
	local checkpoint_mode="id"
	local checkpoint_id=""
	local apply=0
	local force_head=0

	while [ $# -gt 0 ]; do
		case "$1" in
			--id)
				[ $# -gt 1 ] || die "--id requires a value"
				checkpoint_id="$2"
				checkpoint_mode="id"
				shift 2
				;;
			--last)
				checkpoint_mode="last"
				shift
				;;
			--apply)
				apply=1
				shift
				;;
			--force-head)
				force_head=1
				shift
				;;
			*)
				die "unknown option for revert: $1"
				;;
		esac
	done

	ensure_kernel_repo
	ensure_checkpoint_root
	local checkpoint_dir
	checkpoint_dir="$(resolve_checkpoint_dir "${checkpoint_id}" "${checkpoint_mode}")"
	local checkpoint_name
	checkpoint_name="$(basename "${checkpoint_dir}")"

	local checkpoint_head
	checkpoint_head="$(grep '^kernel_head=' "${checkpoint_dir}/meta.env" | cut -d= -f2-)"
	local current_head
	current_head="$(git -C "${KERNEL_DIR}" rev-parse HEAD)"

	if [ "${checkpoint_head}" != "${current_head}" ] && [ "${force_head}" != "1" ]; then
		die "checkpoint head (${checkpoint_head}) != current head (${current_head}); use --force-head to override"
	fi

	local changed_count
	changed_count="$(count_file_lines "${checkpoint_dir}/changed-files.txt")"
	echo "revert target: ${checkpoint_name} (tracked files=${changed_count})"

	if [ "${apply}" != "1" ]; then
		echo "dry-run:"
		echo "  1) restore tracked files in ${KERNEL_DIR} to HEAD"
		echo "  2) apply ${checkpoint_dir}/tracked.patch"
		[ -f "${checkpoint_dir}/untracked.tar" ] && echo "  3) restore ${checkpoint_dir}/untracked.tar"
		echo "pass --apply to execute"
		return 0
	fi

	create_checkpoint "pre-revert-${checkpoint_name}" 0 "safety-before-revert" 1 0 >/dev/null || true

	git -C "${KERNEL_DIR}" restore --staged --worktree --source=HEAD .
	if [ -s "${checkpoint_dir}/tracked.patch" ]; then
		git -C "${KERNEL_DIR}" apply --binary "${checkpoint_dir}/tracked.patch"
	fi

	if [ -f "${checkpoint_dir}/untracked.tar" ]; then
		tar -C "${KERNEL_DIR}" -xf "${checkpoint_dir}/untracked.tar"
	fi

	echo "revert applied: ${checkpoint_name}"
}

cmd_reset() {
	local checkpoint_mode="none"
	local checkpoint_id=""
	local apply=0
	local force_head=0

	while [ $# -gt 0 ]; do
		case "$1" in
			--id)
				[ $# -gt 1 ] || die "--id requires a value"
				checkpoint_id="$2"
				checkpoint_mode="id"
				shift 2
				;;
			--last)
				checkpoint_mode="last"
				shift
				;;
			--apply)
				apply=1
				shift
				;;
			--force-head)
				force_head=1
				shift
				;;
			*)
				die "unknown option for reset: $1"
				;;
		esac
	done

	[ "${checkpoint_mode}" != "none" ] || die "reset requires --id or --last"

	local revert_args=()
	local clean_args=()

	if [ "${checkpoint_mode}" = "last" ]; then
		revert_args+=(--last)
		clean_args+=(--last)
	else
		revert_args+=(--id "${checkpoint_id}")
		clean_args+=(--id "${checkpoint_id}")
	fi
	[ "${apply}" = "1" ] && {
		revert_args+=(--apply)
		clean_args+=(--apply)
	}
	[ "${force_head}" = "1" ] && revert_args+=(--force-head)

	cmd_revert "${revert_args[@]}"
	cmd_clean_build "${clean_args[@]}"

	if [ "${apply}" = "1" ]; then
		echo "reset complete"
	else
		echo "reset dry-run complete"
	fi
}

main() {
	local cmd="${1:-help}"
	shift || true

	case "${cmd}" in
		status) cmd_status "$@" ;;
		auto-checkpoint) cmd_auto_checkpoint "$@" ;;
		checkpoint) cmd_checkpoint "$@" ;;
		list) cmd_list "$@" ;;
		show) cmd_show "$@" ;;
		revert) cmd_revert "$@" ;;
		clean-build) cmd_clean_build "$@" ;;
		reset) cmd_reset "$@" ;;
		help|-h|--help) usage ;;
		*) die "unknown command: ${cmd}" ;;
	esac
}

main "$@"
