// SPDX-License-Identifier: GPL-2.0
/* BPF loader for TC micro-benchmark
 *
 * This loader loads TC BPF programs and attaches them to loopback interface ingress.
 * Programs are pinned so they persist after loader exits.
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
#include <net/if.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>

#define MAX_PROGS 32
#define PIN_BASE_PATH "/sys/fs/bpf/micro_benchmark_tc"
#define IFNAME "lo"

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

/* Load and attach a single TC program */
static int load_and_attach_tc(const char *obj_file, int ifindex)
{
	DECLARE_LIBBPF_OPTS(bpf_tc_hook, hook,
		.ifindex = ifindex,
		.attach_point = BPF_TC_INGRESS,
	);
	DECLARE_LIBBPF_OPTS(bpf_tc_opts, opts);
	struct bpf_object *obj;
	struct bpf_program *prog;
	struct bpf_map *map;
	char pin_path[512];
	const char *prog_name;
	const char *map_name;
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

	/* Find the TC program */
	prog = bpf_object__next_program(obj, NULL);
	if (!prog) {
		fprintf(stderr, "No program found in %s\n", obj_file);
		bpf_object__close(obj);
		return -1;
	}

	prog_name = bpf_program__name(prog);
	prog_fd = bpf_program__fd(prog);

	printf("  Found program: %s (fd=%d)\n", prog_name, prog_fd);

	/* Create TC hook (clsact qdisc) - ignore EEXIST if already created */
	err = bpf_tc_hook_create(&hook);
	if (err && err != -EEXIST) {
		fprintf(stderr, "  Failed to create TC hook on %s: %s\n",
			IFNAME, strerror(-err));
		bpf_object__close(obj);
		return -1;
	}

	/* Try to detach any existing program first (ignore errors) */
	{
		DECLARE_LIBBPF_OPTS(bpf_tc_opts, detach_opts);
		bpf_tc_detach(&hook, &detach_opts);
	}

	/* Attach TC program */
	opts.prog_fd = prog_fd;
	err = bpf_tc_attach(&hook, &opts);
	if (err) {
		fprintf(stderr, "  Failed to attach TC program to %s: %s\n",
			IFNAME, strerror(-err));
		bpf_object__close(obj);
		return -1;
	}

	printf("  ✓ Attached to %s ingress (ifindex=%d, handle=%u, priority=%u)\n",
		IFNAME, ifindex, opts.handle, opts.priority);

	/* Pin the program so it persists after we exit */
	snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_BASE_PATH, prog_name);

	/* Remove old pin if exists */
	unlink(pin_path);

	err = bpf_program__pin(prog, pin_path);
	if (err) {
		fprintf(stderr, "  Failed to pin program %s: %s\n",
			pin_path, strerror(-err));
		/* Detach on failure - need handle and priority from attach */
		bpf_tc_detach(&hook, &opts);
		bpf_object__close(obj);
		return -1;
	}

	printf("  ✓ Pinned program: %s\n", pin_path);

	/* Pin all maps so they persist (required for bpf_wq, bpf_timer, etc.) */
	bpf_object__for_each_map(map, obj) {
		map_name = bpf_map__name(map);

		/* Skip internal maps */
		if (strncmp(map_name, ".rodata", 7) == 0 ||
		    strncmp(map_name, ".data", 5) == 0 ||
		    strncmp(map_name, ".bss", 4) == 0)
			continue;

		snprintf(pin_path, sizeof(pin_path), "%s/map_%s", PIN_BASE_PATH, map_name);

		/* Remove old pin if exists */
		unlink(pin_path);

		err = bpf_map__pin(map, pin_path);
		if (err) {
			fprintf(stderr, "  Warning: Failed to pin map %s: %s\n",
				map_name, strerror(-err));
			/* Continue anyway - some maps may not need pinning */
		} else {
			printf("  ✓ Pinned map: %s\n", pin_path);
		}
	}

	printf("  ✓ Successfully loaded %s\n", obj_file);

	/* Note: We don't close the object as the program needs to stay loaded */
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
	int ifindex;
	int i, err;
	int load_all = 0;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <prog1.o> [prog2.o] ...\n", argv[0]);
		fprintf(stderr, "   or: %s --all\n", argv[0]);
		fprintf(stderr, "\nExample:\n");
		fprintf(stderr, "  %s bpf_progs/test_simple.kern.o\n", argv[0]);
		fprintf(stderr, "  %s --all\n", argv[0]);
		return 1;
	}

	libbpf_set_print(libbpf_print_fn);

	/* Get interface index */
	ifindex = if_nametoindex(IFNAME);
	if (!ifindex) {
		fprintf(stderr, "Failed to get ifindex for %s: %s\n", IFNAME, strerror(errno));
		return 1;
	}

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
	printf("BPF Loader for TC (interface: %s)\n", IFNAME);
	printf("========================================\n");
	printf("Loading %d program(s)...\n", prog_count);

	/* Load each program */
	int success_count = 0;
	for (i = 0; i < prog_count; i++) {
		err = load_and_attach_tc(prog_list[i], ifindex);
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
		printf("\nTC program is now attached to %s ingress and will persist.\n", IFNAME);
		printf("To detach: run ./scripts/detach.sh\n");
		printf("To trigger: run ./scripts/trigger.sh [iterations]\n");
		printf("\nMonitor output: sudo cat /sys/kernel/debug/tracing/trace_pipe\n");
	}

	return (success_count == prog_count) ? 0 : 1;
}
