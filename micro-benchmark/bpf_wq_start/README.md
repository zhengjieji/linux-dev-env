# bpf_wq_start Micro-benchmark

This directory contains a minimal test for the `bpf_wq_start` kfunc.

## Structure

- `test/` - Contains the BPF program and user-space loader
  - `bpf_prog.c` - BPF program that uses bpf_wq_start
  - `loader.c` - User-space program to load and attach BPF program
  - `trigger.c` - Program to trigger TC events
  - `run.sh` - Script to run the complete test

- `kfunc-replacement/` - Contains kernel file replacements (if needed)
- `verifier-replacement/` - Contains verifier replacements (if needed)
- `kfunc-config.yaml` - Configuration for the kfunc

## Running the Test

```bash
cd test
sudo bash run.sh
```

## Kfuncs Used

- `bpf_wq_init` - Initialize a workqueue
- `bpf_wq_set_callback_impl` - Set the workqueue callback
- `bpf_wq_start` - Start the workqueue