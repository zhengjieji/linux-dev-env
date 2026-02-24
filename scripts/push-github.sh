#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

REMOTE="origin"
BRANCH="katran-exp"
COMMIT_MESSAGE="chore: update dual-vm"
FORCE_WITH_LEASE=0

log() {
	echo "[push-github] $*"
}

die() {
	echo "[push-github][error] $*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Commit local changes (excluding linux/) and push to remote branch '${BRANCH}'.
If the local branch does not exist yet, it is created.

Options:
  --remote <name>         Git remote name (default: ${REMOTE})
  --branch <name>         Branch name to push (default: ${BRANCH})
  --message <text>        Commit message for staged changes
  --force-with-lease      Push with --force-with-lease
  -h, --help              Show this help

Example:
  $(basename "$0")
  $(basename "$0") --branch dual-vm --message "sync repo"
EOF
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--remote)
				[ $# -gt 1 ] || die "--remote requires a value"
				REMOTE="$2"
				shift 2
				;;
			--branch)
				[ $# -gt 1 ] || die "--branch requires a value"
				BRANCH="$2"
				shift 2
				;;
			--message)
				[ $# -gt 1 ] || die "--message requires a value"
				COMMIT_MESSAGE="$2"
				shift 2
				;;
			--force-with-lease)
				FORCE_WITH_LEASE=1
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

ensure_repo() {
	require_cmd git
	git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"
	git -C "${ROOT_DIR}" remote get-url "${REMOTE}" >/dev/null 2>&1 || die "git remote '${REMOTE}' not found"
}

ensure_linux_ignored() {
	local gitignore="${ROOT_DIR}/.gitignore"
	touch "${gitignore}"
	if ! grep -qxF "linux/" "${gitignore}"; then
		echo "linux/" >> "${gitignore}"
		log "added 'linux/' to .gitignore"
	fi

	local tracked_linux
	tracked_linux="$(git -C "${ROOT_DIR}" ls-files -- 'linux' 'linux/**')"
	[ -z "${tracked_linux}" ] || die "linux/ is tracked by git; untrack it before pushing"
}

stage_changes_excluding_linux() {
	git -C "${ROOT_DIR}" add -u -- . ':(exclude)linux' ':(exclude)linux/**'

	local untracked_tmp
	untracked_tmp="$(mktemp "${TMPDIR:-/tmp}/push-github-untracked.XXXXXX")"
	git -C "${ROOT_DIR}" ls-files --others --exclude-standard -z -- . ':(exclude)linux' ':(exclude)linux/**' > "${untracked_tmp}"
	if [ -s "${untracked_tmp}" ]; then
		while IFS= read -r -d '' relpath; do
			[ -n "${relpath}" ] || continue
			git -C "${ROOT_DIR}" add -- "${relpath}"
		done < "${untracked_tmp}"
	fi
	rm -f "${untracked_tmp}"

	local staged_linux
	staged_linux="$(git -C "${ROOT_DIR}" diff --cached --name-only -- 'linux' 'linux/**')"
	[ -z "${staged_linux}" ] || die "linux/ paths are staged unexpectedly"
}

commit_if_needed() {
	if git -C "${ROOT_DIR}" diff --cached --quiet; then
		log "no staged changes; pushing current HEAD"
		return 0
	fi

	log "creating commit: ${COMMIT_MESSAGE}"
	git -C "${ROOT_DIR}" commit -m "${COMMIT_MESSAGE}"
}

ensure_local_branch() {
	if git -C "${ROOT_DIR}" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
		return 0
	fi
	git -C "${ROOT_DIR}" branch "${BRANCH}" HEAD
	log "created local branch '${BRANCH}'"
}

push_branch() {
	log "pushing HEAD to ${REMOTE}/${BRANCH}"
	if [ "${FORCE_WITH_LEASE}" -eq 1 ]; then
		git -C "${ROOT_DIR}" push --force-with-lease -u "${REMOTE}" "HEAD:refs/heads/${BRANCH}"
	else
		git -C "${ROOT_DIR}" push -u "${REMOTE}" "HEAD:refs/heads/${BRANCH}"
	fi
}

main() {
	parse_args "$@"
	ensure_repo
	ensure_linux_ignored
	stage_changes_excluding_linux
	commit_if_needed
	ensure_local_branch
	push_branch
	log "done. If you want GitHub default branch to be '${BRANCH}', set it in repository settings."
}

main "$@"
