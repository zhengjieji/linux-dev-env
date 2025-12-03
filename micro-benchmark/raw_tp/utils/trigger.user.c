// SPDX-License-Identifier: GPL-2.0
/* Trigger for raw_tp micro-benchmark using BPF_PROG_TEST_RUN
 *
 * This program runs pinned BPF programs via BPF_PROG_TEST_RUN syscall,
 * which directly executes the BPF program without needing to trigger
 * an actual tracepoint.
 *
 * Usage:
 *   ./trigger [iterations]
 *   ./trigger 1000    # Run all pinned programs 1000 times each
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/syscall.h>
#include <linux/bpf.h>

#define PIN_BASE_PATH "/sys/fs/bpf/micro_benchmark_raw_tp"
#define MAX_PROGS 32

/*
 * Context for raw_tp/sys_enter tracepoint.
 * The raw tracepoint arguments are: (struct pt_regs *regs, long id)
 * For BPF_PROG_TEST_RUN, we pass this as an array of __u64 values.
 */
struct raw_tp_sys_enter_ctx {
	__u64 regs;       /* Pointer to pt_regs (will be 0/NULL in test) */
	__u64 syscall_id; /* Syscall number */
} __attribute__((packed));

static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr, unsigned int size)
{
	return syscall(__NR_bpf, cmd, attr, size);
}

/* Wrapper for bpf_obj_get since we don't link against libbpf in trigger */
static int bpf_obj_get(const char *pathname)
{
	union bpf_attr attr;

	memset(&attr, 0, sizeof(attr));
	attr.pathname = (__u64)(unsigned long)pathname;

	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
}

/* Get pinned program fd */
static int get_prog_fd(const char *pin_path)
{
	return bpf_obj_get(pin_path);
}

/* Run BPF program via BPF_PROG_TEST_RUN */
static int run_prog_test(int prog_fd, int iterations)
{
	union bpf_attr attr;
	struct raw_tp_sys_enter_ctx ctx;
	int ret;

	/* Initialize context for sys_enter tracepoint */
	memset(&ctx, 0, sizeof(ctx));
	ctx.regs = 0;        /* NULL pt_regs - acceptable for testing */
	ctx.syscall_id = 1;  /* Simulate sys_write */

	for (int i = 0; i < iterations; i++) {
		memset(&attr, 0, sizeof(attr));
		attr.test.prog_fd = prog_fd;
		attr.test.ctx_in = (__u64)(unsigned long)&ctx;
		attr.test.ctx_size_in = sizeof(ctx);

		ret = sys_bpf(BPF_PROG_TEST_RUN, &attr, sizeof(attr));
		if (ret < 0) {
			if (errno == ENOTSUP || errno == EOPNOTSUPP) {
				fprintf(stderr, "BPF_PROG_TEST_RUN not supported for this program type\n");
				return -1;
			}
			fprintf(stderr, "BPF_PROG_TEST_RUN failed: %s (errno=%d)\n",
				strerror(errno), errno);
			return -1;
		}

		if ((i + 1) % 100 == 0 || i == 0) {
			printf("Trigger %d/%d\n", i + 1, iterations);
		}
	}

	return 0;
}

/* Find all pinned programs */
static int get_pinned_progs(char **prog_names, int max_progs)
{
	DIR *dir;
	struct dirent *entry;
	int count = 0;

	dir = opendir(PIN_BASE_PATH);
	if (!dir) {
		fprintf(stderr, "No pinned programs found at %s\n", PIN_BASE_PATH);
		fprintf(stderr, "Run './loader --all' first to load programs.\n");
		return -1;
	}

	while ((entry = readdir(dir)) != NULL && count < max_progs) {
		if (entry->d_name[0] == '.')
			continue;
		prog_names[count] = strdup(entry->d_name);
		if (!prog_names[count]) {
			fprintf(stderr, "Memory allocation failed\n");
			closedir(dir);
			return -1;
		}
		count++;
	}

	closedir(dir);
	return count;
}

int main(int argc, char *argv[])
{
	int iterations = 1;
	char *prog_names[MAX_PROGS];
	int prog_count;
	char pin_path[512];
	int prog_fd;

	/* Parse arguments */
	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}

	printf("Triggering raw_tp via BPF_PROG_TEST_RUN (%d iterations)\n", iterations);

	/* Find pinned programs */
	prog_count = get_pinned_progs(prog_names, MAX_PROGS);
	if (prog_count < 0)
		return 1;
	if (prog_count == 0) {
		fprintf(stderr, "No programs found in %s\n", PIN_BASE_PATH);
		return 1;
	}

	printf("Found %d program(s)\n\n", prog_count);

	/* Run each program */
	for (int i = 0; i < prog_count; i++) {
		snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_BASE_PATH, prog_names[i]);
		prog_fd = get_prog_fd(pin_path);
		if (prog_fd < 0) {
			fprintf(stderr, "Failed to get prog fd from %s: %s\n",
				pin_path, strerror(errno));
			continue;
		}

		int ret = run_prog_test(prog_fd, iterations);
		close(prog_fd);

		if (ret < 0) {
			fprintf(stderr, "Failed for %s\n", prog_names[i]);
		}
	}

	/* Cleanup */
	for (int i = 0; i < prog_count; i++) {
		free(prog_names[i]);
	}

	printf("\nDone! Triggered %d times.\n", iterations);
	printf("Check outputs for trace and dmesg logs.\n");

	return 0;
}
