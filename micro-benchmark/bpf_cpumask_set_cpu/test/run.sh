#!/bin/bash

set -e

echo "=== BPF bpf_cpumask_set_cpu kfunc test ==="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Parse arguments
ITERATIONS=${1:-10}

# Kill any existing loader processes
echo "Cleaning up any existing processes..."
pkill -f "./loader" 2>/dev/null || true
sleep 1

# Clean up any previous builds
echo "Cleaning previous builds..."
make clean 2>/dev/null || true

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

# Load BPF program
echo "Loading BPF tracepoint program for bpf_cpumask_set_cpu test..."
./loader bpf_prog.o &
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

echo "BPF program loaded successfully (PID: $LOAD_PID)"

# Run trigger program
echo
echo "Running trigger program..."
./trigger $ITERATIONS

echo
echo "=== BPF Trace Output (last 30 lines) ==="
tail -n 30 /sys/kernel/debug/tracing/trace

# Cleanup
echo
echo "Cleaning up..."
kill $LOAD_PID 2>/dev/null || true

echo "Test completed!"