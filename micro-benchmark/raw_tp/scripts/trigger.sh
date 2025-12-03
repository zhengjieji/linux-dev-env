#!/bin/bash
# Run BPF_PROG_TEST_RUN and capture output
#
# Usage: ./trigger.sh [iterations]
#
# This script runs pinned BPF programs via BPF_PROG_TEST_RUN and captures
# trace_pipe and dmesg output.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$BASE_DIR"

ITERATIONS=${1:-1}
TRACE_LOG="outputs/trace.log"
DMESG_LOG="outputs/dmesg.log"
TRACE_PIPE="/sys/kernel/debug/tracing/trace_pipe"

# Check if trigger exists
if [ ! -f "./trigger" ]; then
    echo "Error: trigger not found. Run 'make' first."
    exit 1
fi

# Check root permissions for trace access
if [ ! -r "$TRACE_PIPE" ]; then
    echo "Error: Cannot read $TRACE_PIPE"
    echo "Please run as root or with sudo"
    exit 1
fi

echo "========================================"
echo "Running BPF Trigger (BPF_PROG_TEST_RUN)"
echo "========================================"
echo "Iterations: $ITERATIONS"
echo "Trace log:  $TRACE_LOG"
echo "Dmesg log:  $DMESG_LOG"
echo ""

# Create outputs directory
mkdir -p outputs

# Clear previous logs
> "$TRACE_LOG"
> "$DMESG_LOG"

# Clear dmesg
echo "[1/4] Clearing dmesg..."
dmesg -C

# Clear trace buffer
echo "[2/4] Clearing trace buffer..."
echo > /sys/kernel/debug/tracing/trace

# Start trace capture in background
echo "[3/4] Starting trace capture..."
timeout 30 cat "$TRACE_PIPE" > "$TRACE_LOG" 2>/dev/null &
TRACE_PID=$!

# Give trace capture time to start
sleep 0.5

# Run trigger
echo "[4/4] Running trigger ($ITERATIONS iterations)..."
./trigger "$ITERATIONS"

# Wait for trace output to flush
echo ""
echo "Waiting for trace buffer to flush (3 seconds)..."
sleep 3

# Stop trace capture
kill $TRACE_PID 2>/dev/null || true
wait $TRACE_PID 2>/dev/null || true

# Capture dmesg
echo "Capturing dmesg output..."
dmesg > "$DMESG_LOG"

echo ""
echo "========================================"
echo "Trigger Complete"
echo "========================================"

# Check output files
if [ -s "$TRACE_LOG" ]; then
    TRACE_LINES=$(wc -l < "$TRACE_LOG")
    echo "✓ Trace output: $TRACE_LINES lines in $TRACE_LOG"
else
    echo "✗ Warning: $TRACE_LOG is empty"
fi

if [ -s "$DMESG_LOG" ]; then
    DMESG_LINES=$(wc -l < "$DMESG_LOG")
    echo "✓ Dmesg output: $DMESG_LINES lines in $DMESG_LOG"
else
    echo "✗ Warning: $DMESG_LOG is empty"
fi

echo ""
echo "Output files saved in outputs/"
