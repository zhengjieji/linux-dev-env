#!/bin/bash
# Attach BPF programs for tp_btf/task_newtask micro-benchmark
#
# Usage:
#   ./attach.sh                           # Load all programs (default)
#   ./attach.sh <prog1.o> [prog2.o] ...   # Load specific programs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$BASE_DIR"

# Check if loader exists
if [ ! -f "./loader" ]; then
    echo "Error: loader not found. Run 'make' first."
    exit 1
fi

echo "========================================"
echo "Attaching BPF Programs"
echo "========================================"

# Default to --all if no arguments provided
if [ $# -eq 0 ]; then
    echo "No programs specified, loading all programs..."
    ./loader --all
else
    # Load specific programs
    ./loader "$@"
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✓ Successfully attached BPF programs"
    echo ""
    echo "Next steps:"
    echo "  - Run trigger: ./scripts/trigger.sh [iterations]"
    echo "  - Monitor output: sudo cat /sys/kernel/debug/tracing/trace_pipe"
    echo "  - Detach when done: ./scripts/detach.sh"
else
    echo ""
    echo "✗ Failed to attach BPF programs"
    exit $EXIT_CODE
fi
