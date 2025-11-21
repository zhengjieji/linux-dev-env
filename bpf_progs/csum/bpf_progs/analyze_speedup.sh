#!/bin/bash
# Analyze speedup from separate trace files

if [ ! -f "trace_original.txt" ] || [ ! -f "trace_optimized.txt" ]; then
    echo "ERROR: trace files not found"
    echo "Run ./run.sh first to generate trace_original.txt and trace_optimized.txt"
    exit 1
fi

echo "============================================"
echo "=== bpf_csum_diff Helper Optimization ==="
echo "=== Speedup Analysis ==="
echo "============================================"
echo

# Use Python to parse and calculate
python3 <<'PYTHON_SCRIPT'
import re
import statistics

def percentile(data, p):
    """Calculate percentile p (0-100) of sorted data"""
    if not data:
        return 0
    sorted_data = sorted(data)
    k = (len(sorted_data) - 1) * (p / 100.0)
    f = int(k)
    c = f + 1
    if c >= len(sorted_data):
        return sorted_data[-1]
    d0 = sorted_data[f] * (c - k)
    d1 = sorted_data[c] * (k - f)
    return int(d0 + d1)

original_times = []
optimized_times = []

print("Parsing trace data...")

# Parse original trace
try:
    with open('trace_original.txt', 'r') as f:
        for line in f:
            # Look for lines with ORIGINAL: time=X
            if 'ORIGINAL:' in line:
                time_match = re.search(r'time=(\d+)', line)
                if time_match:
                    original_times.append(int(time_match.group(1)))
except FileNotFoundError:
    print("ERROR: Cannot read trace_original.txt")
    exit(1)

# Parse optimized trace
try:
    with open('trace_optimized.txt', 'r') as f:
        for line in f:
            # Look for lines with OPTIMIZED: time=X
            if 'OPTIMIZED:' in line:
                time_match = re.search(r'time=(\d+)', line)
                if time_match:
                    optimized_times.append(int(time_match.group(1)))
except FileNotFoundError:
    print("ERROR: Cannot read trace_optimized.txt")
    exit(1)

orig_count = len(original_times)
opt_count = len(optimized_times)
print(f"Found {orig_count} ORIGINAL measurements")
print(f"Found {opt_count} OPTIMIZED measurements\n")

if orig_count == 0 or opt_count == 0:
    print("ERROR: No data found in trace files")
    print("Make sure the BPF programs ran and generated output")
    exit(1)

# Calculate statistics for original
total_original = sum(original_times)
avg_original = statistics.mean(original_times)
median_original = statistics.median(original_times)
min_original = min(original_times)
max_original = max(original_times)
stdev_original = statistics.stdev(original_times) if orig_count > 1 else 0
p90_original = percentile(original_times, 90)
p99_original = percentile(original_times, 99)
p999_original = percentile(original_times, 99.9)

# Calculate statistics for optimized
total_optimized = sum(optimized_times)
avg_optimized = statistics.mean(optimized_times)
median_optimized = statistics.median(optimized_times)
min_optimized = min(optimized_times)
max_optimized = max(optimized_times)
stdev_optimized = statistics.stdev(optimized_times) if opt_count > 1 else 0
p90_optimized = percentile(optimized_times, 90)
p99_optimized = percentile(optimized_times, 99)
p999_optimized = percentile(optimized_times, 99.9)

# Calculate speedup metrics
speedup_avg = avg_original / avg_optimized if avg_optimized > 0 else 0
speedup_median = median_original / median_optimized if median_optimized > 0 else 0
speedup_p90 = p90_original / p90_optimized if p90_optimized > 0 else 0
speedup_p99 = p99_original / p99_optimized if p99_optimized > 0 else 0
time_saved_avg = avg_original - avg_optimized
time_saved_median = median_original - median_optimized
time_saved_pct_avg = (time_saved_avg / avg_original) * 100 if avg_original > 0 else 0
time_saved_pct_median = (time_saved_median / median_original) * 100 if median_original > 0 else 0

# Print results
print("=" * 80)
print("=== SPEEDUP ANALYSIS RESULTS (with Percentile Statistics) ===")
print("=" * 80)
print(f"Helper Functions: bpf_csum_diff vs bpf_csum_diff_optimized")
print(f"Test Scenario:    20-byte buffers (IP header checksum update)")
print(f"Test Method:      Separate runs (eliminates cache bias)")
print()
print("Original bpf_csum_diff:")
print(f"  Measurements:            {orig_count}")
print(f"  Total time:              {total_original:,} ns")
print(f"  Min:                     {min_original} ns")
print(f"  P50 (median):            {int(median_original)} ns")
print(f"  P90:                     {p90_original} ns")
print(f"  P99:                     {p99_original} ns")
print(f"  P99.9:                   {p999_original} ns")
print(f"  Max:                     {max_original} ns")
print(f"  Average:                 {int(avg_original)} ns")
print(f"  Std deviation:           {stdev_original:.2f} ns")
print()
print("Optimized bpf_csum_diff_optimized:")
print(f"  Measurements:            {opt_count}")
print(f"  Total time:              {total_optimized:,} ns")
print(f"  Min:                     {min_optimized} ns")
print(f"  P50 (median):            {int(median_optimized)} ns")
print(f"  P90:                     {p90_optimized} ns")
print(f"  P99:                     {p99_optimized} ns")
print(f"  P99.9:                   {p999_optimized} ns")
print(f"  Max:                     {max_optimized} ns")
print(f"  Average:                 {int(avg_optimized)} ns")
print(f"  Std deviation:           {stdev_optimized:.2f} ns")
print()
print("Performance improvement (Speedup):")
print(f"  P50 (median):            {speedup_median:.3f}x ({int(time_saved_median):+d} ns, {time_saved_pct_median:+.1f}%)")
print(f"  P90:                     {speedup_p90:.3f}x ({int(p90_original - p90_optimized):+d} ns)")
print(f"  P99:                     {speedup_p99:.3f}x ({int(p99_original - p99_optimized):+d} ns)")
print(f"  Average:                 {speedup_avg:.3f}x ({int(time_saved_avg):+d} ns, {time_saved_pct_avg:+.1f}%)")
print()

# Outlier analysis
outlier_threshold = 1000  # ns
orig_outliers = sum(1 for t in original_times if t > outlier_threshold)
opt_outliers = sum(1 for t in optimized_times if t > outlier_threshold)
print(f"Outlier Analysis (> {outlier_threshold} ns):")
print(f"  Original:                {orig_outliers} outliers ({orig_outliers/orig_count*100:.2f}%)")
print(f"  Optimized:               {opt_outliers} outliers ({opt_outliers/opt_count*100:.2f}%)")
print()

# Statistical significance check
if abs(time_saved_pct_median) < 5:
    print("⚠️  WARNING: Median difference is < 5%, may be within measurement noise")
    print("   Result suggests implementations are essentially equivalent")
elif time_saved_pct_median < 0:
    print("⚠️  WARNING: 'Optimized' version is SLOWER than original (by median)!")
    print("   This suggests the optimization may not be effective")
else:
    print("✓  Measurable performance improvement detected (by median)")
    if speedup_p90 > 1.0 and speedup_p99 > 1.0:
        print("✓  Improvement is consistent across P50, P90, and P99")
    else:
        print("⚠️  Improvement varies across percentiles - check for outliers")

print("=" * 80)
print()
print("Notes:")
print("  - Percentiles (P50/P90/P99) are more robust than mean for skewed data")
print("  - P50 (median): 50% of calls are this fast or faster")
print("  - P90: 90% of calls are this fast or faster")
print("  - P99: 99% of calls are this fast or faster (filters worst 1% outliers)")
print("  - Use P50 and P90 for typical performance assessment")
print("  - Large difference between P99 and P50 indicates outliers (preemption, etc.)")
print("=" * 80)

PYTHON_SCRIPT

echo
echo "Analysis complete!"
echo
echo "Output files:"
echo "  - trace_original.txt    (ORIGINAL measurements)"
echo "  - trace_optimized.txt   (OPTIMIZED measurements)"
echo "  - dmesg_original.txt    (ORIGINAL kernel logs)"
echo "  - dmesg_optimized.txt   (OPTIMIZED kernel logs)"
