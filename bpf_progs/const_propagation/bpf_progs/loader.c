// SPDX-License-Identifier: GPL-2.0
/* Simple BPF loader for custom kfunc testing */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>

static volatile int exiting = 0;

static void sig_handler(int sig)
{
	exiting = 1;
}

static int libbpf_print_fn(enum libbpf_print_level level, const char *format, va_list args)
{
	return vfprintf(stderr, format, args);
}

int main(int argc, char *argv[])
{
	struct bpf_object *obj;
	struct bpf_program *prog;
	struct bpf_link *link;
	int err;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <bpf_prog.o>\n", argv[0]);
		return 1;
	}

	libbpf_set_print(libbpf_print_fn);
	signal(SIGINT, sig_handler);
	signal(SIGTERM, sig_handler);

	/* Open BPF object */
	obj = bpf_object__open_file(argv[1], NULL);
	if (!obj) {
		fprintf(stderr, "Failed to open BPF object\n");
		return 1;
	}

	/* Load BPF program */
	err = bpf_object__load(obj);
	if (err) {
		fprintf(stderr, "Failed to load BPF object: %d\n", err);
		bpf_object__close(obj);
		return 1;
	}

	/* Find the program */
	prog = bpf_object__find_program_by_name(obj, "test_custom_kfuncs");
	if (!prog) {
		fprintf(stderr, "Failed to find program 'test_custom_kfuncs'\n");
		bpf_object__close(obj);
		return 1;
	}

	/* Attach to raw tracepoint */
	link = bpf_program__attach(prog);
	if (!link) {
		err = -errno;
		fprintf(stderr, "Failed to attach BPF program: %d\n", err);
		bpf_object__close(obj);
		return 1;
	}

	printf("Custom kfunc BPF program attached successfully!\n");
	printf("Program will run on every syscall entry.\n");
	printf("Monitor output: sudo cat /sys/kernel/debug/tracing/trace_pipe\n");
	printf("Press Ctrl+C to exit\n\n");

	/* Wait for signal */
	while (!exiting) {
		sleep(1);
	}

	printf("\nDetaching...\n");
	bpf_link__destroy(link);
	bpf_object__close(obj);

	return 0;
}
