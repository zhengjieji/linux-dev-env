#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLOT_SCRIPT="${EXP2_EVAL_PLOT_SCRIPT:-${ROOT_DIR}/scripts/exp1/plot_three_way.py}"
EXP1_MAKE_TARGET="${EXP2_EVAL_EXP1_MAKE_TARGET:-exp1-run}"
RESULTS_BASE="${EXP2_EVAL_RESULTS_BASE:-${ROOT_DIR}/results/exp2/eval}"
ORACLE_RESULTS_BASE="${EXP2_ORACLE_RESULTS_BASE:-${ROOT_DIR}/results/exp2/oracle}"
ORACLE_ENV_FILE="${EXP2_EVAL_ORACLE_ENV:-}"
RUN_ID="${EXP2_EVAL_RUN_ID:-}"
ARCHIVE_OLD="${EXP2_EVAL_ARCHIVE_OLD:-1}"
VANILLA_KATRAN_AUTO_BUILD="${EXP2_EVAL_VANILLA_KATRAN_AUTO_BUILD:-1}"
OPT_KATRAN_AUTO_BUILD="${EXP2_EVAL_OPT_KATRAN_AUTO_BUILD:-0}"

usage() {
	cat <<'EOF_USAGE'
Usage: scripts/exp2/eval.sh [options]

Run full Exp2 eval in one command:
  1) no-katran (direct)
  2) vanilla katran
  3) opt katran (from latest oracle-artifacts.env)
  4) three-way plots/csv (direct vs vanilla vs opt)

Options:
  --results-base <path>      eval output base (default: results/exp2/eval)
  --oracle-results-base <p>  oracle build base (default: results/exp2/oracle)
  --oracle-env <path>        explicit oracle-artifacts.env (default: latest under oracle-results-base)
  --run-id <id>              id for threeway output dir name (default: utc timestamp)
  --archive-old <0|1>        archive old threeway-* dirs (default: 1)
  --vanilla-katran-auto-build <0|1>  EXP1_KATRAN_AUTO_BUILD for vanilla lane (default: 1)
  --opt-katran-auto-build <0|1>      EXP1_KATRAN_AUTO_BUILD for opt lane (default: 0)
  --exp1-make-target <name>  make target used for each run kind (default: exp1-run)
  --plot-script <path>       three-way plot script (default: scripts/exp1/plot_three_way.py)
  -h, --help

Notes:
  - wrk/wrk2/full-load parameters come from Makefile exp1 defaults (or your make overrides).
  - this command does NOT rebuild discovery/oracle; it reuses existing oracle artifacts.
EOF_USAGE
}

log() {
	echo "[exp2-eval] $*"
}

fail() {
	echo "[exp2-eval][error] $*" >&2
	exit 1
}

is_bool_01() {
	case "$1" in
		0|1) return 0 ;;
		*) return 1 ;;
	esac
}

normalize_quoted() {
	local value="$1"
	while [ "${value#\"}" != "${value}" ] && [ "${value%\"}" != "${value}" ]; do
		value="${value#\"}"
		value="${value%\"}"
	done
	echo "${value}"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--results-base)
				[ $# -gt 1 ] || fail "--results-base requires value"
				RESULTS_BASE="$2"
				shift 2
				;;
			--oracle-results-base)
				[ $# -gt 1 ] || fail "--oracle-results-base requires value"
				ORACLE_RESULTS_BASE="$2"
				shift 2
				;;
			--oracle-env)
				[ $# -gt 1 ] || fail "--oracle-env requires value"
				ORACLE_ENV_FILE="$2"
				shift 2
				;;
			--run-id)
				[ $# -gt 1 ] || fail "--run-id requires value"
				RUN_ID="$2"
				shift 2
				;;
			--archive-old)
				[ $# -gt 1 ] || fail "--archive-old requires value"
				ARCHIVE_OLD="$2"
				shift 2
				;;
			--exp1-make-target)
				[ $# -gt 1 ] || fail "--exp1-make-target requires value"
				EXP1_MAKE_TARGET="$2"
				shift 2
				;;
			--vanilla-katran-auto-build)
				[ $# -gt 1 ] || fail "--vanilla-katran-auto-build requires value"
				VANILLA_KATRAN_AUTO_BUILD="$2"
				shift 2
				;;
			--opt-katran-auto-build)
				[ $# -gt 1 ] || fail "--opt-katran-auto-build requires value"
				OPT_KATRAN_AUTO_BUILD="$2"
				shift 2
				;;
			--plot-script)
				[ $# -gt 1 ] || fail "--plot-script requires value"
				PLOT_SCRIPT="$2"
				shift 2
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				fail "unknown arg: $1"
				;;
		esac
	done
}

latest_oracle_env() {
	local base="$1"
	find "${base}" -maxdepth 2 -type f -name "oracle-artifacts.env" 2>/dev/null | sort | tail -n 1 || true
}

latest_run_dir() {
	local base="$1"
	local pattern="$2"
	find "${base}" -maxdepth 1 -mindepth 1 -type d -name "${pattern}" 2>/dev/null | sort | tail -n 1 || true
}

read_env_value() {
	local env_file="$1"
	local key="$2"
	awk -F= -v key="${key}" '
		$1 == key {
			sub($1 "=", "", $0)
			print $0
			exit
		}
	' "${env_file}"
}

run_exp1_make() {
	local mode="$1"
	local out_base="$2"
	shift 2
	mkdir -p "${out_base}"
	make -C "${ROOT_DIR}" "${EXP1_MAKE_TARGET}" \
		EXP1_MODE="${mode}" \
		EXP1_RESULTS_BASE="${out_base}" \
		"$@"
}

archive_old_threeway() {
	local keep_dir="$1"
	local archive_dir="${RESULTS_BASE}/archive/threeway"
	local moved=0
	local d
	shopt -s nullglob
	for d in "${RESULTS_BASE}"/threeway-*; do
		[ -d "${d}" ] || continue
		[ "${d}" = "${keep_dir}" ] && continue
		mkdir -p "${archive_dir}"
		mv "${d}" "${archive_dir}/"
		moved=$((moved + 1))
	done
	shopt -u nullglob
	if [ "${moved}" -gt 0 ]; then
		log "archived ${moved} old threeway run(s) to ${archive_dir}"
	fi
}

main() {
	parse_args "$@"

	RESULTS_BASE="$(normalize_quoted "${RESULTS_BASE}")"
	ORACLE_RESULTS_BASE="$(normalize_quoted "${ORACLE_RESULTS_BASE}")"
	ORACLE_ENV_FILE="$(normalize_quoted "${ORACLE_ENV_FILE}")"
	RUN_ID="$(normalize_quoted "${RUN_ID}")"
	ARCHIVE_OLD="$(normalize_quoted "${ARCHIVE_OLD}")"
	VANILLA_KATRAN_AUTO_BUILD="$(normalize_quoted "${VANILLA_KATRAN_AUTO_BUILD}")"
	OPT_KATRAN_AUTO_BUILD="$(normalize_quoted "${OPT_KATRAN_AUTO_BUILD}")"
	EXP1_MAKE_TARGET="$(normalize_quoted "${EXP1_MAKE_TARGET}")"
	PLOT_SCRIPT="$(normalize_quoted "${PLOT_SCRIPT}")"

	is_bool_01 "${ARCHIVE_OLD}" || fail "--archive-old must be 0 or 1"
	is_bool_01 "${VANILLA_KATRAN_AUTO_BUILD}" || fail "--vanilla-katran-auto-build must be 0 or 1"
	is_bool_01 "${OPT_KATRAN_AUTO_BUILD}" || fail "--opt-katran-auto-build must be 0 or 1"
	[ -f "${PLOT_SCRIPT}" ] || fail "plot script not found: ${PLOT_SCRIPT}"
	command -v make >/dev/null 2>&1 || fail "missing required command: make"
	command -v python3 >/dev/null 2>&1 || fail "missing required command: python3"

	if [ -z "${RUN_ID}" ]; then
		RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
	fi
	mkdir -p "${RESULTS_BASE}"

	if [ -z "${ORACLE_ENV_FILE}" ]; then
		ORACLE_ENV_FILE="$(latest_oracle_env "${ORACLE_RESULTS_BASE}")"
	fi
	[ -n "${ORACLE_ENV_FILE}" ] || fail "cannot find oracle-artifacts.env under ${ORACLE_RESULTS_BASE}"
	[ -f "${ORACLE_ENV_FILE}" ] || fail "oracle env file not found: ${ORACLE_ENV_FILE}"

	local oracle_server_bin
	local oracle_bpf_obj
	local oracle_goclient_bin
	local oracle_lib_dirs
	oracle_server_bin="$(read_env_value "${ORACLE_ENV_FILE}" "exp1_katran_server_bin_vm")"
	oracle_bpf_obj="$(read_env_value "${ORACLE_ENV_FILE}" "exp1_katran_bpf_obj_vm")"
	oracle_goclient_bin="$(read_env_value "${ORACLE_ENV_FILE}" "exp1_katran_goclient_bin_vm")"
	oracle_lib_dirs="$(read_env_value "${ORACLE_ENV_FILE}" "exp1_katran_lib_dirs_vm")"
	[ -n "${oracle_server_bin}" ] || fail "missing exp1_katran_server_bin_vm in ${ORACLE_ENV_FILE}"
	[ -n "${oracle_bpf_obj}" ] || fail "missing exp1_katran_bpf_obj_vm in ${ORACLE_ENV_FILE}"
	[ -n "${oracle_goclient_bin}" ] || fail "missing exp1_katran_goclient_bin_vm in ${ORACLE_ENV_FILE}"
	[ -n "${oracle_lib_dirs}" ] || fail "missing exp1_katran_lib_dirs_vm in ${ORACLE_ENV_FILE}"

	local direct_base="${RESULTS_BASE}/direct"
	local vanilla_base="${RESULTS_BASE}/vanilla"
	local opt_base="${RESULTS_BASE}/opt"

	log "run id: ${RUN_ID}"
	log "results base: ${RESULTS_BASE}"
	log "oracle env: ${ORACLE_ENV_FILE}"

	log "running direct (no-katran)"
	run_exp1_make "direct" "${direct_base}"
	local direct_run
	direct_run="$(latest_run_dir "${direct_base}" "*-direct-nginx")"
	[ -n "${direct_run}" ] || fail "cannot resolve direct run dir under ${direct_base}"

	log "running vanilla katran"
	run_exp1_make "katran" "${vanilla_base}" \
		EXP1_KATRAN_AUTO_BUILD="${VANILLA_KATRAN_AUTO_BUILD}"
	local vanilla_run
	vanilla_run="$(latest_run_dir "${vanilla_base}" "*-vanilla-katran")"
	[ -n "${vanilla_run}" ] || fail "cannot resolve vanilla run dir under ${vanilla_base}"

	log "running opt katran (oracle artifacts)"
	run_exp1_make "katran" "${opt_base}" \
		EXP1_KATRAN_SERVER_BIN="${oracle_server_bin}" \
		EXP1_KATRAN_BPF_OBJ="${oracle_bpf_obj}" \
		EXP1_KATRAN_GOCLIENT_BIN="${oracle_goclient_bin}" \
		EXP1_KATRAN_LIB_DIRS="${oracle_lib_dirs}" \
		EXP1_KATRAN_REQUIRED_BPF_DEFINE="EXP2_ORACLE_CH_RINGS" \
		EXP1_KATRAN_AUTO_BUILD="${OPT_KATRAN_AUTO_BUILD}"
	local opt_run
	opt_run="$(latest_run_dir "${opt_base}" "*-vanilla-katran")"
	[ -n "${opt_run}" ] || fail "cannot resolve opt run dir under ${opt_base}"

	local threeway_dir="${RESULTS_BASE}/threeway-${RUN_ID}"
	log "generating three-way plot"
	python3 "${PLOT_SCRIPT}" \
		--direct-dir "${direct_run}" \
		--vanilla-dir "${vanilla_run}" \
		--opt-dir "${opt_run}" \
		--out-dir "${threeway_dir}"

	if [ "${ARCHIVE_OLD}" -eq 1 ]; then
		archive_old_threeway "${threeway_dir}"
	fi

	log "complete"
	log "artifacts: ${direct_run}"
	log "artifacts: ${vanilla_run}"
	log "artifacts: ${opt_run}"
	log "artifacts: ${threeway_dir}"
}

main "$@"
