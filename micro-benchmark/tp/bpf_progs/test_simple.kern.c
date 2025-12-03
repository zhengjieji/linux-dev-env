// SPDX-License-Identifier: GPL-2.0
/* Simple tracepoint BPF program to test basic functionality */

#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int test_simple(void *ctx)
{
	u64 pid_tgid = bpf_get_current_pid_tgid();
	u32 pid = pid_tgid >> 32;
	u32 tgid = pid_tgid & 0xFFFFFFFF;

	bpf_printk("TP: pid=%u tgid=%u", pid, tgid);

	return 0;
}
