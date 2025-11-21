# BPF Programs for Custom Kfunc Testing

BPF program that tests custom kfuncs by attaching to syscall tracepoint.

## Files

- **bpf_prog.c** - BPF program (raw_tp/sys_enter)
- **loader.c** - Userspace loader
- **trigger.c** - Syscall trigger
- **run.sh** - Automated test
- **Makefile** - Build system

## Quick Start

```bash
# Build and run
sudo ./run.sh
```

## How It Works

- **Attaches to:** `sys_enter` raw tracepoint (fires on every syscall)
- **Triggers:** Any syscall (trigger.c calls getpid())
- **Tests:** All 3 custom kfuncs on each execution

## Expected Output

```
Test 1: bpf_test_add(10, 20) = 30
Test 1: bpf_test_multiply(10, 20) = 200
Test 1: bpf_test_check_range(50, 0, 100) = 0
Test 1: bpf_test_check_range(-10, 0, 100) = -22
Test 1: bpf_test_check_range(150, 0, 100) = -22
```

## Manual Usage

```bash
make                     # Build
sudo ./loader bpf_prog.o & # Load
sudo ./trigger 5         # Trigger
sudo cat /sys/kernel/debug/tracing/trace_pipe  # Monitor
```
