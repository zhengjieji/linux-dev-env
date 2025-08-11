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
VERIFIER_BACKUP="$LINUX_DIR/kernel/bpf/verifier.c.original"

if [ ! -f "$VERIFIER_BACKUP" ]; then
    echo "Error: Original backup not found: $VERIFIER_BACKUP"
    echo "Run 'make verifier-setup' first"
    exit 1
fi

if [ ! -f "$VERIFIER_SRC" ]; then
    echo "Error: BPF verifier source not found: $VERIFIER_SRC"
    exit 1
fi

# Revert to original verifier
cp "$VERIFIER_BACKUP" "$VERIFIER_SRC"

# Verify revert
if diff -q "$VERIFIER_BACKUP" "$VERIFIER_SRC" > /dev/null; then
    echo "✓ Reverted to original verifier"
else
    echo "✗ Revert failed"
    exit 1
fi