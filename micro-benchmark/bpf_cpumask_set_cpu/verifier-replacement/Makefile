# BPF Verifier Replacement Makefile for bpf_cpumask_set_cpu kfunc
# This Makefile manages verifier replacement specific to the bpf_cpumask_set_cpu micro-benchmark

# Check if LINUX_DIR is provided, otherwise use default
ifndef LINUX_DIR
    LINUX_DIR := ../../../linux
endif

# Verifier file paths
VERIFIER_FILE := kernel/bpf/verifier.c
VERIFIER_SRC := $(LINUX_DIR)/$(VERIFIER_FILE)
VERIFIER_BACKUP := $(VERIFIER_SRC).original
VERIFIER_LOCAL := verifier.c
ORIGINAL_LOCAL := original.c
CUSTOM_LOCAL := custom.c

# Default target
.PHONY: help
help:
	@echo "=== BPF Verifier Replacement for bpf_cpumask_set_cpu ==="
	@echo ""
	@echo "Available targets:"
	@echo "  make setup LINUX_DIR=/path/to/linux   - Initial setup: backup and copy original"
	@echo "  make replace LINUX_DIR=/path/to/linux - Replace kernel verifier with custom version"
	@echo "  make revert LINUX_DIR=/path/to/linux  - Revert to original kernel verifier"
	@echo "  make status                           - Show current verifier status"
	@echo "  make diff                             - Show differences between original and custom"
	@echo "  make clean                            - Clean up local files (preserves kernel backup)"
	@echo ""
	@echo "Default LINUX_DIR: $(LINUX_DIR)"
	@echo ""
	@echo "Workflow:"
	@echo "  1. make setup LINUX_DIR=/path/to/linux    (first time only)"
	@echo "  2. Edit $(CUSTOM_LOCAL)"
	@echo "  3. make replace LINUX_DIR=/path/to/linux"
	@echo "  4. Rebuild kernel and test"
	@echo "  5. make revert LINUX_DIR=/path/to/linux   (when done)"

# Setup: Create backup and local copies
.PHONY: setup
setup:
	@echo "=== Setting up verifier replacement for bpf_cpumask_set_cpu ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(VERIFIER_SRC)" ]; then \
		echo "Error: BPF verifier source not found: $(VERIFIER_SRC)"; \
		exit 1; \
	fi
	@# Create backup in Linux directory (only once)
	@if [ ! -f "$(VERIFIER_BACKUP)" ]; then \
		cp "$(VERIFIER_SRC)" "$(VERIFIER_BACKUP)"; \
		echo "✓ Backup created: $(VERIFIER_BACKUP)"; \
	else \
		echo "✓ Backup exists: $(VERIFIER_BACKUP)"; \
	fi
	@# Copy original to local directory
	@cp "$(VERIFIER_BACKUP)" "$(ORIGINAL_LOCAL)"
	@echo "✓ Original copied: $(ORIGINAL_LOCAL)"
	@# Create custom verifier file if it doesn't exist
	@if [ ! -f "$(CUSTOM_LOCAL)" ]; then \
		cp "$(VERIFIER_BACKUP)" "$(CUSTOM_LOCAL)"; \
		echo "✓ Custom template: $(CUSTOM_LOCAL)"; \
		echo ""; \
		echo "NOTE: You can now edit $(CUSTOM_LOCAL) to modify verifier behavior for bpf_cpumask_set_cpu"; \
	else \
		echo "✓ Custom exists: $(CUSTOM_LOCAL)"; \
	fi
	@echo ""
	@echo "Setup complete. Files created:"
	@echo "  - $(ORIGINAL_LOCAL) (original kernel verifier)"
	@echo "  - $(CUSTOM_LOCAL) (your custom verifier)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit $(CUSTOM_LOCAL) to modify verifier"
	@echo "  2. Run 'make replace LINUX_DIR=$(LINUX_DIR)' to apply changes"
	@echo "  3. Rebuild kernel and test"

# Replace kernel verifier with custom version
.PHONY: replace
replace:
	@echo "=== Replacing verifier with custom implementation ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CUSTOM_LOCAL)" ]; then \
		echo "Error: Custom verifier file not found: $(CUSTOM_LOCAL)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(VERIFIER_SRC)" ]; then \
		echo "Error: Kernel verifier source not found: $(VERIFIER_SRC)"; \
		exit 1; \
	fi
	@# Replace verifier file
	@cp "$(CUSTOM_LOCAL)" "$(VERIFIER_SRC)"
	@# Verify replacement
	@if diff -q "$(CUSTOM_LOCAL)" "$(VERIFIER_SRC)" > /dev/null; then \
		echo "✓ Replaced $(VERIFIER_FILE) with custom implementation"; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. cd ../../.. && sudo make vmlinux"; \
		echo "  2. make qemu-run"; \
		echo "  3. Test with bpf_cpumask_set_cpu benchmark"; \
	else \
		echo "✗ Replacement failed"; \
		exit 1; \
	fi

# Revert to original verifier
.PHONY: revert
revert:
	@echo "=== Reverting to original verifier implementation ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(VERIFIER_BACKUP)" ]; then \
		echo "Error: Original backup not found: $(VERIFIER_BACKUP)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(VERIFIER_SRC)" ]; then \
		echo "Error: Kernel verifier source not found: $(VERIFIER_SRC)"; \
		exit 1; \
	fi
	@# Revert to original verifier
	@cp "$(VERIFIER_BACKUP)" "$(VERIFIER_SRC)"
	@# Verify revert
	@if diff -q "$(VERIFIER_BACKUP)" "$(VERIFIER_SRC)" > /dev/null; then \
		echo "✓ Reverted $(VERIFIER_FILE) to original implementation"; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. Rebuild kernel: cd ../../.. && sudo make vmlinux"; \
		echo "  2. Reboot or reload kernel module"; \
	else \
		echo "✗ Revert failed"; \
		exit 1; \
	fi

# Show verifier status
.PHONY: status
status:
	@echo "=== BPF Verifier Status for bpf_cpumask_set_cpu ==="
	@echo ""
	@echo "Linux directory: $(LINUX_DIR)"
	@echo "Verifier file: $(VERIFIER_FILE)"
	@echo ""
	@if [ -f "$(VERIFIER_BACKUP)" ]; then \
		echo "✓ Backup: $(VERIFIER_BACKUP)"; \
	else \
		echo "✗ Backup: Not found (run 'make setup LINUX_DIR=$(LINUX_DIR)')"; \
	fi
	@if [ -f "$(ORIGINAL_LOCAL)" ]; then \
		echo "✓ Original: $(ORIGINAL_LOCAL)"; \
	else \
		echo "✗ Original: Not found (run 'make setup LINUX_DIR=$(LINUX_DIR)')"; \
	fi
	@if [ -f "$(CUSTOM_LOCAL)" ]; then \
		echo "✓ Custom: $(CUSTOM_LOCAL)"; \
		if [ -f "$(VERIFIER_SRC)" ] && diff -q "$(VERIFIER_SRC)" "$(CUSTOM_LOCAL)" > /dev/null 2>&1; then \
			echo "  Status: ACTIVE (kernel using custom verifier)"; \
		elif [ -f "$(VERIFIER_BACKUP)" ] && [ -f "$(VERIFIER_SRC)" ] && diff -q "$(VERIFIER_SRC)" "$(VERIFIER_BACKUP)" > /dev/null 2>&1; then \
			echo "  Status: ORIGINAL (kernel using original verifier)"; \
		elif [ -f "$(VERIFIER_SRC)" ]; then \
			echo "  Status: MODIFIED (kernel has uncommitted changes)"; \
		else \
			echo "  Status: UNKNOWN (kernel source not found)"; \
		fi \
	else \
		echo "✗ Custom: Not found (run 'make setup LINUX_DIR=$(LINUX_DIR)')"; \
	fi

# Show differences between original and custom
.PHONY: diff
diff:
	@if [ -f "$(ORIGINAL_LOCAL)" ] && [ -f "$(CUSTOM_LOCAL)" ]; then \
		echo "=== Differences between original and custom verifier ==="; \
		echo "(Showing first 100 lines of diff)"; \
		diff -u "$(ORIGINAL_LOCAL)" "$(CUSTOM_LOCAL)" | head -100 || true; \
	else \
		echo "Error: Missing files. Run 'make setup LINUX_DIR=$(LINUX_DIR)' first."; \
	fi

# Clean up local files (preserves kernel backup)
.PHONY: clean
clean:
	@rm -f "$(ORIGINAL_LOCAL)" "$(CUSTOM_LOCAL)"
	@echo "✓ Cleaned local verifier files"
	@echo "Note: Kernel backup at $(VERIFIER_BACKUP) preserved"