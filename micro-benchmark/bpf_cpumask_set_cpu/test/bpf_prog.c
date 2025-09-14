// SPDX-License-Identifier: GPL-2.0
/* BPF program to test bpf_cpumask_set_cpu kfunc */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char _license[] SEC("license") = "GPL";

/* Declare cpumask kfuncs */
extern struct bpf_cpumask *bpf_cpumask_create(void) __ksym;
extern void bpf_cpumask_release(struct bpf_cpumask *cpumask) __ksym;
extern void bpf_cpumask_set_cpu(u32 cpu, struct bpf_cpumask *cpumask) __ksym;
extern void bpf_cpumask_clear_cpu(u32 cpu, struct bpf_cpumask *cpumask) __ksym;
extern bool bpf_cpumask_test_cpu(u32 cpu, const struct cpumask *cpumask) __ksym;

/* Helper to cast bpf_cpumask to cpumask */
#define cast(cpumask) ((const struct cpumask *)(cpumask))

SEC("tp_btf/task_newtask")
int BPF_PROG(test_cpumask_ops, struct task_struct *task, u64 clone_flags)
{
	struct bpf_cpumask *mask;
	bool is_set;
	
	/* Create new cpumask */
	mask = bpf_cpumask_create();
	if (!mask) {
		bpf_printk("bpf_cpumask_create failed\n");
		return 0;
	}
	
	/* Set CPU 0 */
	bpf_cpumask_set_cpu(0, mask);
	bpf_printk("Set CPU 0 in cpumask\n");
	
	/* Test if CPU 0 is set */
	is_set = bpf_cpumask_test_cpu(0, cast(mask));
	bpf_printk("CPU 0 is %s\n", is_set ? "set" : "not set");
	
	/* Clear CPU 0 */
	bpf_cpumask_clear_cpu(0, mask);
	bpf_printk("Cleared CPU 0\n");
	
	/* Test if CPU 0 is still set */
	is_set = bpf_cpumask_test_cpu(0, cast(mask));
	bpf_printk("After clear, CPU 0 is %s\n", is_set ? "set" : "not set");
	
	/* Release cpumask */
	bpf_cpumask_release(mask);
	
	return 0;
}