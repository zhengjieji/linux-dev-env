#!/bin/bash

# Automation script for compiler optimization tests
# This script compiles, runs, and analyzes all test programs

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
RESULTS_DIR="$PROJECT_DIR/results"
ASM_DIR="$RESULTS_DIR/assembly"
PERF_DIR="$RESULTS_DIR/performance"
COMP_DIR="$RESULTS_DIR/comparison"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Compiler Optimization Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Setup
echo -e "${YELLOW}[1/6] Setting up directories...${NC}"
cd "$PROJECT_DIR"
make setup
echo -e "${GREEN}✓ Setup complete${NC}"
echo ""

# Step 2: Compile
echo -e "${YELLOW}[2/6] Compiling all tests...${NC}"
make compile
echo -e "${GREEN}✓ Compilation complete${NC}"
echo ""

# Step 3: Generate assembly
echo -e "${YELLOW}[3/6] Generating assembly output...${NC}"
make assembly
echo -e "${GREEN}✓ Assembly generation complete${NC}"
echo ""

# Step 4: Run benchmarks
echo -e "${YELLOW}[4/6] Running performance benchmarks...${NC}"
echo -e "${BLUE}This may take a few minutes...${NC}"
make benchmark
echo -e "${GREEN}✓ Benchmarking complete${NC}"
echo ""

# Step 5: Analyze assembly
echo -e "${YELLOW}[5/6] Analyzing assembly code...${NC}"

# Create assembly analysis report
ANALYSIS_FILE="$COMP_DIR/assembly_analysis.txt"
echo "Compiler Optimization Tests - Assembly Analysis" > "$ANALYSIS_FILE"
echo "Generated: $(date)" >> "$ANALYSIS_FILE"
echo "========================================" >> "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"

for test_src in "$PROJECT_DIR/src"/*.c; do
    test_name=$(basename "$test_src" .c)
    echo "Test: $test_name" >> "$ANALYSIS_FILE"
    echo "----------------------------------------" >> "$ANALYSIS_FILE"

    for opt in O0 O1 O2 O3 Os; do
        asm_file="$ASM_DIR/${test_name}_${opt}.asm"
        if [ -f "$asm_file" ]; then
            # Count instructions in main compute function
            instr_count=$(grep -A 100 "<compute" "$asm_file" | grep ":" | grep -v "^[0-9a-f]*:" | wc -l)
            # Get file size
            bin_size=$(stat -c%s "$BUILD_DIR/${test_name}_${opt}" 2>/dev/null || echo "0")

            echo "  -$opt: $instr_count instructions, $bin_size bytes" >> "$ANALYSIS_FILE"
        fi
    done
    echo "" >> "$ANALYSIS_FILE"
done

echo -e "${GREEN}✓ Assembly analysis complete${NC}"
echo ""

# Step 6: Generate summary report
echo -e "${YELLOW}[6/6] Generating summary report...${NC}"

SUMMARY_FILE="$RESULTS_DIR/summary_report.txt"
cat > "$SUMMARY_FILE" << 'EOF'
====================================================================
            COMPILER OPTIMIZATION TESTS - SUMMARY REPORT
====================================================================

This report summarizes the results of compiler optimization tests
across different optimization levels (O0, O1, O2, O3, Os).

--------------------------------------------------------------------
TEST DESCRIPTIONS
--------------------------------------------------------------------

1. Constant Propagation (01_const_propagation)
   - Tests compile-time evaluation of constant expressions
   - Expected: Runtime calculations eliminated at O2+

2. Loop Unrolling (02_loop_unrolling)
   - Tests unrolling of small fixed-size loops
   - Expected: Loop overhead eliminated at O2+

3. Branch Elimination (03_branch_elimination)
   - Tests elimination of compile-time known branches
   - Expected: Branch instructions removed at O2+

4. Dead Code Elimination (04_dead_code_elimination)
   - Tests removal of unused code and variables
   - Expected: Unused code eliminated at O1+

5. Strength Reduction (05_strength_reduction)
   - Tests replacement of expensive ops with cheaper ones
   - Expected: Multiplies→shifts at O1+

6. Common Subexpression Elimination (06_cse)
   - Tests elimination of redundant calculations
   - Expected: Duplicate computations removed at O2+

7. Function Inlining (07_function_inlining)
   - Tests inlining of small functions
   - Expected: Call overhead eliminated at O2+

--------------------------------------------------------------------
PERFORMANCE RESULTS
--------------------------------------------------------------------

EOF

# Append CSV data formatted as table
if [ -f "$PERF_DIR/benchmark_results.csv" ]; then
    echo "" >> "$SUMMARY_FILE"
    column -t -s',' "$PERF_DIR/benchmark_results.csv" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "--------------------------------------------------------------------" >> "$SUMMARY_FILE"
echo "ASSEMBLY ANALYSIS" >> "$SUMMARY_FILE"
echo "--------------------------------------------------------------------" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

if [ -f "$ANALYSIS_FILE" ]; then
    cat "$ANALYSIS_FILE" >> "$SUMMARY_FILE"
fi

echo "" >> "$SUMMARY_FILE"
echo "--------------------------------------------------------------------" >> "$SUMMARY_FILE"
echo "KEY OBSERVATIONS" >> "$SUMMARY_FILE"
echo "--------------------------------------------------------------------" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "1. O0 (No optimization):" >> "$SUMMARY_FILE"
echo "   - Baseline for comparison" >> "$SUMMARY_FILE"
echo "   - Largest code size" >> "$SUMMARY_FILE"
echo "   - Slowest execution" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "2. O1 (Basic optimizations):" >> "$SUMMARY_FILE"
echo "   - Dead code elimination" >> "$SUMMARY_FILE"
echo "   - Simple strength reduction" >> "$SUMMARY_FILE"
echo "   - Moderate improvements" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "3. O2 (Recommended):" >> "$SUMMARY_FILE"
echo "   - All O1 plus:" >> "$SUMMARY_FILE"
echo "   - Loop unrolling" >> "$SUMMARY_FILE"
echo "   - Function inlining" >> "$SUMMARY_FILE"
echo "   - CSE and constant propagation" >> "$SUMMARY_FILE"
echo "   - Best balance of speed and size" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "4. O3 (Aggressive):" >> "$SUMMARY_FILE"
echo "   - All O2 plus more aggressive optimizations" >> "$SUMMARY_FILE"
echo "   - May increase code size" >> "$SUMMARY_FILE"
echo "   - Diminishing returns in some cases" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "5. Os (Size optimization):" >> "$SUMMARY_FILE"
echo "   - Optimizes for smallest code size" >> "$SUMMARY_FILE"
echo "   - Disables optimizations that increase size" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "====================================================================" >> "$SUMMARY_FILE"

echo -e "${GREEN}✓ Summary report generated${NC}"
echo ""

# Display summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RESULTS SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Results directory: ${YELLOW}$RESULTS_DIR${NC}"
echo ""
echo -e "Generated files:"
echo -e "  📊 Performance data:  ${YELLOW}$PERF_DIR/benchmark_results.csv${NC}"
echo -e "  📝 Assembly code:     ${YELLOW}$ASM_DIR/${NC}"
echo -e "  📈 Analysis:          ${YELLOW}$COMP_DIR/assembly_analysis.txt${NC}"
echo -e "  📋 Summary report:    ${YELLOW}$RESULTS_DIR/summary_report.txt${NC}"
echo ""
echo -e "${GREEN}All tests completed successfully!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. View summary: ${YELLOW}cat $RESULTS_DIR/summary_report.txt${NC}"
echo -e "  2. Analyze results: ${YELLOW}./scripts/analyze_results.sh${NC}"
echo -e "  3. Compare specific test: ${YELLOW}make quick-<test_name>${NC}"
echo ""
