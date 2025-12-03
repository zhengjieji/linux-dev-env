# BPF Kernel Patch

Track kernel file modifications across experiments. Safely apply/revert changes without losing work or creating conflicts.

## Quick Start

```bash
cd tools/bpf-kernel-patch

# Create a new experiment
make new NAME=my_kfunc_opt

# Track files you want to modify
make track FILE=kernel/trace/bpf_trace.c
make track FILES="kernel/bpf/helpers.c kernel/bpf/verifier.c"

# Edit the patch files
vim ../../experiments/my_kfunc_opt/patches/kernel/trace/bpf_trace.c

# Apply changes to kernel
make apply

# Build and test
cd ../..
sudo make vmlinux
make qemu-run

# When done, revert changes
cd tools/bpf-kernel-patch
make revert
```

## Commands

| Command | Description |
|---------|-------------|
| `make new NAME=xxx` | Create new experiment, set as active |
| `make list` | List all experiments |
| `make delete NAME=xxx` | Delete an experiment |
| `make activate NAME=xxx` | Switch active experiment |
| `make track FILE=xxx` | Track existing kernel file (backup + copy to patches) |
| `make track FILES="a b c"` | Track multiple files |
| `make track-add FILE=xxx` | Track a new file (will be added to kernel) |
| `make untrack FILE=xxx` | Stop tracking a file |
| `make apply` | Apply patches to kernel source |
| `make revert` | Revert kernel to original state |
| `make status` | Show current experiment status |
| `make diff` | Show diff for all tracked files |
| `make diff FILE=xxx` | Show diff for specific file |
| `make help` | Show help message |

## Directory Structure

```
experiments/                   # Created in project root
├── state.json                 # Global state (active experiment, applied status)
└── my_kfunc_opt/
    ├── manifest.json          # Experiment config (file list, modes, hashes)
    ├── backups/               # Original kernel files (preserved)
    │   └── kernel/trace/bpf_trace.c
    └── patches/               # Your modified files (edit these)
        └── kernel/trace/bpf_trace.c
```

## Workflow

### Replacing Existing Files

```bash
make new NAME=optimize_signal
make track FILE=kernel/trace/bpf_trace.c

# Edit the patch file
vim ../../experiments/optimize_signal/patches/kernel/trace/bpf_trace.c

# Apply to kernel
make apply

# Test...
cd ../.. && sudo make vmlinux && make qemu-run

# Revert when done
cd tools/bpf-kernel-patch && make revert
```

### Adding New Files

```bash
make new NAME=new_helper
make track-add FILE=kernel/bpf/my_new_helper.c

# Create your new file
vim ../../experiments/new_helper/patches/kernel/bpf/my_new_helper.c

# Apply (copies file to kernel)
make apply

# Revert (deletes file from kernel)
make revert
```

### Switching Experiments

```bash
# Must revert current experiment first
make revert

# Then activate another
make activate NAME=other_experiment

# Apply if needed
make apply
```

## Safety Features

1. **Hash verification**: Before `apply`, verifies kernel files haven't been modified outside the experiment
2. **Applied state tracking**: Prevents deleting or switching experiments with applied changes
3. **Backup preservation**: Original files are always preserved in `backups/`
4. **Mode enforcement**: `track` requires existing files, `track-add` requires non-existing files

## Configuration

Override the Linux source path:

```bash
make track FILE=kernel/bpf/helpers.c LINUX=/path/to/linux
```

Default: `../../linux`

## Requirements

- `jq` - JSON processor (install: `sudo apt-get install jq`)
- `bash` 4.0+

## Example Session

```bash
$ make new NAME=send_signal_opt
[OK] Created experiment 'send_signal_opt' and set as active

$ make track FILE=kernel/trace/bpf_trace.c
[OK] Tracking 'kernel/trace/bpf_trace.c' (replace mode)
[INFO]   Edit: /path/to/experiments/send_signal_opt/patches/kernel/trace/bpf_trace.c

$ make status

Active experiment: send_signal_opt
Changes applied: no

Tracked files:
  [replace] kernel/trace/bpf_trace.c (unchanged)

$ vim ../../experiments/send_signal_opt/patches/kernel/trace/bpf_trace.c
# ... make changes ...

$ make diff
=== kernel/trace/bpf_trace.c (replace) ===
--- backup
+++ patch
@@ -100,6 +100,7 @@
...

$ make apply
[INFO] Verifying files...
[INFO] Applying changes...
[OK] Applied: kernel/trace/bpf_trace.c (replace)
[OK] All changes applied for experiment 'send_signal_opt'

[INFO] Next: sudo make vmlinux && make qemu-run

$ cd ../.. && sudo make vmlinux && make qemu-run
# ... test ...

$ cd tools/bpf-kernel-patch && make revert
[INFO] Reverting changes...
[OK] Reverted: kernel/trace/bpf_trace.c
[OK] All changes reverted for experiment 'send_signal_opt'
```
