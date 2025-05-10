# -----------------------  paths (edit if you move things)  ------------------
PROJECT_ROOT ?= ../../..
KDIR := $(PROJECT_ROOT)/linux
INC  := $(PROJECT_ROOT)/kfunc-test-suite/include   # put vmlinux.h here once, manually

# -----------------------  tools  -------------------------------------------
CLANG ?= clang
CC ?= gcc

# -----------------------  flags  -------------------------------------------
BPF_CFLAGS  := -g -O2 -Wall -target bpf \
               -I$(INC) \
               -I$(KDIR)/usr/include \
               -I$(KDIR)/tools/lib

USER_CFLAGS := -g \
               -I$(KDIR)/usr/include \
               -I$(KDIR)/tools/lib

USER_LDLIBS := -L$(KDIR)/tools/lib/bpf

# -----------------------  sources & objects  -------------------------------
KERN_SRC := $(wildcard *.kern.c)
KERN_OBJ := $(KERN_SRC:.kern.c=.kern.o)

USER_SRC := $(wildcard *.user.c)
USER_OBJ := $(USER_SRC:.user.c=.user.o)
USER_BIN := $(USER_SRC:.user.c=.user)

# -----------------------  top targets --------------------------------------
.PHONY: all clean
all: $(KERN_OBJ) $(USER_OBJ) $(USER_BIN)

clean:
	rm -f $(KERN_OBJ) $(USER_OBJ)

# -----------------------  build rules --------------------------------------
%.kern.o: %.kern.c
	$(CLANG) $(BPF_CFLAGS) -c $< -o $@

%.user.o: %.user.c
	$(CC)   $(USER_CFLAGS) -c $< -o $@

%.user: %.user.o
	$(CC) $^ $(USER_LDLIBS) -lbpf -o $@