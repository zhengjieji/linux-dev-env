#!/bin/bash
# Detach BPF programs for tp_btf/task_newtask micro-benchmark
#
# This script removes all pinned BPF links

set -e

PIN_BASE_PATH="/sys/fs/bpf/micro_benchmark_tp_btf"

echo "========================================"
echo "Detaching BPF Programs"
echo "========================================"

# Check if pin directory exists
if [ ! -d "$PIN_BASE_PATH" ]; then
    echo "No BPF programs currently attached (pin directory doesn't exist)"
    exit 0
fi

# Count pinned links
LINK_COUNT=$(find "$PIN_BASE_PATH" -type f 2>/dev/null | wc -l)

if [ "$LINK_COUNT" -eq 0 ]; then
    echo "No BPF programs currently attached"
    rmdir "$PIN_BASE_PATH" 2>/dev/null || true
    exit 0
fi

echo "Found $LINK_COUNT pinned BPF link(s)"
echo ""

# Remove all pinned links
for link_file in "$PIN_BASE_PATH"/*; do
    if [ -f "$link_file" ]; then
        link_name=$(basename "$link_file")
        echo "  Removing: $link_name"
        rm -f "$link_file"
    fi
done

# Remove directory
rmdir "$PIN_BASE_PATH" 2>/dev/null || true

echo ""
echo "✓ Successfully detached all BPF programs"
