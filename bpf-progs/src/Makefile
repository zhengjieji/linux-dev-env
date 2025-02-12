# Makefile for test_func 模块
BPF-CLANG   := clang
BPF_CLANG_CFLAGS := -target bpf -g -Wall -O2 -c
INCLUDE     := -I../../linux/usr/include/ -I../../linux/tools/lib/
USER-CFLAGS := -g -I../../linux/usr/include/ -I../../linux/tools/lib/ -L../../linux/tools/lib/bpf/

# BPF 程序文件
HELPER_SRC  := test_func_helper.kern.c
KFUNC_SRC   := test_func_kfunc.kern.c

# 生成的 BPF 对象文件
HELPER_BPF  := test_func_helper.bpf.o
KFUNC_BPF   := test_func_kfunc.bpf.o

# 用户空间程序
DRIVER_SRC  := test_func_driver.user.c
TRIGGER_SRC := trigger.user.c
DRIVER_BIN  := test_func_driver
TRIGGER_BIN := trigger

.PHONY: all clean

all: $(HELPER_BPF) $(KFUNC_BPF) $(DRIVER_BIN) $(TRIGGER_BIN)

# 编译 BPF 程序（*.kern.c 用 clang）
%.bpf.o: %.kern.c
	$(BPF-CLANG) $(INCLUDE) $(BPF_CLANG_CFLAGS) -o $@ $<

# 编译用户空间加载器（*.user.c 用 gcc）
$(DRIVER_BIN): $(DRIVER_SRC)
	gcc $(USER-CFLAGS) -o $@ $< -lbpf

# 编译触发程序（*.user.c 用 gcc）
$(TRIGGER_BIN): $(TRIGGER_SRC)
	gcc $(USER-CFLAGS) -o $@ $< -lbpf

clean:
	rm -f *.o *.bpf.o $(DRIVER_BIN) $(TRIGGER_BIN)

