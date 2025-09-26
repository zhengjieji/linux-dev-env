// SPDX-License-Identifier: GPL-2.0
/* BPF program to test bpf_wq_start kfunc */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

char _license[] SEC("license") = "GPL";

/* Workqueue element structure */
struct elem {
	struct bpf_wq work;
	int counter;
};

/* Map to hold workqueue */
struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__uint(max_entries, 1);
	__type(key, int);
	__type(value, struct elem);
} wq_map SEC(".maps");

/* Global to track if initialized */
__u32 wq_initialized = 0;

/* Declare kfuncs */
extern int bpf_wq_init(struct bpf_wq *wq, void *p__map, unsigned int flags) __ksym;
extern int bpf_wq_set_callback_impl(struct bpf_wq *wq,
				    int (callback_fn)(void *map, int *key, void *value),
				    unsigned int flags,
				    void *aux__ign) __ksym;
extern int bpf_wq_start(struct bpf_wq *wq, unsigned int flags) __ksym;

/* Workqueue callback function */
static int wq_callback(void *map, int *key, void *value)
{
	struct elem *data = (struct elem *)value;

	data->counter++;
	bpf_printk("wq_callback: counter=%d\n", data->counter);
	return 0;
}

SEC("tc")
int test_wq_init(struct __sk_buff *ctx)
{
	struct elem *val;
	int key = 0;
	int ret;

	/* Get workqueue element from map */
	val = bpf_map_lookup_elem(&wq_map, &key);
	if (!val) {
		bpf_printk("Failed to lookup wq element\n");
		return 0;
	}

	/* Only initialize once */
	if (!wq_initialized) {
		/* Initialize workqueue */
		ret = bpf_wq_init(&val->work, &wq_map, 0);
		if (ret != 0) {
			bpf_printk("bpf_wq_init failed: %d\n", ret);
			return 0;
		}

		/* Set callback */
		ret = bpf_wq_set_callback_impl(&val->work, wq_callback, 0, NULL);
		if (ret) {
			bpf_printk("bpf_wq_set_callback_impl failed: %d\n", ret);
			return 0;
		}

		wq_initialized = 1;
		bpf_printk("Workqueue initialized successfully\n");
	}

	/* Start workqueue */
	ret = bpf_wq_start(&val->work, 0);
	if (ret) {
		bpf_printk("bpf_wq_start failed: %d\n", ret);
		return 0;
	}

	bpf_printk("bpf_wq_start triggered successfully\n");
	return 0;
}