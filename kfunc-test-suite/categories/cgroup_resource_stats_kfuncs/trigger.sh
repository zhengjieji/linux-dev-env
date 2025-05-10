echo "Triggering BPF program"
# 同样模拟两次回车 + 后台执行
(echo; sleep 0.1; echo) | ./trigger.user &

sleep 2  # 给 trigger 稍微一点执行时间
echo "Showing trace_pipe..."
cat /sys/kernel/debug/tracing/trace_pipe