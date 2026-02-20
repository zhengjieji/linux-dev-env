#!/usr/bin/env bash

set -euo pipefail

EXP2_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${EXP2_DIR}/common.sh"

OUT_ROOT="${EXP2_DISCOVERY_ROOT_DEFAULT}"
RATE_PPS=600000
DURATION_SECS=120
INTERVAL_SECS=30
NO_VM_START=0
NO_VM_SETUP=0
DRY_RUN=0
VIP="192.168.100.100"
VIP_PORT=80
MAX_DUMP_LINES=2000

usage() {
	cat <<USAGE
Usage: $(basename "$0") [options]

Run Exp2 discovery snapshots to identify stable map contents.

Options:
  --out-root <path>      Output root (default: ${OUT_ROOT})
  --rate-pps <n>         Workload rate during discovery (default: ${RATE_PPS})
  --duration <sec>       Total discovery duration (default: ${DURATION_SECS})
  --interval <sec>       Snapshot interval (default: ${INTERVAL_SECS})
  --vip <ip>             VIP (default: ${VIP})
  --vip-port <n>         VIP port (default: ${VIP_PORT})
  --max-dump-lines <n>   Max lines per map dump snapshot (default: ${MAX_DUMP_LINES})
  --no-vm-start          Assume VMs are already running
  --no-vm-setup          Skip VM setup call
  --dry-run              Print steps only
  -h, --help             Show this help
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
		--out-root)
			[ $# -gt 1 ] || exp2_die "--out-root requires value"
			OUT_ROOT="$2"
			shift 2
			;;
		--rate-pps)
			[ $# -gt 1 ] || exp2_die "--rate-pps requires value"
			RATE_PPS="$2"
			shift 2
			;;
		--duration)
			[ $# -gt 1 ] || exp2_die "--duration requires value"
			DURATION_SECS="$2"
			shift 2
			;;
		--interval)
			[ $# -gt 1 ] || exp2_die "--interval requires value"
			INTERVAL_SECS="$2"
			shift 2
			;;
		--vip)
			[ $# -gt 1 ] || exp2_die "--vip requires value"
			VIP="$2"
			shift 2
			;;
		--vip-port)
			[ $# -gt 1 ] || exp2_die "--vip-port requires value"
			VIP_PORT="$2"
			shift 2
			;;
		--max-dump-lines)
			[ $# -gt 1 ] || exp2_die "--max-dump-lines requires value"
			MAX_DUMP_LINES="$2"
			shift 2
			;;
		--no-vm-start)
			NO_VM_START=1
			shift
			;;
		--no-vm-setup)
			NO_VM_SETUP=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
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

OUT_ROOT="$(resolve_path_exp2 "${OUT_ROOT}")"
mkdir -p "${OUT_ROOT}"
RUN_ID="$(new_exp2_id discovery)"
RUN_DIR="${OUT_ROOT}/${RUN_ID}"
SNAP_DIR="${RUN_DIR}/snapshots"
mkdir -p "${SNAP_DIR}"

if [ "${DRY_RUN}" -eq 1 ]; then
	exp2_log "[dry-run] would run discovery at rate=${RATE_PPS}, duration=${DURATION_SECS}, interval=${INTERVAL_SECS}"
	echo "RUN_DIR=${RUN_DIR}"
	exit 0
fi

maybe_start_dual_vms "${NO_VM_START}"
if [ "${NO_VM_SETUP}" -eq 0 ]; then
	"${EXP2_DIR}/vm-setup.sh" --out-root "${RUN_DIR}/setup" --no-vm-start >"${RUN_DIR}/vm-setup.log" 2>&1
fi

exp2_log "applying katran-orig-bpf mode for discovery"
ssh_vm vm1 "/linux-dev-env/scripts/katran/vm1-run-mode.sh --mode katran-orig-bpf --vip ${VIP} --vip-port ${VIP_PORT}" >"${RUN_DIR}/mode.log" 2>&1

REMOTE_WORKLOAD_OUT="/tmp/exp2-discovery-workload-${RUN_ID}.txt"
exp2_log "starting discovery workload on vm2"
ssh_vm vm2 "/linux-dev-env/scripts/katran/vm2-run-workload.sh --vip ${VIP} --dport ${VIP_PORT} --rate-pps ${RATE_PPS} --duration ${DURATION_SECS} --output ${REMOTE_WORKLOAD_OUT}" >"${RUN_DIR}/workload.log" 2>&1 &
work_pid=$!

map_name_for_id() {
	local map_id="$1"
	ssh_vm vm1 "bpftool map show id ${map_id} 2>/dev/null | sed -n 's/.*name \([^ ]*\).*/\\1/p' | head -n1" || true
}

find_xdp_prog_id() {
	ssh_vm vm1 "iface=\$(ip -o link | grep -i '52:54:00:aa:00:11' | head -n1 | awk -F': ' '{print \$2}' | sed 's/@.*//'); ip -d link show dev \"\${iface}\" 2>/dev/null | sed -n 's/.*prog\\/xdp id \\([0-9][0-9]*\\).*/\\1/p' | head -n1" || true
}

list_map_ids_for_prog() {
	local prog_id="$1"
	ssh_vm vm1 "bpftool prog show id ${prog_id} 2>/dev/null | sed -n 's/.*map_ids //p' | tr ',' ' '" || true
}

snapshot_csv="${RUN_DIR}/snapshot-index.csv"
echo "snapshot_idx,timestamp_utc,map_id,map_name,sha256,dump_bytes" >"${snapshot_csv}"

start_epoch="$(date +%s)"
snapshot_idx=0

while true; do
	now_epoch="$(date +%s)"
	elapsed=$((now_epoch - start_epoch))
	if [ "${elapsed}" -ge "${DURATION_SECS}" ]; then
		break
	fi

	snap_stamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	snap_path="${SNAP_DIR}/snapshot-${snapshot_idx}"
	mkdir -p "${snap_path}"

	prog_id="$(find_xdp_prog_id | tr -d '[:space:]')"
	echo "prog_id=${prog_id}" >"${snap_path}/meta.env"
	echo "timestamp_utc=${snap_stamp}" >>"${snap_path}/meta.env"
	if [ -n "${prog_id}" ]; then
		map_ids="$(list_map_ids_for_prog "${prog_id}" | xargs echo || true)"
		echo "map_ids=${map_ids}" >>"${snap_path}/meta.env"
		for map_id in ${map_ids}; do
			[ -n "${map_id}" ] || continue
			show_file="${snap_path}/map-${map_id}.show.txt"
			dump_file="${snap_path}/map-${map_id}.dump.txt"
			ssh_vm vm1 "bpftool map show id ${map_id}" >"${show_file}" 2>"${snap_path}/map-${map_id}.show.err" || true
			ssh_vm vm1 "bpftool map dump id ${map_id} | head -n ${MAX_DUMP_LINES}" >"${dump_file}" 2>"${snap_path}/map-${map_id}.dump.err" || true
			sha="$(sha256sum "${dump_file}" | awk '{print $1}')"
			bytes="$(wc -c <"${dump_file}" | awk '{print $1}')"
			name="$(map_name_for_id "${map_id}" | head -n1 | tr -d '[:space:]')"
			echo "${snapshot_idx},${snap_stamp},${map_id},${name},${sha},${bytes}" >>"${snapshot_csv}"
		done
	fi

	snapshot_idx=$((snapshot_idx + 1))
	sleep "${INTERVAL_SECS}"
done

wait_start="$(date +%s)"
wait_timeout=$((DURATION_SECS + INTERVAL_SECS + 30))
while kill -0 "${work_pid}" 2>/dev/null; do
	now_wait="$(date +%s)"
	if [ $((now_wait - wait_start)) -gt "${wait_timeout}" ]; then
		kill "${work_pid}" 2>/dev/null || true
		exp2_die "discovery workload timed out; see ${RUN_DIR}/workload.log"
	fi
	sleep 1
done
wait "${work_pid}" || exp2_die "discovery workload failed; see ${RUN_DIR}/workload.log"

summary_csv="${RUN_DIR}/invariant-candidates.csv"
{
	echo "map_id,map_name,samples,distinct_hashes,status,last_hash"
	awk -F, 'NR>1{key=$3; name[key]=$4; cnt[key]++; seen[key FS $5]=1; last[key]=$5} END {for (k in cnt) {d=0; for (s in seen) {split(s,a,FS); if (a[1]==k) d++} status=(d==1?"invariant":"variant"); print k "," name[k] "," cnt[k] "," d "," status "," last[k]}}' "${snapshot_csv}" | sort -t, -k1,1n
} >"${summary_csv}"

{
	echo "run_id=${RUN_ID}"
	echo "run_dir=${RUN_DIR}"
	echo "rate_pps=${RATE_PPS}"
	echo "duration_secs=${DURATION_SECS}"
	echo "interval_secs=${INTERVAL_SECS}"
	echo "snapshots=${snapshot_idx}"
	echo "summary_csv=${summary_csv}"
} >"${RUN_DIR}/summary.env"

{
	echo "# Exp2 Discovery Summary"
	echo
	echo "- run_id: ${RUN_ID}"
	echo "- rate_pps: ${RATE_PPS}"
	echo "- duration_secs: ${DURATION_SECS}"
	echo "- interval_secs: ${INTERVAL_SECS}"
	echo "- snapshots: ${snapshot_idx}"
	echo "- candidate_csv: ${summary_csv}"
	echo
	echo "## Candidate Counts"
	echo
	echo "\`\`\`"
	awk -F, 'NR>1{c[$5]++} END{for (k in c) print k "=" c[k]}' "${summary_csv}" | sort
	echo "\`\`\`"
} >"${RUN_DIR}/summary.md"

exp2_log "discovery complete: ${RUN_DIR}"
echo "RUN_DIR=${RUN_DIR}"
