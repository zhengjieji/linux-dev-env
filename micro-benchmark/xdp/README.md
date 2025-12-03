# XDP Micro-Benchmark

Standardized benchmark for testing BPF programs on XDP (eXpress Data Path).

## Hook Point

- **Type**: XDP (eXpress Data Path)
- **Attach**: XDP on loopback interface (`lo`)
- **Trigger**: Send UDP packets to loopback

## Quick Start

```bash
# Build
make

# Run all tests (default: 1 iteration per program)
sudo ./scripts/run_all.sh

# View results
cat outputs/summary.txt
```

## Manual Testing

```bash
# Attach all programs (default)
sudo ./scripts/attach.sh

# Trigger and capture logs (default: 1 iteration)
sudo ./scripts/trigger.sh

# View outputs
cat outputs/trace.log

# Detach
sudo ./scripts/detach.sh
```

## BPF Programs

### test_simple.kern.c
Simple XDP program that prints current pid/tgid.
- Output: `XDP: pid=X tgid=Y`

## Adding New BPF Programs

1. Create `bpf_progs/test_<name>.kern.c`:

```c
// SPDX-License-Identifier: GPL-2.0
#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("xdp")
int test_my_feature(struct xdp_md *ctx)
{
    bpf_printk("TEST: my test output");
    return XDP_PASS;
}
```

2. Build: `make`
3. Test: `sudo ./scripts/attach.sh`

## Scripts

- **attach.sh** - Load BPF programs (pins them, loader exits). Default: load all programs.
- **detach.sh** - Unload all pinned programs
- **trigger.sh** - Send UDP packets + capture trace_pipe and dmesg. Default: 1 iteration.
- **run_all.sh** - Test programs separately (attach → test → detach each). Default: 1 iteration per program.

## How It Works

**Loader**: Load-and-exit pattern
1. Loads BPF programs
2. Attaches to XDP on `lo` interface
3. Pins to `/sys/fs/bpf/micro_benchmark_xdp/<prog_name>`
4. Exits (programs persist)

**Trigger**: Sends UDP packets to `127.0.0.1:9999` with 1ms delay between packets

**run_all.sh**: Tests each program separately for clean output
- For each program: attach → trigger → save logs → detach
- Each program gets isolated test environment
- Generates per-program logs and summary
