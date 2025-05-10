#!/bin/bash

echo "Loading BPF program: test_cgroup_rstat_updated"
(echo; sleep 0.1; echo) | ./load.user all.kern.o test_cgroup_rstat_updated &
echo "BPF program loaded: test_cgroup_rstat_updated"

sleep 2  # 等待加载完成

echo "Loading BPF program: test_cgroup_rstat_flush"
(echo; sleep 0.1; echo) | ./load.user all.kern.o test_cgroup_rstat_flush &
echo "BPF program loaded: test_cgroup_rstat_flush"

sleep 2  # 给 trigger 稍微一点执行时间

echo "BPF programs attached"