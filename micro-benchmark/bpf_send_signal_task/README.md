# BPF Send Signal Task - Micro Benchmark

A framework for testing how kfunc verification affects BPF program performance by comparing:
1. Original kernel (baseline)
2. Modified kfunc (with verification removed)
3. Modified verifier (with relaxed checks)

## Purpose

This benchmark tests whether removing verification code from the `bpf_send_signal_task` kfunc impacts BPF program behavior and performance.

## Directory Structure

```
bpf_send_signal_task/
├── kfunc-config.yaml       # Kernel files configuration
├── kfunc-replacement/      # Kernel kfunc modification tools
│   ├── Makefile
│   ├── custom_bpf_trace.c  # Modified kfunc (verification removed)
│   └── original_bpf_trace.c # Original kernel code (auto-generated)
├── verifier-replacement/   # BPF verifier modification tools  
│   ├── Makefile
│   ├── custom.c            # Modified verifier (relaxed checks)
│   └── original.c          # Original verifier (auto-generated)
└── test/                   # BPF test programs
    ├── Makefile
    ├── bpf_prog.c          # BPF program using bpf_send_signal_task
    ├── loader.c            # BPF loader
    ├── trigger.c           # Test trigger
    └── run.sh              # Test runner

```

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
#    - Edit kfunc-replacement/custom_bpf_trace.c
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
cd /linux-dev-env/micro-benchmark/bpf_send_signal_task/test
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
cd /linux-dev-env/micro-benchmark/bpf_send_signal_task/test
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
cd /linux-dev-env/micro-benchmark/bpf_send_signal_task/test
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
cd /linux-dev-env/micro-benchmark/bpf_send_signal_task/test
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

## What to Measure

When running `./run.sh` in each configuration, observe:
- Execution time differences
- BPF program loading success/failure
- Verifier output differences
- Trace output variations
- Any behavioral changes

## Notes

- Default `LINUX_DIR` is `../../../linux` if not specified
- QEMU SSH access: port 52222
- Test directory in QEMU: `/linux-dev-env/micro-benchmark/bpf_send_signal_task/test`
- Always rebuild kernel (`sudo make vmlinux`) after any replacement/revert