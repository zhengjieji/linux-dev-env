#!/bin/bash
# 检查是否以 root 权限运行
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 权限运行此脚本。"
    exit 1
fi

# 定义 ftrace 相关路径
TRACE_DIR="/sys/kernel/debug/tracing"
TRACE_FILE="${TRACE_DIR}/trace"
FILTER_FILE="${TRACE_DIR}/set_ftrace_filter"
CURRENT_TRACER="${TRACE_DIR}/current_tracer"
TRACING_ON="${TRACE_DIR}/tracing_on"
OUTPUT_FILE="$(dirname "$0")/kfunc_trace.log"

# 用于存储所有启动的 BPF 程序 PID
BPF_PIDS=()

# 定义退出清理函数
function cleanup {
    echo "收到中断信号，关闭 ftrace 追踪..."
    echo 0 > "$TRACING_ON"
    echo "保存追踪日志到: $OUTPUT_FILE"
    cp "$TRACE_FILE" "$OUTPUT_FILE"
    echo "清除过滤器配置..."
    echo > "$FILTER_FILE"
    echo "恢复默认 tracer（nop）..."
    echo nop > "$CURRENT_TRACER"
    # 终止所有 BPF 程序
    for pid in "${BPF_PIDS[@]}"; do
        if kill -0 $pid 2>/dev/null; then
            kill $pid
        fi
    done
    # 移除内核模块
    pushd ../ko > /dev/null
    rmmod reg_kfunc.ko
    popd > /dev/null
    exit 0
}

trap cleanup INT

echo "清空 trace 缓冲区..."
> "$TRACE_FILE"

echo "设置 tracer 为 function_graph..."
echo function_graph > "$CURRENT_TRACER"

# 设置过滤器：追踪 kfunc 入口（请根据实际情况修改此处函数名）
echo "配置过滤器，只追踪 bpf_kfunc_call（请根据实际情况修改函数名）..."
echo "bpf_kfunc_call" > "$FILTER_FILE"

echo "开启 ftrace 追踪..."
echo 1 > "$TRACING_ON"

# 进入 ko 目录加载内核模块
echo "进入 ko 目录，加载内核模块 reg_kfunc.ko..."
pushd ../ko > /dev/null
insmod reg_kfunc.ko
popd > /dev/null

#########################
# 测试 test_helper_prog
#########################
echo "准备测试 test_helper_prog（加载 test_func_helper.bpf.o，函数名 test_helper_prog）..."
echo "按 Enter 键开始测试 test_helper_prog"
read dummy

pushd ../src > /dev/null
./test_func_driver test_func_helper.bpf.o test_helper_prog &
BPF_PIDS+=($!)
popd > /dev/null

echo "test_helper_prog 已启动，请触发 getcwd 调用..."
echo "完成 test_helper_prog 测试后，按 Enter 键结束该测试"
read dummy

# 结束 test_helper_prog 进程
for pid in "${BPF_PIDS[@]}"; do
    kill $pid 2>/dev/null
done
BPF_PIDS=()
sleep 1

#########################
# 测试 test_kfunc_prog
#########################
echo "准备测试 test_kfunc_prog（加载 test_func_kfunc.bpf.o，函数名 test_kfunc_prog）..."
echo "按 Enter 键开始测试 test_kfunc_prog"
read dummy

pushd ../src > /dev/null
./test_func_driver test_func_kfunc.bpf.o test_kfunc_prog &
BPF_PIDS+=($!)
popd > /dev/null

echo "test_kfunc_prog 已启动，请触发相应调用，完成后按 Ctrl+C 退出..."
# 等待用户按 Ctrl+C 结束追踪
wait

