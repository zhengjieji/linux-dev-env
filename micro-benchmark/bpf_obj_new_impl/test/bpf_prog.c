// SPDX-License-Identifier: GPL-2.0
/* BPF program to test bpf_obj_new_impl kfunc */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

char _license[] SEC("license") = "GPL";

/* Simple test structure for allocation */
struct foo {
	int value;
	long timestamp;
};

/* Declare kfuncs */
extern void *bpf_obj_new_impl(__u64 local_type_id__maybe_null, void *meta__maybe_null) __ksym;
extern void bpf_obj_drop_impl(void *kptr, void *meta__maybe_null) __ksym;

#define bpf_obj_new(type) ((type *)bpf_obj_new_impl(bpf_core_type_id_local(type), NULL))
#define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)

SEC("tc")
int test_obj_alloc(struct __sk_buff *ctx)
{
	struct foo *f;
	
	/* Allocate new object */
	f = bpf_obj_new(typeof(*f));
	if (!f) {
		bpf_printk("bpf_obj_new failed\n");
		return 0;
	}
	
	/* Use the allocated object */
	f->value = 42;
	f->timestamp = bpf_ktime_get_ns();
	
	bpf_printk("bpf_obj_new success: value=%d\n", f->value);
	
	/* Clean up - always drop allocated objects */
	bpf_obj_drop(f);
	
	return 0;
}