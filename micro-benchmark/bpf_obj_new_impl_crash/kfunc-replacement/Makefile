# BPF Kfunc Replacement Makefile for bpf_obj_new_impl
# This Makefile manages kfunc replacement for multiple kernel files

# Check if LINUX_DIR is provided, otherwise use default
ifndef LINUX_DIR
    LINUX_DIR := ../../../linux
endif

# Configuration from kfunc-config.yaml
CONFIG_FILE := ../kfunc-config.yaml

# Multiple kernel files to replace
KFUNC_FILES := kernel/bpf/helpers.c kernel/bpf/memalloc.c

# Define file-specific variables
HELPERS_SRC := $(LINUX_DIR)/kernel/bpf/helpers.c
HELPERS_BACKUP := $(HELPERS_SRC).original
HELPERS_ORIGINAL := original_helpers.c
HELPERS_CUSTOM := custom_helpers.c

MEMALLOC_SRC := $(LINUX_DIR)/kernel/bpf/memalloc.c
MEMALLOC_BACKUP := $(MEMALLOC_SRC).original
MEMALLOC_ORIGINAL := original_memalloc.c
MEMALLOC_CUSTOM := custom_memalloc.c

# Default target
.PHONY: help
help:
	@echo "=== BPF Kfunc Replacement for bpf_obj_new_impl ==="
	@echo ""
	@echo "This kfunc requires replacement of multiple kernel files:"
	@echo "  - kernel/bpf/helpers.c"
	@echo "  - kernel/bpf/memalloc.c"
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
	@echo "  2. Edit custom_helpers.c and custom_memalloc.c"
	@echo "  3. make replace LINUX_DIR=/path/to/linux"
	@echo "  4. Rebuild kernel and test"
	@echo "  5. make revert LINUX_DIR=/path/to/linux   (when done)"

# Setup: Create backup and local copies for all files
.PHONY: setup
setup:
	@echo "=== Setting up kfunc replacement for bpf_obj_new_impl ==="
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
	@# Setup memalloc.c
	@echo "Setting up memalloc.c..."
	@if [ ! -f "$(MEMALLOC_SRC)" ]; then \
		echo "Error: Source file not found: $(MEMALLOC_SRC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(MEMALLOC_BACKUP)" ]; then \
		cp "$(MEMALLOC_SRC)" "$(MEMALLOC_BACKUP)"; \
		echo "  ✓ Backup created: $(MEMALLOC_BACKUP)"; \
	else \
		echo "  ✓ Backup exists: $(MEMALLOC_BACKUP)"; \
	fi
	@cp "$(MEMALLOC_BACKUP)" "$(MEMALLOC_ORIGINAL)"
	@echo "  ✓ Original copied: $(MEMALLOC_ORIGINAL)"
	@if [ ! -f "$(MEMALLOC_CUSTOM)" ]; then \
		cp "$(MEMALLOC_BACKUP)" "$(MEMALLOC_CUSTOM)"; \
		echo "  ✓ Custom template: $(MEMALLOC_CUSTOM)"; \
	else \
		echo "  ✓ Custom exists: $(MEMALLOC_CUSTOM)"; \
	fi
	@echo ""
	@echo "Setup complete. Files created:"
	@echo "  - $(HELPERS_ORIGINAL) / $(HELPERS_CUSTOM)"
	@echo "  - $(MEMALLOC_ORIGINAL) / $(MEMALLOC_CUSTOM)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit $(HELPERS_CUSTOM) and $(MEMALLOC_CUSTOM)"
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
	@# Replace memalloc.c
	@echo "Replacing memalloc.c..."
	@if [ ! -f "$(MEMALLOC_CUSTOM)" ]; then \
		echo "Error: Custom file not found: $(MEMALLOC_CUSTOM)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@if [ ! -f "$(MEMALLOC_SRC)" ]; then \
		echo "Error: Kernel source not found: $(MEMALLOC_SRC)"; \
		exit 1; \
	fi
	@cp "$(MEMALLOC_CUSTOM)" "$(MEMALLOC_SRC)"
	@if diff -q "$(MEMALLOC_CUSTOM)" "$(MEMALLOC_SRC)" > /dev/null; then \
		echo "  ✓ Replaced kernel/bpf/memalloc.c"; \
	else \
		echo "  ✗ Failed to replace memalloc.c"; \
		exit 1; \
	fi
	@echo ""
	@echo "Replacement complete!"
	@echo "Next steps:"
	@echo "  1. cd ../../.. && sudo make vmlinux"
	@echo "  2. make qemu-run"
	@echo "  3. Test with bpf_obj_new_impl benchmark"

# Revert to original kernel files
.PHONY: revert
revert:
	@echo "=== Reverting to original kernel implementations ==="
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
	@# Revert memalloc.c
	@echo "Reverting memalloc.c..."
	@if [ ! -f "$(MEMALLOC_BACKUP)" ]; then \
		echo "Error: Original backup not found: $(MEMALLOC_BACKUP)"; \
		echo "Run 'make setup LINUX_DIR=$(LINUX_DIR)' first"; \
		exit 1; \
	fi
	@cp "$(MEMALLOC_BACKUP)" "$(MEMALLOC_SRC)"
	@if diff -q "$(MEMALLOC_BACKUP)" "$(MEMALLOC_SRC)" > /dev/null; then \
		echo "  ✓ Reverted kernel/bpf/memalloc.c"; \
	else \
		echo "  ✗ Failed to revert memalloc.c"; \
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
	@echo "=== BPF Kfunc Status for bpf_obj_new_impl ==="
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
	@echo "memalloc.c status:"
	@if [ -f "$(MEMALLOC_BACKUP)" ]; then \
		echo "  ✓ Backup: $(MEMALLOC_BACKUP)"; \
	else \
		echo "  ✗ Backup: Not found"; \
	fi
	@if [ -f "$(MEMALLOC_ORIGINAL)" ]; then \
		echo "  ✓ Original: $(MEMALLOC_ORIGINAL)"; \
	else \
		echo "  ✗ Original: Not found"; \
	fi
	@if [ -f "$(MEMALLOC_CUSTOM)" ]; then \
		echo "  ✓ Custom: $(MEMALLOC_CUSTOM)"; \
		if [ -f "$(MEMALLOC_SRC)" ] && diff -q "$(MEMALLOC_SRC)" "$(MEMALLOC_CUSTOM)" > /dev/null 2>&1; then \
			echo "    Status: ACTIVE (using custom)"; \
		elif [ -f "$(MEMALLOC_BACKUP)" ] && [ -f "$(MEMALLOC_SRC)" ] && diff -q "$(MEMALLOC_SRC)" "$(MEMALLOC_BACKUP)" > /dev/null 2>&1; then \
			echo "    Status: ORIGINAL"; \
		else \
			echo "    Status: MODIFIED"; \
		fi \
	else \
		echo "  ✗ Custom: Not found"; \
	fi
	@echo ""
	@echo "Config file: $(CONFIG_FILE)"

# Show differences for all files
.PHONY: diff
diff:
	@echo "=== Differences in helpers.c ==="
	@if [ -f "$(HELPERS_ORIGINAL)" ] && [ -f "$(HELPERS_CUSTOM)" ]; then \
		diff -u "$(HELPERS_ORIGINAL)" "$(HELPERS_CUSTOM)" | head -50 || true; \
	else \
		echo "Missing files for helpers.c comparison"; \
	fi
	@echo ""
	@echo "=== Differences in memalloc.c ==="
	@if [ -f "$(MEMALLOC_ORIGINAL)" ] && [ -f "$(MEMALLOC_CUSTOM)" ]; then \
		diff -u "$(MEMALLOC_ORIGINAL)" "$(MEMALLOC_CUSTOM)" | head -50 || true; \
	else \
		echo "Missing files for memalloc.c comparison"; \
	fi

# Clean up local files (preserves kernel backups)
.PHONY: clean
clean:
	@rm -f "$(HELPERS_ORIGINAL)" "$(HELPERS_CUSTOM)"
	@rm -f "$(MEMALLOC_ORIGINAL)" "$(MEMALLOC_CUSTOM)"
	@echo "✓ Cleaned local files"
	@echo "Note: Kernel backups preserved at:"
	@echo "  - $(HELPERS_BACKUP)"
	@echo "  - $(MEMALLOC_BACKUP)"