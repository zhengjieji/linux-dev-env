// test_func_helper.kern.c
#include <linux/bpf.h>
#include <linux/types.h>
#include <bpf/bpf_helpers.h>

/*
 * 使用 kprobe 挂载，调用内置 helper bpf_get_current_pid_tgid，
 * 并通过 bpf_printk 打印返回值。
 */
SEC("kprobe/__x64_sys_getcwd")
int test_helper_prog(struct pt_regs *ctx)
{
    __u64 pid_tgid = bpf_get_current_pid_tgid();
    bpf_printk("TEST_HELPER: pid_tgid = %llu\n", pid_tgid);
    return 0;
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
