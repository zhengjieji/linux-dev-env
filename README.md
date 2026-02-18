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

#### Push Repo to GitHub Branch `single-vm` (Exclude `linux/`)

```sh
./scripts/push-github.sh
```

This script:
- ensures `linux/` is ignored and never staged
- commits local changes (if any)
- pushes `HEAD` to `origin/single-vm`
- creates local branch `single-vm` if missing

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
