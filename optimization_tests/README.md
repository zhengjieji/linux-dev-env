# Compiler Optimization Verification Tests

This project systematically tests 7 compiler optimizations to understand their impact on code generation and performance. This helps identify which optimizations are most valuable for BPF kfunc specialization.

## Project Structure

```
compiler_optimization_tests/
├── README.md                   # Overview and usage
├── RESULTS.md                  # Detailed results analysis
├── Makefile                    # Build automation
├── src/                        # 7 test programs
│   ├── 01_const_propagation.c
│   ├── 02_loop_unrolling.c
│   ├── 03_branch_elimination.c
│   ├── 04_dead_code_elimination.c
│   ├── 05_strength_reduction.c
│   ├── 06_cse.c
│   └── 07_function_inlining.c
├── scripts/
│   ├── run_tests.sh           # Compiles, runs benchmarks, generates assembly
│   └── analyze_results.sh     # Analyzes assembly and creates comparison reports
└── results/                   # Generated output
    ├── performance/           # Timing data (CSV)
    ├── assembly/              # Disassembled binaries
    └── comparison/            # Analysis reports
```

## Quick Start

```bash
# Run everything (recommended first time)
./scripts/run_tests.sh

# View results documentation
cat RESULTS.md
```

## Optimization Types Tested

| # | Optimization | What It Does | BPF Relevance |
|---|-------------|--------------|---------------|
| 1 | Constant Propagation | Compute constants at compile time | ★★★★★ High - verifier proves values |
| 2 | Loop Unrolling | Expand loops with known bounds | ★★★★☆ High - bounded loops common |
| 3 | Branch Elimination | Remove compile-time known branches | ★★★★★ High - eliminate runtime checks |
| 4 | Dead Code Elimination | Remove unused code | ★★★★☆ Medium - remove error paths |
| 5 | Strength Reduction | Replace expensive ops with cheap ones | ★★★☆☆ Medium - arithmetic optimization |
| 6 | Common Subexpression Elimination | Compute repeated expressions once | ★★★☆☆ Medium - reduce redundancy |
| 7 | Function Inlining | Eliminate function call overhead | ★★★☆☆ Medium - inline small helpers |

## Scripts Explained

### run_tests.sh
**Purpose:** Automated end-to-end test runner

**What it does:**
1. Creates directory structure (`results/performance`, `results/assembly`, `results/comparison`)
2. Compiles all 7 test programs with 5 optimization levels (O0, O1, O2, O3, Os)
3. Runs performance benchmarks and saves timing data to CSV
4. Generates assembly output using `objdump`
5. Creates initial assembly analysis (instruction counts, binary sizes)
6. Generates summary report

**Output:**
- `results/performance/benchmark_results.csv` - Timing data
- `results/assembly/*.asm` - Disassembled binaries
- `results/summary_report.txt` - Overview of all results

### analyze_results.sh
**Purpose:** Detailed result analysis and comparison

**What it does:**
1. Extracts key functions from assembly files
2. Counts instructions for each optimization level
3. Creates per-test analysis reports (O0 vs O3 comparison)
4. Generates comparative analysis across all tests
5. Ranks optimizations by effectiveness
6. Creates visualization helper script

**Output:**
- `results/comparison/*_analysis.txt` - Individual test analyses
- `results/comparison/comparative_analysis.txt` - Cross-test comparison
- `results/comparison/view_comparison.sh` - Assembly diff helper

## Optimization Levels

- **O0**: No optimization - baseline for comparison
- **O1**: Basic optimizations (dead code elimination, simple constant folding)
- **O2**: Recommended level (adds loop unrolling, inlining, CSE)
- **O3**: Aggressive (most optimizations enabled, may increase size)
- **Os**: Size-optimized (prefers smaller code over speed)

## Usage Examples

```bash
# Quick test one optimization (O0 vs O3)
make quick-01_const_propagation

# Run specific test with all optimization levels
make run-02_loop_unrolling

# View assembly comparison
make asm-03_branch_elimination

# List all available tests
make list

# Full workflow
make all              # Compile everything
make benchmark        # Run performance tests
make assembly         # Generate assembly
./scripts/analyze_results.sh  # Analyze results
```

## Understanding Results

See [RESULTS.md](RESULTS.md) for detailed analysis with:
- Actual instruction counts for each optimization level
- Assembly code comparisons (before/after)
- Performance timing data
- Explanation of what each optimization does

## Requirements

- GCC or Clang compiler
- `objdump` for disassembly
- `bc` for calculations
- Basic Unix utilities (bash, awk, grep)

## Application to BPF Optimization

**Goal:** Use compiler optimizations to eliminate redundant runtime checks in BPF kfuncs

**Approach:**
1. BPF verifier proves argument constraints (e.g., `0 <= x <= 100`)
2. Create specialized kfunc with constraints as compile-time knowledge
3. Compiler optimizes away redundant checks

**Key Insights from This Project:**
- Constant propagation and branch elimination show 70-90% instruction reduction
- Most effective for eliminating runtime checks (branch elimination)
- Loop unrolling valuable for bounded BPF loops
- Understand how to structure code to enable these optimizations

See [../PROJECT.md](../PROJECT.md) for the main BPF optimization project.
