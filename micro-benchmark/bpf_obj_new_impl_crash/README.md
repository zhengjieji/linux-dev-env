# BPF Object New Implementation - Micro Benchmark

A framework for testing how kfunc verification affects BPF object allocation performance by comparing:
1. Original kernel (baseline)
2. Modified kfunc (with verification removed)
3. Modified verifier (with relaxed checks)

## Purpose

This benchmark tests whether removing verification code from the `bpf_obj_new_impl` kfunc impacts BPF object allocation and deallocation behavior and performance.

## Directory Structure

```
bpf_obj_new_impl/
├── kfunc-config.yaml       # Kernel files configuration
├── kfunc-replacement/      # Kernel kfunc modification tools
│   ├── Makefile
│   ├── custom_helpers.c    # Modified helpers.c (verification removed)
│   ├── original_helpers.c  # Original helpers.c (auto-generated)
│   ├── custom_memalloc.c   # Modified memalloc.c (memory allocation changes)
│   └── original_memalloc.c # Original memalloc.c (auto-generated)
├── verifier-replacement/   # BPF verifier modification tools  
│   ├── Makefile
│   ├── custom.c            # Modified verifier (relaxed checks)
│   └── original.c          # Original verifier (auto-generated)
└── test/                   # BPF test programs
    ├── Makefile
    ├── bpf_prog.c          # BPF program using bpf_obj_new_impl
    ├── loader.c            # BPF loader with statistics
    ├── trigger.c           # Test trigger
    └── run.sh              # Test runner

```

## BPF Program Details

The test BPF program (`bpf_prog.c`) demonstrates proper usage of `bpf_obj_new_impl`:
- Allocates custom BPF objects using `bpf_obj_new_impl`
- Always pairs allocations with `bpf_obj_drop` to prevent memory leaks
- Tests allocation in TC (Traffic Control) context
- Simple allocation and deallocation flow

**Note**: This kfunc requires modifications to multiple kernel files:
- `kernel/bpf/helpers.c` - Contains the main kfunc implementation
- `kernel/bpf/memalloc.c` - Contains memory allocation infrastructure

## Testing Pipeline

### Initial Setup (One Time)

```bash
# 1. Setup kfunc replacement
cd kfunc-replacement/
make setup LINUX_DIR=/path/to/linux

# 2. Setup verifier replacement
cd ../verifier-replacement/
make setup LINUX_DIR=/path/to/linux

# 3. Modify the custom files to remove verification:
#    - Edit kfunc-replacement/custom_helpers.c
#    - Edit kfunc-replacement/custom_memalloc.c
#    - Edit verifier-replacement/custom.c
```

### Test 1: Baseline (Original Kernel)

```bash
# Ensure original kernel is in place
cd kfunc-replacement/
make revert LINUX_DIR=/path/to/linux
cd ../verifier-replacement/
make revert LINUX_DIR=/path/to/linux

# Build and test
cd ../../..
sudo make vmlinux
make qemu-run

# In QEMU, run test
cd /linux-dev-env/micro-benchmark/bpf_obj_new_impl/test
./run.sh 100  # Record results
```

### Test 2: Modified Kfunc Only

```bash
# Apply modified kfunc, keep original verifier
cd kfunc-replacement/
make replace LINUX_DIR=/path/to/linux
cd ../verifier-replacement/
make revert LINUX_DIR=/path/to/linux

# Build and test
cd ../../..
sudo make vmlinux
make qemu-run

# In QEMU, run test
cd /linux-dev-env/micro-benchmark/bpf_obj_new_impl/test
./run.sh 100  # Compare with baseline
```

### Test 3: Modified Verifier Only

```bash
# Apply modified verifier, keep original kfunc
cd kfunc-replacement/
make revert LINUX_DIR=/path/to/linux
cd ../verifier-replacement/
make replace LINUX_DIR=/path/to/linux

# Build and test
cd ../../..
sudo make vmlinux
make qemu-run

# In QEMU, run test
cd /linux-dev-env/micro-benchmark/bpf_obj_new_impl/test
./run.sh 100  # Compare with baseline
```

### Test 4: Both Modified (Optional)

```bash
# Apply both modifications
cd kfunc-replacement/
make replace LINUX_DIR=/path/to/linux
cd ../verifier-replacement/
make replace LINUX_DIR=/path/to/linux

# Build and test
cd ../../..
sudo make vmlinux
make qemu-run

# In QEMU, run test
cd /linux-dev-env/micro-benchmark/bpf_obj_new_impl/test
./run.sh 100  # Compare all results
```

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `make setup LINUX_DIR=/path` | Initial setup and backup |
| `make replace LINUX_DIR=/path` | Apply custom implementation |
| `make revert LINUX_DIR=/path` | Restore original |
| `make status` | Check current state |
| `make diff` | View modifications |

## Test Script Options

```bash
./run.sh [iterations] [delay_ms]
```

- `iterations`: Number of test iterations (default: 100)
- `delay_ms`: Delay between iterations in milliseconds (default: 10)

## What to Measure

When running `./run.sh` in each configuration, observe:
- Allocation/deallocation success rates
- Performance metrics (events per second)
- Memory usage patterns
- Verifier behavior differences
- Any crashes or failures

## Expected Output

The test will show:
- Allocation and drop counters
- Time elapsed for operations
- Events per second throughput
- BPF trace output showing successful allocations
- Kernel memory statistics

## Notes

- Default `LINUX_DIR` is `../../../linux` if not specified
- QEMU SSH access: port 52222
- Test directory in QEMU: `/linux-dev-env/micro-benchmark/bpf_obj_new_impl/test`
- Always rebuild kernel (`sudo make vmlinux`) after any replacement/revert
- The BPF program properly manages memory by pairing every `bpf_obj_new` with `bpf_obj_drop`