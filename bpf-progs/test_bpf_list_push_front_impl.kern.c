#include "vmlinux.h"
// #include <linux/bpf.h>
// #include <linux/types.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_core_read.h>

/* From/tools/testing/selftests/bpf/bpf_experimental.h */

#define __contains(name, node) __attribute__((btf_decl_tag("contains:" #name ":" #node)))

// extern void *bpf_obj_new_impl(__u64 local_type_id, void *meta) __ksym;

#define bpf_obj_new(type) ((type *)bpf_obj_new_impl(bpf_core_type_id_local(type), NULL))

// extern void bpf_obj_drop_impl(void *kptr, void *meta) __ksym;

// #define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)

// extern int bpf_list_push_front_impl(struct bpf_list_head *head,
//     struct bpf_list_node *node,
//     void *meta, __u64 off) __ksym;

// #define bpf_list_push_front(head, node) bpf_list_push_front_impl(head, node, NULL, 0)

// extern int bpf_list_push_back_impl(struct bpf_list_head *head,
//     struct bpf_list_node *node,
//     void *meta, __u64 off) __ksym;

// #define bpf_list_push_back(head, node) bpf_list_push_back_impl(head, node, NULL, 0)

/* From /tools/testing/selftests/bpf/progs/linked_list.h */

struct bar {
	struct bpf_list_node node;
	int data;
};

struct foo {
	struct bpf_list_node node;
	struct bpf_list_head head; // __contains(bar, node);
	// struct bpf_spin_lock lock;
	// int data;
	// struct bpf_list_node node2;
};

#define private(name) SEC(".bss." #name) __hidden __attribute__((aligned(8)))

private(A) struct bpf_spin_lock glock;
private(A) struct bpf_list_head ghead; // __contains(foo, node2);

/* From /tools/testing/selftests/bpf/progs/linked_list.c */

// static __always_inline
int list_push_pop(struct bpf_spin_lock *lock, struct bpf_list_head *head, bool leave_in_map)
{
	struct bpf_list_node *n;
	struct foo *f;

	// f = bpf_obj_new(typeof(*f));
	// if (!f)
		// return 2;

	// bpf_spin_lock(lock);
	// n = bpf_list_pop_front(head);
	// bpf_spin_unlock(lock);
	// if (n) {
	// 	bpf_obj_drop(container_of(n, struct foo, node2));
	// 	bpf_obj_drop(f);
	// 	return 3;
	// }

	// bpf_spin_lock(lock);
	// n = bpf_list_pop_back(head);
	// bpf_spin_unlock(lock);
	// if (n) {
	// 	bpf_obj_drop(container_of(n, struct foo, node2));
	// 	bpf_obj_drop(f);
	// 	return 4;
	// }

	// bpf_spin_lock(lock);
	// f->data = 42;
	// bpf_list_push_front(head, &f->node2);
	// bpf_spin_unlock(lock);
	// if (leave_in_map)
	// 	return 0;
	// bpf_spin_lock(lock);
	// n = bpf_list_pop_back(head);
	// bpf_spin_unlock(lock);
	// if (!n)
	// 	return 5;
	// f = container_of(n, struct foo, node2);
	// if (f->data != 42) {
	// 	bpf_obj_drop(f);
	// 	return 6;
	// }

	// bpf_spin_lock(lock);
	// f->data = 13;
	// bpf_list_push_front(head, &f->node2);
	// bpf_spin_unlock(lock);
	// bpf_spin_lock(lock);
	// n = bpf_list_pop_front(head);
	// bpf_spin_unlock(lock);
	// if (!n)
	// 	return 7;
	// f = container_of(n, struct foo, node2);
	// if (f->data != 13) {
	// 	bpf_obj_drop(f);
	// 	return 8;
	// }
	// bpf_obj_drop(f);

	// bpf_spin_lock(lock);
	// n = bpf_list_pop_front(head);
	// bpf_spin_unlock(lock);
	// if (n) {
	// 	bpf_obj_drop(container_of(n, struct foo, node2));
	// 	return 9;
	// }

	// bpf_spin_lock(lock);
	// n = bpf_list_pop_back(head);
	// bpf_spin_unlock(lock);
	// if (n) {
	// 	bpf_obj_drop(container_of(n, struct foo, node2));
	// 	return 10;
	// }
	return 0;
}

// static __always_inline
int test_list_push_pop(struct bpf_spin_lock *lock, struct bpf_list_head *head)
{
	int ret;

	ret = list_push_pop(lock, head, false);
	if (ret)
		return ret;
	return list_push_pop(lock, head, true);
}

SEC("tp/syscalls/sys_enter_getcwd")
int bpf_prog(void *ctx)
{
	int r;
	r = test_list_push_pop(&glock, &ghead);
    bpf_printk("test_list_push_pop returned %d\n", r);
    return 0;
}

char LISENSE[] SEC("license") = "Dual BSD/GPL";