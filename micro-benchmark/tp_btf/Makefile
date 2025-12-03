# Makefile for tp_btf/task_newtask micro-benchmark

# Project paths
PROJECT_ROOT := $(realpath ../..)
LINUX_DIR := $(PROJECT_ROOT)/linux
LIBBPF_DIR := $(LINUX_DIR)/tools/lib/bpf
BPFTOOL := $(LINUX_DIR)/tools/bpf/bpftool/bpftool

# Compiler settings
CC := gcc
CLANG := clang

# BPF compilation flags
BPF_CFLAGS := -target bpf -g -Wall -O2 -c
BPF_INCLUDES := -I. \
                -I$(LINUX_DIR)/usr/include \
                -I$(LINUX_DIR)/tools/lib

# User-space compilation flags
USER_CFLAGS := -g -Wall
USER_INCLUDES := -I$(LINUX_DIR)/usr/include \
                 -I$(LINUX_DIR)/tools/lib
USER_LDFLAGS := -L$(LIBBPF_DIR)
USER_LIBS := -lbpf

# Auto-discover all BPF programs in bpf_progs/
BPF_SRCS := $(wildcard bpf_progs/*.kern.c)
BPF_OBJS := $(BPF_SRCS:.c=.o)

# User-space programs
USER_PROGS := loader trigger

.PHONY: all clean help

all: $(BPF_OBJS) $(USER_PROGS)

help:
	@echo "Micro-benchmark Makefile for tp_btf/task_newtask"
	@echo ""
	@echo "Targets:"
	@echo "  make           - Build all BPF programs and user-space tools"
	@echo "  make clean     - Remove all built files"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "BPF programs found:"
	@for prog in $(BPF_SRCS); do echo "  - $$prog"; done

# Generate vmlinux.h if needed
vmlinux.h:
	@echo "Generating vmlinux.h..."
	@if [ ! -f vmlinux.h ]; then \
		if [ -f $(BPFTOOL) ]; then \
			$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		else \
			bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		fi \
	fi

# Build BPF programs
bpf_progs/%.kern.o: bpf_progs/%.kern.c vmlinux.h
	@echo "Compiling BPF program: $<"
	$(CLANG) $(BPF_INCLUDES) $(BPF_CFLAGS) -o $@ $<

# Build user-space loader
loader: utils/loader.user.c
	@echo "Building loader..."
	$(CC) $(USER_CFLAGS) $(USER_INCLUDES) $< $(USER_LDFLAGS) $(USER_LIBS) -o $@

# Build trigger program
trigger: utils/trigger.user.c
	@echo "Building trigger..."
	$(CC) $(USER_CFLAGS) $< -o $@

clean:
	@echo "Cleaning..."
	rm -f $(BPF_OBJS) $(USER_PROGS)
	rm -f vmlinux.h
	rm -f outputs/*.log outputs/*.txt outputs/.*.pid
	@echo "Clean complete"
