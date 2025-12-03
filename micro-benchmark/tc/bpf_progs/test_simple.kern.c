// SPDX-License-Identifier: GPL-2.0
/* Simple TC BPF program to test basic functionality */

#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tc")
int test_simple(struct __sk_buff *ctx)
{
	u64 pid_tgid = bpf_get_current_pid_tgid();
	u32 pid = pid_tgid >> 32;
	u32 tgid = pid_tgid & 0xFFFFFFFF;

	bpf_printk("TC: pid=%u tgid=%u", pid, tgid);

	return 0; /* TC_ACT_OK */
}
