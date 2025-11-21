// SPDX-License-Identifier: GPL-2.0
/* BPF program to test custom kfuncs */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char _license[] SEC("license") = "GPL";

/* Declare custom kfuncs for constant propagation test */
extern s64 const_propagation_original(s64 x, s64 y) __ksym;
extern s64 const_propagation_optimized(s64 x, s64 y) __ksym;

SEC("tp/syscalls/sys_enter_getcwd")
int test_custom_kfuncs(void *ctx)
{
	s64 result_original, result_optimized;
	u64 start_time, original_time, optimized_time;

	/* Test original version with runtime checks */
	start_time = bpf_ktime_get_ns();
	result_original = const_propagation_original(50, 2);
	original_time = bpf_ktime_get_ns() - start_time;

	/* Test optimized version with constant propagation */
	start_time = bpf_ktime_get_ns();
	result_optimized = const_propagation_optimized(50, 2);
	optimized_time = bpf_ktime_get_ns() - start_time;

	/* Print data for each iteration - parseable format */
	bpf_printk("DATA: original=%llu optimized=%llu", original_time, optimized_time);

	return 0;
}
