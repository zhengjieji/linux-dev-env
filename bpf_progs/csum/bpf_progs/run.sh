#!/bin/bash
# Run separate tests for original and optimized helpers

set -e

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

INTERFACE="lo"
ITERATIONS=2000

echo "=========================================="
echo "=== BPF Helper Performance Comparison ==="
echo "=========================================="
echo

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    pkill -f "./loader" 2>/dev/null || true
}
trap cleanup EXIT

# Build
echo "[1/5] Building..."
make clean 2>/dev/null || true
make

echo
echo "=========================================="
echo "=== TEST 1: ORIGINAL bpf_csum_diff ==="
echo "=========================================="
echo

# Setup tracing for original
echo "[2/5] Setting up tracing for ORIGINAL..."
# Increase trace buffer size to handle burst of packets
echo 16384 > /sys/kernel/debug/tracing/buffer_size_kb
echo 1 > /sys/kernel/debug/tracing/tracing_on
echo > /sys/kernel/debug/tracing/trace
dmesg -C

# Load ORIGINAL BPF program
echo "[3/5] Loading ORIGINAL BPF program..."
./loader bpf_prog.o $INTERFACE &
LOADER_PID=$!
sleep 2

# Run triggers
echo "[4/5] Sending $ITERATIONS packets..."
./trigger $ITERATIONS

# Wait for all printk output to be flushed to trace buffer
echo "[5/5] Waiting for trace buffer to flush..."
sleep 3

# Capture trace buffer (read from 'trace' file, not 'trace_pipe')
echo "Capturing trace buffer..."
cat /sys/kernel/debug/tracing/trace > trace_original.txt

# Cleanup
kill $LOADER_PID 2>/dev/null || true
wait $LOADER_PID 2>/dev/null || true

# Capture dmesg for original
dmesg > dmesg_original.txt

echo
echo "Original test complete!"
echo "Waiting 3 seconds before optimized test..."
sleep 3

echo
echo "==========================================="
echo "=== TEST 2: OPTIMIZED bpf_csum_diff_optimized ==="
echo "==========================================="
echo

# Setup tracing for optimized
echo "[2/5] Setting up tracing for OPTIMIZED..."
# Increase trace buffer size to handle burst of packets
echo 16384 > /sys/kernel/debug/tracing/buffer_size_kb
echo 1 > /sys/kernel/debug/tracing/tracing_on
echo > /sys/kernel/debug/tracing/trace
dmesg -C

# Load OPTIMIZED BPF program
echo "[3/5] Loading OPTIMIZED BPF program..."
./loader bpf_prog_optimized.o $INTERFACE &
LOADER_PID=$!
sleep 2

# Run triggers
echo "[4/5] Sending $ITERATIONS packets..."
./trigger $ITERATIONS

# Wait for all printk output to be flushed to trace buffer
echo "[5/5] Waiting for trace buffer to flush..."
sleep 3

# Capture trace buffer (read from 'trace' file, not 'trace_pipe')
echo "Capturing trace buffer..."
cat /sys/kernel/debug/tracing/trace > trace_optimized.txt

# Cleanup
kill $LOADER_PID 2>/dev/null || true
wait $LOADER_PID 2>/dev/null || true

# Capture dmesg for optimized
dmesg > dmesg_optimized.txt

echo
echo "=========================================="
echo "=== TESTS COMPLETE ==="
echo "=========================================="
echo
echo "Output files created:"
echo "  - trace_original.txt    (ORIGINAL helper trace)"
echo "  - trace_optimized.txt   (OPTIMIZED helper trace)"
echo "  - dmesg_original.txt    (ORIGINAL kernel messages)"
echo "  - dmesg_optimized.txt   (OPTIMIZED kernel messages)"
echo

# Check files
if [ -s "trace_original.txt" ]; then
    ORIG_LINES=$(wc -l < trace_original.txt)
    echo "✓ trace_original.txt: $ORIG_LINES lines"
else
    echo "✗ trace_original.txt is empty"
fi

if [ -s "trace_optimized.txt" ]; then
    OPT_LINES=$(wc -l < trace_optimized.txt)
    echo "✓ trace_optimized.txt: $OPT_LINES lines"
else
    echo "✗ trace_optimized.txt is empty"
fi

echo
echo "Next step: Run ./analyze_speedup.sh to compare results"
