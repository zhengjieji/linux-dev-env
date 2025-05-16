SOURCES := $(wildcard *.kern.c)
FILES := $(SOURCES:.c=.o)
SKEL_H := $(SOURCES:.kern.c=.skel.h)
MAP_FINE_SRC := $(wildcard map-fine/*.kern.c)
MAP_FINE_OBJ := $(MAP_FINE_SRC:.c=.o)
MAP_FINE_USER_SRC := $(wildcard map-fine/*.user.c)
MAP_FINE_USER_OBJ := $(MAP_FINE_USER_SRC:.c=)
USER_SRC := $(wildcard *.user.c)
USER := $(USER_SRC:.c=)
ARCH = $(shell uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')
BPF_CLANG := clang-19
BPF_CLANG_CFLAGS := -g -O0 -target bpf
INCLUDE := -I/linux/usr/include/ -I/linux/tools/lib/ -I/linux-dev-env/libbpf/src
USER_CFLAGS := -g -I/linux/usr/include -I/linux/tools/lib/ -L/linux-dev-env/libbpf/src
SKEL_H := $(SOURCES:.kern.c=.skel.h)
BPF_OBJ := $(SOURCES:.kern.c=.bpf.o)  

all: $(FILES) $(SKEL_H) $(USER) 
	
test: test.c
	$(BPF_CLANG) $(INCLUDE) $(BPF_CLANG_CFLAGS)  -o test test.c

$(FILES) : %.o : %.c  vmlinux.h
	$(BPF_CLANG) $(INCLUDE) $(BPF_CLANG_CFLAGS)  -o $@ -c $<

$(USER) : % : %.c 
	gcc $(USER_CFLAGS) $< -lbpf -lelf -lz -o $@

.PHONY : vmlinux.h
vmlinux.h:
	/linux/tools/bpf/bpftool/bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

run:
	LIBBPF_LOG_LEVEL=debug ./empty.btf.user

%.skel.h: %.kern.o
	/linux/tools/bpf/bpftool/bpftool gen skeleton $< > $@

.PHONY : clean

clean :
	rm $(FILES) $(USER) empty.skel.h