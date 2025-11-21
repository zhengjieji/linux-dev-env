#!/bin/bash

# Analysis script for comparing optimization results
# This script generates detailed comparison reports

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
echo -e "${BLUE}Analyzing Optimization Results${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create comparison directory if it doesn't exist
mkdir -p "$COMP_DIR"

# Function to extract key function from assembly
extract_key_function() {
    local asm_file=$1
    local func_name=${2:-compute}

    if [ -f "$asm_file" ]; then
        # Try to extract the main computation function
        awk "/<$func_name/,/^$|^[0-9a-f]+ </" "$asm_file" | head -50
    else
        echo "File not found: $asm_file"
    fi
}

# Function to count instructions
count_instructions() {
    local asm_file=$1
    local func_name=${2:-compute}

    if [ -f "$asm_file" ]; then
        grep -A 100 "<$func_name" "$asm_file" 2>/dev/null | \
            grep -E "^\s+[0-9a-f]+:" | \
            wc -l
    else
        echo "0"
    fi
}

# Function to analyze specific optimization
analyze_optimization() {
    local test_name=$1
    local description=$2
    local output_file="$COMP_DIR/${test_name}_analysis.txt"

    echo -e "${YELLOW}Analyzing: $test_name${NC}"

    cat > "$output_file" << EOF
====================================================================
                    $description
====================================================================
Test: $test_name
Generated: $(date)

--------------------------------------------------------------------
INSTRUCTION COUNT COMPARISON
--------------------------------------------------------------------

EOF

    # Count instructions for each optimization level
    for opt in O0 O1 O2 O3 Os; do
        asm_file="$ASM_DIR/${test_name}_${opt}.asm"
        count=$(count_instructions "$asm_file")
        bin_size=$(stat -c%s "$BUILD_DIR/${test_name}_${opt}" 2>/dev/null || echo "0")
        printf "%-4s: %3d instructions, %6d bytes\n" "$opt" "$count" "$bin_size" >> "$output_file"
    done

    echo "" >> "$output_file"
    echo "--------------------------------------------------------------------" >> "$output_file"
    echo "KEY FUNCTION ASSEMBLY (O0 vs O3)" >> "$output_file"
    echo "--------------------------------------------------------------------" >> "$output_file"
    echo "" >> "$output_file"

    # Show O0 assembly
    echo "=== O0 (No Optimization) ===" >> "$output_file"
    echo "" >> "$output_file"
    extract_key_function "$ASM_DIR/${test_name}_O0.asm" >> "$output_file"
    echo "" >> "$output_file"

    # Show O3 assembly
    echo "=== O3 (Aggressive Optimization) ===" >> "$output_file"
    echo "" >> "$output_file"
    extract_key_function "$ASM_DIR/${test_name}_O3.asm" >> "$output_file"
    echo "" >> "$output_file"

    echo "--------------------------------------------------------------------" >> "$output_file"
    echo "OPTIMIZATION IMPACT" >> "$output_file"
    echo "--------------------------------------------------------------------" >> "$output_file"
    echo "" >> "$output_file"

    # Calculate improvement
    o0_count=$(count_instructions "$ASM_DIR/${test_name}_O0.asm")
    o3_count=$(count_instructions "$ASM_DIR/${test_name}_O3.asm")

    if [ "$o0_count" -gt 0 ]; then
        reduction=$(echo "scale=2; (($o0_count - $o3_count) / $o0_count) * 100" | bc)
        echo "Instruction reduction: ${reduction}%" >> "$output_file"
    fi

    echo "" >> "$output_file"
    echo "====================================================================" >> "$output_file"

    echo -e "${GREEN}✓ Analysis saved to: $output_file${NC}"
}

# Analyze each test
echo -e "${CYAN}Generating detailed analysis for each test...${NC}"
echo ""

analyze_optimization "01_const_propagation" "CONSTANT PROPAGATION ANALYSIS"
analyze_optimization "02_loop_unrolling" "LOOP UNROLLING ANALYSIS"
analyze_optimization "03_branch_elimination" "BRANCH ELIMINATION ANALYSIS"
analyze_optimization "04_dead_code_elimination" "DEAD CODE ELIMINATION ANALYSIS"
analyze_optimization "05_strength_reduction" "STRENGTH REDUCTION ANALYSIS"
analyze_optimization "06_cse" "COMMON SUBEXPRESSION ELIMINATION ANALYSIS"
analyze_optimization "07_function_inlining" "FUNCTION INLINING ANALYSIS"

echo ""
echo -e "${CYAN}Generating comparative analysis...${NC}"

# Create comparative report
COMP_REPORT="$COMP_DIR/comparative_analysis.txt"

cat > "$COMP_REPORT" << 'EOF'
====================================================================
           COMPARATIVE OPTIMIZATION ANALYSIS
====================================================================

This report compares the effectiveness of different optimizations
across all tests.

--------------------------------------------------------------------
INSTRUCTION COUNT REDUCTION (O0 → O3)
--------------------------------------------------------------------

Test                            O0      O3      Reduction
EOF

echo "" >> "$COMP_REPORT"

for test_src in "$PROJECT_DIR/src"/*.c; do
    test_name=$(basename "$test_src" .c)
    o0_count=$(count_instructions "$ASM_DIR/${test_name}_O0.asm")
    o3_count=$(count_instructions "$ASM_DIR/${test_name}_O3.asm")

    if [ "$o0_count" -gt 0 ]; then
        reduction=$(echo "scale=1; (($o0_count - $o3_count) / $o0_count) * 100" | bc)
        printf "%-30s  %4d    %4d    %5s%%\n" "$test_name" "$o0_count" "$o3_count" "$reduction" >> "$COMP_REPORT"
    fi
done

cat >> "$COMP_REPORT" << 'EOF'

--------------------------------------------------------------------
BINARY SIZE COMPARISON (bytes)
--------------------------------------------------------------------

Test                            O0      O2      O3      Os
EOF

echo "" >> "$COMP_REPORT"

for test_src in "$PROJECT_DIR/src"/*.c; do
    test_name=$(basename "$test_src" .c)
    o0_size=$(stat -c%s "$BUILD_DIR/${test_name}_O0" 2>/dev/null || echo "0")
    o2_size=$(stat -c%s "$BUILD_DIR/${test_name}_O2" 2>/dev/null || echo "0")
    o3_size=$(stat -c%s "$BUILD_DIR/${test_name}_O3" 2>/dev/null || echo "0")
    os_size=$(stat -c%s "$BUILD_DIR/${test_name}_Os" 2>/dev/null || echo "0")

    printf "%-30s  %6d  %6d  %6d  %6d\n" "$test_name" "$o0_size" "$o2_size" "$o3_size" "$os_size" >> "$COMP_REPORT"
done

cat >> "$COMP_REPORT" << 'EOF'

--------------------------------------------------------------------
OPTIMIZATION EFFECTIVENESS RANKING
--------------------------------------------------------------------

Based on instruction count reduction, the optimizations ranked by
effectiveness are:

EOF

# Calculate and sort by effectiveness
temp_file=$(mktemp)
for test_src in "$PROJECT_DIR/src"/*.c; do
    test_name=$(basename "$test_src" .c)
    o0_count=$(count_instructions "$ASM_DIR/${test_name}_O0.asm")
    o3_count=$(count_instructions "$ASM_DIR/${test_name}_O3.asm")

    if [ "$o0_count" -gt 0 ]; then
        reduction=$(echo "scale=2; (($o0_count - $o3_count) / $o0_count) * 100" | bc)
        echo "$reduction|$test_name" >> "$temp_file"
    fi
done

# Sort and display
rank=1
sort -rn -t'|' -k1 "$temp_file" | while IFS='|' read -r reduction test_name; do
    printf "%2d. %-35s %6.2f%% reduction\n" "$rank" "$test_name" "$reduction" >> "$COMP_REPORT"
    rank=$((rank + 1))
done

rm -f "$temp_file"

cat >> "$COMP_REPORT" << 'EOF'

--------------------------------------------------------------------
KEY FINDINGS
--------------------------------------------------------------------

1. Most Effective Optimizations:
   - Optimizations that show the highest instruction count reduction
   - Typically: constant propagation, dead code elimination

2. Size vs Speed Trade-offs:
   - O3 may increase binary size for marginal speed gains
   - Os provides good balance for size-constrained environments

3. Recommendations for BPF Optimization:
   - Focus on optimizations showing >50% instruction reduction
   - Prioritize constant propagation with verifier constraints
   - Consider loop unrolling for bounded loops
   - Branch elimination particularly valuable for runtime checks

====================================================================
EOF

echo -e "${GREEN}✓ Comparative analysis saved to: $COMP_REPORT${NC}"

# Generate visual comparison script
echo ""
echo -e "${CYAN}Creating visualization helper...${NC}"

cat > "$COMP_DIR/view_comparison.sh" << 'VIZEOF'
#!/bin/bash
# Helper script to view side-by-side assembly comparison

if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_name>"
    echo "Example: $0 01_const_propagation"
    exit 1
fi

TEST=$1
ASM_DIR="../results/assembly"

if command -v diff &> /dev/null; then
    echo "=== O0 vs O3 Diff ==="
    diff -y --suppress-common-lines \
        <(grep -A 50 "<compute" "$ASM_DIR/${TEST}_O0.asm") \
        <(grep -A 50 "<compute" "$ASM_DIR/${TEST}_O3.asm") \
        2>/dev/null | head -50
else
    echo "O0 version:"
    grep -A 30 "<compute" "$ASM_DIR/${TEST}_O0.asm"
    echo ""
    echo "O3 version:"
    grep -A 30 "<compute" "$ASM_DIR/${TEST}_O3.asm"
fi
VIZEOF

chmod +x "$COMP_DIR/view_comparison.sh"

echo -e "${GREEN}✓ Visualization helper created${NC}"

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Analysis Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Generated files:"
echo -e "  📊 Individual analyses:  ${YELLOW}$COMP_DIR/*_analysis.txt${NC}"
echo -e "  📈 Comparative report:   ${YELLOW}$COMP_REPORT${NC}"
echo -e "  🔍 View helper:          ${YELLOW}$COMP_DIR/view_comparison.sh${NC}"
echo ""
echo -e "Quick commands:"
echo -e "  View summary:            ${YELLOW}cat $COMP_REPORT${NC}"
echo -e "  View specific test:      ${YELLOW}cat $COMP_DIR/01_const_propagation_analysis.txt${NC}"
echo -e "  Compare assembly:        ${YELLOW}$COMP_DIR/view_comparison.sh 01_const_propagation${NC}"
echo ""
