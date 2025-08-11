# Determine project root (4 levels up from current directory)
PROJECT_ROOT := $(realpath ../../../..)
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

# Kernel module settings
obj-m += custom_kfunc.o
KBUILD_CFLAGS += -g -O2

# Targets
BPF_PROG := bpf_prog_custom.o
USER_PROGS := loader trigger
KMOD := custom_kfunc.ko

.PHONY: all clean

all: $(BPF_PROG) $(USER_PROGS) $(KMOD)

# Generate vmlinux.h if it doesn't exist
vmlinux.h:
	@if [ ! -f vmlinux.h ]; then \
		if [ -f $(BPFTOOL) ]; then \
			$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		else \
			bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h; \
		fi \
	fi

# Build BPF program
$(BPF_PROG): bpf_prog_custom.c vmlinux.h
	$(CLANG) $(BPF_INCLUDES) $(BPF_CFLAGS) -o $@ $<

# Build kernel module
$(KMOD): custom_kfunc.c
	$(MAKE) -C $(LINUX_DIR) M=$(PWD) modules

# Build user-space loader
loader: loader.c
	$(CC) $(USER_CFLAGS) $(USER_INCLUDES) $< $(USER_LDFLAGS) $(USER_LIBS) -o $@

# Build trigger program
trigger: trigger.c
	$(CC) $(USER_CFLAGS) $(USER_INCLUDES) $< $(USER_LDFLAGS) $(USER_LIBS) -o $@

clean:
	rm -f $(BPF_PROG) $(USER_PROGS)
	rm -f *.ko *.o *.mod *.mod.c *.mod.o modules.order Module.symvers
	rm -rf .tmp_versions/ .*.cmd
	rm -f vmlinux.h