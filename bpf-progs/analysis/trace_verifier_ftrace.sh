#!/bin/bash
# trace_verifier_ftrace.sh
# 利用 ftrace 的 function_graph tracer 从入口函数 bpf_check 开始追踪 verifier 内部调用链，
# 并将采集结果保存到当前目录下的 verifier_trace_output.txt 文件中。
#
# 注意：请以 root 权限运行此脚本！
#
# 使用固定路径 /sys/kernel/debug/tracing

TRACE_DIR="/sys/kernel/debug/tracing"
OUTPUT_FILE="verifier_trace_output.txt"
SLEEP_TIME=30

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 权限运行此脚本！"
    exit 1
fi

# 检查 ftrace 接口目录是否存在
if [ ! -d "$TRACE_DIR" ]; then
    echo "$TRACE_DIR 不存在，请确认系统已挂载 debugfs 并启用了 ftrace。"
    exit 1
fi

echo "使用的 ftrace 接口目录: ${TRACE_DIR}"

# 停止 tracing 并清空 trace 缓存
echo 0 > "${TRACE_DIR}/tracing_on"
echo "" > "${TRACE_DIR}/trace"

# 设置 tracer 为 function_graph
echo function_graph > "${TRACE_DIR}/current_tracer"

# 设置过滤器：只追踪入口函数 bpf_check 及其调用链
echo bpf_check > "${TRACE_DIR}/set_ftrace_filter"

echo "请在此时加载 BPF 程序（例如使用 test_func_driver 触发 verifier），采集时间为 ${SLEEP_TIME} 秒..."
# 开启 tracing
echo 1 > "${TRACE_DIR}/tracing_on"
sleep $SLEEP_TIME

# 关闭 tracing
echo 0 > "${TRACE_DIR}/tracing_on"

# 将 trace 内容保存到文件
cp "${TRACE_DIR}/trace" "${OUTPUT_FILE}"
echo "调用链信息已保存到 ${OUTPUT_FILE}"

# 恢复默认 tracer 与清空过滤器
echo nop > "${TRACE_DIR}/current_tracer"
echo "" > "${TRACE_DIR}/set_ftrace_filter"

