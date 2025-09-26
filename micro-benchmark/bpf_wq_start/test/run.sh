#!/bin/bash

set -e

echo "=== BPF bpf_wq_start kfunc test ==="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Parse arguments
ITERATIONS=${1:-100}

# Kill any existing loader processes
echo "Cleaning up any existing processes..."
pkill -f "./loader" 2>/dev/null || true
sleep 1

# Clean up any previous builds
echo "Cleaning previous builds..."
make clean 2>/dev/null || true

# Clean up any existing TC filters
tc filter del dev lo ingress 2>/dev/null || true
tc qdisc del dev lo clsact 2>/dev/null || true

# Generate vmlinux.h if it doesn't exist
if [ ! -f "vmlinux.h" ]; then
    echo "Generating vmlinux.h..."
    make vmlinux.h
fi

# Build the BPF program and user programs
echo "Building BPF program and tools..."
make

# Clear trace buffer
echo > /sys/kernel/debug/tracing/trace

# Load BPF program (attach to loopback interface)
echo "Loading BPF TC program for bpf_wq_start test..."
./loader bpf_prog.o lo &
LOAD_PID=$!

# Wait for program to load
sleep 2

# Check if loader is still running
if ! kill -0 $LOAD_PID 2>/dev/null; then
    echo "Error: BPF program failed to load"
    echo "Check dmesg for verifier errors:"
    dmesg | tail -20
    exit 1
fi

echo "BPF TC program loaded successfully (PID: $LOAD_PID)"

# Run trigger program
echo
echo "Running trigger program..."
./trigger $ITERATIONS

echo
echo "=== BPF Trace Output (last 20 lines) ==="
tail -n 20 /sys/kernel/debug/tracing/trace | grep -E "bpf_wq_start|bpf_wq_init|wq_callback" || echo "No trace output found"

# Cleanup
echo
echo "Cleaning up..."
kill $LOAD_PID 2>/dev/null || true
tc filter del dev lo ingress 2>/dev/null || true
tc qdisc del dev lo clsact 2>/dev/null || true

echo "Test completed!"