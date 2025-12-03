# Raw Tracepoint Micro-Benchmark (BPF_PROG_TEST_RUN)

This micro-benchmark tests raw tracepoint BPF programs using `BPF_PROG_TEST_RUN` syscall, which directly executes the BPF program without actually triggering the tracepoint.

## Key Difference from Other Benchmarks

Unlike `tp/`, `tp_btf/`, `xdp/`, or `tc/` benchmarks that attach to real hooks and require triggering events:

- **Other benchmarks**: Attach to hook → Trigger event → BPF runs
- **This benchmark**: Load program → `BPF_PROG_TEST_RUN` directly executes BPF

This approach is ideal for:
- Measuring pure BPF program execution time
- Benchmarking without side effects
- Testing programs in isolation

## Quick Start

```bash
# Build everything
make

# Run all tests (default: 1 iteration each)
sudo ./scripts/run_all.sh

# Run with more iterations
sudo ./scripts/run_all.sh 1000

# View results
cat outputs/summary.txt
```

## Manual Testing

```bash
# Load programs (pins them for later use)
sudo ./scripts/attach.sh

# Run benchmark
sudo ./scripts/trigger.sh 1000

# Or run specific program
sudo ./scripts/trigger.sh 1000 test_simple

# Unload when done
sudo ./scripts/detach.sh
```

## Directory Structure

```
raw_tp/
├── bpf_progs/           # BPF test programs (*.kern.c)
│   └── simple.kern.c    # Simple raw tracepoint program
├── utils/
│   ├── loader.user.c    # Loads and pins BPF programs
│   └── trigger.user.c   # Runs BPF_PROG_TEST_RUN benchmark
├── scripts/
│   ├── attach.sh        # Load programs
│   ├── detach.sh        # Unload programs
│   ├── trigger.sh       # Run benchmark
│   └── run_all.sh       # Test all programs sequentially
├── outputs/             # Benchmark results
├── Makefile
└── README.md
```

## How It Works

1. **Loader** (`loader`):
   - Opens and loads BPF object files
   - Pins program fds to `/sys/fs/bpf/micro_benchmark_raw_tp/`
   - Does NOT attach to any tracepoint

2. **Trigger** (`trigger`):
   - Gets pinned program fds
   - Uses `BPF_PROG_TEST_RUN` syscall to execute programs
   - Reports timing statistics (total duration, average per run)

3. **BPF_PROG_TEST_RUN**:
   - Kernel executes the BPF program with provided context
   - Returns execution duration in nanoseconds
   - Supports batch execution via `repeat` parameter

## Output Format

```
Program: test_simple
----------------------------------------
Avg per run: 123.45 ns
Total duration: 123450 ns
Result file: outputs/test_simple_benchmark.log
Status: COMPLETED
```

## Adding New Test Programs

1. Create a new BPF program in `bpf_progs/`:

```c
// bpf_progs/my_test.kern.c
#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "GPL";

SEC("raw_tp/sys_enter")
int BPF_PROG(my_test, struct pt_regs *regs, long id)
{
    // Your test code here
    return 0;
}
```

2. Run `make` - the Makefile auto-discovers new `*.kern.c` files

3. Run benchmark: `sudo ./scripts/run_all.sh 1000`

## Limitations

- `BPF_PROG_TEST_RUN` may not be supported for all program types
- Context provided is simulated (not from real syscall)
- Some kfuncs may behave differently in test mode
