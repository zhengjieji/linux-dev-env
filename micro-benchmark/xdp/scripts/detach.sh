#!/bin/bash
# Detach BPF programs for XDP micro-benchmark
#
# This script detaches XDP from interface and removes pinned programs

set -e

PIN_BASE_PATH="/sys/fs/bpf/micro_benchmark_xdp"
IFNAME="lo"

echo "========================================"
echo "Detaching XDP BPF Programs"
echo "========================================"

# Detach XDP from interface
echo "Detaching XDP from $IFNAME..."
ip link set dev "$IFNAME" xdp off 2>/dev/null || true

# Check if pin directory exists
if [ ! -d "$PIN_BASE_PATH" ]; then
    echo "No pinned BPF programs found"
    echo ""
    echo "✓ XDP detached from $IFNAME"
    exit 0
fi

# Count pinned programs
PROG_COUNT=$(find "$PIN_BASE_PATH" -type f 2>/dev/null | wc -l)

if [ "$PROG_COUNT" -eq 0 ]; then
    echo "No pinned BPF programs found"
    rmdir "$PIN_BASE_PATH" 2>/dev/null || true
    echo ""
    echo "✓ XDP detached from $IFNAME"
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
echo "✓ Successfully detached XDP from $IFNAME"
echo "✓ Removed all pinned BPF programs"
