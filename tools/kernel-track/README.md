# Kernel Track Tool

`ktrack.sh` tracks Linux kernel source changes and provides checkpoint-based restore/cleanup.

Path: `tools/kernel-track/ktrack.sh`

## What It Stores

Each checkpoint is saved under `tools/kernel-track/checkpoints/<id>/` with:
- `tracked.patch`
- `changed-files.txt`
- `tracked-existing-files.txt`
- `tracked-deleted-files.txt`
- `tracked-current.tar` (snapshot of current changed files that still exist)
- `meta.env`
- optional untracked snapshot files

## Common Commands

```sh
# status
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh status

# create checkpoint
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh checkpoint --label my-change

# list/show checkpoints
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh list
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh show --id <checkpoint-id>

# revert (dry-run by default)
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last --apply

# clean generated build files in changed dirs
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last --apply
```

## Build Integration

`Makefile` calls `auto-checkpoint` before:
- `vmlinux`
- `kernel`
- `headers-install`
- `modules-install`

Helper make targets:
- `make ktrack-status`
- `make ktrack-list`
- `make ktrack-checkpoint`

## Tests

Tool tests live with the tool:
- `tools/kernel-track/tests/run.sh`

What it validates:
- checkpoint creation
- auto-checkpoint dedupe
- revert apply flow
- build artifact cleanup

Run:

```sh
./tools/kernel-track/tests/run.sh
```
