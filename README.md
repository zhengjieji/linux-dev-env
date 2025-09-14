# Linux Development Environment

This repository contains workflows for building and modifying the Linux kernel, plus **Simple BPF Verifier Replacement Tools** and **BPF Micro-Benchmarking Suite**.

## BPF Micro-Benchmarks

Performance testing framework for comparing original and custom BPF kfunc implementations.

### Structure
```
micro-benchmark/
└── <kfunc_name>/           # Top-level directory named after the kfunc
    ├── original/           # Original kernel implementation
    │   ├── bpf_prog.c     # BPF program using original kfunc
    │   ├── loader.c       # User-space loader
    │   ├── trigger.c      # Test trigger program
    │   ├── run.sh         # Execution script
    │   └── Makefile       # Build configuration
    └── custom/            # Custom implementation
        ├── bpf_prog_custom.c  # BPF program using custom kfunc
        ├── custom_kfunc.c     # Kernel module with custom kfunc
        ├── loader.c           # User-space loader
        ├── trigger.c          # Test trigger program
        ├── run.sh             # Execution script
        └── Makefile           # Build configuration
```

### Building BPF Programs
```bash
# Build programs in a specific directory
cd micro-benchmark/<kfunc_name>/original
make

# Or for custom implementation
cd micro-benchmark/<kfunc_name>/custom
make
```

## BPF Verifier Replacement

Simple system to replace the kernel BPF verifier with your custom implementation. The verifier replacement tools are now located within each kfunc's micro-benchmark directory.

### Structure
```
micro-benchmark/
└── <kfunc_name>/                      # e.g., bpf_send_signal_task
    ├── kfunc-config.yaml              # Configuration of files to replace
    ├── kfunc-replacement/              # Kfunc replacement tools
    │   ├── original_bpf_trace.c       # Original kernel implementation
    │   ├── custom_bpf_trace.c         # Your custom kfunc implementation
    │   ├── setup_kfunc.sh             # Copy kfunc from kernel source
    │   ├── replace_kfunc.sh           # Replace kernel with custom kfunc
    │   ├── revert_kfunc.sh            # Revert to original kfunc
    │   └── Makefile                   # Kfunc management commands
    ├── verifier-replacement/           # Verifier replacement tools
    │   ├── original.c                 # Original kernel verifier
    │   ├── custom.c                   # Your custom verifier implementation
    │   ├── setup_verifiers.sh         # Copy verifiers from kernel source
    │   ├── replace_verifier.sh        # Replace kernel with custom verifier
    │   ├── revert_verifier.sh         # Revert to original verifier
    │   └── Makefile                   # Verifier management commands
    └── test/                          # Test programs for the kfunc
```

### Usage (from kfunc verifier-replacement directory)

Navigate to the specific kfunc's verifier-replacement directory:
```bash
cd micro-benchmark/bpf_send_signal_task/verifier-replacement/
```

**1. Setup (First Time)**
```bash
make setup
```

**2. Check Status**
```bash
make status
```

**3. Edit Custom Verifier**
```bash
vi custom.c
```

**4. Replace Verifier**
```bash
sudo make replace
# Then rebuild kernel from project root:
cd ../../../..
sudo make vmlinux
sudo reboot
```

**5. Revert When Needed**
```bash
sudo make revert
# Then rebuild kernel and reboot
```

**6. Clean Up**
```bash
make clean
```

### Makefile Targets (in verifier-replacement directory)

- **`make setup`** - Copy original verifier from kernel source
- **`make replace`** - Replace kernel with custom verifier  
- **`make revert`** - Revert to original verifier
- **`make status`** - Show verifier status and usage
- **`make clean`** - Clean verifier files

## BPF Kfunc Replacement

System to replace kernel kfunc implementations with custom versions for testing and benchmarking.

### Usage (from kfunc kfunc-replacement directory)

Navigate to the specific kfunc's kfunc-replacement directory:
```bash
cd micro-benchmark/bpf_send_signal_task/kfunc-replacement/
```

**1. Setup (First Time)**
```bash
make setup
```

**2. Check Status**
```bash
make status
```

**3. Edit Custom Kfunc Implementation**
```bash
vi custom_bpf_trace.c
# Modify the bpf_send_signal_task function
```

**4. Replace Kfunc**
```bash
sudo make replace
# Then rebuild kernel from project root:
cd ../../../..
sudo make vmlinux
sudo reboot
```

**5. Show Differences**
```bash
make diff
```

**6. Revert When Done**
```bash
sudo make revert
# Then rebuild kernel and reboot
```

**7. Clean Up**
```bash
make clean
```

### Makefile Targets (in kfunc-replacement directory)

- **`make setup`** - Copy original kfunc from kernel source
- **`make replace`** - Replace kernel with custom kfunc implementation
- **`make revert`** - Revert to original kfunc
- **`make status`** - Show current kfunc status
- **`make diff`** - Show differences between original and custom
- **`make clean`** - Clean kfunc files

### Configuration

Each kfunc directory contains a `kfunc-config.yaml` file that specifies which kernel files implement the kfunc. For `bpf_send_signal_task`, this is `kernel/trace/bpf_trace.c`.

---

## Original Linux Development Environment

This repository contains *one* workflow for building and modifying the Linux kernel. It consists of two main components. The first is a docker container that contains all the requirements to build the Linux kernel, as well as the requirements to run QEMU. The second is a QEMU  script that boots a virtual machine running a custom version of the Linux kernel. Using these together allows you to easily make and test changes to the Linux kernel without needing to manage all the packages locally.


==Make sure you have pahole installed!==: `sudo apt-get install dwarves`

***This repository is cloned and modified from rosalab/(unknown)-kernel***

#### Build Docker Container
```sh
sudo make docker 
```

#### Download Linux

```sh
git clone https://github.com/torvalds/linux.git

cd linux

# checkout to a specific tag
git checkout v6.13
```

#### Copy Config File to Linux Folder

```sh
cp linux-config-6.13/.config ./linux
```

#### Build Dependencies
```sh
cd ..

sudo make headers-install

sudo make modules-install
```

#### Build Linux
```sh
sudo make vmlinux
```

#### Build Tools
```sh
sudo make libbpf

sudo make bpftool
```

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
target remote:1234
c
```
then set your breakpoints and debug more


## Adding Ports to QEMU
By default host port 52223 is connected to port 52223 inside the QEMU virtual machine.
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

