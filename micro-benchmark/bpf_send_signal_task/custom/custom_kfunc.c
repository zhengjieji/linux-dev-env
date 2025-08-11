// SPDX-License-Identifier: GPL-2.0
/*
 * Custom kfunc implementation that mimics bpf_send_signal_task
 * This module exports a custom version for testing modifications
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/btf.h>
#include <linux/btf_ids.h>
#include <linux/bpf.h>
#include <linux/sched.h>
#include <linux/sched/signal.h>
#include <linux/pid.h>
#include <linux/rcupdate.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Custom BPF Testing");
MODULE_DESCRIPTION("Custom BPF kfunc for send_signal_task testing");
MODULE_VERSION("1.0");

/* Helper function similar to bpf_send_signal_common in kernel */
static int custom_send_signal_common(int sig, enum pid_type type, 
                                     struct task_struct *task, u64 value)
{
    struct kernel_siginfo info;
    int ret;

    /* Clear and prepare siginfo */
    clear_siginfo(&info);
    info.si_signo = sig;
    info.si_errno = 0;
    info.si_code = SI_KERNEL;
    info.si_pid = 0;
    info.si_uid = 0;
    
    /* Store the value if provided (similar to sigqueue) */
    if (value) {
        info.si_value.sival_ptr = (void *)(unsigned long)value;
    }

    /* Send the signal */
    if (type == PIDTYPE_PID) {
        ret = send_sig_info(sig, &info, task);
    } else {
        /* For PIDTYPE_TGID, send to thread group */
        ret = send_sig_info(sig, &info, task);
    }

    /* Log for debugging */
    pr_info("custom_send_signal: sig=%d, type=%d, pid=%d, ret=%d\n",
            sig, type, task->pid, ret);

    return ret;
}

/* Declare the kfunc prototype */
__bpf_kfunc int custom_send_signal_task(struct task_struct *task, int sig, 
                                        enum pid_type type, u64 value);

/* Start kfunc definitions - following kernel pattern */
__bpf_kfunc_start_defs();

__bpf_kfunc int custom_send_signal_task(struct task_struct *task, int sig, 
                                        enum pid_type type, u64 value)
{
    /* Validate type like the original */
    if (type != PIDTYPE_PID && type != PIDTYPE_TGID)
        return -EINVAL;

    return custom_send_signal_common(sig, type, task, value);
}

__bpf_kfunc_end_defs();

/* Define the BTF kfuncs ID set */
BTF_KFUNCS_START(custom_send_signal_task_ids)
BTF_ID_FLAGS(func, custom_send_signal_task, KF_TRUSTED_ARGS)
BTF_KFUNCS_END(custom_send_signal_task_ids)

static const struct btf_kfunc_id_set custom_kfunc_set = {
    .owner = THIS_MODULE,
    .set = &custom_send_signal_task_ids,
};

static int __init custom_kfunc_init(void)
{
    int ret;

    printk(KERN_INFO "Registering kfunc: custom_send_signal_task\n");

    /* Register for tracepoint programs */
    ret = register_btf_kfunc_id_set(BPF_PROG_TYPE_TRACEPOINT, &custom_kfunc_set);
    if (ret) {
        pr_err("Failed to register tracepoint kfuncs: %d\n", ret);
        return ret;
    }

    /* Register for kprobe programs */
    ret = register_btf_kfunc_id_set(BPF_PROG_TYPE_KPROBE, &custom_kfunc_set);
    if (ret) {
        pr_err("Failed to register kprobe kfuncs: %d\n", ret);
        return ret;
    }

    printk(KERN_INFO "kfunc: custom_send_signal_task registered successfully\n");
    return 0;
}

static void __exit custom_kfunc_exit(void)
{
    printk(KERN_INFO "Unregistering kfunc: custom_send_signal_task\n");
}

module_init(custom_kfunc_init);
module_exit(custom_kfunc_exit);