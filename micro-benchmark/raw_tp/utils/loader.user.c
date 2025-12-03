// SPDX-License-Identifier: GPL-2.0
/* BPF loader for raw_tp micro-benchmark
 *
 * This loader loads BPF programs and pins the prog fd for later use with
 * BPF_PROG_TEST_RUN. Unlike other benchmarks, raw_tp programs are NOT attached
 * to actual tracepoints - they are executed directly via BPF_PROG_TEST_RUN.
 *
 * Usage:
 *   ./loader <prog1.o> [prog2.o] ...    # Load specific programs
 *   ./loader --all                      # Load all programs in bpf_progs/
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>
#include <fcntl.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>

#define MAX_PROGS 32
#define PIN_BASE_PATH "/sys/fs/bpf/micro_benchmark_raw_tp"

static int libbpf_print_fn(enum libbpf_print_level level, const char *format, va_list args)
{
	if (level == LIBBPF_DEBUG)
		return 0;
	return vfprintf(stderr, format, args);
}

/* Create directory if it doesn't exist */
static int mkdir_p(const char *path)
{
	char tmp[256];
	char *p = NULL;
	size_t len;

	snprintf(tmp, sizeof(tmp), "%s", path);
	len = strlen(tmp);
	if (tmp[len - 1] == '/')
		tmp[len - 1] = 0;

	for (p = tmp + 1; *p; p++) {
		if (*p == '/') {
			*p = 0;
			if (mkdir(tmp, 0755) != 0 && errno != EEXIST) {
				fprintf(stderr, "Failed to create directory %s: %s\n",
					tmp, strerror(errno));
				return -1;
			}
			*p = '/';
		}
	}

	if (mkdir(tmp, 0755) != 0 && errno != EEXIST) {
		fprintf(stderr, "Failed to create directory %s: %s\n",
			tmp, strerror(errno));
		return -1;
	}

	return 0;
}

/* Load and pin a single BPF program (prog fd only, no attachment) */
static int load_and_pin_program(const char *obj_file)
{
	struct bpf_object *obj;
	struct bpf_program *prog;
	char pin_path[512];
	char *prog_name;
	int prog_fd;
	int err;

	printf("\n=== Loading %s ===\n", obj_file);

	/* Open BPF object */
	obj = bpf_object__open_file(obj_file, NULL);
	if (!obj) {
		fprintf(stderr, "Failed to open BPF object %s\n", obj_file);
		return -1;
	}

	/* Load BPF program */
	err = bpf_object__load(obj);
	if (err) {
		fprintf(stderr, "Failed to load BPF object %s: %d\n", obj_file, err);
		bpf_object__close(obj);
		return -1;
	}

	/* Iterate through all programs in the object */
	bpf_object__for_each_program(prog, obj) {
		prog_name = (char *)bpf_program__name(prog);
		prog_fd = bpf_program__fd(prog);

		printf("  Found program: %s (fd=%d)\n", prog_name, prog_fd);

		/* Pin the program fd so it persists and can be used by trigger */
		snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_BASE_PATH, prog_name);

		/* Remove old pin if exists */
		unlink(pin_path);

		err = bpf_obj_pin(prog_fd, pin_path);
		if (err) {
			fprintf(stderr, "  Failed to pin program %s: %s\n",
				pin_path, strerror(errno));
			bpf_object__close(obj);
			return -1;
		}

		printf("  ✓ Loaded and pinned: %s\n", pin_path);
	}

	/* Don't close object - it will persist via pinned progs */
	/* bpf_object__close(obj); */

	printf("  ✓ Successfully loaded %s\n", obj_file);
	return 0;
}

/* Get list of .o files in bpf_progs/ directory */
static int get_all_bpf_progs(char **prog_list, int max_progs)
{
	DIR *dir;
	struct dirent *entry;
	int count = 0;
	char path[512];

	dir = opendir("bpf_progs");
	if (!dir) {
		fprintf(stderr, "Failed to open bpf_progs directory: %s\n", strerror(errno));
		return -1;
	}

	while ((entry = readdir(dir)) != NULL && count < max_progs) {
		/* Look for .kern.o files */
		if (strstr(entry->d_name, ".kern.o")) {
			snprintf(path, sizeof(path), "bpf_progs/%s", entry->d_name);
			prog_list[count] = strdup(path);
			if (!prog_list[count]) {
				fprintf(stderr, "Memory allocation failed\n");
				closedir(dir);
				return -1;
			}
			count++;
		}
	}

	closedir(dir);
	return count;
}

int main(int argc, char *argv[])
{
	char *prog_list[MAX_PROGS];
	int prog_count = 0;
	int i, err;
	int load_all = 0;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <prog1.o> [prog2.o] ...\n", argv[0]);
		fprintf(stderr, "   or: %s --all\n", argv[0]);
		fprintf(stderr, "\nExample:\n");
		fprintf(stderr, "  %s bpf_progs/simple.kern.o\n", argv[0]);
		fprintf(stderr, "  %s --all\n", argv[0]);
		return 1;
	}

	libbpf_set_print(libbpf_print_fn);

	/* Create pin directory */
	if (mkdir_p(PIN_BASE_PATH) != 0) {
		return 1;
	}

	/* Parse arguments */
	if (strcmp(argv[1], "--all") == 0) {
		load_all = 1;
		prog_count = get_all_bpf_progs(prog_list, MAX_PROGS);
		if (prog_count < 0) {
			fprintf(stderr, "Failed to get BPF program list\n");
			return 1;
		}
		if (prog_count == 0) {
			fprintf(stderr, "No .kern.o files found in bpf_progs/\n");
			return 1;
		}
		printf("Found %d BPF programs to load\n", prog_count);
	} else {
		/* Load specific programs from command line */
		for (i = 1; i < argc && prog_count < MAX_PROGS; i++) {
			prog_list[prog_count++] = argv[i];
		}
	}

	printf("========================================\n");
	printf("BPF Loader for raw_tp (BPF_PROG_TEST_RUN)\n");
	printf("========================================\n");
	printf("Loading %d program(s)...\n", prog_count);
	printf("NOTE: Programs are NOT attached - use trigger for BPF_PROG_TEST_RUN\n");

	/* Load each program */
	int success_count = 0;
	for (i = 0; i < prog_count; i++) {
		err = load_and_pin_program(prog_list[i]);
		if (err == 0) {
			success_count++;
		} else {
			fprintf(stderr, "\n✗ Failed to load %s\n", prog_list[i]);
		}
	}

	/* Free allocated memory if we used --all */
	if (load_all) {
		for (i = 0; i < prog_count; i++) {
			free(prog_list[i]);
		}
	}

	printf("\n========================================\n");
	printf("Summary: %d/%d programs loaded successfully\n", success_count, prog_count);
	printf("========================================\n");

	if (success_count > 0) {
		printf("\nPrograms are now loaded and pinned (NOT attached).\n");
		printf("To run benchmark: ./scripts/trigger.sh [iterations]\n");
		printf("To unload: ./scripts/detach.sh\n");
	}

	return (success_count == prog_count) ? 0 : 1;
}
