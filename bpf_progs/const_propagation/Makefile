# Custom Kfunc Framework Makefile
#
# This Makefile manages custom BPF kfuncs by:
# - Backing up original kernel files before modification
# - Replacing kernel files with custom versions
# - Reverting to original files when needed

# Paths
KERNEL_DIR = ../../linux
BPF_DIR = $(KERNEL_DIR)/kernel/bpf
REPLACEMENT_DIR = replacement
BACKUP_DIR = backup

# Files to manage
KFUNC_FILE = custom_kfuncs.c
MAKEFILE_FILE = Makefile

# Backup file names
BACKUP_MAKEFILE = $(BACKUP_DIR)/Makefile.backup

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
RED = \033[0;31m
NC = \033[0m # No Color

# Assembly analysis
ASM_DIR = assembly_analysis
KFUNC_OBJ = $(BPF_DIR)/custom_kfuncs.o

.PHONY: help status replace revert clean check asm compare-asm

# Default target
help:
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)          Custom BPF Kfunc Framework$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  make status       - Check current state (original or modified)"
	@echo "  make check        - Verify kernel directory exists"
	@echo "  make replace      - Install custom kfuncs into kernel"
	@echo "  make revert       - Restore original kernel files"
	@echo "  make clean        - Remove backup files"
	@echo "  make asm          - Extract assembly from kfunc object file"
	@echo "  make compare-asm  - Compare runtime vs optimized kfunc assembly"
	@echo ""
	@echo "$(YELLOW)Workflow:$(NC)"
	@echo "  1. make check      # Verify kernel directory"
	@echo "  2. make replace    # Install custom kfuncs"
	@echo "  3. cd ../linux && make -j\$$(nproc)  # Build kernel"
	@echo "  4. make revert     # Restore original files when done"
	@echo ""
	@echo "$(YELLOW)Directory structure:$(NC)"
	@echo "  replacement/       - Custom kfunc files to install"
	@echo "  backup/           - Backup of original kernel files"
	@echo "  bpf_progs/        - BPF programs to test kfuncs"
	@echo ""

# Check if kernel directory exists
check:
	@echo "$(BLUE)Checking kernel directory...$(NC)"
	@if [ ! -d "$(KERNEL_DIR)" ]; then \
		echo "$(RED)Error: Kernel directory not found at $(KERNEL_DIR)$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d "$(BPF_DIR)" ]; then \
		echo "$(RED)Error: BPF directory not found at $(BPF_DIR)$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Kernel directory found: $(KERNEL_DIR)$(NC)"
	@echo "$(GREEN)✓ BPF directory found: $(BPF_DIR)$(NC)"

# Check current status
status: check
	@echo ""
	@echo "$(BLUE)Current status:$(NC)"
	@if [ -f "$(BACKUP_MAKEFILE)" ]; then \
		echo "  $(YELLOW)State: Modified (custom kfuncs installed)$(NC)"; \
		echo "  $(YELLOW)Backup exists: $(BACKUP_MAKEFILE)$(NC)"; \
		if [ -f "$(BPF_DIR)/$(KFUNC_FILE)" ]; then \
			echo "  $(GREEN)✓ Custom kfunc file present: $(BPF_DIR)/$(KFUNC_FILE)$(NC)"; \
		else \
			echo "  $(RED)✗ Custom kfunc file missing!$(NC)"; \
		fi; \
	else \
		echo "  $(GREEN)State: Original (clean kernel)$(NC)"; \
		echo "  No backups found"; \
	fi

# Replace kernel files with custom versions
replace: check
	@echo ""
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)Installing custom kfuncs into kernel$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""

	# Check if already replaced
	@if [ -f "$(BACKUP_MAKEFILE)" ]; then \
		echo "$(YELLOW)Warning: Backup already exists. Kernel may already be modified.$(NC)"; \
		echo "$(YELLOW)Run 'make revert' first if you want to re-install.$(NC)"; \
		exit 1; \
	fi

	# Create backup directory
	@mkdir -p $(BACKUP_DIR)
	@echo "$(GREEN)[1/4] Created backup directory$(NC)"

	# Backup original Makefile
	@if [ -f "$(BPF_DIR)/$(MAKEFILE_FILE)" ]; then \
		cp "$(BPF_DIR)/$(MAKEFILE_FILE)" "$(BACKUP_MAKEFILE)"; \
		echo "$(GREEN)[2/4] Backed up original Makefile$(NC)"; \
	else \
		echo "$(RED)Error: Original Makefile not found$(NC)"; \
		exit 1; \
	fi

	# Copy custom kfunc file
	@if [ -f "$(REPLACEMENT_DIR)/$(KFUNC_FILE)" ]; then \
		cp "$(REPLACEMENT_DIR)/$(KFUNC_FILE)" "$(BPF_DIR)/$(KFUNC_FILE)"; \
		echo "$(GREEN)[3/4] Installed custom kfunc file$(NC)"; \
	else \
		echo "$(RED)Error: Custom kfunc file not found$(NC)"; \
		rm -f "$(BACKUP_MAKEFILE)"; \
		exit 1; \
	fi

	# Replace Makefile
	@if [ -f "$(REPLACEMENT_DIR)/$(MAKEFILE_FILE)" ]; then \
		cp "$(REPLACEMENT_DIR)/$(MAKEFILE_FILE)" "$(BPF_DIR)/$(MAKEFILE_FILE)"; \
		echo "$(GREEN)[4/4] Installed custom Makefile$(NC)"; \
	else \
		echo "$(RED)Error: Custom Makefile not found$(NC)"; \
		cp "$(BACKUP_MAKEFILE)" "$(BPF_DIR)/$(MAKEFILE_FILE)"; \
		rm -f "$(BACKUP_MAKEFILE)"; \
		rm -f "$(BPF_DIR)/$(KFUNC_FILE)"; \
		exit 1; \
	fi

	@echo ""
	@echo "$(GREEN)=====================================================================$(NC)"
	@echo "$(GREEN)✓ Custom kfuncs installed successfully!$(NC)"
	@echo "$(GREEN)=====================================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Build the kernel:"
	@echo "     cd $(KERNEL_DIR) && make -j\$$(nproc)"
	@echo ""
	@echo "  2. Install the kernel (if needed)"
	@echo ""
	@echo "  3. Test your BPF programs with the custom kfuncs"
	@echo ""
	@echo "  4. When done, restore original files:"
	@echo "     make revert"
	@echo ""

# Revert to original kernel files
revert: check
	@echo ""
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)Reverting to original kernel files$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""

	# Check if backup exists
	@if [ ! -f "$(BACKUP_MAKEFILE)" ]; then \
		echo "$(YELLOW)No backups found. Kernel is already in original state.$(NC)"; \
		exit 0; \
	fi

	# Restore original Makefile
	@if [ -f "$(BACKUP_MAKEFILE)" ]; then \
		cp "$(BACKUP_MAKEFILE)" "$(BPF_DIR)/$(MAKEFILE_FILE)"; \
		echo "$(GREEN)[1/3] Restored original Makefile$(NC)"; \
	fi

	# Remove custom kfunc file
	@if [ -f "$(BPF_DIR)/$(KFUNC_FILE)" ]; then \
		rm -f "$(BPF_DIR)/$(KFUNC_FILE)"; \
		echo "$(GREEN)[2/3] Removed custom kfunc file$(NC)"; \
	fi

	# Remove backup files
	@rm -f "$(BACKUP_MAKEFILE)"
	@echo "$(GREEN)[3/3] Removed backup files$(NC)"

	@echo ""
	@echo "$(GREEN)=====================================================================$(NC)"
	@echo "$(GREEN)✓ Kernel files restored to original state$(NC)"
	@echo "$(GREEN)=====================================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Note: You may want to rebuild the kernel:$(NC)"
	@echo "  cd $(KERNEL_DIR) && make -j\$$(nproc)"
	@echo ""

# Clean backup files (use with caution!)
clean:
	@echo "$(YELLOW)Warning: This will remove all backup files.$(NC)"
	@echo "$(YELLOW)Make sure you have reverted to original files first.$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf $(BACKUP_DIR); \
		echo "$(GREEN)✓ Backup files removed$(NC)"; \
	else \
		echo "$(BLUE)Cancelled$(NC)"; \
	fi

# Extract assembly from kfunc object file
asm: check
	@echo ""
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)Extracting Assembly from custom_kfuncs.o$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""

	# Check if object file exists
	@if [ ! -f "$(KFUNC_OBJ)" ]; then \
		echo "$(RED)Error: Object file not found: $(KFUNC_OBJ)$(NC)"; \
		echo "$(YELLOW)Build the kernel first:$(NC)"; \
		echo "  cd $(KERNEL_DIR) && make -j\$$(nproc)"; \
		exit 1; \
	fi

	# Create assembly directory
	@mkdir -p $(ASM_DIR)
	@echo "$(GREEN)[1/2] Created assembly directory: $(ASM_DIR)$(NC)"

	# Extract full assembly
	@objdump -d $(KFUNC_OBJ) > $(ASM_DIR)/custom_kfuncs_full.asm
	@echo "$(GREEN)[2/2] Extracted full assembly to $(ASM_DIR)/custom_kfuncs_full.asm$(NC)"

	@echo ""
	@echo "$(GREEN)✓ Assembly extraction complete$(NC)"
	@echo ""
	@echo "$(YELLOW)Next step:$(NC)"
	@echo "  make compare-asm  # Compare runtime vs optimized functions"
	@echo ""