# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Linux kernel development environment focused on BPF (Berkeley Packet Filter) testing and micro-benchmarking. The project uses Docker containers to provide a consistent build environment and QEMU for kernel testing without requiring local package management.

## Essential Commands

### Initial Setup
```bash
# Build the Docker container (required once)
sudo make docker

# Build the Linux kernel
sudo make vmlinux

# Install kernel headers and modules
sudo make headers-install
sudo make modules-install

# Build BPF development tools
sudo make libbpf
sudo make bpftool
```

### Development Workflow
```bash
# Run QEMU with the custom kernel
make qemu-run

# SSH into the running QEMU instance
make qemu-ssh

# Enter the Docker container for debugging
make enter-docker

# Clean build artifacts
make linux-clean
make libbpf-clean
make bpftool-clean
```

### Building BPF Programs (in micro-benchmark directories)
```bash
# Build all BPF kernel objects and user programs
make

# Clean built objects
make clean
```

## Architecture and Structure

### Directory Layout
- `/linux/` - Linux kernel source code (must be cloned separately from github.com/torvalds/linux)
- `/linux-config-6.13/` - Kernel configuration files for different versions
- `/micro-benchmark/` - BPF micro-benchmarking programs
  - Each subdirectory contains pairs of BPF kernel programs (*.kern.c) and user-space loaders (*.user.c)
  - `vmlinux.h` headers provide kernel type definitions
- `/q-script/yifei-q` - QEMU launch script with networking, SSH, and 9p filesystem support

### Docker-based Build System
All kernel compilation happens inside a Docker container (`runtime-dev-zj`) which includes:
- Full kernel build toolchain (gcc, clang, bison, flex)
- BPF development tools (libbpf, bpftool)
- QEMU for virtualization
- Required libraries for kernel and BPF development

The Makefile wraps Docker commands to:
- Mount the Linux source as a volume
- Execute build commands in the container
- Map ports for SSH (52222) and network services (52223)
- Enable GDB debugging (port 1234)

### QEMU Virtualization
The q-script sets up a QEMU VM with:
- 9p filesystem for sharing host directories
- Virtio networking with port forwarding
- SSH server for remote access
- BPF filesystem mounted at `/sys/fs/bpf`
- Automatic kernel module loading
- GDB server for kernel debugging

### BPF Development
The micro-benchmark directories contain testing infrastructure for BPF programs:
- Kernel-side BPF programs compiled with clang -target bpf
- User-space loaders using libbpf
- Scripts for loading, triggering, and dumping BPF state

## Important Notes

- Always ensure the Linux kernel source is present in the `linux/` directory
- The kernel must be configured with the provided config file before building
- Port 52222 is used for SSH, 52223 for general networking, and 1234 for GDB
- BPF programs require both kernel objects (.kern.o) and user-space loaders
- The project currently targets Linux kernel v6.13