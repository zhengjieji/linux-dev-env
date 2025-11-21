# Compiler Optimization Tests Makefile

CC = gcc
CFLAGS = -Wall -Wextra
OPT_LEVELS = O0 O1 O2 O3 Os

# Source files
SOURCES = $(wildcard src/*.c)
BASENAMES = $(basename $(notdir $(SOURCES)))

# Output directories
BUILD_DIR = build
RESULTS_DIR = results
ASM_DIR = $(RESULTS_DIR)/assembly
PERF_DIR = $(RESULTS_DIR)/performance
COMP_DIR = $(RESULTS_DIR)/comparison

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: all clean assembly benchmark compare help setup

# Default target
all: setup compile

# Create necessary directories
setup:
	@echo "$(BLUE)Creating directory structure...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(ASM_DIR)
	@mkdir -p $(PERF_DIR)
	@mkdir -p $(COMP_DIR)
	@mkdir -p scripts
	@echo "$(GREEN)Directory structure created$(NC)"

# Compile all programs with all optimization levels
compile: setup
	@echo "$(BLUE)Compiling all test programs with different optimization levels...$(NC)"
	@for src in $(SOURCES); do \
		base=$$(basename $$src .c); \
		echo "$(YELLOW)Compiling $$base...$(NC)"; \
		for opt in $(OPT_LEVELS); do \
			echo "  -$$opt"; \
			$(CC) $(CFLAGS) -$$opt $$src -o $(BUILD_DIR)/$${base}_$$opt -lrt; \
		done; \
	done
	@echo "$(GREEN)Compilation complete$(NC)"

# Generate assembly output for all programs
assembly: setup compile
	@echo "$(BLUE)Generating assembly output...$(NC)"
	@for src in $(SOURCES); do \
		base=$$(basename $$src .c); \
		echo "$(YELLOW)Disassembling $$base...$(NC)"; \
		for opt in $(OPT_LEVELS); do \
			objdump -d -M intel $(BUILD_DIR)/$${base}_$$opt > $(ASM_DIR)/$${base}_$$opt.asm; \
			objdump -d -M intel -S $(BUILD_DIR)/$${base}_$$opt > $(ASM_DIR)/$${base}_$$opt.annotated.asm; \
		done; \
	done
	@echo "$(GREEN)Assembly generation complete$(NC)"
	@echo "Assembly files saved in $(ASM_DIR)/"

# Run performance benchmarks
benchmark: setup compile
	@echo "$(BLUE)Running performance benchmarks...$(NC)"
	@echo "Test,Optimization,Time(s),Instructions,Cycles,CodeSize(bytes)" > $(PERF_DIR)/benchmark_results.csv
	@for src in $(SOURCES); do \
		base=$$(basename $$src .c); \
		echo "$(YELLOW)Benchmarking $$base...$(NC)"; \
		for opt in $(OPT_LEVELS); do \
			echo "  -$$opt"; \
			size=$$(stat -c%s $(BUILD_DIR)/$${base}_$$opt 2>/dev/null || echo "0"); \
			echo -n "$$base,$$opt," >> $(PERF_DIR)/benchmark_results.csv; \
			$(BUILD_DIR)/$${base}_$$opt | grep "Time:" | awk '{print $$2}' | tr -d '\n' >> $(PERF_DIR)/benchmark_results.csv; \
			echo -n ",,$$size" >> $(PERF_DIR)/benchmark_results.csv; \
			echo "" >> $(PERF_DIR)/benchmark_results.csv; \
		done; \
	done
	@echo "$(GREEN)Benchmarking complete$(NC)"
	@echo "Results saved in $(PERF_DIR)/benchmark_results.csv"

# Generate comparison reports
compare: assembly benchmark
	@echo "$(BLUE)Generating comparison reports...$(NC)"
	@./scripts/analyze_results.sh
	@echo "$(GREEN)Comparison complete$(NC)"
	@echo "Reports saved in $(COMP_DIR)/"

# Run specific test
run-%: compile
	@echo "$(BLUE)Running test: $*$(NC)"
	@for opt in $(OPT_LEVELS); do \
		echo "$(YELLOW)=== Optimization level: $$opt ===$(NC)"; \
		$(BUILD_DIR)/$*_$$opt; \
		echo ""; \
	done

# Compare assembly for specific test
asm-%: assembly
	@echo "$(BLUE)Assembly comparison for: $*$(NC)"
	@for opt in $(OPT_LEVELS); do \
		echo "$(YELLOW)=== Optimization level: $$opt ===$(NC)"; \
		echo "Main function instructions:"; \
		grep -A 20 "<compute" $(ASM_DIR)/$*_$$opt.asm | head -25; \
		echo ""; \
	done

# Quick test - compile and run one test
quick-%:
	@echo "$(BLUE)Quick test: $*$(NC)"
	@$(CC) $(CFLAGS) -O0 src/$*.c -o $(BUILD_DIR)/$*_O0 -lrt
	@$(CC) $(CFLAGS) -O3 src/$*.c -o $(BUILD_DIR)/$*_O3 -lrt
	@echo "$(YELLOW)=== -O0 (No optimization) ===$(NC)"
	@$(BUILD_DIR)/$*_O0
	@echo ""
	@echo "$(YELLOW)=== -O3 (Aggressive optimization) ===$(NC)"
	@$(BUILD_DIR)/$*_O3

# Show test list
list:
	@echo "$(BLUE)Available tests:$(NC)"
	@for src in $(SOURCES); do \
		base=$$(basename $$src .c); \
		desc=$$(grep "Test [0-9]:" $$src | head -1 | cut -d: -f2-); \
		echo "  $(YELLOW)$$base$(NC)$$desc"; \
	done

# Clean build artifacts
clean:
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -rf $(RESULTS_DIR)
	@echo "$(GREEN)Clean complete$(NC)"

# Deep clean - remove everything including scripts
distclean: clean
	@echo "$(BLUE)Deep cleaning...$(NC)"
	rm -rf scripts
	@echo "$(GREEN)Deep clean complete$(NC)"

# Help target
help:
	@echo "$(BLUE)Compiler Optimization Tests - Makefile Help$(NC)"
	@echo ""
	@echo "$(YELLOW)Main targets:$(NC)"
	@echo "  make all        - Compile all tests with all optimization levels"
	@echo "  make assembly   - Generate assembly output for all tests"
	@echo "  make benchmark  - Run performance benchmarks"
	@echo "  make compare    - Generate comparison reports"
	@echo "  make clean      - Remove build artifacts"
	@echo ""
	@echo "$(YELLOW)Specific test targets:$(NC)"
	@echo "  make run-XX     - Run specific test (XX = test name)"
	@echo "  make asm-XX     - Show assembly comparison for test"
	@echo "  make quick-XX   - Quick O0 vs O3 comparison"
	@echo ""
	@echo "$(YELLOW)Utility targets:$(NC)"
	@echo "  make list       - List all available tests"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "$(YELLOW)Example:$(NC)"
	@echo "  make quick-01_const_propagation"
	@echo "  make run-02_loop_unrolling"
	@echo "  make asm-03_branch_elimination"
