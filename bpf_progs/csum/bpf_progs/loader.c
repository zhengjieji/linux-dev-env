// SPDX-License-Identifier: GPL-2.0
/* Simple XDP loader for bpf_csum_diff helper testing */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <net/if.h>
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
	int prog_fd, ifindex;
	int err;

	if (argc < 3) {
		fprintf(stderr, "Usage: %s <bpf_prog.o> <ifname>\n", argv[0]);
		fprintf(stderr, "Example: %s bpf_prog.o lo\n", argv[0]);
		return 1;
	}

	const char *ifname = argv[2];
	ifindex = if_nametoindex(ifname);
	if (!ifindex) {
		fprintf(stderr, "Failed to get ifindex for %s: %s\n", ifname, strerror(errno));
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

	/* Find the XDP program */
	prog = bpf_object__find_program_by_name(obj, "xdp_csum_test");
	if (!prog) {
		fprintf(stderr, "Failed to find program 'xdp_csum_test'\n");
		bpf_object__close(obj);
		return 1;
	}

	prog_fd = bpf_program__fd(prog);
	if (prog_fd < 0) {
		fprintf(stderr, "Failed to get program fd\n");
		bpf_object__close(obj);
		return 1;
	}

	/* Attach XDP program to interface */
	err = bpf_xdp_attach(ifindex, prog_fd, 0, NULL);
	if (err) {
		fprintf(stderr, "Failed to attach XDP program to %s: %d\n", ifname, err);
		bpf_object__close(obj);
		return 1;
	}

	printf("XDP csum test program attached to %s successfully!\n", ifname);
	printf("Program will run on every packet received on %s.\n", ifname);
	printf("Monitor output: sudo cat /sys/kernel/debug/tracing/trace_pipe\n");
	printf("Press Ctrl+C to exit\n\n");

	/* Wait for signal */
	while (!exiting) {
		sleep(1);
	}

	printf("\nDetaching XDP program...\n");
	bpf_xdp_detach(ifindex, 0, NULL);
	bpf_object__close(obj);

	return 0;
}
