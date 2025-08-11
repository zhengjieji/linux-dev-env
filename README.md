# Linux Development Environment

This repository contains workflows for building and modifying the Linux kernel, plus **Simple BPF Verifier Replacement Tools**.

## BPF Verifier Replacement

Simple system to replace the kernel BPF verifier with your custom implementation.

### Structure
```
├── verifiers/
│   ├── original.c       # Original kernel verifier (copied from /linux)
│   └── custom.c         # Your custom verifier implementation  
├── setup_verifiers.sh   # Copy verifiers from kernel source
├── replace_verifier.sh  # Replace kernel with custom verifier
└── revert_verifier.sh   # Revert to original verifier
```

### Usage

**1. Setup (First Time)**
```bash
make verifier-setup
```

**2. Check Status**
```bash
make verifier-status
```

**3. Edit Custom Verifier**
```bash
vi verifiers/custom.c
```

**4. Replace Verifier**
```bash
sudo make verifier-replace
sudo reboot
```

**5. Revert When Needed**
```bash
sudo make verifier-revert
sudo reboot
```

**6. Clean Up**
```bash
make verifier-clean
```

### Makefile Targets

- **`make verifier-setup`** - Copy original verifier from kernel source
- **`make verifier-replace`** - Replace kernel with custom verifier  
- **`make verifier-revert`** - Revert to original verifier
- **`make verifier-status`** - Show verifier status and usage
- **`make verifier-clean`** - Clean verifier files and logs

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

