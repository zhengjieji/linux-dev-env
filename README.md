# Linux Dev Environment (Single VM)

Dockerized Linux kernel development workflow with QEMU runtime and checkpoint tooling.

This repo is a local dev environment around:
- Docker build/runtime image
- Linux source tree at `./linux`
- QEMU launcher script `q-script/yifei-q`
- Kernel change tracker `tools/kernel-track/ktrack.sh`

## Quick Start

Recommended:

```sh
./scripts/setup.sh
```

What it does:
- clone Linux repo into `./linux` (if missing)
- checkout `v6.17`
- copy config from `linux-configs/linux-config-6.17/.config`
- build docker image, kernel artifacts, libbpf, bpftool

Common variants:

```sh
# skip heavy build steps
./scripts/setup.sh --skip-kernel-build --skip-tools-build

# use another kernel tag during setup
./scripts/setup.sh --linux-tag v6.18-rc1
```

## Daily Workflow

Build:

```sh
make vmlinux
make kernel
make headers-install
make modules-install
make libbpf
make bpftool
```

Run VM:

```sh
make qemu-run
make qemu-ssh
```

Enter runtime container shell:

```sh
make enter-docker
```

GDB (from another terminal):

```sh
cd linux
gdb vmlinux
target remote:1210
```

## Switch Kernel Version

Use:

```sh
./scripts/switch-kernel.sh --tag v6.18
```

Default flow:
- checkout target tag
- migrate config using `make olddefconfig` (non-interactive)
- validate Linux dev flow (build + qemu ssh smoke)
- save working config to `linux-configs/linux-config-<version>/.config`

Useful options:

```sh
./scripts/switch-kernel.sh --tag v6.18 --skip-qemu-ssh
./scripts/switch-kernel.sh --tag v6.18 --force-save
```

## Kernel Checkpoints

Build targets `vmlinux`, `kernel`, `headers-install`, `modules-install` auto-create checkpoints when tracked Linux files changed.

Quick commands:

```sh
make ktrack-status
make ktrack-list
make ktrack-checkpoint
```

Direct tool usage:

```sh
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last --apply
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last --apply
```

Details: `tools/kernel-track/README.md`.

## Push to GitHub (`single-vm`)

Use:

```sh
./scripts/push-github.sh
```

This script:
- excludes `linux/` from staging/pushing
- creates a commit if needed
- pushes `HEAD` to `origin/single-vm`
- creates local branch `single-vm` if missing

To set GitHub default branch to `single-vm`, change it in GitHub repository settings.

## Tests

Run all non-destructive tests:

```sh
./tests/run.sh
```

Run suites directly:

```sh
./tests/vm-linux-dev/run.sh
./tools/kernel-track/tests/run.sh
```

## Port Mapping

Default host ports from `Makefile`:
- SSH: `127.0.0.1:51022` -> container `52222` -> guest `22`
- NET: `127.0.0.1:51023` -> container `52223` -> guest `52223`
- GDB: `127.0.0.1:1210` -> container/QEMU `1234`

If you add or change forwarded ports, update both:
- `Makefile` `qemu-run` port mapping
- `q-script/yifei-q` `-netdev user ... hostfwd=...`
