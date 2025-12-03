# BPF API Extractor

Extract BPF helper functions and kfuncs from Linux kernel source.

## Usage

```bash
./run.sh                              # Uses ../../linux by default
./run.sh --linux-dir /path/to/linux   # Custom kernel path
./run.sh --helpers-only               # Only extract helpers
./run.sh --kfuncs-only                # Only extract kfuncs
```

## Requirements

- Python 3.10+
- Linux kernel source
- (Optional) vmlinux with BTF for kfunc signatures

## Output

- `output/helpers.csv` - Helper functions with signatures and descriptions
- `output/kfuncs.csv` - Kfuncs with flags, program types, and source locations
