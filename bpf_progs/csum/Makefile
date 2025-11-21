# Makefile for managing BPF helper replacements
# This manages the replacement of kernel files with optimized versions

KERNEL_DIR ?= ../../linux
FILTER_PATH = net/core/filter.c
BPF_H_PATH = include/uapi/linux/bpf.h
TOOLS_BPF_H_PATH = tools/include/uapi/linux/bpf.h
BPF_HELPER_DEFS_PATHS = tools/lib/bpf/bpf_helper_defs.h \
                        tools/bpf/bpftool/libbpf/include/bpf/bpf_helper_defs.h \
                        tools/bpf/bpftool/bootstrap/libbpf/include/bpf/bpf_helper_defs.h
BPF_DOC_SCRIPT = scripts/bpf_doc.py

# Assembly analysis paths
ASM_DIR = assembly_analysis
FILTER_OBJ = $(KERNEL_DIR)/net/core/filter.o

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

.PHONY: all init replace revert status diff clean help asm compare-asm

help:
	@echo "BPF Helper Optimization Management"
	@echo "=================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make init         - Initialize: backup original kernel files"
	@echo "  make replace      - Replace kernel files with optimized versions"
	@echo "  make revert       - Revert to original kernel files"
	@echo "  make status       - Check current replacement status"
	@echo "  make diff         - Show differences between original and replacement"
	@echo "  make asm          - Extract assembly from filter.o"
	@echo "  make compare-asm  - Compare original vs optimized helper assembly"
	@echo "  make clean        - Remove all backup files"
	@echo ""
	@echo "Usage:"
	@echo "  1. Run 'make init' first to backup original files"
	@echo "  2. Replacement files are already in replacement/ folder"
	@echo "  3. Run 'make replace' to apply changes to kernel"
	@echo "  4. Build kernel with 'cd ../.. && sudo make vmlinux'"
	@echo "  5. Run 'make asm' or 'make compare-asm' to analyze assembly"
	@echo "  6. Run 'make revert' to restore original files"

all: help

init:
	@echo "$(GREEN)Initializing BPF helper replacement...$(NC)"
	@if [ ! -f "$(KERNEL_DIR)/$(FILTER_PATH)" ]; then \
		echo "$(RED)Error: Kernel source not found at $(KERNEL_DIR)$(NC)"; \
		echo "Set KERNEL_DIR variable or use: make init KERNEL_DIR=/path/to/linux"; \
		exit 1; \
	fi
	@echo "Creating backup directory..."
	@mkdir -p backup
	@echo "Backing up original filter.c..."
	@cp "$(KERNEL_DIR)/$(FILTER_PATH)" backup/filter.c
	@echo "Backing up original bpf.h..."
	@cp "$(KERNEL_DIR)/$(BPF_H_PATH)" backup/bpf.h
	@echo "$(GREEN)Initialization complete!$(NC)"
	@echo ""
	@echo "Next step: Run 'make replace' to apply optimized helpers"

replace:
	@echo "$(YELLOW)Replacing kernel files with optimized versions...$(NC)"
	@if [ ! -f backup/filter.c ] || [ ! -f backup/bpf.h ]; then \
		echo "$(RED)Error: Backup files not found. Run 'make init' first.$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f replacement/filter.c ] || [ ! -f replacement/bpf.h ]; then \
		echo "$(RED)Error: Replacement files not found.$(NC)"; \
		exit 1; \
	fi
	@echo "Replacing filter.c..."
	@cp replacement/filter.c "$(KERNEL_DIR)/$(FILTER_PATH)"
	@echo "Replacing bpf.h..."
	@cp replacement/bpf.h "$(KERNEL_DIR)/$(BPF_H_PATH)"
	@echo "Copying bpf.h to tools directory..."
	@cp replacement/bpf.h "$(KERNEL_DIR)/$(TOOLS_BPF_H_PATH)"
	@echo "Regenerating bpf_helper_defs.h files..."
	@python3 "$(KERNEL_DIR)/$(BPF_DOC_SCRIPT)" --header --filename "$(KERNEL_DIR)/$(BPF_H_PATH)" helpers > /tmp/bpf_helper_defs.h.tmp
	@for path in $(BPF_HELPER_DEFS_PATHS); do \
		echo "  Updating $(KERNEL_DIR)/$$path"; \
		mkdir -p "$$(dirname "$(KERNEL_DIR)/$$path")"; \
		cp /tmp/bpf_helper_defs.h.tmp "$(KERNEL_DIR)/$$path"; \
	done
	@rm /tmp/bpf_helper_defs.h.tmp
	@echo "$(GREEN)Replacement complete!$(NC)"
	@echo ""
	@echo "Next step: Rebuild kernel with 'cd ../.. && sudo make vmlinux'"

revert:
	@echo "$(YELLOW)Reverting to original kernel files...$(NC)"
	@if [ ! -f backup/filter.c ] || [ ! -f backup/bpf.h ]; then \
		echo "$(RED)Error: Backup files not found. Cannot revert.$(NC)"; \
		exit 1; \
	fi
	@echo "Restoring original filter.c..."
	@cp backup/filter.c "$(KERNEL_DIR)/$(FILTER_PATH)"
	@echo "Restoring original bpf.h..."
	@cp backup/bpf.h "$(KERNEL_DIR)/$(BPF_H_PATH)"
	@echo "Restoring original bpf.h in tools..."
	@cp backup/bpf.h "$(KERNEL_DIR)/$(TOOLS_BPF_H_PATH)"
	@echo "Regenerating original bpf_helper_defs.h files..."
	@python3 "$(KERNEL_DIR)/$(BPF_DOC_SCRIPT)" --header --filename "$(KERNEL_DIR)/$(BPF_H_PATH)" helpers > /tmp/bpf_helper_defs.h.tmp
	@for path in $(BPF_HELPER_DEFS_PATHS); do \
		echo "  Updating $(KERNEL_DIR)/$$path"; \
		cp /tmp/bpf_helper_defs.h.tmp "$(KERNEL_DIR)/$$path"; \
	done
	@rm /tmp/bpf_helper_defs.h.tmp
	@echo "$(GREEN)Revert complete!$(NC)"
	@echo ""
	@echo "Next step: Rebuild kernel with 'cd ../.. && sudo make vmlinux'"

status:
	@echo "$(GREEN)BPF Helper Replacement Status$(NC)"
	@echo "=============================="
	@echo ""
	@if [ -f backup/filter.c ] && [ -f backup/bpf.h ]; then \
		echo "✓ Backup files exist"; \
	else \
		echo "✗ Backup files missing (run 'make init')"; \
	fi
	@if [ -f replacement/filter.c ] && [ -f replacement/bpf.h ]; then \
		echo "✓ Replacement files exist"; \
	else \
		echo "✗ Replacement files missing"; \
	fi
	@echo ""
	@echo "Checking if kernel files are modified..."
	@if [ -f backup/filter.c ] && [ -f "$(KERNEL_DIR)/$(FILTER_PATH)" ]; then \
		if diff -q backup/filter.c "$(KERNEL_DIR)/$(FILTER_PATH)" > /dev/null; then \
			echo "  filter.c: $(GREEN)Original$(NC)"; \
		else \
			if [ -f replacement/filter.c ] && diff -q replacement/filter.c "$(KERNEL_DIR)/$(FILTER_PATH)" > /dev/null; then \
				echo "  filter.c: $(YELLOW)Modified (using replacement)$(NC)"; \
			else \
				echo "  filter.c: $(RED)Modified (unknown changes)$(NC)"; \
			fi \
		fi \
	fi
	@if [ -f backup/bpf.h ] && [ -f "$(KERNEL_DIR)/$(BPF_H_PATH)" ]; then \
		if diff -q backup/bpf.h "$(KERNEL_DIR)/$(BPF_H_PATH)" > /dev/null; then \
			echo "  bpf.h: $(GREEN)Original$(NC)"; \
		else \
			if [ -f replacement/bpf.h ] && diff -q replacement/bpf.h "$(KERNEL_DIR)/$(BPF_H_PATH)" > /dev/null; then \
				echo "  bpf.h: $(YELLOW)Modified (using replacement)$(NC)"; \
			else \
				echo "  bpf.h: $(RED)Modified (unknown changes)$(NC)"; \
			fi \
		fi \
	fi

diff:
	@echo "$(GREEN)Showing differences between original and replacement files$(NC)"
	@echo "=========================================================="
	@echo ""
	@if [ -f backup/filter.c ] && [ -f replacement/filter.c ]; then \
		echo "$(YELLOW)Changes in filter.c (showing first 50 lines):$(NC)"; \
		echo "--------------------"; \
		diff -u backup/filter.c replacement/filter.c | grep -E "^(\+\+\+|---|@@|\+[^+]|-[^-])" | head -50 || true; \
		echo ""; \
	fi
	@if [ -f backup/bpf.h ] && [ -f replacement/bpf.h ]; then \
		echo "$(YELLOW)Changes in bpf.h:$(NC)"; \
		echo "----------------"; \
		diff -u backup/bpf.h replacement/bpf.h | grep -E "^(\+\+\+|---|@@|\+[^+]|-[^-])" | head -20 || true; \
	fi

clean:
	@echo "$(RED)Cleaning up backup files...$(NC)"
	@echo "Warning: This will remove all backups!"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf backup; \
		echo "$(GREEN)Cleanup complete!$(NC)"; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Extract assembly from filter.o
asm:
	@echo ""
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)Extracting Assembly from filter.o$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""
	@if [ ! -f "$(FILTER_OBJ)" ]; then \
		echo "$(RED)Error: Object file not found: $(FILTER_OBJ)$(NC)"; \
		echo "$(YELLOW)Build the kernel first:$(NC)"; \
		echo "  cd $(KERNEL_DIR) && make -j$$(nproc)"; \
		exit 1; \
	fi
	@mkdir -p $(ASM_DIR)
	@echo "$(GREEN)[1/4] Created assembly directory: $(ASM_DIR)$(NC)"
	@objdump -d $(FILTER_OBJ) > $(ASM_DIR)/filter_full.asm
	@echo "$(GREEN)[2/4] Extracted full assembly to $(ASM_DIR)/filter_full.asm$(NC)"
	@objdump -d $(FILTER_OBJ) | sed -n '/<bpf_csum_diff>:/,/^$$/p' | head -n -1 > $(ASM_DIR)/bpf_csum_diff_original.asm
	@echo "$(GREEN)[3/4] Extracted bpf_csum_diff to $(ASM_DIR)/bpf_csum_diff_original.asm$(NC)"
	@objdump -d $(FILTER_OBJ) | sed -n '/<bpf_csum_diff_optimized>:/,/^$$/p' | head -n -1 > $(ASM_DIR)/bpf_csum_diff_optimized.asm 2>/dev/null || \
		echo "$(YELLOW)     Note: bpf_csum_diff_optimized not found (have you applied replacement?)$(NC)"
	@if [ -s $(ASM_DIR)/bpf_csum_diff_optimized.asm ]; then \
		echo "$(GREEN)[4/4] Extracted bpf_csum_diff_optimized to $(ASM_DIR)/bpf_csum_diff_optimized.asm$(NC)"; \
	else \
		echo "$(YELLOW)[4/4] bpf_csum_diff_optimized not found in object file$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)✓ Assembly extraction complete$(NC)"
	@echo ""
	@echo "$(YELLOW)Assembly files created:$(NC)"
	@echo "  - $(ASM_DIR)/filter_full.asm (complete filter.o disassembly)"
	@echo "  - $(ASM_DIR)/bpf_csum_diff_original.asm (original helper)"
	@if [ -s $(ASM_DIR)/bpf_csum_diff_optimized.asm ]; then \
		echo "  - $(ASM_DIR)/bpf_csum_diff_optimized.asm (optimized helper)"; \
	fi
	@echo ""
	@echo "$(YELLOW)Next step:$(NC)"
	@echo "  make compare-asm  # Generate comparison report"
	@echo ""

# Compare original vs optimized assembly
compare-asm: asm
	@echo ""
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo "$(BLUE)Comparing bpf_csum_diff vs bpf_csum_diff_optimized$(NC)"
	@echo "$(BLUE)=====================================================================$(NC)"
	@echo ""
	@if [ ! -s $(ASM_DIR)/bpf_csum_diff_optimized.asm ]; then \
		echo "$(RED)Error: Optimized helper assembly not found.$(NC)"; \
		echo "$(YELLOW)Make sure you have:$(NC)"; \
		echo "  1. Applied the replacement (make replace)"; \
		echo "  2. Built the kernel (cd $(KERNEL_DIR) && make -j$$(nproc))"; \
		exit 1; \
	fi
	@echo "$(GREEN)Generating comparison report...$(NC)"
	@echo "# BPF Helper Assembly Comparison" > $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "Comparison between \`bpf_csum_diff\` (original) and \`bpf_csum_diff_optimized\`" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "## Instruction Count" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@ORIG_COUNT=$$(grep -c "^[[:space:]]*[0-9a-f]\+:" $(ASM_DIR)/bpf_csum_diff_original.asm 2>/dev/null || echo "0"); \
	OPT_COUNT=$$(grep -c "^[[:space:]]*[0-9a-f]\+:" $(ASM_DIR)/bpf_csum_diff_optimized.asm 2>/dev/null || echo "0"); \
	echo "- **Original bpf_csum_diff**: $$ORIG_COUNT instructions" >> $(ASM_DIR)/COMPARISON.md; \
	echo "- **Optimized bpf_csum_diff_optimized**: $$OPT_COUNT instructions" >> $(ASM_DIR)/COMPARISON.md; \
	if [ $$ORIG_COUNT -gt 0 ] && [ $$OPT_COUNT -gt 0 ]; then \
		REDUCTION=$$(awk "BEGIN {printf \"%.1f\", (1 - $$OPT_COUNT / $$ORIG_COUNT) * 100}"); \
		if [ $$(echo "$$REDUCTION < 0" | bc -l) -eq 1 ]; then \
			INCREASE=$$(awk "BEGIN {printf \"%.1f\", -$$REDUCTION}"); \
			echo "- **Change**: +$$INCREASE% (increased by $$(( $$OPT_COUNT - $$ORIG_COUNT )) instructions)" >> $(ASM_DIR)/COMPARISON.md; \
		else \
			echo "- **Reduction**: $$REDUCTION% ($$(($$ORIG_COUNT - $$OPT_COUNT)) instructions eliminated)" >> $(ASM_DIR)/COMPARISON.md; \
		fi \
	fi
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "## Original Helper Assembly (\`bpf_csum_diff\`)" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "\`\`\`asm" >> $(ASM_DIR)/COMPARISON.md
	@cat $(ASM_DIR)/bpf_csum_diff_original.asm >> $(ASM_DIR)/COMPARISON.md
	@echo "\`\`\`" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "## Optimized Helper Assembly (\`bpf_csum_diff_optimized\`)" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "\`\`\`asm" >> $(ASM_DIR)/COMPARISON.md
	@cat $(ASM_DIR)/bpf_csum_diff_optimized.asm >> $(ASM_DIR)/COMPARISON.md
	@echo "\`\`\`" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "## Analysis" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "### Optimizations Applied" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "The optimized version includes the following optimization strategies:" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "1. **IP Header Fast Path**: Special handling for 20-byte buffers (common in IP header updates)" >> $(ASM_DIR)/COMPARISON.md
	@echo "2. **Push Operation Optimization**: Streamlined path when only adding data (from=NULL)" >> $(ASM_DIR)/COMPARISON.md
	@echo "3. **Pull Operation Optimization**: Streamlined path when only removing data (to=NULL)" >> $(ASM_DIR)/COMPARISON.md
	@echo "4. **Fixed-Size Optimization**: Special cases for 4, 8, 16-byte operations" >> $(ASM_DIR)/COMPARISON.md
	@echo "5. **Early Returns**: Reduced unnecessary code execution" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "### Expected Performance Impact" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo "- For IP header updates (20 bytes): Fastest execution path" >> $(ASM_DIR)/COMPARISON.md
	@echo "- For push/pull operations: Eliminated unnecessary branching" >> $(ASM_DIR)/COMPARISON.md
	@echo "- For small fixed sizes: Better compiler optimization opportunities" >> $(ASM_DIR)/COMPARISON.md
	@echo "" >> $(ASM_DIR)/COMPARISON.md
	@echo ""
	@echo "$(GREEN)✓ Comparison report generated$(NC)"
	@echo ""
	@echo "$(YELLOW)Report saved to: $(ASM_DIR)/COMPARISON.md$(NC)"
	@echo ""
	@echo "View the report with:"
	@echo "  cat $(ASM_DIR)/COMPARISON.md"
	@echo "  or"
	@echo "  less $(ASM_DIR)/COMPARISON.md"
	@echo ""
