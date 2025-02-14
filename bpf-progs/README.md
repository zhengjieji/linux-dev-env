## 使用说明

### 编译代码
- 进入docker环境
```sh
sudo make enter-docker
```
- 进入 ko/ 和 src/ 目录，运行 make 编译

### 内核模块
进入 ko/ 目录，编译并加载内核模块 reg_kfunc.ko
```sh
insmod reg_kfunc.ko
```

### 测试
- 启动加载器（传入函数名 test_helper_prog）
```sh
./test_func_driver test_func_helper.bpf.o test_helper_prog
```
- 加载内核模块后，启动加载器（传入函数名 test_kfunc_prog）
```sh
./test_func_driver test_func_kfunc.bpf.o test_kfunc_prog
```
- 启动触发程序：
```sh
./trigger`
```
- 在 /sys/kernel/debug/tracing/trace_pipe 中观察输出
