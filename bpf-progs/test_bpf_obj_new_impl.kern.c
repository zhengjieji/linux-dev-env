#include <linux/bpf.h>
#include <linux/types.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

struct my_obj {
    __u64 foo;
};

extern void *bpf_obj_new_impl(__u64 local_type_id, void *meta) __ksym;
extern void bpf_obj_drop_impl(void *kptr, void *meta) __ksym;

SEC("tp/syscalls/sys_enter_getcwd") // env -i /bin/pwd
int bpf_prog(void *ctx)
{
    // 分配一个 my_obj 实例
    struct my_obj *p = bpf_obj_new_impl(
        bpf_core_type_id_local(struct my_obj),  // BTF 中的本地类型 ID
        NULL                                    // meta 参数由 verifier 填充
    );
    if (!p) {
        bpf_printk("obj_new_impl returned NULL\n");
        return 0;
    }

    // 初始化并打印
    p->foo = 0x12345678;
    bpf_printk("Allocated my_obj @ %p, foo=0x%llx\n", p, p->foo);

    // 释放对象，避免 verifier 报 “leaked kptr”
    bpf_obj_drop_impl(
        p,    // 要释放的指针
        NULL  // meta 参数忽略
    );

    bpf_printk("Successful");
    return 0;
}

char LISENSE[] SEC("license") = "Dual BSD/GPL";