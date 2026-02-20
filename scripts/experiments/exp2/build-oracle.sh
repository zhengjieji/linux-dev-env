#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

EXP2_SRC="${EXP2_SOURCE_DEFAULT}"
BASE_SRC="${EXP2_BASE_SOURCE_DEFAULT}"
PATCH_FILE=""
DEFAULT_PATCH_FILE="${EXP2_DIR}/patches/oracle-default.patch"
OUT_ROOT="${EXP2_ORACLE_BUILD_ROOT_DEFAULT}"
RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"
UPDATE=0
USE_DEFAULT_PATCH=1
ALLOW_IDENTICAL=0

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Build oracle BPF object in isolated Exp2 source tree without touching Exp1 source.

Options:
  --exp2-src <path>     Exp2 isolated source (default: ${EXP2_SRC})
  --base-src <path>     Exp1/base source for checksum reference (default: ${BASE_SRC})
  --patch <path>        Oracle patch to apply in Exp2 source before build
  --no-default-patch    Do not auto-use ${DEFAULT_PATCH_FILE}
  --allow-identical     Allow oracle hash == exp1 hash (debug only)
  --out-root <path>     Output root for build artifacts (default: ${OUT_ROOT})
  --runtime-image <n>   Runtime image for build (default: ${RUNTIME_IMAGE})
  --update              Update/fetch exp2 source before build
  -h, --help            Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--exp2-src)
			[ $# -gt 1 ] || exp2_die "--exp2-src requires value"
			EXP2_SRC="$2"
			shift 2
			;;
		--base-src)
			[ $# -gt 1 ] || exp2_die "--base-src requires value"
			BASE_SRC="$2"
			shift 2
			;;
		--patch)
			[ $# -gt 1 ] || exp2_die "--patch requires value"
			PATCH_FILE="$2"
			shift 2
			;;
		--no-default-patch)
			USE_DEFAULT_PATCH=0
			shift
			;;
		--allow-identical)
			ALLOW_IDENTICAL=1
			shift
			;;
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
			;;
		--runtime-image)
			[ $# -gt 1 ] || exp2_die "--runtime-image requires value"
			RUNTIME_IMAGE="$2"
			shift 2
			;;
		--update)
			UPDATE=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			exp2_die "unknown option: $1"
			;;
	esac
done

EXP2_SRC="$(resolve_path_exp2 "${EXP2_SRC}")"
BASE_SRC="$(resolve_path_exp2 "${BASE_SRC}")"
OUT_ROOT="$(resolve_path_exp2 "${OUT_ROOT}")"
mkdir -p "${OUT_ROOT}"

RUN_ID="$(new_exp2_id oracle-build)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
ART_DIR="${RUN_DIR}/artifacts"
mkdir -p "${ART_DIR}"

prepare_cmd=("${EXP2_DIR}/prepare-source.sh" --base-src "${BASE_SRC}" --exp2-src "${EXP2_SRC}" --runtime-image "${RUNTIME_IMAGE}")
if [ "${UPDATE}" -eq 1 ]; then
	prepare_cmd+=(--update)
fi
"${prepare_cmd[@]}" >"${RUN_DIR}/prepare-source.log" 2>&1

orig_obj="${BASE_SRC}/build/katran/lib/bpf/balancer.bpf.o"
exp2_obj="${EXP2_SRC}/build/katran/lib/bpf/balancer.bpf.o"

if [ ! -f "${orig_obj}" ]; then
	exp2_log "base object missing; building from base source: ${BASE_SRC}"
	"${ROOT_DIR}/scripts/katran/build-katran-host.sh" --src "${BASE_SRC}" --runtime-image "${RUNTIME_IMAGE}" --force >"${RUN_DIR}/build-base.log" 2>&1
fi
assert_file "${orig_obj}"

PATCH_SOURCE="explicit"
PATCH_APPLIED=0
PATCH_ALREADY_PRESENT=0
if [ -z "${PATCH_FILE}" ] && [ "${USE_DEFAULT_PATCH}" -eq 1 ] && [ -f "${DEFAULT_PATCH_FILE}" ]; then
	PATCH_FILE="${DEFAULT_PATCH_FILE}"
	PATCH_SOURCE="default"
fi
if [ -z "${PATCH_FILE}" ]; then
	PATCH_SOURCE="none"
fi

if [ -n "${PATCH_FILE}" ]; then
	PATCH_FILE="$(resolve_path_exp2 "${PATCH_FILE}")"
	assert_file "${PATCH_FILE}"
	exp2_log "applying ${PATCH_SOURCE} oracle patch in isolated Exp2 source: ${PATCH_FILE}"
	if git -C "${EXP2_SRC}" apply --check "${PATCH_FILE}" >"${RUN_DIR}/patch-check.log" 2>&1; then
		git -C "${EXP2_SRC}" apply "${PATCH_FILE}" >"${RUN_DIR}/patch-apply.log" 2>&1
		PATCH_APPLIED=1
	elif git -C "${EXP2_SRC}" apply --reverse --check "${PATCH_FILE}" >"${RUN_DIR}/patch-reverse-check.log" 2>&1; then
		exp2_log "patch already present in ${EXP2_SRC}; reusing current patched tree"
		PATCH_ALREADY_PRESENT=1
	else
		exp2_die "patch check failed; see ${RUN_DIR}/patch-check.log and ${RUN_DIR}/patch-reverse-check.log"
	fi
else
	exp2_log "no oracle patch provided; building current Exp2 source state"
fi

"${ROOT_DIR}/scripts/katran/build-katran-host.sh" --src "${EXP2_SRC}" --runtime-image "${RUNTIME_IMAGE}" --force >"${RUN_DIR}/build.log" 2>&1

assert_file "${exp2_obj}"

cp -f "${exp2_obj}" "${ART_DIR}/balancer.oracle.bpf.o"
cp -f "${orig_obj}" "${ART_DIR}/balancer.exp1-orig.bpf.o"

bytecode_dir="${RUN_DIR}/bytecode"
"${EXP2_DIR}/bytecode-compare.sh" \
	--orig-obj "${ART_DIR}/balancer.exp1-orig.bpf.o" \
	--oracle-obj "${ART_DIR}/balancer.oracle.bpf.o" \
	--out-dir "${bytecode_dir}" >"${RUN_DIR}/bytecode.log" 2>&1
assert_file "${bytecode_dir}/section-metrics.csv"

oracle_sha="$(sha256sum "${ART_DIR}/balancer.oracle.bpf.o" | awk '{print $1}')"
orig_sha="$(sha256sum "${ART_DIR}/balancer.exp1-orig.bpf.o" | awk '{print $1}')"
OBJECTS_IDENTICAL=0
if [ "${oracle_sha}" = "${orig_sha}" ]; then
	OBJECTS_IDENTICAL=1
fi

{
	echo "run_id=${RUN_ID}"
	echo "run_dir=${RUN_DIR}"
	echo "exp2_src=${EXP2_SRC}"
	echo "base_src=${BASE_SRC}"
	echo "patch_file=${PATCH_FILE}"
	echo "patch_source=${PATCH_SOURCE}"
	echo "patch_applied=${PATCH_APPLIED}"
	echo "patch_already_present=${PATCH_ALREADY_PRESENT}"
	echo "allow_identical=${ALLOW_IDENTICAL}"
	echo "oracle_obj=${ART_DIR}/balancer.oracle.bpf.o"
	echo "oracle_sha256=${oracle_sha}"
	echo "bytecode_dir=${bytecode_dir}"
	echo "bytecode_metrics_csv=${bytecode_dir}/section-metrics.csv"
	echo "exp1_orig_obj=${ART_DIR}/balancer.exp1-orig.bpf.o"
	echo "exp1_orig_sha256=${orig_sha}"
	echo "objects_identical=${OBJECTS_IDENTICAL}"
	echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >"${RUN_DIR}/manifest.env"

{
	echo "# Exp2 Oracle Build"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- exp2_src: ${EXP2_SRC}"
	echo "- patch_file: ${PATCH_FILE}"
	echo "- patch_source: ${PATCH_SOURCE}"
	echo "- oracle_obj: ${ART_DIR}/balancer.oracle.bpf.o"
	echo "- oracle_sha256: ${oracle_sha}"
	echo "- exp1_orig_sha256: ${orig_sha}"
	echo "- objects_identical: ${OBJECTS_IDENTICAL}"
	echo "- bytecode_summary: ${bytecode_dir}/summary.md"
	echo "- bytecode_metrics_csv: ${bytecode_dir}/section-metrics.csv"
} >"${RUN_DIR}/summary.md"

if [ "${OBJECTS_IDENTICAL}" -eq 1 ] && [ "${ALLOW_IDENTICAL}" -ne 1 ]; then
	exp2_die "oracle hash equals exp1 hash (${oracle_sha}). Not a true oracle comparison; provide a valid patch or keep default patch enabled."
fi

exp2_log "oracle build complete: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
echo "ORACLE_OBJ=${ART_DIR}/balancer.oracle.bpf.o"
