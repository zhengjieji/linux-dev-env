# tp/syscalls/sys_enter_getcwd Micro-Benchmark

Standardized benchmark for testing BPF programs on the `tp/syscalls/sys_enter_getcwd` tracepoint.

## Hook Point

- **Type**: Tracepoint
- **Location**: `tp/syscalls/sys_enter_getcwd`
- **Trigger**: Call `getcwd()` syscall

## Structure

```
├── bpf_progs/              # BPF test programs (*.kern.c)
├── utils/                  # loader.user.c, trigger.user.c
├── scripts/                # attach.sh, detach.sh, trigger.sh, run_all.sh
├── outputs/                # Test results (*.log)
└── Makefile
```

## Quick Start

```bash
# Build
make

# Run all tests (default: 1 iteration per program)
sudo ./scripts/run_all.sh

# Or specify iterations
sudo ./scripts/run_all.sh 1000

# View results
cat outputs/summary.txt
```

## Manual Testing

```bash
# Attach all programs (default)
sudo ./scripts/attach.sh

# Or attach specific program
sudo ./scripts/attach.sh bpf_progs/test_program.kern.o

# Trigger and capture logs (default: 1 iteration)
sudo ./scripts/trigger.sh

# Or specify iterations
sudo ./scripts/trigger.sh 1000

# View outputs
cat outputs/trace.log
cat outputs/dmesg.log

# Detach
sudo ./scripts/detach.sh
```

## Load Multiple Programs

```bash
# Load all programs (default)
sudo ./scripts/attach.sh

# Load specific programs
sudo ./scripts/attach.sh bpf_progs/prog1.kern.o bpf_progs/prog2.kern.o

# Trigger (all loaded programs run, default: 1 iteration)
sudo ./scripts/trigger.sh

# Detach all
sudo ./scripts/detach.sh
```

## Adding New BPF Programs

1. Create `bpf_progs/test_<name>.kern.c`:

```c
// SPDX-License-Identifier: GPL-2.0
#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>

char _license[] SEC("license") = "GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int test_my_feature(void *ctx)
{
    bpf_printk("TEST: my test output");
    return 0;
}
```

2. Build: `make`
3. Test: `sudo ./scripts/attach.sh` (loads all) or `sudo ./scripts/attach.sh bpf_progs/test_<name>.kern.o` (specific)

## Scripts

- **attach.sh** - Load BPF programs (pins them, loader exits). Default: load all programs.
- **detach.sh** - Unload all pinned programs
- **trigger.sh** - Run trigger + capture trace_pipe and dmesg. Default: 1 iteration.
- **run_all.sh** - Test programs separately (attach → test → detach each). Default: 1 iteration per program.

## Output Files

All outputs in `outputs/`:
- `trace.log` - trace_pipe output
- `dmesg.log` - kernel messages
- `<prog>_trace.log` - per-program trace (from run_all.sh)
- `<prog>_dmesg.log` - per-program dmesg (from run_all.sh)
- `summary.txt` - test summary (from run_all.sh)

## How It Works

**Loader**: Load-and-exit pattern
1. Loads BPF programs
2. Pins to `/sys/fs/bpf/micro_benchmark_tp_getcwd/<prog_name>`
3. Exits (programs persist)

**Trigger**: Calls `getcwd()` repeatedly with 1ms delay between calls

**run_all.sh**: Tests each program separately for clean output
- For each program: attach → trigger → save logs → detach
- Each program gets isolated test environment
- Generates per-program logs and summary

## BPF Programs

### test_simple.kern.c
Simple tracepoint program that prints current pid/tgid.
- Output: `TP: pid=X tgid=Y`

### test_const_propagation.kern.c
Tests custom kfuncs with/without constant propagation optimization.
- Requires: `const_propagation_original()`, `const_propagation_optimized()` kfuncs
- Output: `CONST_PROP: original=X optimized=Y` (times in ns)

### test_bpf_list_pop_front.kern.c
Tests `bpf_list_pop_front()` kfunc performance.
- Tests list operations on BPF linked lists
- Output: `LIST_POP_FRONT: time=X` (time in ns)

### test_bpf_send_signal_task.kern.c
Tests `bpf_send_signal_task()` kfunc performance.
- Uses signal 0 (null signal) for safe performance measurement
- Output: `SEND_SIGNAL_TASK: time=X ret=Y`

## Troubleshooting

**Compilation error**: Check vmlinux.h exists: `ls -lh vmlinux.h`

**Program won't load**: Check verifier errors: `dmesg | tail -50`

**No trace output**:
- Check program loaded: `ls /sys/fs/bpf/micro_benchmark_tp_getcwd/`
- Check tracing enabled: `cat /sys/kernel/debug/tracing/tracing_on`

**Permission denied**: Run with `sudo`
