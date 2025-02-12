/*
 * 文件：reg_kfunc_get_current_pid_tgid.c
 * 说明：基于内核模块的方式实现 bpf_get_current_pid_tgid kfunc，
 *       模块加载时注册该 kfunc，供 BPF 程序调用。
 */

#include <linux/init.h>       // 模块初始化相关宏
#include <linux/module.h>     // 核心模块接口
#include <linux/kernel.h>     // 内核日志宏
#include <linux/bpf.h>
#include <linux/btf.h>
#include <linux/btf_ids.h>
#include <linux/sched.h>      // 提供 current 指针

/*
 * 以下宏和定义假设内核中已包含相关的 kfunc 宏定义：
 * __bpf_kfunc_start_defs()、__bpf_kfunc_end_defs()、__bpf_kfunc
 * 这些宏用来标记函数作为 BPF kfunc，并生成必要的 BTF 信息。
 */

__bpf_kfunc_start_defs();

/* 定义 kfunc 实现，功能与原 helper bpf_get_current_pid_tgid() 一致 */
__bpf_kfunc u64 bpf_get_current_pid_tgid(void)
{
    struct task_struct *t = current;
    return ((u64)t->tgid << 32) | (u32)t->pid;
}

__bpf_kfunc_end_defs();

/*
 * 定义 BTF kfunc ID 集，此 ID 集用于描述本模块中注册的 kfunc。
 * 这里使用 BTF_ID_FLAGS 宏将 bpf_get_current_pid_tgid 函数加入该集合。
 */
BTF_KFUNCS_START(bpf_kfunc_get_current_pid_tgid_ids_set)
    BTF_ID_FLAGS(func, bpf_get_current_pid_tgid)
BTF_KFUNCS_END(bpf_kfunc_get_current_pid_tgid_ids_set)

/* 定义一个 kfunc ID 集注册结构，owner 指定当前模块 */
static const struct btf_kfunc_id_set bpf_kfunc_get_current_pid_tgid_set = {
    .owner = THIS_MODULE,
    .set = &bpf_kfunc_get_current_pid_tgid_ids_set,
};

/*
 * 模块加载时执行的初始化函数，
 * 在这里调用 register_btf_kfunc_id_set() 完成 kfunc 的注册。
 */
static int __init reg_kfunc_get_current_pid_tgid_init(void)
{
    int ret;

    printk(KERN_INFO "Registering kfunc: bpf_get_current_pid_tgid\n");

    ret = register_btf_kfunc_id_set(BPF_PROG_TYPE_KPROBE, &bpf_kfunc_get_current_pid_tgid_set);
    if (ret) {
        pr_err("Failed to register kfunc: bpf_get_current_pid_tgid\n");
        return ret;
    }

    printk(KERN_INFO "kfunc: bpf_get_current_pid_tgid registered successfully\n");
    return 0;
}

/*
 * 模块卸载时执行的退出函数，
 * 如果内核提供了注销接口，可以在此处调用相应的 unregister 函数。
 */
static void __exit reg_kfunc_get_current_pid_tgid_exit(void)
{
    printk(KERN_INFO "Unregistering kfunc: bpf_get_current_pid_tgid\n");
    /* 
     * 如果需要注销，且内核支持注销接口，可调用：
     * unregister_btf_kfunc_id_set(BPF_PROG_TYPE_KPROBE, &bpf_kfunc_get_current_pid_tgid_set);
     */
}

module_init(reg_kfunc_get_current_pid_tgid_init);
module_exit(reg_kfunc_get_current_pid_tgid_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("Kfunc implementation for bpf_get_current_pid_tgid");
MODULE_VERSION("1.0");

