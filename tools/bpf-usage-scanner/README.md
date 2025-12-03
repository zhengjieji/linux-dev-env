# BPF Usage Scanner

Scan BPF projects for helper and kfunc usage.

## Usage

```bash
# Run after bpf-api-extractor
./run.sh
```

## Requirements

- Python 3.8+
- Output from bpf-api-extractor (helpers.csv and kfuncs.csv)

## Output

- `output/summary.csv` - Cross-project usage summary
- `output/<project>/helpers.csv` - Per-project helper usage
- `output/<project>/kfuncs.csv` - Per-project kfunc usage
