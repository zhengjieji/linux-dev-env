## 使用说明
### 内核模块
编译并加载内核模块 reg_kfunc_my_get_current_pid_tgid.ko（确保模块成功加载并注册了 kfunc my_get_current_pid_tgid）。

### 编译测试代码
进入 bpf-progs/test_func/ 目录，运行 make 编译生成两个 BPF 对象和用户程序。

### 测试 Helper 版本
启动加载器（传入函数名 test_helper_prog）： `./test_func_driver test_func_helper.bpf.o test_helper_prog`
再启动触发程序： `./trigger`

### 测试 Kfunc 版本
加载内核模块后，启动加载器（传入函数名 test_kfunc_prog）： `./test_func_driver test_func_kfunc.bpf.o test_kfunc_prog`
在 /sys/kernel/debug/tracing/trace_pipe 中观察输出类似于 TEST_HELPER: pid_tgid = ...。
