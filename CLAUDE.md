# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a BPF (Berkeley Packet Filter) research repository focused on **kernel function (kfunc) specialization** and **performance benchmarking**. The core concept: BPF verifier validates argument properties at compile-time, but kernel functions still perform redundant runtime checks. This project provides tools to replace kfunc implementations with optimized versions that eliminate these redundant checks.

The repository contains three main components:
1. **Linux kernel development environment** (Docker + QEMU)
2. **Standardized micro-benchmark framework** (`micro-benchmark/`)
3. **BPF API analysis tools** (`tools/`)

## Key Architecture Concepts

### The Specialization Approach

**Problem**: BPF programs call kernel functions that contain runtime checks, but the BPF verifier already validates these properties at verification time. Functions are compiled separately, preventing cross-function optimization.

**Solution**: Generate specialized kfunc implementations by:
1. Extracting verifier-proven argument constraints (e.g., `size=32`, `meta=NULL`)
2. Combining kfunc + all callees into a single compilation unit
3. Adding systematic assertion/conditional checks at entry point for optimization hints
4. Letting standard compiler optimizers eliminate redundant checks automatically

### Directory Structure

**Micro-Benchmark Framework** (organized by hook point):
```
micro-benchmark/
├── tp/                          # Tracepoint hook benchmarks
├── tp_btf/                      # BTF-based tracepoint benchmarks
├── raw_tp/                      # Raw tracepoint: triggers via BPF_PROG_TEST_RUN
├── xdp/                         # XDP: triggers via UDP packets on loopback
└── tc/                          # TC: triggers via UDP packets on loopback

Each hook directory contains:
├── bpf_progs/                   # BPF test programs (*.kern.c auto-discovered)
├── utils/                       # loader.user.c + trigger.user.c
├── scripts/                     # attach.sh, detach.sh, trigger.sh, run_all.sh
├── outputs/                     # Per-program logs + summary
└── Makefile
```

**BPF API Analysis Tools**:
```
tools/
├── bpf-api-extractor/           # Extract helpers/kfuncs from kernel source
└── bpf-usage-scanner/           # Scan BPF projects for helper/kfunc usage
```

## Essential Build Commands

### Initial Setup

```bash
# 1. Build Docker container with all dependencies
sudo make docker

# 2. Clone Linux kernel (if not present)
git clone https://github.com/torvalds/linux.git
cd linux && git checkout v6.13 && cd ..

# 3. Copy kernel config (6.13 or 6.17 available)
cp linux-configs/linux-config-6.13/.config ./linux/

# 4. Build kernel dependencies
sudo make headers-install
sudo make modules-install

# 5. Build kernel
sudo make vmlinux

# 6. Build BPF tools
sudo make libbpf
sudo make bpftool
```

### Development Workflow

```bash
# Run QEMU with custom kernel
make qemu-run

# SSH into QEMU (from another terminal)
make qemu-ssh

# Enter Docker container for debugging
make enter-docker

# Clean kernel build
make linux-clean

# Rebuild after kernel modifications
sudo make vmlinux && make qemu-run
```

### Using BPF API Analysis Tools

```bash
# Extract helpers and kfuncs from kernel source
cd tools/bpf-api-extractor/
./run.sh                              # Uses ../../linux by default
./run.sh --linux-dir /path/to/linux   # Custom kernel path
./run.sh --helpers-only               # Only extract helpers
./run.sh --kfuncs-only                # Only extract kfuncs
# Output: output/helpers.csv, output/kfuncs.csv

# Scan BPF projects for helper/kfunc usage (run after bpf-api-extractor)
cd ../bpf-usage-scanner/
./run.sh
# Output: output/summary.csv, output/<project>/{helpers,kfuncs}.csv
```

### Using the Standardized Micro-Benchmark Framework

```bash
# Navigate to a micro-benchmark directory (tp, tp_btf, raw_tp, xdp, or tc)
cd micro-benchmark/xdp/

# Build all BPF programs and utilities
make

# Run all tests (default: 1 iteration per program, tests separately)
sudo ./scripts/run_all.sh

# Or specify iterations
sudo ./scripts/run_all.sh 1000

# View results
cat outputs/summary.txt

# Manual testing of specific program
sudo ./scripts/attach.sh bpf_progs/test_specific.kern.o
sudo ./scripts/trigger.sh 100
cat outputs/trace.log
sudo ./scripts/detach.sh
```

**Key Features:**
- **Auto-discovery**: Makefile automatically finds all `bpf_progs/*.kern.c` files
- **Separate testing**: `run_all.sh` tests each program individually (attach→test→detach)
- **vmlinux.h generation**: Automatically generated from `/sys/kernel/btf/vmlinux` via bpftool

### Using raw_tp with BPF_PROG_TEST_RUN

The `raw_tp/` benchmark uses `BPF_PROG_TEST_RUN` syscall to directly execute BPF programs without attaching to actual tracepoints. This is ideal for measuring pure BPF execution time:

```bash
cd micro-benchmark/raw_tp/
make

# Run benchmark (programs are loaded but NOT attached)
sudo ./scripts/run_all.sh 1000

# Results show execution time per run in nanoseconds
cat outputs/summary.txt
```

**Key difference**: Other benchmarks (tp, xdp, tc) attach to real hooks and require triggering events. `raw_tp` directly executes via `BPF_PROG_TEST_RUN` for isolated benchmarking.

### BPF Kernel Patch

Track kernel file modifications across experiments with safe apply/revert:

```bash
# Create experiment
make patch-new NAME=my_kfunc_opt

# Track files to modify (auto-backup + copy to patches dir)
make patch-track FILE=kernel/trace/bpf_trace.c
make patch-track FILES="kernel/bpf/helpers.c kernel/bpf/verifier.c"

# Track new files to add
make patch-track-add FILE=kernel/bpf/my_new_helper.c

# Edit patches
vim experiments/my_kfunc_opt/patches/kernel/trace/bpf_trace.c

# Check status and diff
make patch-status
make patch-diff

# Apply to kernel, build, test
make patch-apply
sudo make vmlinux && make qemu-run

# Revert when done
make patch-revert
```

See [tools/bpf-kernel-patch/README.md](tools/bpf-kernel-patch/README.md) for full documentation.

## Testing Pipeline for Benchmarking

When benchmarking kernel modifications:

```bash
# 1. Create experiment and track files
make patch-new NAME=my_opt
make patch-track FILE=kernel/trace/bpf_trace.c

# 2. Edit patches, apply, rebuild kernel
make patch-apply
sudo make vmlinux

# 3. Run QEMU with modified kernel
make qemu-run

# 4. Inside QEMU, run benchmarks
cd /linux-dev-env/micro-benchmark/xdp/
make
sudo ./scripts/run_all.sh 1000
cat outputs/summary.txt

# 5. Revert when done
make patch-revert
```

## Important Development Notes

### Linux Kernel Source Location

The `LINUX` variable in the root Makefile defaults to `./linux`. If your kernel is elsewhere, override with:
```bash
make vmlinux LINUX=/path/to/linux
```

### QEMU Port Mappings

Default ports (host → QEMU):
- SSH: 52222 → 52222
- Network: 52223 → 52223
- GDB: 1234 → 1234

To add more ports, modify both:
1. **Makefile**: Add `-p 127.0.0.1:HOST_PORT:DOCKER_PORT` to `qemu-run` target
2. **q-script/yifei-q**: Add `hostfwd=tcp::DOCKER_PORT-:QEMU_PORT` to the netdev line

### GDB Debugging

```bash
# Start QEMU with GDB server (automatically enabled)
make qemu-run

# In another terminal
cd linux
gdb vmlinux
target remote :1234
# Set breakpoints and continue
```

### Docker Environment

All kernel compilation happens inside Docker to ensure consistent build environment. The Docker image ([Dockerfile](Dockerfile)) includes:
- Kernel build tools (gcc, clang, make, etc.)
- BPF toolchain (bpfcc-tools, libbpf)
- QEMU for virtualization
- Development utilities (flex, bison, bc, etc.)

### BPF Test Program Structure

Each micro-benchmark directory follows this pattern:
- **bpf_progs/*.kern.c**: BPF programs (kernel-side)
- **utils/loader.user.c**: User-space program that loads BPF programs and pins them
- **utils/trigger.user.c**: Program that triggers the BPF hook execution
- **scripts/**: Shell scripts to orchestrate testing

### Compilation Architecture

**Key insight for specialization**: Standard kernel builds compile files separately:
- `kernel/bpf/helpers.o` (contains kfuncs)
- `kernel/bpf/memalloc.o` (contains callees)
- `kernel/trace/bpf_trace.o` (contains trace kfuncs)

The optimizer cannot see across compilation units. The specialization approach:
1. Identifies a kfunc and ALL its callees
2. Combines them into a single `.c` file
3. Adds entry-point assertions with known argument values
4. Compiles with `-O2`/`-O3` to enable aggressive optimization

The compiler then performs:
- Constant propagation (e.g., `size=32` flows through all functions)
- Dead code elimination (e.g., `if (!size)` becomes `if (false)` → removed)
- Function inlining (callees are `static inline`)

## Adding New Micro-Benchmarks

To create a new standardized micro-benchmark for a different hook point:

1. **Create directory structure**:
```bash
mkdir -p micro-benchmark/<hook_name>/{bpf_progs,utils,scripts,outputs}
```

2. **Copy and adapt from existing benchmark**:
```bash
# Use xdp as template
cp micro-benchmark/xdp/{Makefile,README.md} micro-benchmark/<hook_name>/
cp -r micro-benchmark/xdp/{utils,scripts} micro-benchmark/<hook_name>/
```

3. **Customize for your hook**:
- Update `utils/trigger.user.c` to trigger your specific hook
- Update `utils/loader.user.c` pin path
- Create BPF programs in `bpf_progs/*.kern.c` with appropriate SEC()

## Common Pitfalls

1. **Missing pahole**: The kernel requires `pahole` (from dwarves package). Install with: `sudo apt-get install dwarves`

2. **Missing jq**: The patch system requires `jq` for JSON processing. Install with: `sudo apt-get install jq`

3. **Forgetting to rebuild kernel**: After kernel source changes, you MUST run `sudo make vmlinux` and reboot QEMU

4. **Port conflicts**: If QEMU fails to start, check if ports 52222, 52223, or 1234 are already in use

5. **Docker permissions**: Most Docker commands require `sudo` due to kernel compilation needs

6. **BPF program compilation**: BPF programs must be compiled with clang targeting BPF (`-target bpf`), not gcc
