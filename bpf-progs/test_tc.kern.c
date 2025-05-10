// SPDX-License-Identifier: GPL-2.0
#include "vmlinux.h"  // 使用bpftool生成的vmlinux头文件
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

// 手动声明kfuncs
extern int bpf_list_push_front_impl(struct bpf_list_head *head,
                   struct bpf_list_node *node,
                   void *meta, __u64 off) __ksym;

extern void *bpf_obj_new_impl(__u64 local_type_id, void *meta) __ksym;
extern void bpf_obj_drop_impl(void *kptr, void *meta) __ksym;

// 简化版宏定义
#define __contains(name, node)
#define private(name) SEC(".bss." #name) __hidden __attribute__((aligned(8)))

/************ 程序数据结构定义 ************/
struct test_node {
    struct bpf_list_node node;
    int data;
};

struct map_value {
    struct bpf_spin_lock lock;
    struct bpf_list_head head __contains(test_node, node);
};

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __type(key, int);
    __type(value, struct map_value);
    __uint(max_entries, 1);
} list_map SEC(".maps");

/************ 辅助宏 ************/
#define bpf_obj_new(type) ((type *)bpf_obj_new_impl(0, NULL))
#define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)
#define bpf_list_push_front(head, node) \
    bpf_list_push_front_impl(head, node, NULL, 0)

/************ BPF程序 ************/
SEC("tc")
int bpf_prog(struct __sk_buff *ctx)
{
    int key = 0;
    struct map_value *v;
    struct test_node *n;

    // 获取map中的链表头
    v = bpf_map_lookup_elem(&list_map, &key);
    if (!v) return 1;

    // 分配新节点
    n = bpf_obj_new(typeof(*n));
    if (!n) return 2;
    n->data = 42;

    // 加锁操作链表
    bpf_spin_lock(&v->lock);
    
    int ret = bpf_list_push_front(&v->head, &n->node);
    bpf_spin_unlock(&v->lock);
    
    if (ret) {
        bpf_obj_drop(n);
        return ret;
    }
    
    return 0;
}

char _license[] SEC("license") = "GPL";