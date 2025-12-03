#!/bin/bash
# Run all BPF programs sequentially and collect results
#
# This script:
# 1. For each BPF program in bpf_progs/:
#    - Attach the program
#    - Run trigger
#    - Save outputs with program-specific names
#    - Detach the program
# 2. Generate a summary report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$BASE_DIR"

ITERATIONS=${1:-1}
TRACE_PIPE="/sys/kernel/debug/tracing/trace_pipe"

# Check root permissions
if [ ! -r "$TRACE_PIPE" ]; then
    echo "Error: This script requires root permissions"
    echo "Please run with sudo"
    exit 1
fi

# Check if programs are built
if [ ! -f "./loader" ] || [ ! -f "./trigger" ]; then
    echo "Error: Programs not built. Run 'make' first."
    exit 1
fi

# Find all BPF programs
BPF_PROGS=(bpf_progs/*.kern.o)

if [ ${#BPF_PROGS[@]} -eq 0 ] || [ ! -f "${BPF_PROGS[0]}" ]; then
    echo "Error: No BPF programs found in bpf_progs/"
    echo "Please compile BPF programs first: make"
    exit 1
fi

echo "========================================"
echo "Running All BPF Programs"
echo "========================================"
echo "Found ${#BPF_PROGS[@]} BPF program(s)"
echo "Iterations per program: $ITERATIONS"
echo ""

# Create outputs directory
mkdir -p outputs

# Summary file
SUMMARY_FILE="outputs/summary.txt"
> "$SUMMARY_FILE"

echo "=== BPF Micro-Benchmark Summary ===" >> "$SUMMARY_FILE"
echo "Date: $(date)" >> "$SUMMARY_FILE"
echo "Iterations per program: $ITERATIONS" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Process each BPF program
for BPF_PROG in "${BPF_PROGS[@]}"; do
    PROG_NAME=$(basename "$BPF_PROG" .kern.o)

    echo ""
    echo "========================================"
    echo "Testing: $PROG_NAME"
    echo "========================================"

    # Output files for this program
    TRACE_LOG="outputs/${PROG_NAME}_trace.log"
    DMESG_LOG="outputs/${PROG_NAME}_dmesg.log"

    echo "Program: $PROG_NAME" >> "$SUMMARY_FILE"
    echo "----------------------------------------" >> "$SUMMARY_FILE"

    # Step 1: Attach program
    echo "[1/4] Attaching $PROG_NAME..."
    ./loader "$BPF_PROG" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "✗ Failed to attach $PROG_NAME"
        echo "Status: FAILED (attach error)" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        continue
    fi

    sleep 1

    # Step 2: Clear buffers
    echo "[2/4] Clearing buffers..."
    dmesg -C
    echo > /sys/kernel/debug/tracing/trace

    # Step 3: Start trace capture and run trigger
    echo "[3/4] Running trigger ($ITERATIONS iterations)..."

    timeout 30 cat "$TRACE_PIPE" > "$TRACE_LOG" 2>/dev/null &
    TRACE_PID=$!
    sleep 0.5

    ./trigger "$ITERATIONS" > /dev/null 2>&1

    sleep 3
    kill $TRACE_PID 2>/dev/null || true
    wait $TRACE_PID 2>/dev/null || true

    # Capture dmesg
    dmesg > "$DMESG_LOG"

    # Step 4: Detach program
    echo "[4/4] Detaching $PROG_NAME..."
    ./scripts/detach.sh > /dev/null 2>&1

    # Analyze results
    if [ -s "$TRACE_LOG" ]; then
        TRACE_LINES=$(wc -l < "$TRACE_LOG")
        echo "✓ Captured $TRACE_LINES trace lines"
        echo "Trace lines: $TRACE_LINES" >> "$SUMMARY_FILE"
        echo "Trace file: $TRACE_LOG" >> "$SUMMARY_FILE"
    else
        echo "✗ Warning: No trace output"
        echo "Trace lines: 0 (EMPTY)" >> "$SUMMARY_FILE"
    fi

    if [ -s "$DMESG_LOG" ]; then
        DMESG_LINES=$(wc -l < "$DMESG_LOG")
        echo "✓ Captured $DMESG_LINES dmesg lines"
        echo "Dmesg lines: $DMESG_LINES" >> "$SUMMARY_FILE"
        echo "Dmesg file: $DMESG_LOG" >> "$SUMMARY_FILE"
    else
        echo "Dmesg lines: 0" >> "$SUMMARY_FILE"
    fi

    echo "Status: COMPLETED" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"

    # Wait between tests
    sleep 2
done

echo ""
echo "========================================"
echo "All Tests Complete"
echo "========================================"
echo ""
echo "Summary saved to: $SUMMARY_FILE"
echo ""
cat "$SUMMARY_FILE"
