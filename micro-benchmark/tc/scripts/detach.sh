#!/bin/bash
# Detach BPF programs for TC micro-benchmark
#
# This script removes TC qdisc and pinned programs

set -e

PIN_BASE_PATH="/sys/fs/bpf/micro_benchmark_tc"
IFNAME="lo"

echo "========================================"
echo "Detaching TC BPF Programs"
echo "========================================"

# Remove TC clsact qdisc (this detaches all TC BPF programs)
echo "Removing TC clsact qdisc from $IFNAME..."
tc qdisc del dev "$IFNAME" clsact 2>/dev/null || true

# Check if pin directory exists
if [ ! -d "$PIN_BASE_PATH" ]; then
    echo "No pinned BPF programs found"
    echo ""
    echo "✓ TC detached from $IFNAME"
    exit 0
fi

# Count pinned programs
PROG_COUNT=$(find "$PIN_BASE_PATH" -type f 2>/dev/null | wc -l)

if [ "$PROG_COUNT" -eq 0 ]; then
    echo "No pinned BPF programs found"
    rmdir "$PIN_BASE_PATH" 2>/dev/null || true
    echo ""
    echo "✓ TC detached from $IFNAME"
    exit 0
fi

echo "Found $PROG_COUNT pinned BPF object(s)"
echo ""

# Remove all pinned programs and maps
for obj_file in "$PIN_BASE_PATH"/*; do
    if [ -f "$obj_file" ]; then
        obj_name=$(basename "$obj_file")
        echo "  Removing: $obj_name"
        rm -f "$obj_file"
    fi
done

# Remove directory
rmdir "$PIN_BASE_PATH" 2>/dev/null || true

echo ""
echo "✓ Successfully detached TC from $IFNAME"
echo "✓ Removed all pinned BPF programs and maps"
