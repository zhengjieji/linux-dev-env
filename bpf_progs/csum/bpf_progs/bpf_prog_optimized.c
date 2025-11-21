// SPDX-License-Identifier: GPL-2.0
/* XDP program to test OPTIMIZED bpf_csum_diff_optimized helper */

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

char _license[] SEC("license") = "GPL";

SEC("xdp")
int xdp_csum_test(struct xdp_md *ctx)
{
	/* Simple test data for checksum calculation */
	__be32 from_buf[5] = {0x01020304, 0x05060708, 0x090a0b0c, 0x0d0e0f10, 0x11121314};
	__be32 to_buf[5] = {0x15161718, 0x191a1b1c, 0x1d1e1f20, 0x21222324, 0x25262728};

	__u64 start_time, elapsed_time;
	__s64 csum_result;

	/* Test optimized bpf_csum_diff_optimized */
	start_time = bpf_ktime_get_ns();
	csum_result = bpf_csum_diff_optimized(from_buf, 20, to_buf, 20, 0);
	elapsed_time = bpf_ktime_get_ns() - start_time;

	/* Print timing data for analysis */
	bpf_printk("OPTIMIZED: time=%llu result=0x%llx", elapsed_time, csum_result);

	return XDP_PASS;
}
