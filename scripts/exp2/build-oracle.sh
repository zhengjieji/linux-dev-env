#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GEN_SCRIPT="${EXP2_ORACLE_GEN_SCRIPT:-${ROOT_DIR}/scripts/exp2/generate-oracle.py}"
KATRAN_BUILD_SCRIPT="${EXP2_ORACLE_KATRAN_BUILD_SCRIPT:-${ROOT_DIR}/scripts/exp1/build-katran.sh}"

DISCOVERY_BASE="${EXP2_RESULTS_BASE:-${ROOT_DIR}/results/exp2/discovery}"
RESULTS_BASE="${EXP2_ORACLE_RESULTS_BASE:-${ROOT_DIR}/results/exp2/oracle}"
SPEC_FILE="${EXP2_ORACLE_SPEC:-}"
RUN_ID="${EXP2_ORACLE_RUN_ID:-}"

RING_SIZE="${EXP2_ORACLE_RING_SIZE:-65537}"
GENERATED_HEADER="${EXP2_ORACLE_GENERATED_HEADER:-${ROOT_DIR}/source/katran/katran/lib/bpf/oracle/exp2_oracle_generated.h}"
KATRAN_SRC_DIR="${EXP2_ORACLE_KATRAN_SRC_DIR:-${ROOT_DIR}/source/katran}"
KATRAN_BUILD_DIR="${EXP2_ORACLE_KATRAN_BUILD_DIR:-${KATRAN_SRC_DIR}/_build_exp2_oracle}"
BPF_DEFINES="${EXP2_ORACLE_BPF_DEFINES:--DLOCAL_DELIVERY_OPTIMIZATION -DEXP2_ORACLE_CH_RINGS}"
FORCE_REBUILD="${EXP2_ORACLE_FORCE_REBUILD:-0}"
SKIP_BUILD="${EXP2_ORACLE_SKIP_BUILD:-0}"

usage() {
	cat <<'EOF_USAGE'
Usage: scripts/exp2/build-oracle.sh [options]

Generate and build Exp2 oracle Katran BPF artifacts.

Steps:
  1) Read Stage A specialization spec
  2) Generate exp2_oracle_generated.h (all supported invariant maps + policy macros)
  3) Build Katran in isolated build dir with EXP2_ORACLE_CH_RINGS define

Options:
  --spec <path>              specialization-spec.json path (default: latest stageA under results/exp2/discovery)
  --results-base <path>      output dir base (default: results/exp2/oracle)
  --run-id <id>              custom run id (default: utc timestamp)
  --ring-size <n>            ring size used by Katran compile-time constants (default: 65537)
  --generated-header <path>  output generated header path
  --katran-src-dir <path>    Katran source dir (default: source/katran)
  --katran-build-dir <path>  isolated Katran build dir for oracle (default: source/katran/_build_exp2_oracle)
  --bpf-defines "<defs>"     BPF defines passed to build-katran.sh
  --force-rebuild <0|1>      force clean rebuild for oracle build dir (default: 0)
  --skip-build <0|1>         only generate header, skip Katran build (default: 0)
  -h, --help
EOF_USAGE
}

log() {
	echo "[exp2-oracle] $*"
}

fail() {
	echo "[exp2-oracle][error] $*" >&2
	exit 1
}

is_pos_int() {
	local value="$1"
	[[ "${value}" =~ ^[0-9]+$ ]] && [ "${value}" -gt 0 ]
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
			--spec)
				[ $# -gt 1 ] || fail "--spec requires value"
				SPEC_FILE="$2"
				shift 2
				;;
			--results-base)
				[ $# -gt 1 ] || fail "--results-base requires value"
				RESULTS_BASE="$2"
				shift 2
				;;
			--run-id)
				[ $# -gt 1 ] || fail "--run-id requires value"
				RUN_ID="$2"
				shift 2
				;;
			--ring-size)
				[ $# -gt 1 ] || fail "--ring-size requires value"
				RING_SIZE="$2"
				shift 2
				;;
			--generated-header)
				[ $# -gt 1 ] || fail "--generated-header requires value"
				GENERATED_HEADER="$2"
				shift 2
				;;
			--katran-src-dir)
				[ $# -gt 1 ] || fail "--katran-src-dir requires value"
				KATRAN_SRC_DIR="$2"
				shift 2
				;;
			--katran-build-dir)
				[ $# -gt 1 ] || fail "--katran-build-dir requires value"
				KATRAN_BUILD_DIR="$2"
				shift 2
				;;
			--bpf-defines)
				[ $# -gt 1 ] || fail "--bpf-defines requires value"
				BPF_DEFINES="$2"
				shift 2
				;;
			--force-rebuild)
				[ $# -gt 1 ] || fail "--force-rebuild requires value"
				FORCE_REBUILD="$2"
				shift 2
				;;
			--skip-build)
				[ $# -gt 1 ] || fail "--skip-build requires value"
				SKIP_BUILD="$2"
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

resolve_latest_spec() {
	local latest
	latest="$(ls -1d "${DISCOVERY_BASE}"/*-stageA 2>/dev/null | sort | tail -n 1 || true)"
	[ -n "${latest}" ] || fail "cannot find stageA run under ${DISCOVERY_BASE}; pass --spec"
	[ -f "${latest}/specialization-spec.json" ] || fail "latest stageA missing specialization-spec.json: ${latest}"
	SPEC_FILE="${latest}/specialization-spec.json"
}

to_vm_path() {
	local host_path="$1"
	local root_abs
	local host_abs
	root_abs="$(realpath -m "${ROOT_DIR}")"
	host_abs="$(realpath -m "${host_path}")"
	case "${host_abs}" in
		"${root_abs}"/*)
			echo "/linux-dev-env${host_abs#${root_abs}}"
			;;
		*)
			fail "path outside repo root cannot map to VM path: ${host_abs}"
			;;
	esac
}

write_artifacts_env() {
	local run_dir="$1"
	local spec_abs="$2"
	local header_abs="$3"
	local katran_src_abs="$4"
	local katran_build_abs="$5"
	local server_host="${katran_build_abs}/build/example_grpc/katran_server_grpc"
	local bpf_host="${katran_build_abs}/deps/bpfprog/bpf/balancer.bpf.o"
	local goclient_host="${katran_src_abs}/example_grpc/goclient/src/katranc/main/main"
	local libs_host="${katran_build_abs}/deps/lib:${katran_build_abs}/deps/lib64"

	local env_file="${run_dir}/oracle-artifacts.env"
	cat >"${env_file}" <<EOF_ENV
run_id=${RUN_ID}
spec_file=${spec_abs}
generated_header=${header_abs}
katran_src_dir=${katran_src_abs}
katran_build_dir=${katran_build_abs}
exp1_katran_server_bin_vm=$(to_vm_path "${server_host}")
exp1_katran_bpf_obj_vm=$(to_vm_path "${bpf_host}")
exp1_katran_goclient_bin_vm=$(to_vm_path "${goclient_host}")
exp1_katran_lib_dirs_vm=$(to_vm_path "${katran_build_abs}/deps/lib"):$(to_vm_path "${katran_build_abs}/deps/lib64")
exp2_oracle_bpf_defines=${BPF_DEFINES}
EOF_ENV
	log "oracle env file: ${env_file}"
}

main() {
	parse_args "$@"

	RING_SIZE="$(normalize_quoted "${RING_SIZE}")"
	FORCE_REBUILD="$(normalize_quoted "${FORCE_REBUILD}")"
	SKIP_BUILD="$(normalize_quoted "${SKIP_BUILD}")"
	RESULTS_BASE="$(normalize_quoted "${RESULTS_BASE}")"
	DISCOVERY_BASE="$(normalize_quoted "${DISCOVERY_BASE}")"
	SPEC_FILE="$(normalize_quoted "${SPEC_FILE}")"
	GENERATED_HEADER="$(normalize_quoted "${GENERATED_HEADER}")"
	KATRAN_SRC_DIR="$(normalize_quoted "${KATRAN_SRC_DIR}")"
	KATRAN_BUILD_DIR="$(normalize_quoted "${KATRAN_BUILD_DIR}")"
	BPF_DEFINES="$(normalize_quoted "${BPF_DEFINES}")"

	is_pos_int "${RING_SIZE}" || fail "--ring-size must be positive int"
	is_bool_01 "${FORCE_REBUILD}" || fail "--force-rebuild must be 0 or 1"
	is_bool_01 "${SKIP_BUILD}" || fail "--skip-build must be 0 or 1"
	[ -f "${GEN_SCRIPT}" ] || fail "generator script not found: ${GEN_SCRIPT}"
	[ -x "${KATRAN_BUILD_SCRIPT}" ] || fail "katran build script not executable: ${KATRAN_BUILD_SCRIPT}"

	if [ -z "${SPEC_FILE}" ]; then
		resolve_latest_spec
	fi
	[ -f "${SPEC_FILE}" ] || fail "spec file not found: ${SPEC_FILE}"

	local spec_abs
	local header_abs
	local katran_src_abs
	local katran_build_abs
	spec_abs="$(realpath -m "${SPEC_FILE}")"
	header_abs="$(realpath -m "${GENERATED_HEADER}")"
	katran_src_abs="$(realpath -m "${KATRAN_SRC_DIR}")"
	katran_build_abs="$(realpath -m "${KATRAN_BUILD_DIR}")"

	[ -d "${katran_src_abs}" ] || fail "katran src dir not found: ${katran_src_abs}"

	if [ -z "${RUN_ID}" ]; then
		RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
	fi
	local run_dir="${RESULTS_BASE}/${RUN_ID}-build"
	mkdir -p "${run_dir}"

	log "run id: ${RUN_ID}"
	log "spec: ${spec_abs}"
	log "generating oracle header: ${header_abs}"
	python3 "${GEN_SCRIPT}" \
		--spec "${spec_abs}" \
		--output-header "${header_abs}" \
		--meta-output "${run_dir}/oracle-meta.json" \
		--ring-size "${RING_SIZE}"

	if [ "${SKIP_BUILD}" -eq 0 ]; then
		log "building isolated oracle Katran artifacts"
		EXP1_KATRAN_SRC_DIR="${katran_src_abs}" \
		EXP1_KATRAN_BUILD_DIR="${katran_build_abs}" \
		EXP1_KATRAN_FORCE_REBUILD="${FORCE_REBUILD}" \
		EXP1_KATRAN_BPF_DEFINES="${BPF_DEFINES}" \
		"${KATRAN_BUILD_SCRIPT}"
	else
		log "skip build enabled; only header generated"
	fi

	write_artifacts_env "${run_dir}" "${spec_abs}" "${header_abs}" "${katran_src_abs}" "${katran_build_abs}"

	log "complete"
	log "artifacts: ${run_dir}"
}

main "$@"
