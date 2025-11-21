# Determine project root (now 3 levels up from current directory)
PROJECT_ROOT := $(realpath ../../..)
LINUX_DIR := $(PROJECT_ROOT)/linux
LIBBPF_DIR := $(LINUX_DIR)/tools/lib/bpf
BPFTOOL := $(LINUX_DIR)/tools/bpf/bpftool/bpftool

# Compiler settings
CC := gcc
CLANG := clang

# BPF compilation flags
BPF_CFLAGS := -target bpf -g -Wall -O2 -c
BPF_INCLUDES := -I$(LINUX_DIR)/usr/include \
                -I$(LINUX_DIR)/tools/lib

# User-space compilation flags
USER_CFLAGS := -g -Wall
USER_INCLUDES := -I$(LINUX_DIR)/usr/include \
                 -I$(LINUX_DIR)/tools/lib
USER_LDFLAGS := -L$(LIBBPF_DIR)
USER_LIBS := -lbpf

# Targets
BPF_PROGS := bpf_prog.o bpf_prog_optimized.o
USER_PROGS := loader trigger

.PHONY: all clean

all: $(BPF_PROGS) $(USER_PROGS)

# Generate vmlinux.h if it doesn't exist
vmlinux.h:
	@if [ ! -f vmlinux.h ]; then \
		if [ -f $(BPFTOOL) ]; then \
			$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		else \
			bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		fi \
	fi

# Build BPF programs
%.o: %.c vmlinux.h
	$(CLANG) $(BPF_INCLUDES) $(BPF_CFLAGS) -o $@ $<

# Build user-space loader
loader: loader.c
	$(CC) $(USER_CFLAGS) $(USER_INCLUDES) $< $(USER_LDFLAGS) $(USER_LIBS) -o $@

# Build trigger program (no BPF libs needed)
trigger: trigger.c
	$(CC) $(USER_CFLAGS) $< -o $@

clean:
	rm -f $(BPF_PROGS) $(USER_PROGS)
	rm -f vmlinux.h