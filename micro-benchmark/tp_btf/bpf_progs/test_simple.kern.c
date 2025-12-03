// SPDX-License-Identifier: GPL-2.0
/* Simple tp_btf BPF program to test basic functionality */

#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "GPL";

SEC("tp_btf/task_newtask")
int BPF_PROG(test_simple, struct task_struct *task, u64 clone_flags)
{
	u32 pid = task->pid;
	u32 tgid = task->tgid;

	bpf_printk("TP_BTF: new task pid=%u tgid=%u", pid, tgid);

	return 0;
}
