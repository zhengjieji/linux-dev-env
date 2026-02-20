# Linux Development Environment

This repository contains *one* workflow for building and modifying the Linux kernel. It consists of two main components. The first is a docker container that contains all the requirements to build the Linux kernel, as well as the requirements to run QEMU. The second is a QEMU  script that boots a virtual machine running a custom version of the Linux kernel. Using these together allows you to easily make and test changes to the Linux kernel without needing to manage all the packages locally.

***This repository is cloned and modified from rosalab/(unknown)-kernel***

#### One-Command Setup (No sudo)
```sh
./scripts/setup.sh
```

This script will:
- clone Linux into `./linux` (if missing)
- checkout `v6.17`
- copy `linux-configs/linux-config-6.17/.config` into `linux/.config`
- build docker image + kernel + headers/modules + libbpf + bpftool

Useful variants:

```sh
# skip heavy build steps
./scripts/setup.sh --skip-kernel-build --skip-tools-build

# use a different kernel tag
./scripts/setup.sh --linux-tag v6.18-rc1
```

#### Manual Setup (No sudo)

```sh
make docker

git clone https://github.com/torvalds/linux.git
git -C linux checkout v6.17

cp linux-configs/linux-config-6.17/.config ./linux/.config

make headers-install
make modules-install
make vmlinux
make libbpf
make bpftool
```

#### Switch Kernel Version (Auto migrate config + test + save)

Use the switch script when moving to a new kernel tag.

It does:
- checkout target tag
- migrate your base config via `make olddefconfig` (non-interactive oldconfig)
- run Linux dev validation (build + qemu ssh smoke by default)
- save the verified config to `linux-configs/linux-config-<version>/.config`

```sh
# full flow
./scripts/switch-kernel.sh --tag v6.18

# faster flow (skip qemu ssh smoke)
./scripts/switch-kernel.sh --tag v6.18 --skip-qemu-ssh

# if overwriting an existing saved config
./scripts/switch-kernel.sh --tag v6.18 --force-save
```

#### Push Repo to GitHub Branch `katran-exp` (Exclude `linux/`, `source/`, `results/`)

```sh
./scripts/push-github.sh
```

This script:
- ensures `linux/`, `source/`, and `results/` are ignored
- auto-untracks those dirs from git index on first run (keeps local files)
- commits local changes (if any)
- pushes `HEAD` to `origin/katran-exp` by default
- first run: creates local `katran-exp` from base `dual-vm` (or `origin/dual-vm`)
- supports override via `--branch` and `--base-branch`

When you run kernel build targets (`vmlinux`, `kernel`, `headers-install`, `modules-install`),
the pipeline now auto-creates a checkpoint if tracked files in `linux/` changed.

#### Run QEMU
```sh
make qemu-run
```

#### If you want to ssh into the QEMU
```sh
make qemu-ssh
```

#### Run Dual VMs (vm1 + vm2)

Start both VMs in separate terminals:

```sh
make dual-vm1
make dual-vm2
```

Inspect, SSH, and stop:

```sh
make dual-vm-status
make dual-vm1-ssh
make dual-vm2-ssh
make dual-vm-stop
```

Dual VM details:
- vm1 SSH: `127.0.0.1:53022`
- vm2 SSH: `127.0.0.1:53122`
- vm1 data-plane IP: `192.168.100.1/24`
- vm2 data-plane IP: `192.168.100.2/24`
- vm1 and vm2 share a bridge in the session container for direct L2 connectivity

#### If you want to enter the docker container where QEMU is running
```sh
make enter-docker
```

#### If you want to debug the kernel using GDB

In an another terminal
```sh
cd linux
gdb vmlinux
target remote:1210
```
then set your breakpoints and debug more

## Kernel Change Tracker

The tracker lives at `tools/kernel-track/ktrack.sh` and stores checkpoints under
`tools/kernel-track/checkpoints/`.

Common commands:

```sh
# current change/checkpoint state
make ktrack-status

# list checkpoints
make ktrack-list

# create manual checkpoint
make ktrack-checkpoint
```

Direct script commands:

```sh
# preview a revert without changing files
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last

# apply revert to last checkpoint
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh revert --last --apply

# preview cleanup of build artifacts corresponding to that checkpoint
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last

# apply build artifact cleanup
KTRACK_KERNEL_DIR=$PWD/linux tools/kernel-track/ktrack.sh clean-build --last --apply
```

## Dual VM Testing

Dry-run checks:

```sh
./tests/vm-linux-dev/run.sh
```

Live dual-vm integration (ssh + ping + xdp smoke):

```sh
./tests/vm-linux-dev/dual-vm-live.sh

# or through unified live runner
./tests/vm-linux-dev/run-live.sh --dual-vm
```


## Adding Ports to QEMU
By default host port 51023 is connected to port 52223 inside the QEMU virtual machine.
If you need to be able to connect to more than one port (or a specific port) on your custom kernel from the host, you will have to add new rules.
The needed rules are in `q-script/yifei-q` and in the Makefile.

### Makefile Modifications
You must add a line that maps a host port to a Docker port.
In the Makefile you must add a line 
    ```-p 127.0.0.1:HOST_PORT:DOCKER_PORT```
This will map the host port to the docker port.

### q-script Modifications
You must modify the q-script to connect the DOCKER_PORT to a QEMU_PORT.
In the q-script you must append a new rule.
Find the line that starts with `"net += -netdev user..."`.
Then at the end of the line add the text ```"hostfwd=tcp::DOCKER_PORT-:QEMU_PORT"```

## Experiments (Exp1/Exp2/Exp3)

Plans and reports:

- `documents/experiment-1.md`
- `documents/experiment-1-report-20260219T233444Z.md`
- `documents/experiment-2.md`
- `documents/experiment-3.md`

Initialize organized results directories:

```sh
make exp-results-init
```

### Exp1 (implemented)

Build Katran object:

```sh
make katran-clone
make katran-build-host
```

Prepare both VMs:

```sh
make exp1-vm-setup
```

Run one case:

```sh
make exp1-run-one EXP1_MODE=baseline-no-katran EXP1_RATE_PPS=200000 EXP1_DURATION_SECS=30
make exp1-run-one EXP1_MODE=katran-orig-bpf EXP1_RATE_PPS=200000 EXP1_DURATION_SECS=30
```

Run full suite (Exp1 matrix):

```sh
make exp1-run-suite
```

Plot latest suite:

```sh
make exp1-plot-latest
```

Legacy aliases are still available:

- `make katran-exp-one`
- `make katran-exp-suite`
- `make katran-plot-suite`

### Exp2 (implemented)

Recommended flow:

```sh
make exp2-precheck
make exp2-vm-setup
make exp2-prepare-source
make exp2-build-oracle
make exp2-bytecode-compare # optional manual compare
make exp2-test-smoke
```

Then run Exp2 measurements:

```sh
make exp2-discovery
make exp2-run-throughput
make exp2-run-latency
make exp2-analyze
make exp2-plot
```

Tune latency progress refresh if needed (default `1` second):

```sh
make exp2-run-latency EXP2_LAT_PROGRESS_INTERVAL=1
```

Or run one-shot pipeline:

```sh
make exp2-run-all
```

For plots only from latest analysis:

```sh
make exp2-plot
```

Exp2 result layout:

- `results/exp2/precheck/`
- `results/exp2/setup/`
- `results/exp2/smoke/`
- `results/exp2/discovery/`
- `results/exp2/measurement/throughput/`
- `results/exp2/measurement/latency/`
- `results/exp2/oracle-builds/` (includes bytecode compare artifacts per oracle build)
- `results/exp2/analysis/`

### Exp3 (placeholder)

```sh
make exp3-auto-v0
```

Overall organized results:

- `results/exp1/runs/`
- `results/exp1/suites/`
- `results/exp2/`
- `results/exp3/runs/`
- `results/exp3/analysis/`
