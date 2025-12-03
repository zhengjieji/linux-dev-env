// SPDX-License-Identifier: GPL-2.0
/* BPF loader for tp/syscalls/sys_enter_getcwd micro-benchmark
 *
 * This loader loads BPF programs and EXITS, keeping them pinned.
 * Use detach.sh to clean up later.
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
#include <bpf/libbpf.h>
#include <bpf/bpf.h>

#define MAX_PROGS 32
#define PIN_BASE_PATH "/sys/fs/bpf/micro_benchmark_tp_getcwd"

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

/* Load and pin a single BPF program */
static int load_and_pin_program(const char *obj_file)
{
	struct bpf_object *obj;
	struct bpf_program *prog;
	struct bpf_link *link;
	char pin_path[512];
	char *prog_name;
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

		printf("  Found program: %s\n", prog_name);

		/* Attach program */
		link = bpf_program__attach(prog);
		if (!link) {
			err = -errno;
			fprintf(stderr, "  Failed to attach program %s: %s\n",
				prog_name, strerror(-err));
			bpf_object__close(obj);
			return -1;
		}

		/* Pin the link so it persists after we exit */
		snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_BASE_PATH, prog_name);
		err = bpf_link__pin(link, pin_path);
		if (err) {
			fprintf(stderr, "  Failed to pin link %s: %s\n",
				pin_path, strerror(-err));
			bpf_link__destroy(link);
			bpf_object__close(obj);
			return -1;
		}

		printf("  ✓ Attached and pinned: %s\n", pin_path);

		/* Don't destroy - it's pinned and will persist */
		/* bpf_link__destroy(link); */
	}

	/* Don't close object - it will persist via pinned links */
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
		fprintf(stderr, "  %s bpf_progs/test_csum.kern.o\n", argv[0]);
		fprintf(stderr, "  %s bpf_progs/test_csum.kern.o bpf_progs/test_obj_new.kern.o\n", argv[0]);
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
	printf("BPF Loader for tp/syscalls/sys_enter_getcwd\n");
	printf("========================================\n");
	printf("Loading %d program(s)...\n", prog_count);

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
		printf("\nPrograms are now loaded and will persist.\n");
		printf("To detach: run ./scripts/detach.sh\n");
		printf("To trigger: run ./scripts/trigger.sh [iterations]\n");
		printf("\nMonitor output: sudo cat /sys/kernel/debug/tracing/trace_pipe\n");
	}

	return (success_count == prog_count) ? 0 : 1;
}
