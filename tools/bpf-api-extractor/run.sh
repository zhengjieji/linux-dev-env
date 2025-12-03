#!/bin/bash
#
# BPF API Extractor - Extract helper and kfunc definitions from Linux kernel
#
# Usage:
#   ./run.sh [--linux-dir <path>] [--vmlinux <path>] [--helpers-only] [--kfuncs-only]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Default paths (relative to script directory)
# Project structure: tools/bpf-api-extractor/ -> linux is at ../../linux
LINUX_DIR="${SCRIPT_DIR}/../../linux"
VMLINUX="${SCRIPT_DIR}/vmlinux"

# Parse arguments
EXTRACT_HELPERS=1
EXTRACT_KFUNCS=1

while [[ $# -gt 0 ]]; do
    case $1 in
        --linux-dir)
            LINUX_DIR="$2"
            shift 2
            ;;
        --vmlinux)
            VMLINUX="$2"
            shift 2
            ;;
        --helpers-only)
            EXTRACT_KFUNCS=0
            shift
            ;;
        --kfuncs-only)
            EXTRACT_HELPERS=0
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --linux-dir <path>   Path to Linux source directory (default: ../../linux)"
            echo "  --vmlinux <path>     Path to vmlinux with BTF (default: ./vmlinux)"
            echo "  --output-dir <path>  Output directory (default: ./output)"
            echo "  --helpers-only       Only extract helpers"
            echo "  --kfuncs-only        Only extract kfuncs"
            echo "  -h, --help           Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate Linux directory
if [[ ! -d "$LINUX_DIR" ]]; then
    echo "Error: Linux directory not found: $LINUX_DIR"
    echo "Please specify --linux-dir or ensure ../../linux exists"
    exit 1
fi

# Check for bpf.h
if [[ ! -f "$LINUX_DIR/include/uapi/linux/bpf.h" ]]; then
    echo "Error: $LINUX_DIR does not appear to be a Linux source tree"
    echo "Missing: include/uapi/linux/bpf.h"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "================================"
echo "BPF API Extractor"
echo "================================"
echo "Linux directory: $LINUX_DIR"
echo "vmlinux: $VMLINUX"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Extract helpers
if [[ $EXTRACT_HELPERS -eq 1 ]]; then
    echo ">>> Extracting BPF helpers..."
    python3 "${SCRIPT_DIR}/extract_helpers.py" \
        --linux-dir "$LINUX_DIR" \
        --output "$OUTPUT_DIR/helpers.csv"
    echo ""
fi

# Extract kfuncs
if [[ $EXTRACT_KFUNCS -eq 1 ]]; then
    echo ">>> Extracting BPF kfuncs..."
    
    KFUNC_ARGS=(--linux-dir "$LINUX_DIR" --output "$OUTPUT_DIR/kfuncs.csv")
    
    if [[ -f "$VMLINUX" ]]; then
        KFUNC_ARGS+=(--vmlinux "$VMLINUX")
    else
        echo "Warning: vmlinux not found, extracting kfuncs from source only"
        echo "         (signatures will be missing)"
    fi
    
    python3 "${SCRIPT_DIR}/extract_kfuncs.py" "${KFUNC_ARGS[@]}"
    echo ""
fi

echo "================================"
echo "Done! Output files:"
[[ $EXTRACT_HELPERS -eq 1 ]] && echo "  - $OUTPUT_DIR/helpers.csv"
[[ $EXTRACT_KFUNCS -eq 1 ]] && echo "  - $OUTPUT_DIR/kfuncs.csv"
echo "================================"