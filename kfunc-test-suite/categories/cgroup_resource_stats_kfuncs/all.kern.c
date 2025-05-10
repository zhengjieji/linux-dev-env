#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getcwd")
int test_cgroup_rstat_updated(void *ctx)
{
    bpf_printk("Hello from 1\n");
	return 0;
}

SEC("tp/syscalls/sys_enter_getcwd")
int test_cgroup_rstat_flush(void *ctx)
{
    bpf_printk("Hello from 2\n");
	return 0;
}