#!/bin/bash

set -e

echo "=== BPF send_signal_task kfunc test (custom implementation) ==="
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

# Unload module if loaded
echo "Unloading custom kfunc module if present..."
rmmod custom_kfunc 2>/dev/null || true

# Clean up any previous builds
echo "Cleaning previous builds..."
make clean 2>/dev/null || true

# Generate vmlinux.h if it doesn't exist
if [ ! -f "vmlinux.h" ]; then
    echo "Generating vmlinux.h..."
    make vmlinux.h
fi

# Build everything including the module
echo "Building BPF programs, tools, and kernel module..."
make all

# Check if custom_kfunc.ko was built
if [ ! -f "custom_kfunc.ko" ]; then
    echo "Error: custom_kfunc.ko not found!"
    echo "Build output should have generated the .ko file"
    exit 1
fi

# Load the custom kfunc module
echo "Loading custom kfunc kernel module..."
insmod custom_kfunc.ko
if lsmod | grep -q custom_kfunc; then
    echo "Custom kfunc module loaded successfully"
else
    echo "Failed to load custom kfunc module"
    exit 1
fi

# Check dmesg for module load message
echo "=== Module Load Messages ==="
dmesg | grep "custom_send_signal_task" | tail -5

# Clear trace buffer
echo > /sys/kernel/debug/tracing/trace

# Load BPF program with custom kfunc
echo "Loading BPF tracepoint program with custom kfunc..."
./loader bpf_prog_custom.o &
LOAD_PID=$!

# Wait for program to load
sleep 2

# Check if loader is still running
if ! kill -0 $LOAD_PID 2>/dev/null; then
    echo "Error: BPF program failed to load"
    echo "Check dmesg for verifier errors:"
    dmesg | tail -20
    rmmod custom_kfunc
    exit 1
fi

echo "BPF program loaded successfully (PID: $LOAD_PID)"

# Run trigger program
echo
echo "Running trigger program..."
./trigger $ITERATIONS

echo
echo "=== BPF Trace Output (last 20 lines) ==="
tail -n 20 /sys/kernel/debug/tracing/trace

echo
echo "=== Kernel Module Messages ==="
dmesg | grep "custom_send_signal" | tail -10

# Cleanup
echo
echo "Cleaning up..."
kill $LOAD_PID 2>/dev/null || true
sleep 2  # Give time for BPF program to detach

echo "Unloading custom kfunc module..."
rmmod custom_kfunc 2>/dev/null || echo "Note: Module may still be in use, try 'rmmod custom_kfunc' later"

echo "Test completed!"