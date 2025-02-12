/* SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause) */
#define BPF_NO_GLOBAL_DATA
#include <linux/bpf.h>
#include <linux/types.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

/* 声明外部 kfunc my_get_current_pid_tgid，使用 __ksym 辅助符号解析 */
extern __u64 my_get_current_pid_tgid(void) __ksym;

char LICENSE[] SEC("license") = "Dual BSD/GPL";

/*
 * 调用自定义 kfunc my_get_current_pid_tgid()，打印输出 TEST_KFUNC 标记信息
 */
SEC("kprobe/__do_sys_getcwd")
int test_kfunc_prog(struct pt_regs *ctx)
{
    __u64 pid_tgid = my_get_current_pid_tgid();
    bpf_printk("TEST_KFUNC: pid_tgid = %llu\n", pid_tgid);
    return 0;
}

