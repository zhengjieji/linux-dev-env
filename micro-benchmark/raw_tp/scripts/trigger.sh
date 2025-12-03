#!/bin/bash
# Run BPF_PROG_TEST_RUN benchmark for raw_tp programs
#
# Usage: ./trigger.sh [iterations] [prog_name]
#
# This script runs pinned BPF programs via BPF_PROG_TEST_RUN and captures
# timing results. Unlike other benchmarks, this does NOT trigger actual
# tracepoints - it directly executes the BPF program.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$BASE_DIR"

ITERATIONS=${1:-1}
PROG_NAME=${2:-}
RESULT_LOG="outputs/benchmark.log"

# Check if trigger exists
if [ ! -f "./trigger" ]; then
    echo "Error: trigger not found. Run 'make' first."
    exit 1
fi

# Check root permissions (needed for BPF syscalls)
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script requires root permissions"
    echo "Please run with sudo"
    exit 1
fi

echo "========================================"
echo "BPF_PROG_TEST_RUN Benchmark"
echo "========================================"
echo "Iterations: $ITERATIONS"
if [ -n "$PROG_NAME" ]; then
    echo "Program: $PROG_NAME"
else
    echo "Programs: all pinned"
fi
echo "Result log: $RESULT_LOG"
echo ""

# Create outputs directory
mkdir -p outputs

# Run trigger and capture output
if [ -n "$PROG_NAME" ]; then
    ./trigger "$ITERATIONS" "$PROG_NAME" 2>&1 | tee "$RESULT_LOG"
else
    ./trigger "$ITERATIONS" 2>&1 | tee "$RESULT_LOG"
fi

echo ""
echo "========================================"
echo "Benchmark Complete"
echo "========================================"
echo "Results saved to: $RESULT_LOG"
