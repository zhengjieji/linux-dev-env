#!/bin/bash
# Simple script: trigger BPF 100 times and log dmesg and trace_pipe to files

set -e

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

ITERATIONS=100
DMESG_LOG="dmesg_output.txt"
TRACE_LOG="trace_output.txt"

echo "=== BPF Test - 100 iterations ==="
echo

# Cleanup
echo "[1/5] Cleaning up..."
pkill -f "./loader" 2>/dev/null || true
pkill -f "cat /sys/kernel/debug/tracing/trace_pipe" 2>/dev/null || true
fuser -k /sys/kernel/debug/tracing/trace_pipe 2>/dev/null || true
make clean 2>/dev/null || true
sleep 1

# Build
echo "[2/5] Building..."
make

# Setup tracing
echo "[3/5] Setting up tracing..."
echo 1 > /sys/kernel/debug/tracing/tracing_on
echo > /sys/kernel/debug/tracing/trace
dmesg -c > /dev/null

# Start trace_pipe capture
echo "[4/5] Starting trace capture..."
cat /sys/kernel/debug/tracing/trace_pipe > $TRACE_LOG &
TRACE_PID=$!
sleep 0.5

# Load BPF program
./loader bpf_prog.o &
LOADER_PID=$!
sleep 2

# Run triggers
echo "[5/5] Running $ITERATIONS triggers..."
./trigger $ITERATIONS

# Wait a bit
sleep 2

# Stop trace capture
kill $TRACE_PID 2>/dev/null || true
wait $TRACE_PID 2>/dev/null || true

# Capture dmesg
dmesg > $DMESG_LOG

# Cleanup
kill $LOADER_PID 2>/dev/null || true

echo
echo "Done!"
echo "Logs saved:"
echo "  - trace_pipe: $TRACE_LOG"
echo "  - dmesg: $DMESG_LOG"
