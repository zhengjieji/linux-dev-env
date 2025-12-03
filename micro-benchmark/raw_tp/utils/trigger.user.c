// SPDX-License-Identifier: GPL-2.0
/* Trigger for raw_tp micro-benchmark using BPF_PROG_TEST_RUN
 *
 * This program runs pinned BPF programs via BPF_PROG_TEST_RUN syscall,
 * which directly executes the BPF program without needing to trigger
 * an actual tracepoint. This is ideal for benchmarking BPF program
 * execution time in isolation.
 *
 * Usage:
 *   ./trigger [iterations] [prog_name]
 *   ./trigger 1000              # Run all pinned programs 1000 times each
 *   ./trigger 1000 test_simple  # Run specific program 1000 times
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <time.h>
#include <sys/syscall.h>
#include <linux/bpf.h>

#define PIN_BASE_PATH "/sys/fs/bpf/micro_benchmark_raw_tp"
#define MAX_PROGS 32

/* Context buffer for raw_tp programs (simulated pt_regs + syscall id) */
struct raw_tp_test_ctx {
	__u64 regs[32];  /* Simulated pt_regs */
	__s64 syscall_id;
} __attribute__((packed));

static inline int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr, unsigned int size)
{
	return syscall(__NR_bpf, cmd, attr, size);
}

/* Get pinned program fd */
static int get_prog_fd(const char *pin_path)
{
	return bpf_obj_get(pin_path);
}

/* Wrapper for bpf_obj_get since we don't link against libbpf in trigger */
static int bpf_obj_get(const char *pathname)
{
	union bpf_attr attr;

	memset(&attr, 0, sizeof(attr));
	attr.pathname = (__u64)(unsigned long)pathname;

	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
}

/* Run BPF program via BPF_PROG_TEST_RUN */
static int run_prog_test(int prog_fd, int iterations, __u64 *total_duration_ns)
{
	union bpf_attr attr;
	struct raw_tp_test_ctx ctx;
	int ret;
	__u64 duration_sum = 0;

	/* Initialize context with dummy values */
	memset(&ctx, 0, sizeof(ctx));
	ctx.syscall_id = 1; /* Simulate sys_write */

	for (int i = 0; i < iterations; i++) {
		memset(&attr, 0, sizeof(attr));
		attr.test.prog_fd = prog_fd;
		attr.test.ctx_in = (__u64)(unsigned long)&ctx;
		attr.test.ctx_size_in = sizeof(ctx);
		attr.test.repeat = 1;

		ret = sys_bpf(BPF_PROG_TEST_RUN, &attr, sizeof(attr));
		if (ret < 0) {
			if (errno == ENOTSUPP || errno == EOPNOTSUPP) {
				fprintf(stderr, "BPF_PROG_TEST_RUN not supported for this program type\n");
				return -1;
			}
			fprintf(stderr, "BPF_PROG_TEST_RUN failed: %s (errno=%d)\n",
				strerror(errno), errno);
			return -1;
		}

		duration_sum += attr.test.duration;

		if ((i + 1) % 1000 == 0 || i == 0) {
			printf("  Run %d/%d (last duration: %u ns)\n",
			       i + 1, iterations, attr.test.duration);
		}
	}

	*total_duration_ns = duration_sum;
	return 0;
}

/* Run benchmark with repeat count (more efficient) */
static int run_prog_test_batch(int prog_fd, int total_runs, __u32 batch_size, __u64 *total_duration_ns)
{
	union bpf_attr attr;
	struct raw_tp_test_ctx ctx;
	int ret;
	__u64 duration_sum = 0;
	int runs_done = 0;

	/* Initialize context with dummy values */
	memset(&ctx, 0, sizeof(ctx));
	ctx.syscall_id = 1; /* Simulate sys_write */

	while (runs_done < total_runs) {
		__u32 this_batch = batch_size;
		if (runs_done + this_batch > total_runs)
			this_batch = total_runs - runs_done;

		memset(&attr, 0, sizeof(attr));
		attr.test.prog_fd = prog_fd;
		attr.test.ctx_in = (__u64)(unsigned long)&ctx;
		attr.test.ctx_size_in = sizeof(ctx);
		attr.test.repeat = this_batch;

		ret = sys_bpf(BPF_PROG_TEST_RUN, &attr, sizeof(attr));
		if (ret < 0) {
			if (errno == ENOTSUPP || errno == EOPNOTSUPP) {
				fprintf(stderr, "BPF_PROG_TEST_RUN not supported for this program type\n");
				return -1;
			}
			fprintf(stderr, "BPF_PROG_TEST_RUN failed: %s (errno=%d)\n",
				strerror(errno), errno);
			return -1;
		}

		duration_sum += attr.test.duration;
		runs_done += this_batch;

		printf("  Batch complete: %d/%d runs (batch duration: %u ns)\n",
		       runs_done, total_runs, attr.test.duration);
	}

	*total_duration_ns = duration_sum;
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
	char *target_prog = NULL;
	char *prog_names[MAX_PROGS];
	int prog_count;
	char pin_path[512];
	int prog_fd;
	__u64 total_duration;
	int use_batch = 1;
	__u32 batch_size = 100;

	/* Parse arguments */
	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}
	if (argc > 2) {
		target_prog = argv[2];
	}

	printf("========================================\n");
	printf("BPF_PROG_TEST_RUN Trigger for raw_tp\n");
	printf("========================================\n");
	printf("Iterations: %d\n", iterations);
	if (target_prog)
		printf("Target program: %s\n", target_prog);
	else
		printf("Target: all pinned programs\n");
	printf("\n");

	/* Find pinned programs */
	if (target_prog) {
		prog_names[0] = target_prog;
		prog_count = 1;
	} else {
		prog_count = get_pinned_progs(prog_names, MAX_PROGS);
		if (prog_count < 0)
			return 1;
		if (prog_count == 0) {
			fprintf(stderr, "No programs found in %s\n", PIN_BASE_PATH);
			return 1;
		}
	}

	printf("Found %d program(s) to benchmark\n\n", prog_count);

	/* Run each program */
	for (int i = 0; i < prog_count; i++) {
		printf("----------------------------------------\n");
		printf("Program: %s\n", prog_names[i]);
		printf("----------------------------------------\n");

		snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_BASE_PATH, prog_names[i]);
		prog_fd = get_prog_fd(pin_path);
		if (prog_fd < 0) {
			fprintf(stderr, "Failed to get prog fd from %s: %s\n",
				pin_path, strerror(errno));
			continue;
		}

		printf("  Got prog_fd=%d\n", prog_fd);

		/* Run benchmark */
		int ret;
		if (use_batch && iterations > batch_size) {
			printf("  Running %d iterations in batches of %u...\n", iterations, batch_size);
			ret = run_prog_test_batch(prog_fd, iterations, batch_size, &total_duration);
		} else {
			printf("  Running %d iterations...\n", iterations);
			ret = run_prog_test(prog_fd, iterations, &total_duration);
		}

		close(prog_fd);

		if (ret < 0) {
			fprintf(stderr, "  ✗ Benchmark failed for %s\n", prog_names[i]);
			continue;
		}

		/* Report results */
		double avg_ns = (double)total_duration / iterations;
		printf("\n  Results for %s:\n", prog_names[i]);
		printf("    Total runs:     %d\n", iterations);
		printf("    Total duration: %lu ns\n", total_duration);
		printf("    Avg per run:    %.2f ns\n", avg_ns);
		printf("  ✓ Benchmark complete\n\n");
	}

	/* Cleanup if we allocated prog_names */
	if (!target_prog) {
		for (int i = 0; i < prog_count; i++) {
			free(prog_names[i]);
		}
	}

	printf("========================================\n");
	printf("All benchmarks complete!\n");
	printf("========================================\n");

	return 0;
}
