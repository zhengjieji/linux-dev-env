#!/bin/bash
# Unload BPF programs for raw_tp micro-benchmark
#
# This script removes all pinned BPF programs

set -e

PIN_BASE_PATH="/sys/fs/bpf/micro_benchmark_raw_tp"

echo "========================================"
echo "Unloading BPF Programs (raw_tp)"
echo "========================================"

# Check if pin directory exists
if [ ! -d "$PIN_BASE_PATH" ]; then
    echo "No BPF programs currently loaded (pin directory doesn't exist)"
    exit 0
fi

# Count pinned programs
PROG_COUNT=$(find "$PIN_BASE_PATH" -type f 2>/dev/null | wc -l)

if [ "$PROG_COUNT" -eq 0 ]; then
    echo "No BPF programs currently loaded"
    rmdir "$PIN_BASE_PATH" 2>/dev/null || true
    exit 0
fi

echo "Found $PROG_COUNT pinned BPF program(s)"
echo ""

# Remove all pinned programs
for prog_file in "$PIN_BASE_PATH"/*; do
    if [ -f "$prog_file" ]; then
        prog_name=$(basename "$prog_file")
        echo "  Removing: $prog_name"
        rm -f "$prog_file"
    fi
done

# Remove directory
rmdir "$PIN_BASE_PATH" 2>/dev/null || true

echo ""
echo "✓ Successfully unloaded all BPF programs"
