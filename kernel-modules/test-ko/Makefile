# 指定要编译的内核模块目标
obj-m += minimal_module.o

# 定义内核源码目录，这里使用相对路径，转换为绝对路径
KERNEL_DIR := $(realpath ../../linux)
# 当前模块源码目录
PWD := $(shell pwd)

all:
	@echo "Compiling module using kernel sources at $(KERNEL_DIR)..."
	make -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	@echo "Cleaning module build files..."
	make -C $(KERNEL_DIR) M=$(PWD) clean

