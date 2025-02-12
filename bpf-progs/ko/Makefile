obj-m += reg_kfunc.o

# Enable BTF generation
KBUILD_CFLAGS += -g -O2

KERNEL_DIR := $(realpath ../../linux)
PWD := $(shell pwd)

all:
	make -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	make -C $(KERNEL_DIR) M=$(PWD) clean
