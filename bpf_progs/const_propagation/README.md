# Constant Propagation Optimization Example

Testing constant propagation optimization in BPF kfuncs - comparing runtime parameter validation vs compile-time constant folding.

## Overview

This example demonstrates how constant propagation can eliminate runtime checks when the compiler knows parameter values at compile time.

**Two versions of the same computation:**
1. **Runtime checks**: `bpf_compute_with_runtime_checks(x, y)` - validates parameters at runtime
2. **Constant propagation**: `bpf_compute_with_const_propagation(x, y)` - uses hardcoded constants, allowing compiler to fold everything

## Directory Structure

```
const_propagation/
├── README.md                    # This file
├── Makefile                     # Framework control + assembly comparison
├── replacement/                 # Custom kfunc files
│   ├── custom_kfuncs.c         # Two versions of computation kfunc
│   └── Makefile                # Modified kernel/bpf/Makefile
├── backup/                      # Backup of original kernel files
├── assembly_analysis/           # Generated assembly comparison
│   ├── runtime_checks.asm      # Runtime version assembly
│   ├── const_propagation.asm   # Optimized version assembly
│   └── COMPARISON.md           # Side-by-side comparison report
└── bpf_progs/                   # BPF test programs
    ├── bpf_prog.c              # Calls both kfunc versions
    ├── run_speedup.sh          # Run test and capture trace
    └── analyze_speedup.sh      # Calculate speedup from trace
```

## Quick Start

### 1. Install Custom Kfuncs
```bash
make replace
```

### 2. Build Kernel
```bash
cd ../../
make vmlinux
```

### 3. Run Performance Test
```bash
cd custom_kfunc_examples/const_propagation/bpf_progs
sudo ./run_speedup.sh      # Trigger 100 iterations, save trace
./analyze_speedup.sh       # Calculate speedup
```

### 4. Compare Assembly
```bash
cd ..
make compare-asm           # Extract and compare assembly
cat assembly_analysis/COMPARISON.md
```

### 5. Revert When Done
```bash
make revert
```

## The Two Kfuncs

### Runtime Version (bpf_compute_with_runtime_checks)

```c
__bpf_kfunc s64 bpf_compute_with_runtime_checks(s64 x, s64 y)
{
    // Runtime parameter validation
    if (x < 0 || x > 1000) return -EINVAL;
    if (y < 1 || y > 10) return -EINVAL;

    s64 result;
    result = x * y;
    result = result + 100;
    result = result / 2;
    result = result * 3;
    result = result - 50;

    if (result > 500)
        result = result / 2;
    else
        result = result * 2;

    return result;
}
```

### Optimized Version (bpf_compute_with_const_propagation)

```c
__bpf_kfunc s64 bpf_compute_with_const_propagation(s64 x, s64 y)
{
    // Hardcode constants to enable optimization
    const s64 x_const = 50;
    const s64 y_const = 2;

    // Same computation but compiler knows all values
    s64 result;
    result = x_const * y_const;  // Compiler: 100
    result = result + 100;        // Compiler: 200
    result = result / 2;          // Compiler: 100
    result = result * 3;          // Compiler: 300
    result = result - 50;         // Compiler: 250

    if (result > 500)             // Compiler: false, branch eliminated
        result = result / 2;
    else
        result = result * 2;      // Compiler: 500

    return result;                // Compiler: return 500;
}
```

## Expected Optimizations

The optimized version benefits from:
- **Constant propagation**: Compiler knows x=50, y=2 at compile time
- **Constant folding**: All arithmetic operations computed at compile time
- **Dead code elimination**: Parameter validation removed (constants always valid)
- **Branch elimination**: Conditional branches resolved at compile time

**Expected result**: ~2-3x speedup, 90%+ fewer instructions

## Testing Workflow

### Performance Testing

```bash
# 1. Run test (100 getcwd syscalls)
sudo ./bpf_progs/run_speedup.sh

# 2. Analyze results
./bpf_progs/analyze_speedup.sh
```

Output shows:
- Total iterations
- Runtime version: total time, average per iteration
- Optimized version: total time, average per iteration
- Speedup ratio (e.g., 2.43x faster)
- Time saved percentage

### Assembly Analysis

```bash
# Compare generated assembly code
make compare-asm

# View comparison report
cat assembly_analysis/COMPARISON.md
```

Output shows:
- Instruction count for both versions
- Percentage reduction
- Side-by-side assembly code
- Analysis of applied optimizations

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make status` | Check if kernel is modified |
| `make replace` | Install custom kfuncs into kernel |
| `make revert` | Restore original kernel files |
| `make asm` | Extract assembly from kfunc object |
| `make compare-asm` | Compare runtime vs optimized assembly |

## How BPF Program Works

The test program (`bpf_progs/bpf_prog.c`):
1. Attached to `tp/syscalls/sys_enter_getcwd` tracepoint
2. Calls both kfunc versions on each `getcwd()` syscall
3. Prints timing data: `DATA: runtime=X optimized=Y`
4. Verifies both return same result (500)

The trigger program calls `getcwd()` N times to generate test data.

## Results

Expected performance improvement:
- **Speedup**: 2-3x faster
- **Instructions**: ~90% reduction
- **Time saved**: ~60-70%

Actual results depend on:
- Compiler version and optimization level
- CPU architecture
- Cache effects
- Measurement overhead

## Path Configuration

This example is located in `custom_kfunc_examples/const_propagation/`.

Paths are configured for this location:
- `KERNEL_DIR = ../../linux` (in main Makefile)
- `PROJECT_ROOT = ../../..` (in bpf_progs/Makefile)

## Related Files

- Main framework: `../../README.md`
- Other examples: `../`
- Compiler tests: `../../compiler_optimization_tests/`
