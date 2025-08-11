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
VERIFIER_DIR="verifiers"

if [ ! -f "$VERIFIER_SRC" ]; then
    echo "Error: BPF verifier source not found: $VERIFIER_SRC"
    exit 1
fi

# Create verifiers directory if it doesn't exist
mkdir -p "$VERIFIER_DIR"

# Create backup in Linux directory (only once)
if [ ! -f "$VERIFIER_BACKUP" ]; then
    cp "$VERIFIER_SRC" "$VERIFIER_BACKUP"
    echo "✓ Backup created: $VERIFIER_BACKUP"
else
    echo "✓ Backup exists: $VERIFIER_BACKUP"
fi

# Copy original to verifiers directory
cp "$VERIFIER_BACKUP" "$VERIFIER_DIR/original.c"
echo "✓ Original copied: $VERIFIER_DIR/original.c"

# Create custom verifier template if it doesn't exist
if [ ! -f "$VERIFIER_DIR/custom.c" ]; then
    cp "$VERIFIER_BACKUP" "$VERIFIER_DIR/custom.c"
    echo "✓ Custom template: $VERIFIER_DIR/custom.c"
else
    echo "✓ Custom exists: $VERIFIER_DIR/custom.c"
fi

echo ""
echo "Ready. Edit $VERIFIER_DIR/custom.c for your modifications."