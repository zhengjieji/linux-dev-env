#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

ORIG_OBJ=""
ORACLE_OBJ=""
OUT_DIR=""

usage() {
	cat <<USAGE
Usage: $(basename "$0") --orig-obj <path> --oracle-obj <path> [options]

Compare original vs oracle BPF bytecode and emit section-level metrics.

Options:
  --orig-obj <path>     Original BPF object path (required)
  --oracle-obj <path>   Oracle BPF object path (required)
  --out-dir <path>      Output directory (default: <oracle-obj-dir>/bytecode)
  -h, --help            Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--orig-obj)
			[ $# -gt 1 ] || exp2_die "--orig-obj requires value"
			ORIG_OBJ="$2"
			shift 2
			;;
		--oracle-obj)
			[ $# -gt 1 ] || exp2_die "--oracle-obj requires value"
			ORACLE_OBJ="$2"
			shift 2
			;;
		--out-dir)
			[ $# -gt 1 ] || exp2_die "--out-dir requires value"
			OUT_DIR="$2"
			shift 2
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

[ -n "${ORIG_OBJ}" ] || exp2_die "--orig-obj is required"
[ -n "${ORACLE_OBJ}" ] || exp2_die "--oracle-obj is required"

ORIG_OBJ="$(resolve_path_exp2 "${ORIG_OBJ}")"
ORACLE_OBJ="$(resolve_path_exp2 "${ORACLE_OBJ}")"
if [ -z "${OUT_DIR}" ]; then
	OUT_DIR="$(dirname -- "${ORACLE_OBJ}")/bytecode"
fi
OUT_DIR="$(resolve_path_exp2 "${OUT_DIR}")"

assert_file "${ORIG_OBJ}"
assert_file "${ORACLE_OBJ}"

require_cmd llvm-readelf
require_cmd llvm-objdump
require_cmd awk
require_cmd sed
require_cmd sort
require_cmd diff

section_file_tag() {
	printf '%s' "$1" | tr -cs '[:alnum:]_-' '_'
}

hex_to_dec() {
	local hex="${1#0x}"
	if [ -z "${hex}" ]; then
		echo 0
		return 0
	fi
	echo "$((16#${hex}))"
}

list_exec_sections() {
	local obj="$1"
	llvm-readelf -W -S "${obj}" | awk '$1=="[" && $4=="PROGBITS" && $9 ~ /X/ {print $3","$7}'
}

section_size_hex() {
	local csv="$1"
	local section="$2"
	awk -F, -v s="${section}" '$1==s {print $2; exit}' "${csv}"
}

has_section() {
	local csv="$1"
	local section="$2"
	awk -F, -v s="${section}" '$1==s{found=1} END{exit !found}' "${csv}"
}

count_insns() {
	local disasm_file="$1"
	awk '/^[[:space:]]*[0-9a-f]+:/ {c++} END {print c+0}' "${disasm_file}"
}

count_jumps() {
	local disasm_file="$1"
	awk '/^[[:space:]]*[0-9a-f]+:.*[[:space:]](if|goto)[[:space:]]/ {c++} END {print c+0}' "${disasm_file}"
}

mkdir -p "${OUT_DIR}/orig" "${OUT_DIR}/oracle" "${OUT_DIR}/diff"

orig_sections_csv="${OUT_DIR}/orig-sections.csv"
oracle_sections_csv="${OUT_DIR}/oracle-sections.csv"
all_sections_list="${OUT_DIR}/all-sections.txt"
metrics_csv="${OUT_DIR}/section-metrics.csv"
summary_md="${OUT_DIR}/summary.md"

list_exec_sections "${ORIG_OBJ}" >"${orig_sections_csv}"
list_exec_sections "${ORACLE_OBJ}" >"${oracle_sections_csv}"

{
	cut -d, -f1 "${orig_sections_csv}" || true
	cut -d, -f1 "${oracle_sections_csv}" || true
} | sed '/^$/d' | sort -u >"${all_sections_list}"

llvm-objdump -dr "${ORIG_OBJ}" >"${OUT_DIR}/orig/full.disasm.txt"
llvm-objdump -dr "${ORACLE_OBJ}" >"${OUT_DIR}/oracle/full.disasm.txt"

{
	echo "section,orig_size_bytes,oracle_size_bytes,size_delta_bytes,size_delta_pct,orig_insns,oracle_insns,insn_delta,orig_jumps,oracle_jumps,jump_delta"
} >"${metrics_csv}"

while IFS= read -r section; do
	[ -n "${section}" ] || continue
	tag="$(section_file_tag "${section}")"
	orig_disasm="${OUT_DIR}/orig/${tag}.disasm.txt"
	oracle_disasm="${OUT_DIR}/oracle/${tag}.disasm.txt"
	diff_file="${OUT_DIR}/diff/${tag}.diff.txt"
	removed_branch_file="${OUT_DIR}/diff/${tag}.removed-branches.txt"

	if has_section "${orig_sections_csv}" "${section}"; then
		llvm-objdump -dr --section="${section}" "${ORIG_OBJ}" >"${orig_disasm}"
	else
		: >"${orig_disasm}"
	fi

	if has_section "${oracle_sections_csv}" "${section}"; then
		llvm-objdump -dr --section="${section}" "${ORACLE_OBJ}" >"${oracle_disasm}"
	else
		: >"${oracle_disasm}"
	fi

	orig_size_hex="$(section_size_hex "${orig_sections_csv}" "${section}" || true)"
	oracle_size_hex="$(section_size_hex "${oracle_sections_csv}" "${section}" || true)"
	orig_size="$(hex_to_dec "${orig_size_hex}")"
	oracle_size="$(hex_to_dec "${oracle_size_hex}")"
	size_delta=$((oracle_size - orig_size))
	size_delta_pct="$(awk -v o="${orig_size}" -v n="${oracle_size}" 'BEGIN {if (o>0) printf "%.2f", ((n-o)*100.0)/o; else printf "0.00"}')"

	orig_insns="$(count_insns "${orig_disasm}")"
	oracle_insns="$(count_insns "${oracle_disasm}")"
	insn_delta=$((oracle_insns - orig_insns))

	orig_jumps="$(count_jumps "${orig_disasm}")"
	oracle_jumps="$(count_jumps "${oracle_disasm}")"
	jump_delta=$((oracle_jumps - orig_jumps))

	diff -u "${orig_disasm}" "${oracle_disasm}" >"${diff_file}" || true
	grep -E '^-([[:space:]]*[0-9a-f]+:).*\b(if|goto)\b' "${diff_file}" | sed 's/^-//' >"${removed_branch_file}" || true

	echo "${section},${orig_size},${oracle_size},${size_delta},${size_delta_pct},${orig_insns},${oracle_insns},${insn_delta},${orig_jumps},${oracle_jumps},${jump_delta}" >>"${metrics_csv}"
done <"${all_sections_list}"

{
	echo "# Exp2 Bytecode Compare"
	echo
	echo "- orig_obj: ${ORIG_OBJ}"
	echo "- oracle_obj: ${ORACLE_OBJ}"
	echo "- metrics_csv: ${metrics_csv}"
	echo
	echo "## Aggregate"
	echo
	tail -n +2 "${metrics_csv}" | awk -F, '
		{ os+=$2; ns+=$3; oi+=$6; ni+=$7; oj+=$9; nj+=$10 }
		END {
			printf "- total_orig_size_bytes: %d\n", os
			printf "- total_oracle_size_bytes: %d\n", ns
			printf "- total_size_delta_bytes: %d\n", ns-os
			if (os>0) printf "- total_size_delta_pct: %.2f\n", ((ns-os)*100.0)/os; else print "- total_size_delta_pct: 0.00"
			printf "- total_orig_insns: %d\n", oi
			printf "- total_oracle_insns: %d\n", ni
			printf "- total_insn_delta: %d\n", ni-oi
			printf "- total_orig_jumps: %d\n", oj
			printf "- total_oracle_jumps: %d\n", nj
			printf "- total_jump_delta: %d\n", nj-oj
		}'
	echo
	echo "## Section Metrics"
	echo
	echo '```csv'
	cat "${metrics_csv}"
	echo '```'
} >"${summary_md}"

echo "OUT_DIR=${OUT_DIR}"
echo "METRICS_CSV=${metrics_csv}"
echo "SUMMARY_MD=${summary_md}"
