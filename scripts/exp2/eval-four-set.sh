#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLOT_SCRIPT="${EXP2_EVAL4_PLOT_SCRIPT:-${ROOT_DIR}/scripts/exp1/plot_four_way.py}"
EXP1_MAKE_TARGET="${EXP2_EVAL4_EXP1_MAKE_TARGET:-exp1-run}"
RESULTS_BASE="${EXP2_EVAL4_RESULTS_BASE:-${ROOT_DIR}/results/exp2/eval-fourway}"
ORACLE_RESULTS_BASE="${EXP2_ORACLE_RESULTS_BASE:-${ROOT_DIR}/results/exp2/oracle}"
ORACLE_ENV_FILE="${EXP2_EVAL4_ORACLE_ENV:-}"
RUN_ID="${EXP2_EVAL4_RUN_ID:-}"
ARCHIVE_OLD="${EXP2_EVAL4_ARCHIVE_OLD:-1}"
VANILLA_KATRAN_AUTO_BUILD="${EXP2_EVAL4_VANILLA_KATRAN_AUTO_BUILD:-1}"
OPT_KATRAN_AUTO_BUILD="${EXP2_EVAL4_OPT_KATRAN_AUTO_BUILD:-0}"

CLIENT_VM="${EXP2_EVAL4_CLIENT_VM:-vm1}"
LB_VM="${EXP2_EVAL4_LB_VM:-vm2}"
BACKEND_VM="${EXP2_EVAL4_BACKEND_VM:-vm3}"
BACKEND_IP="${EXP2_EVAL4_BACKEND_IP:-}"
FORWARD_VIP="${EXP2_EVAL4_FORWARD_VIP:-192.168.100.100}"
KATRAN_VIP="${EXP2_EVAL4_KATRAN_VIP:-${FORWARD_VIP}}"
KATRAN_DEFAULT_MAC="${EXP2_EVAL4_KATRAN_DEFAULT_MAC:-}"

usage() {
	cat <<'EOF_USAGE'
Usage: scripts/exp2/eval-four-set.sh [options]

Run Exp2 3-node 4-set eval in one command:
  1) direct
  2) direct + forward
  3) vanilla katran
  4) oracle katran

Options:
  --results-base <path>      eval output base (default: results/exp2/eval-fourway)
  --oracle-results-base <p>  oracle build base (default: results/exp2/oracle)
  --oracle-env <path>        explicit oracle-artifacts.env (default: latest under oracle-results-base)
  --run-id <id>              id for fourway output dir name (default: utc timestamp)
  --archive-old <0|1>        archive old fourway-* dirs (default: 1)
  --vanilla-katran-auto-build <0|1>  EXP1_KATRAN_AUTO_BUILD for vanilla lane (default: 1)
  --opt-katran-auto-build <0|1>      EXP1_KATRAN_AUTO_BUILD for oracle lane (default: 0)
  --client-vm <vm>           client VM (default: vm1)
  --lb-vm <vm>               LB VM (default: vm2)
  --backend-vm <vm>          backend VM (default: vm3)
  --backend-ip <ip>          backend data-plane IP (default: derived from backend-vm)
  --forward-vip <ip>         VIP for direct+forward (default: 192.168.100.100)
  --katran-vip <ip>          VIP for katran lanes (default: same as forward-vip)
  --katran-default-mac <mac> katran next-hop MAC (default: derived from backend-vm)
  --exp1-make-target <name>  make target used for each lane (default: exp1-run)
  --plot-script <path>       four-way plot script (default: scripts/exp1/plot_four_way.py)
  -h, --help

Notes:
  - wrk/wrk2 workload points/duration/repeats come from exp1 make vars (or your overrides).
  - this command does NOT rebuild discovery/oracle; it reuses existing oracle artifacts.
EOF_USAGE
}

log() {
	echo "[exp2-eval4] $*"
}

fail() {
	echo "[exp2-eval4][error] $*" >&2
	exit 1
}

is_bool_01() {
	case "$1" in
		0|1) return 0 ;;
		*) return 1 ;;
	esac
}

is_vm_name() {
	case "$1" in
		vm1|vm2|vm3|vm4) return 0 ;;
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

vm_data_ip() {
	case "$1" in
		vm1) echo "192.168.100.1" ;;
		vm2) echo "192.168.100.2" ;;
		vm3) echo "192.168.100.3" ;;
		vm4) echo "192.168.100.4" ;;
		*) fail "unknown vm name for data ip: $1" ;;
	esac
}

vm_data_mac() {
	case "$1" in
		vm1) echo "52:54:00:aa:00:11" ;;
		vm2) echo "52:54:00:aa:00:22" ;;
		vm3) echo "52:54:00:aa:00:33" ;;
		vm4) echo "52:54:00:aa:00:44" ;;
		*) fail "unknown vm name for data mac: $1" ;;
	esac
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
			--client-vm)
				[ $# -gt 1 ] || fail "--client-vm requires value"
				CLIENT_VM="$2"
				shift 2
				;;
			--lb-vm)
				[ $# -gt 1 ] || fail "--lb-vm requires value"
				LB_VM="$2"
				shift 2
				;;
			--backend-vm)
				[ $# -gt 1 ] || fail "--backend-vm requires value"
				BACKEND_VM="$2"
				shift 2
				;;
			--backend-ip)
				[ $# -gt 1 ] || fail "--backend-ip requires value"
				BACKEND_IP="$2"
				shift 2
				;;
			--forward-vip)
				[ $# -gt 1 ] || fail "--forward-vip requires value"
				FORWARD_VIP="$2"
				shift 2
				;;
			--katran-vip)
				[ $# -gt 1 ] || fail "--katran-vip requires value"
				KATRAN_VIP="$2"
				shift 2
				;;
			--katran-default-mac)
				[ $# -gt 1 ] || fail "--katran-default-mac requires value"
				KATRAN_DEFAULT_MAC="$2"
				shift 2
				;;
			--exp1-make-target)
				[ $# -gt 1 ] || fail "--exp1-make-target requires value"
				EXP1_MAKE_TARGET="$2"
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
		EXP1_CLIENT_VM="${CLIENT_VM}" \
		EXP1_LB_VM="${LB_VM}" \
		EXP1_BACKEND_VM="${BACKEND_VM}" \
		EXP1_SERVER_IP="${BACKEND_IP}" \
		EXP1_FORWARD_VIP="${FORWARD_VIP}" \
		EXP1_KATRAN_VIP="${KATRAN_VIP}" \
		EXP1_KATRAN_DEFAULT_MAC="${KATRAN_DEFAULT_MAC}" \
		"$@"
}

archive_old_fourway() {
	local keep_dir="$1"
	local archive_dir="${RESULTS_BASE}/archive/fourway"
	local moved=0
	local d
	shopt -s nullglob
	for d in "${RESULTS_BASE}"/fourway-*; do
		[ -d "${d}" ] || continue
		[ "${d}" = "${keep_dir}" ] && continue
		mkdir -p "${archive_dir}"
		mv "${d}" "${archive_dir}/"
		moved=$((moved + 1))
	done
	shopt -u nullglob
	if [ "${moved}" -gt 0 ]; then
		log "archived ${moved} old fourway run(s) to ${archive_dir}"
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
	CLIENT_VM="$(normalize_quoted "${CLIENT_VM}")"
	LB_VM="$(normalize_quoted "${LB_VM}")"
	BACKEND_VM="$(normalize_quoted "${BACKEND_VM}")"
	BACKEND_IP="$(normalize_quoted "${BACKEND_IP}")"
	FORWARD_VIP="$(normalize_quoted "${FORWARD_VIP}")"
	KATRAN_VIP="$(normalize_quoted "${KATRAN_VIP}")"
	KATRAN_DEFAULT_MAC="$(normalize_quoted "${KATRAN_DEFAULT_MAC}")"
	EXP1_MAKE_TARGET="$(normalize_quoted "${EXP1_MAKE_TARGET}")"
	PLOT_SCRIPT="$(normalize_quoted "${PLOT_SCRIPT}")"

	is_bool_01 "${ARCHIVE_OLD}" || fail "--archive-old must be 0 or 1"
	is_bool_01 "${VANILLA_KATRAN_AUTO_BUILD}" || fail "--vanilla-katran-auto-build must be 0 or 1"
	is_bool_01 "${OPT_KATRAN_AUTO_BUILD}" || fail "--opt-katran-auto-build must be 0 or 1"
	is_vm_name "${CLIENT_VM}" || fail "--client-vm must be vm1/vm2/vm3/vm4"
	is_vm_name "${LB_VM}" || fail "--lb-vm must be vm1/vm2/vm3/vm4"
	is_vm_name "${BACKEND_VM}" || fail "--backend-vm must be vm1/vm2/vm3/vm4"
	[ -f "${PLOT_SCRIPT}" ] || fail "plot script not found: ${PLOT_SCRIPT}"
	command -v make >/dev/null 2>&1 || fail "missing required command: make"
	command -v python3 >/dev/null 2>&1 || fail "missing required command: python3"

	[ -n "${BACKEND_IP}" ] || BACKEND_IP="$(vm_data_ip "${BACKEND_VM}")"
	[ -n "${KATRAN_DEFAULT_MAC}" ] || KATRAN_DEFAULT_MAC="$(vm_data_mac "${BACKEND_VM}")"
	local lb_ip
	lb_ip="$(vm_data_ip "${LB_VM}")"

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
	local forward_base="${RESULTS_BASE}/forward"
	local vanilla_base="${RESULTS_BASE}/vanilla"
	local oracle_base="${RESULTS_BASE}/oracle"

	log "run id: ${RUN_ID}"
	log "results base: ${RESULTS_BASE}"
	log "oracle env: ${ORACLE_ENV_FILE}"
	log "roles: client=${CLIENT_VM}, lb=${LB_VM}, backend=${BACKEND_VM} (${BACKEND_IP})"
	log "vip: forward=${FORWARD_VIP}, katran=${KATRAN_VIP}, default-mac=${KATRAN_DEFAULT_MAC}"

	log "running direct"
	run_exp1_make "direct" "${direct_base}"
	local direct_run
	direct_run="$(latest_run_dir "${direct_base}" "*-direct-nginx")"
	[ -n "${direct_run}" ] || fail "cannot resolve direct run dir under ${direct_base}"

	log "running direct+forward"
	run_exp1_make "forward" "${forward_base}"
	local forward_run
	forward_run="$(latest_run_dir "${forward_base}" "*-direct-forward")"
	[ -n "${forward_run}" ] || fail "cannot resolve direct-forward run dir under ${forward_base}"

	log "running vanilla katran"
	run_exp1_make "katran" "${vanilla_base}" \
		EXP1_KATRAN_LOCAL_DELIVERY_FLAGS="1" \
		EXP1_KATRAN_REAL_IP="${lb_ip}" \
		EXP1_KATRAN_ENABLE_LB_RELAY="1" \
		EXP1_KATRAN_RELAY_BACKEND_IP="${BACKEND_IP}" \
		EXP1_KATRAN_AUTO_BUILD="${VANILLA_KATRAN_AUTO_BUILD}"
	local vanilla_run
	vanilla_run="$(latest_run_dir "${vanilla_base}" "*-vanilla-katran")"
	[ -n "${vanilla_run}" ] || fail "cannot resolve vanilla run dir under ${vanilla_base}"

	log "running oracle katran"
	run_exp1_make "katran" "${oracle_base}" \
		EXP1_KATRAN_LOCAL_DELIVERY_FLAGS="1" \
		EXP1_KATRAN_REAL_IP="${lb_ip}" \
		EXP1_KATRAN_ENABLE_LB_RELAY="1" \
		EXP1_KATRAN_RELAY_BACKEND_IP="${BACKEND_IP}" \
		EXP1_KATRAN_SERVER_BIN="${oracle_server_bin}" \
		EXP1_KATRAN_BPF_OBJ="${oracle_bpf_obj}" \
		EXP1_KATRAN_GOCLIENT_BIN="${oracle_goclient_bin}" \
		EXP1_KATRAN_LIB_DIRS="${oracle_lib_dirs}" \
		EXP1_KATRAN_REQUIRED_BPF_DEFINE="EXP2_ORACLE_CH_RINGS" \
		EXP1_KATRAN_AUTO_BUILD="${OPT_KATRAN_AUTO_BUILD}"
	local oracle_run
	oracle_run="$(latest_run_dir "${oracle_base}" "*-vanilla-katran")"
	[ -n "${oracle_run}" ] || fail "cannot resolve oracle run dir under ${oracle_base}"

	local fourway_dir="${RESULTS_BASE}/fourway-${RUN_ID}"
	log "generating four-way plot"
	python3 "${PLOT_SCRIPT}" \
		--direct-dir "${direct_run}" \
		--forward-dir "${forward_run}" \
		--vanilla-dir "${vanilla_run}" \
		--oracle-dir "${oracle_run}" \
		--out-dir "${fourway_dir}"

	if [ "${ARCHIVE_OLD}" -eq 1 ]; then
		archive_old_fourway "${fourway_dir}"
	fi

	log "complete"
	log "artifacts: ${direct_run}"
	log "artifacts: ${forward_run}"
	log "artifacts: ${vanilla_run}"
	log "artifacts: ${oracle_run}"
	log "artifacts: ${fourway_dir}"
}

main "$@"
