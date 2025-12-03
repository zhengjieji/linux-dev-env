#!/bin/bash
# Run all BPF programs sequentially via BPF_PROG_TEST_RUN
#
# This script:
# 1. For each BPF program in bpf_progs/:
#    - Load the program
#    - Run BPF_PROG_TEST_RUN benchmark
#    - Save results with program-specific names
#    - Unload the program
# 2. Generate a summary report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$BASE_DIR"

ITERATIONS=${1:-1}

# Check root permissions
if [ "$(id -u)" -ne 0 ]; then
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
echo "Running All BPF Programs (BPF_PROG_TEST_RUN)"
echo "========================================"
echo "Found ${#BPF_PROGS[@]} BPF program(s)"
echo "Iterations per program: $ITERATIONS"
echo ""

# Create outputs directory
mkdir -p outputs

# Summary file
SUMMARY_FILE="outputs/summary.txt"
> "$SUMMARY_FILE"

echo "=== BPF_PROG_TEST_RUN Benchmark Summary ===" >> "$SUMMARY_FILE"
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

    # Output file for this program
    RESULT_LOG="outputs/${PROG_NAME}_benchmark.log"

    echo "Program: $PROG_NAME" >> "$SUMMARY_FILE"
    echo "----------------------------------------" >> "$SUMMARY_FILE"

    # Step 1: Load program
    echo "[1/3] Loading $PROG_NAME..."
    ./loader "$BPF_PROG" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "✗ Failed to load $PROG_NAME"
        echo "Status: FAILED (load error)" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        continue
    fi

    sleep 0.5

    # Step 2: Run benchmark
    echo "[2/3] Running BPF_PROG_TEST_RUN ($ITERATIONS iterations)..."

    # Extract just the function name (remove test_ prefix if present)
    FUNC_NAME="${PROG_NAME#test_}"

    ./trigger "$ITERATIONS" > "$RESULT_LOG" 2>&1
    TRIGGER_EXIT=$?

    # Step 3: Unload program
    echo "[3/3] Unloading $PROG_NAME..."
    ./scripts/detach.sh > /dev/null 2>&1

    # Analyze results
    if [ $TRIGGER_EXIT -eq 0 ] && [ -s "$RESULT_LOG" ]; then
        # Extract timing info from log
        AVG_NS=$(grep -oP 'Avg per run:\s+\K[\d.]+' "$RESULT_LOG" | tail -1)
        TOTAL_NS=$(grep -oP 'Total duration:\s+\K\d+' "$RESULT_LOG" | tail -1)

        if [ -n "$AVG_NS" ]; then
            echo "✓ Avg execution time: ${AVG_NS} ns"
            echo "Avg per run: ${AVG_NS} ns" >> "$SUMMARY_FILE"
            echo "Total duration: ${TOTAL_NS} ns" >> "$SUMMARY_FILE"
        else
            echo "✓ Benchmark completed (see log for details)"
        fi
        echo "Result file: $RESULT_LOG" >> "$SUMMARY_FILE"
        echo "Status: COMPLETED" >> "$SUMMARY_FILE"
    else
        echo "✗ Benchmark failed or no output"
        echo "Status: FAILED (benchmark error)" >> "$SUMMARY_FILE"
    fi

    echo "" >> "$SUMMARY_FILE"

    # Brief pause between tests
    sleep 1
done

echo ""
echo "========================================"
echo "All Tests Complete"
echo "========================================"
echo ""
echo "Summary saved to: $SUMMARY_FILE"
echo ""
cat "$SUMMARY_FILE"
