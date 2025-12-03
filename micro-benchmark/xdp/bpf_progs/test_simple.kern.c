// SPDX-License-Identifier: GPL-2.0
/* Simple XDP BPF program to test basic functionality */

#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("xdp")
int test_simple(struct xdp_md *ctx)
{
	u64 pid_tgid = bpf_get_current_pid_tgid();
	u32 pid = pid_tgid >> 32;
	u32 tgid = pid_tgid & 0xFFFFFFFF;

	bpf_printk("XDP: pid=%u tgid=%u", pid, tgid);

	return XDP_PASS;
}
