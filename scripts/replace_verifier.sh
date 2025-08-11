#!/bin/bash

set -e

LINUX_DIR=$1

if [ -z "$LINUX_DIR" ]; then
    echo "Error: Linux kernel directory not specified"
    exit 1
fi

if [ ! -d "$LINUX_DIR" ]; then
    echo "Error: Linux kernel directory not found: $LINUX_DIR"
    exit 1
fi

VERIFIER_SRC="$LINUX_DIR/kernel/bpf/verifier.c"
VERIFIER_DIR="verifiers"
CUSTOM_VERIFIER="$VERIFIER_DIR/custom.c"

if [ ! -f "$CUSTOM_VERIFIER" ]; then
    echo "Error: Custom verifier not found: $CUSTOM_VERIFIER"
    echo "Run 'make verifier-setup' first"
    exit 1
fi

if [ ! -f "$VERIFIER_SRC" ]; then
    echo "Error: BPF verifier source not found: $VERIFIER_SRC"
    exit 1
fi

# Replace verifier
cp "$CUSTOM_VERIFIER" "$VERIFIER_SRC"

# Verify replacement
if diff -q "$CUSTOM_VERIFIER" "$VERIFIER_SRC" > /dev/null; then
    echo "✓ Replaced with custom verifier"
else
    echo "✗ Replacement failed"
    exit 1
fi