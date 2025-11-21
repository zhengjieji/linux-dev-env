#!/bin/bash
# Helper script to view side-by-side assembly comparison

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_name>"
    echo "Example: $0 01_const_propagation"
    exit 1
fi

TEST=$1
ASM_DIR="../results/assembly"

if command -v diff &> /dev/null; then
    echo "=== O0 vs O3 Diff ==="
    diff -y --suppress-common-lines \
        <(grep -A 50 "<compute" "$ASM_DIR/${TEST}_O0.asm") \
        <(grep -A 50 "<compute" "$ASM_DIR/${TEST}_O3.asm") \
        2>/dev/null | head -50
else
    echo "O0 version:"
    grep -A 30 "<compute" "$ASM_DIR/${TEST}_O0.asm"
    echo ""
    echo "O3 version:"
    grep -A 30 "<compute" "$ASM_DIR/${TEST}_O3.asm"
fi
