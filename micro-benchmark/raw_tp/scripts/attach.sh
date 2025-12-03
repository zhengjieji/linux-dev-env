#!/bin/bash
# Load BPF programs for raw_tp micro-benchmark
#
# NOTE: For raw_tp, programs are loaded and pinned but NOT attached to
# any tracepoint. They are executed via BPF_PROG_TEST_RUN in trigger.
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
echo "Loading BPF Programs (raw_tp)"
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
    echo "✓ Successfully loaded BPF programs"
    echo ""
    echo "Next steps:"
    echo "  - Run benchmark: ./scripts/trigger.sh [iterations]"
    echo "  - Unload when done: ./scripts/detach.sh"
else
    echo ""
    echo "✗ Failed to load BPF programs"
    exit $EXIT_CODE
fi
