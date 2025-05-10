#!/bin/bash

# 使用 bpftool dump 来生成
bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

echo "Loading BPF program $1"
# 模拟两次回车 + 后台执行
# (echo; sleep 0.1; echo) | ./load.user test_bpf_obj_new_impl.kern.o bpf_prog &
(echo; sleep 0.1; echo) | ./load.user test.kern.o bpf_prog &

sleep 1  # 等待加载完成

echo "Running BPF program $1"
# 同样模拟两次回车 + 后台执行
(echo; sleep 0.1; echo) | ./trigger.user &

sleep 1  # 给 trigger 稍微一点执行时间

echo "Tailing trace_pipe..."
cat /sys/kernel/debug/tracing/trace_pipe
