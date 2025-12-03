# tp_btf/task_newtask Micro-Benchmark

This directory contains micro-benchmark tests for BPF programs using `tp_btf/task_newtask` tracepoint.

## Overview

The `tp_btf/task_newtask` tracepoint fires when a new task (process) is created via `fork()` or `clone()`. Programs using this tracepoint can inspect the new task's `task_struct`.

## Directory Structure

```
tp_btf/
├── bpf_progs/              # BPF programs (.kern.c files)
│   └── test_*.kern.c       # Auto-discovered by build
├── utils/
│   ├── loader.user.c       # Load and pin BPF programs
│   └── trigger.user.c      # Fork processes to trigger tracepoint
├── scripts/
│   ├── attach.sh           # Load programs (default: all)
│   ├── detach.sh           # Unload all programs
│   ├── trigger.sh          # Trigger + capture logs
│   └── run_all.sh          # Test each program separately
├── outputs/                # Logs and results
├── Makefile                # Auto-discovery build
└── README.md
```

## Quick Start

```bash
# Build everything
make

# Run all tests (1 iteration per program)
sudo ./scripts/run_all.sh

# Or specify iterations
sudo ./scripts/run_all.sh 100

# View results
cat outputs/summary.txt
```

## Manual Testing

```bash
# Build
make

# Load specific program
sudo ./scripts/attach.sh bpf_progs/test_cpumask.kern.o

# Or load all programs
sudo ./scripts/attach.sh

# Trigger (fork to create new tasks)
sudo ./scripts/trigger.sh 10

# Monitor output
sudo cat /sys/kernel/debug/tracing/trace_pipe

# Check logs
cat outputs/trace.log

# Detach
sudo ./scripts/detach.sh
```

## Adding New BPF Programs

1. Create `bpf_progs/test_<name>.kern.c`
2. Use `SEC("tp_btf/task_newtask")` for the tracepoint
3. Run `make` to build
4. Programs are auto-discovered

Example program:

```c
#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "GPL";

SEC("tp_btf/task_newtask")
int BPF_PROG(test_newtask, struct task_struct *task, u64 clone_flags)
{
    bpf_printk("New task created: pid=%d", task->pid);
    return 0;
}
```

## Pin Location

Programs are pinned to: `/sys/fs/bpf/micro_benchmark_tp_btf/`
