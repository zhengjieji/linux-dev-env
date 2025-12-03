// SPDX-License-Identifier: GPL-2.0
/* Simple raw tracepoint BPF program for benchmarking via BPF_PROG_TEST_RUN */

#include "../vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "GPL";

SEC("raw_tp/sys_enter")
int BPF_PROG(test_simple, struct pt_regs *regs, long id)
{
	u64 pid_tgid = bpf_get_current_pid_tgid();
	u32 pid = pid_tgid >> 32;
	u32 tid = pid_tgid;

	bpf_printk("RAW_TP: sys_enter id=%ld pid=%u tid=%u", id, pid, tid);

	return 0;
}
