# BPF Kfunc Replacement Makefile for bpf_wq_start
# This Makefile manages kfunc replacement for kernel files

# Check if LINUX_DIR is provided, otherwise use default
ifndef LINUX_DIR
    LINUX_DIR := ../../../linux
endif

# Configuration from kfunc-config.yaml
CONFIG_FILE := ../kfunc-config.yaml

# Kernel files to replace (only helpers.c for bpf_wq_start)
KFUNC_FILES := kernel/bpf/helpers.c

# Define file-specific variables
HELPERS_SRC := $(LINUX_DIR)/kernel/bpf/helpers.c
HELPERS_BACKUP := $(HELPERS_SRC).original
HELPERS_ORIGINAL := original_helpers.c
HELPERS_CUSTOM := custom_helpers.c

# Default target
.PHONY: help
help:
	@echo "=== BPF Kfunc Replacement for bpf_wq_start ==="
	@echo ""
	@echo "This kfunc requires replacement of kernel files:"
	@echo "  - kernel/bpf/helpers.c (contains bpf_wq_start, bpf_wq_init, bpf_wq_set_callback_impl)"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup LINUX_DIR=/path/to/linux   - Initial setup: backup and copy originals"
	@echo "  make replace LINUX_DIR=/path/to/linux - Replace kernel files with custom versions"
	@echo "  make revert LINUX_DIR=/path/to/linux  - Revert to original kernel files"
	@echo "  make status                           - Show current status"
	@echo "  make diff                             - Show differences between original and custom"
	@echo "  make clean                            - Clean up local files (preserves kernel backups)"
	@echo ""
	@echo "Default LINUX_DIR: $(LINUX_DIR)"
	@echo ""
	@echo "Workflow:"
	@echo "  1. make setup LINUX_DIR=/path/to/linux    (first time only)"
	@echo "  2. Edit custom_helpers.c to modify bpf_wq_start behavior"
	@echo "  3. make replace LINUX_DIR=/path/to/linux"
	@echo "  4. Rebuild kernel and test"
	@echo "  5. make revert LINUX_DIR=/path/to/linux   (when done)"

# Setup: Create backup and local copies
.PHONY: setup
setup:
	@echo "=== Setting up kfunc replacement for bpf_wq_start ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "Error: Kfunc config file not found: $(CONFIG_FILE)"; \
		exit 1; \
	fi
	@# Setup helpers.c
	@echo "Setting up helpers.c..."
	@if [ ! -f "$(HELPERS_SRC)" ]; then \
		echo "Error: Source file not found: $(HELPERS_SRC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(HELPERS_BACKUP)" ]; then \
		cp "$(HELPERS_SRC)" "$(HELPERS_BACKUP)"; \
		echo "  ✓ Backup created: $(HELPERS_BACKUP)"; \
	else \
		echo "  ✓ Backup exists: $(HELPERS_BACKUP)"; \
	fi
	@cp "$(HELPERS_BACKUP)" "$(HELPERS_ORIGINAL)"
	@echo "  ✓ Original copied: $(HELPERS_ORIGINAL)"
	@if [ ! -f "$(HELPERS_CUSTOM)" ]; then \
		cp "$(HELPERS_BACKUP)" "$(HELPERS_CUSTOM)"; \
		echo "  ✓ Custom template: $(HELPERS_CUSTOM)"; \
	else \
		echo "  ✓ Custom exists: $(HELPERS_CUSTOM)"; \
	fi
	@echo ""
	@echo "Setup complete. Files created:"
	@echo "  - $(HELPERS_ORIGINAL) (reference)"
	@echo "  - $(HELPERS_CUSTOM) (edit this file)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit $(HELPERS_CUSTOM) to modify bpf_wq_start implementation"
	@echo "  2. Run 'make replace LINUX_DIR=$(LINUX_DIR)' to apply changes"
	@echo "  3. Rebuild kernel and test"

# Replace kernel files with custom versions
.PHONY: replace
replace:
	@echo "=== Replacing kernel files with custom implementations ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@# Replace helpers.c
	@echo "Replacing helpers.c..."
	@if [ ! -f "$(HELPERS_CUSTOM)" ]; then \
		echo "Error: Custom file not found: $(HELPERS_CUSTOM)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(HELPERS_SRC)" ]; then \
		echo "Error: Kernel source not found: $(HELPERS_SRC)"; \
		exit 1; \
	fi
	@cp "$(HELPERS_CUSTOM)" "$(HELPERS_SRC)"
	@if diff -q "$(HELPERS_CUSTOM)" "$(HELPERS_SRC)" > /dev/null; then \
		echo "  ✓ Replaced kernel/bpf/helpers.c"; \
	else \
		echo "  ✗ Failed to replace helpers.c"; \
		exit 1; \
	fi
	@echo ""
	@echo "Replacement complete!"
	@echo "Next steps:"
	@echo "  1. cd ../../.. && sudo make vmlinux"
	@echo "  2. make qemu-run"
	@echo "  3. Test with bpf_wq_start benchmark"

# Revert to original kernel files
.PHONY: revert
revert:
	@echo "=== Reverting to original kernel implementation ==="
	@if [ ! -d "$(LINUX_DIR)" ]; then \
		echo "Error: Linux kernel directory not found: $(LINUX_DIR)"; \
		exit 1; \
	fi
	@# Revert helpers.c
	@echo "Reverting helpers.c..."
	@if [ ! -f "$(HELPERS_BACKUP)" ]; then \
		echo "Error: Original backup not found: $(HELPERS_BACKUP)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@cp "$(HELPERS_BACKUP)" "$(HELPERS_SRC)"
	@if diff -q "$(HELPERS_BACKUP)" "$(HELPERS_SRC)" > /dev/null; then \
		echo "  ✓ Reverted kernel/bpf/helpers.c"; \
	else \
		echo "  ✗ Failed to revert helpers.c"; \
		exit 1; \
	fi
	@echo ""
	@echo "Revert complete!"
	@echo "Next steps:"
	@echo "  1. Rebuild kernel: cd ../../.. && sudo make vmlinux"
	@echo "  2. Reboot or reload kernel module"

# Show status of all files
.PHONY: status
status:
	@echo "=== BPF Kfunc Status for bpf_wq_start ==="
	@echo ""
	@echo "Linux directory: $(LINUX_DIR)"
	@echo ""
	@echo "helpers.c status:"
	@if [ -f "$(HELPERS_BACKUP)" ]; then \
		echo "  ✓ Backup: $(HELPERS_BACKUP)"; \
	else \
		echo "  ✗ Backup: Not found"; \
	fi
	@if [ -f "$(HELPERS_ORIGINAL)" ]; then \
		echo "  ✓ Original: $(HELPERS_ORIGINAL)"; \
	else \
		echo "  ✗ Original: Not found"; \
	fi
	@if [ -f "$(HELPERS_CUSTOM)" ]; then \
		echo "  ✓ Custom: $(HELPERS_CUSTOM)"; \
		if [ -f "$(HELPERS_SRC)" ] && diff -q "$(HELPERS_SRC)" "$(HELPERS_CUSTOM)" > /dev/null 2>&1; then \
			echo "    Status: ACTIVE (using custom)"; \
		elif [ -f "$(HELPERS_BACKUP)" ] && [ -f "$(HELPERS_SRC)" ] && diff -q "$(HELPERS_SRC)" "$(HELPERS_BACKUP)" > /dev/null 2>&1; then \
			echo "    Status: ORIGINAL"; \
		else \
			echo "    Status: MODIFIED"; \
		fi \
	else \
		echo "  ✗ Custom: Not found"; \
	fi
	@echo ""
	@echo "Config file: $(CONFIG_FILE)"

# Show differences
.PHONY: diff
diff:
	@echo "=== Differences in helpers.c ==="
	@if [ -f "$(HELPERS_ORIGINAL)" ] && [ -f "$(HELPERS_CUSTOM)" ]; then \
		diff -u "$(HELPERS_ORIGINAL)" "$(HELPERS_CUSTOM)" | head -100 || true; \
	else \
		echo "Missing files for comparison"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
	fi

# Clean up local files (preserves kernel backups)
.PHONY: clean
clean:
	@rm -f "$(HELPERS_ORIGINAL)" "$(HELPERS_CUSTOM)"
	@echo "✓ Cleaned local files"
	@echo "Note: Kernel backup preserved at:"
	@echo "  - $(HELPERS_BACKUP)"