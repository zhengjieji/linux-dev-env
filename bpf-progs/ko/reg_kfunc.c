#include <linux/init.h>       // Macros for module initialization
#include <linux/module.h>     // Core header for loading modules
#include <linux/kernel.h>     // Kernel logging macros
#include <linux/bpf.h>
#include <linux/btf.h>
#include <linux/btf_ids.h>
#include <linux/sched.h>      // current 定义

/* Declare the kfunc prototype */
__bpf_kfunc u64 my_get_current_pid_tgid(void);

/* Begin kfunc definitions */
__bpf_kfunc_start_defs();

/* 定义 kfunc 实现，功能与 bpf_get_current_pid_tgid() 相同*/
__bpf_kfunc u64 my_get_current_pid_tgid(void)
{
    struct task_struct *t = current;
    return ((u64)t->tgid << 32) | (u32)t->pid;
}

/* End kfunc definitions */
__bpf_kfunc_end_defs();

/* Define the BTF kfuncs ID set */
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
