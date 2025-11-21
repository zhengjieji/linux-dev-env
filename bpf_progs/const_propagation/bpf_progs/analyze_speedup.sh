#!/bin/bash
# Analyze speedup from trace_output.txt for Constant Propagation Optimization

if [ ! -f "trace_output.txt" ]; then
    echo "ERROR: trace_output.txt not found"
    echo "Run ./run_speedup.sh first to generate the trace output"
    exit 1
fi

echo "============================================"
echo "=== Constant Propagation Optimization ==="
echo "=== Speedup Analysis ==="
echo "============================================"
echo

# Use Python to parse and calculate
python3 <<'PYTHON_SCRIPT'
import re

total_original = 0
total_optimized = 0
count = 0

print("Parsing trace data...")

try:
    with open('trace_output.txt', 'r') as f:
        for line in f:
            # Look for lines with DATA: original=X optimized=Y
            if 'DATA:' in line:
                # Extract the numbers
                original_match = re.search(r'original=(\d+)', line)
                optimized_match = re.search(r'optimized=(\d+)', line)

                if original_match and optimized_match:
                    original = int(original_match.group(1))
                    optimized = int(optimized_match.group(1))

                    total_original += original
                    total_optimized += optimized
                    count += 1

except FileNotFoundError:
    print("ERROR: Cannot read trace_output.txt")
    exit(1)

print(f"Found {count} data entries\n")

if count == 0:
    print("ERROR: No data found in trace_output.txt")
    print("Make sure the BPF program ran and generated output")
    exit(1)

# Calculate statistics
avg_original = total_original / count
avg_optimized = total_optimized / count
speedup = total_original / total_optimized if total_optimized > 0 else 0
time_saved = total_original - total_optimized
time_saved_pct = (time_saved / total_original) * 100 if total_original > 0 else 0

# Print results
print("=" * 70)
print("=== SPEEDUP ANALYSIS RESULTS ===")
print("=" * 70)
print(f"Optimization Type: Constant Propagation")
print(f"Total iterations analyzed: {count}")
print()
print("Original version (runtime parameter validation):")
print(f"  Total time:              {total_original:,} ns")
print(f"  Average per iteration:   {int(avg_original)} ns")
print()
print("Optimized version (constant propagation + folding):")
print(f"  Total time:              {total_optimized:,} ns")
print(f"  Average per iteration:   {int(avg_optimized)} ns")
print()
print("Performance improvement:")
print(f"  Speedup:                 {speedup:.2f}x faster")
print(f"  Time saved per iter:     {int(avg_original - avg_optimized)} ns")
print(f"  Time saved total:        {time_saved:,} ns")
print(f"  Time saved percentage:   {time_saved_pct:.1f}%")
print("=" * 70)
print()
print("Optimization techniques applied:")
print("  - Constant propagation (compiler knows x=50, y=2)")
print("  - Constant folding (arithmetic computed at compile time)")
print("  - Dead code elimination (parameter checks removed)")
print("  - Branch elimination (conditionals resolved)")
print("=" * 70)

PYTHON_SCRIPT

echo
echo "Analysis complete!"
