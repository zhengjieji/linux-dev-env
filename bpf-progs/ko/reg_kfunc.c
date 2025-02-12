/*
 * 文件：reg_kfunc_my_get_current_pid_tgid.c
 * 说明：通过内核模块注册一个 kfunc 实现，
 *       新符号名为 my_get_current_pid_tgid，与内核内置的
 *       bpf_get_current_pid_tgid 不冲突。
 */

#include <linux/init.h>       // 模块初始化宏
#include <linux/module.h>     // 模块加载接口
#include <linux/kernel.h>     // 内核日志宏
#include <linux/bpf.h>
#include <linux/btf.h>
#include <linux/btf_ids.h>
#include <linux/sched.h>      // current 定义

/* Declare the kfunc prototype */
__bpf_kfunc u64 my_get_current_pid_tgid(void);

/* 使用内核提供的 kfunc 定义宏 */
__bpf_kfunc_start_defs();

/* 定义 kfunc 实现，功能与 bpf_get_current_pid_tgid() 相同，
 * 但使用新的符号名 my_get_current_pid_tgid */
__bpf_kfunc u64 my_get_current_pid_tgid(void)
{
    struct task_struct *t = current;
    return ((u64)t->tgid << 32) | (u32)t->pid;
}

/* 导出该符号，使得 BTF 信息可以被内核全局查找到 */
EXPORT_SYMBOL_GPL(my_get_current_pid_tgid);

__bpf_kfunc_end_defs();

/*
 * 定义 BTF kfunc ID 集，将 my_get_current_pid_tgid() 加入其中
 */
BTF_KFUNCS_START(bpf_kfunc_my_get_current_pid_tgid_ids_set)
    BTF_ID_FLAGS(func, my_get_current_pid_tgid)
BTF_KFUNCS_END(bpf_kfunc_my_get_current_pid_tgid_ids_set)

/* 定义 kfunc ID 集注册结构 */
static const struct btf_kfunc_id_set bpf_kfunc_my_get_current_pid_tgid_set = {
    .owner = THIS_MODULE,
    .set = &bpf_kfunc_my_get_current_pid_tgid_ids_set,
};

/* 模块加载时注册 kfunc */
static int __init reg_kfunc_my_get_current_pid_tgid_init(void)
{
    int ret;

    printk(KERN_INFO "Registering kfunc: my_get_current_pid_tgid\n");

    ret = register_btf_kfunc_id_set(BPF_PROG_TYPE_KPROBE, &bpf_kfunc_my_get_current_pid_tgid_set);
    if (ret) {
        pr_err("Failed to register kfunc: my_get_current_pid_tgid\n");
        return ret;
    }

    printk(KERN_INFO "kfunc: my_get_current_pid_tgid registered successfully\n");
    return 0;
}

/* 模块卸载时注销 kfunc（如果内核支持注销） */
static void __exit reg_kfunc_my_get_current_pid_tgid_exit(void)
{
    printk(KERN_INFO "Unregistering kfunc: my_get_current_pid_tgid\n");
    /*
     * 若内核支持注销，可以调用：
     * unregister_btf_kfunc_id_set(BPF_PROG_TYPE_KPROBE, &bpf_kfunc_my_get_current_pid_tgid_set);
     */
}

module_init(reg_kfunc_my_get_current_pid_tgid_init);
module_exit(reg_kfunc_my_get_current_pid_tgid_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Zhengjie Ji");
MODULE_DESCRIPTION("Kfunc implementation for my_get_current_pid_tgid");
MODULE_VERSION("1.0");

