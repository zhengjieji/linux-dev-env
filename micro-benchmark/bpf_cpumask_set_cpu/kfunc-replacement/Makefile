# BPF Kfunc Replacement Makefile for bpf_cpumask_set_cpu
# This Makefile manages kfunc replacement specific to the bpf_cpumask_set_cpu micro-benchmark

# Check if LINUX_DIR is provided, otherwise use default
ifndef LINUX_DIR
    LINUX_DIR := ../../../linux
endif

# Configuration from kfunc-config.yaml
CONFIG_FILE := ../kfunc-config.yaml
KFUNC_FILE := kernel/bpf/cpumask.c
KFUNC_SRC := $(LINUX_DIR)/$(KFUNC_FILE)
KFUNC_BACKUP := $(KFUNC_SRC).original
KFUNC_LOCAL := cpumask.c
ORIGINAL_LOCAL := original_$(KFUNC_LOCAL)
CUSTOM_LOCAL := custom_$(KFUNC_LOCAL)

# Default target
.PHONY: help
help:
	@echo "=== BPF Kfunc Replacement for bpf_cpumask_set_cpu ==="
	@echo ""
	@echo "Available targets:"
	@echo "  make setup LINUX_DIR=/path/to/linux   - Initial setup: backup and copy original"
	@echo "  make replace LINUX_DIR=/path/to/linux - Replace kernel kfunc with custom version"
	@echo "  make revert LINUX_DIR=/path/to/linux  - Revert to original kernel kfunc"
	@echo "  make status                           - Show current kfunc status"
	@echo "  make diff                             - Show differences between original and custom"
	@echo "  make clean                            - Clean up local files (preserves kernel backup)"
	@echo ""
	@echo "Default LINUX_DIR: $(LINUX_DIR)"
	@echo ""
	@echo "Workflow:"
	@echo "  1. make setup LINUX_DIR=/path/to/linux    (first time only)"
	@echo "  2. Edit custom_$(KFUNC_LOCAL)"
	@echo "  3. make replace LINUX_DIR=/path/to/linux"
	@echo "  4. Rebuild kernel and test"
	@echo "  5. make revert LINUX_DIR=/path/to/linux   (when done)"

# Setup: Create backup and local copies
.PHONY: setup
setup:
	@echo "=== Setting up kfunc replacement for bpf_cpumask_set_cpu ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "Error: Kfunc config file not found: $(CONFIG_FILE)"; \
		exit 1; \
	fi
	@if [ ! -f "$(KFUNC_SRC)" ]; then \
		echo "Error: Kfunc source file not found: $(KFUNC_SRC)"; \
		exit 1; \
	fi
	@# Create backup in Linux directory (only once)
	@if [ ! -f "$(KFUNC_BACKUP)" ]; then \
		cp "$(KFUNC_SRC)" "$(KFUNC_BACKUP)"; \
		echo "✓ Backup created: $(KFUNC_BACKUP)"; \
	else \
		echo "✓ Backup exists: $(KFUNC_BACKUP)"; \
	fi
	@# Copy original to local directory
	@cp "$(KFUNC_BACKUP)" "$(ORIGINAL_LOCAL)"
	@echo "✓ Original copied: $(ORIGINAL_LOCAL)"
	@# Create custom kfunc file if it doesn't exist
	@if [ ! -f "$(CUSTOM_LOCAL)" ]; then \
		cp "$(KFUNC_BACKUP)" "$(CUSTOM_LOCAL)"; \
		echo "✓ Custom template: $(CUSTOM_LOCAL)"; \
		echo ""; \
		echo "NOTE: You can now edit $(CUSTOM_LOCAL) to modify the bpf_cpumask_set_cpu implementation"; \
	else \
		echo "✓ Custom exists: $(CUSTOM_LOCAL)"; \
	fi
	@echo ""
	@echo "Setup complete. Files created:"
	@echo "  - $(ORIGINAL_LOCAL) (original kernel implementation)"
	@echo "  - $(CUSTOM_LOCAL) (your custom implementation)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit $(CUSTOM_LOCAL) to modify the kfunc"
	@echo "  2. Run 'make replace LINUX_DIR=$(LINUX_DIR)' to apply changes"
	@echo "  3. Rebuild kernel and test"

# Replace kernel kfunc with custom version
.PHONY: replace
replace:
	@echo "=== Replacing kfunc with custom implementation ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CUSTOM_LOCAL)" ]; then \
		echo "Error: Custom kfunc file not found: $(CUSTOM_LOCAL)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(KFUNC_SRC)" ]; then \
		echo "Error: Kernel kfunc source not found: $(KFUNC_SRC)"; \
		exit 1; \
	fi
	@# Replace kfunc file
	@cp "$(CUSTOM_LOCAL)" "$(KFUNC_SRC)"
	@# Verify replacement
	@if diff -q "$(CUSTOM_LOCAL)" "$(KFUNC_SRC)" > /dev/null; then \
		echo "✓ Replaced $(KFUNC_FILE) with custom implementation"; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. cd ../../.. && sudo make vmlinux"; \
		echo "  2. make qemu-run"; \
		echo "  3. Test with bpf_cpumask_set_cpu benchmark"; \
	else \
		echo "✗ Replacement failed"; \
		exit 1; \
	fi

# Revert to original kfunc
.PHONY: revert
revert:
	@echo "=== Reverting to original kfunc implementation ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(KFUNC_BACKUP)" ]; then \
		echo "Error: Original backup not found: $(KFUNC_BACKUP)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(KFUNC_SRC)" ]; then \
		echo "Error: Kernel kfunc source not found: $(KFUNC_SRC)"; \
		exit 1; \
	fi
	@# Revert to original kfunc
	@cp "$(KFUNC_BACKUP)" "$(KFUNC_SRC)"
	@# Verify revert
	@if diff -q "$(KFUNC_BACKUP)" "$(KFUNC_SRC)" > /dev/null; then \
		echo "✓ Reverted $(KFUNC_FILE) to original implementation"; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. Rebuild kernel: cd ../../.. && sudo make vmlinux"; \
		echo "  2. Reboot or reload kernel module"; \
	else \
		echo "✗ Revert failed"; \
		exit 1; \
	fi

# Show kfunc status
.PHONY: status
status:
	@echo "=== BPF Kfunc Status for bpf_cpumask_set_cpu ==="
	@echo ""
	@echo "Linux directory: $(LINUX_DIR)"
	@echo "Kfunc file: $(KFUNC_FILE)"
	@echo ""
	@if [ -f "$(KFUNC_BACKUP)" ]; then \
		echo "✓ Backup: $(KFUNC_BACKUP)"; \
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
		if [ -f "$(KFUNC_SRC)" ] && diff -q "$(KFUNC_SRC)" "$(CUSTOM_LOCAL)" > /dev/null 2>&1; then \
			echo "  Status: ACTIVE (kernel using custom kfunc)"; \
		elif [ -f "$(KFUNC_BACKUP)" ] && [ -f "$(KFUNC_SRC)" ] && diff -q "$(KFUNC_SRC)" "$(KFUNC_BACKUP)" > /dev/null 2>&1; then \
			echo "  Status: ORIGINAL (kernel using original kfunc)"; \
		elif [ -f "$(KFUNC_SRC)" ]; then \
			echo "  Status: MODIFIED (kernel has uncommitted changes)"; \
		else \
			echo "  Status: UNKNOWN (kernel source not found)"; \
		fi \
	else \
		echo "✗ Custom: Not found (run 'make setup LINUX_DIR=$(LINUX_DIR)')"; \
	fi
	@echo ""
	@echo "Config file: $(CONFIG_FILE)"

# Show differences between original and custom
.PHONY: diff
diff:
	@if [ -f "$(ORIGINAL_LOCAL)" ] && [ -f "$(CUSTOM_LOCAL)" ]; then \
		echo "=== Differences between original and custom kfunc ==="; \
		diff -u "$(ORIGINAL_LOCAL)" "$(CUSTOM_LOCAL)" || true; \
	else \
		echo "Error: Missing files. Run 'make setup LINUX_DIR=$(LINUX_DIR)' first."; \
	fi

# Clean up local files (preserves kernel backup)
.PHONY: clean
clean:
	@rm -f "$(ORIGINAL_LOCAL)" "$(CUSTOM_LOCAL)"
	@echo "✓ Cleaned local kfunc files"
	@echo "Note: Kernel backup at $(KFUNC_BACKUP) preserved"