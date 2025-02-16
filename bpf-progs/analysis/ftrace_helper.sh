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
OUTPUT_FILE="$(dirname "$0")/helper_trace.log"

# 检查 ftrace 目录是否存在
if [ ! -d "$TRACE_DIR" ]; then
    echo "ftrace 目录不存在，请确认内核已开启 ftrace 功能。"
    exit 1
fi

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
    # 如果 BPF 程序仍在运行，则终止它
    if [ -n "$BPF_PID" ]; then
        kill "$BPF_PID" 2>/dev/null
    fi
    exit 0
}

trap cleanup INT

echo "清空 trace 缓冲区..."
> "$TRACE_FILE"

echo "设置 tracer 为 function_graph..."
echo function_graph > "$CURRENT_TRACER"

echo "配置过滤器，只追踪 bpf_check（verifier 入口）..."
echo "bpf_check" > "$FILTER_FILE"

echo "开启 ftrace 追踪..."
echo 1 > "$TRACING_ON"

echo "切换到 src 目录，加载 BPF 程序..."
pushd ../src > /dev/null

# 启动加载器（BPF 驱动程序）并保存其进程 PID（注意这里用 $! 而非 $?）
./test_func_driver test_func_helper.bpf.o test_helper_prog &
BPF_PID=$!

popd > /dev/null

echo "BPF 程序已加载，等待触发（按 Ctrl+C 退出）..."
# 等待 BPF 程序结束（此程序会循环等待触发 getcwd 调用）
wait "$BPF_PID"

