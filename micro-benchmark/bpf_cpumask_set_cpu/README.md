# BPF CPUmask Set CPU - Micro Benchmark

A framework for testing how kfunc verification affects BPF cpumask operations performance by comparing:
1. Original kernel (baseline)
2. Modified kfunc (with verification removed)
3. Modified verifier (with relaxed checks)

## Purpose

This benchmark tests whether removing verification code from the `bpf_cpumask_set_cpu` kfunc impacts BPF cpumask operations behavior and performance.

## Directory Structure

```
bpf_cpumask_set_cpu/
├── kfunc-config.yaml       # Kernel files configuration
├── kfunc-replacement/      # Kernel kfunc modification tools
│   ├── Makefile
│   ├── custom_cpumask.c    # Modified kfunc (verification removed)
│   └── original_cpumask.c  # Original kernel code (auto-generated)
├── verifier-replacement/   # BPF verifier modification tools  
│   ├── Makefile
│   ├── custom.c            # Modified verifier (relaxed checks)
│   └── original.c          # Original verifier (auto-generated)
└── test/                   # BPF test programs
    ├── Makefile
    ├── bpf_prog.c          # BPF program using cpumask kfuncs
    ├── loader.c            # BPF loader
    ├── trigger.c           # Test trigger
    └── run.sh              # Test runner

```

## BPF Program Details

The test BPF program (`bpf_prog.c`) demonstrates cpumask operations:
- Creates a new cpumask with `bpf_cpumask_create`
- Sets multiple CPUs using `bpf_cpumask_set_cpu`
- Tests CPU states with `bpf_cpumask_test_cpu`
- Clears CPUs with `bpf_cpumask_clear_cpu`
- Finds first set/zero CPU with helper functions
- Properly releases cpumask with `bpf_cpumask_release`

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
#    - Edit kfunc-replacement/custom_cpumask.c
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
cd /linux-dev-env/micro-benchmark/bpf_cpumask_set_cpu/test
./run.sh 10  # Record results
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
cd /linux-dev-env/micro-benchmark/bpf_cpumask_set_cpu/test
./run.sh 10  # Compare with baseline
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
cd /linux-dev-env/micro-benchmark/bpf_cpumask_set_cpu/test
./run.sh 10  # Compare with baseline
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
cd /linux-dev-env/micro-benchmark/bpf_cpumask_set_cpu/test
./run.sh 10  # Compare all results
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
./run.sh [iterations]
```

- `iterations`: Number of test iterations (default: 10)

## What to Measure

When running `./run.sh` in each configuration, observe:
- CPU mask operation success/failure
- Performance of set/clear operations
- Correctness of CPU state tracking
- Verifier behavior differences
- Any crashes or errors

## Expected Output

The test will show:
- Cpumask creation and release
- CPU set/clear operations
- CPU state verification
- First set/zero CPU detection
- Operation timing and throughput

## Notes

- Default `LINUX_DIR` is `../../../linux` if not specified
- QEMU SSH access: port 52222
- Test directory in QEMU: `/linux-dev-env/micro-benchmark/bpf_cpumask_set_cpu/test`
- Always rebuild kernel (`sudo make vmlinux`) after any replacement/revert
- The BPF program uses TC (Traffic Control) context for testing