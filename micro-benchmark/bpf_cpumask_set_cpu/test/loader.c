#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/resource.h>

#include <bpf/bpf.h>
#include <bpf/libbpf.h>

static volatile sig_atomic_t exiting = 0;

static void sig_handler(int sig)
{
    exiting = 1;
}

static int libbpf_print_fn(enum libbpf_print_level level, const char *format, va_list args)
{
    return vfprintf(stderr, format, args);
}

static void bump_memlock_rlimit(void)
{
    struct rlimit rlim_new = {
        .rlim_cur = RLIM_INFINITY,
        .rlim_max = RLIM_INFINITY,
    };

    if (setrlimit(RLIMIT_MEMLOCK, &rlim_new)) {
        fprintf(stderr, "Failed to increase RLIMIT_MEMLOCK limit!\n");
    }
}

int main(int argc, char *argv[])
{
    struct bpf_object *obj = NULL;
    struct bpf_link *link = NULL;
    struct bpf_program *prog;
    int err = 0;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <bpf_object_file>\n", argv[0]);
        return 1;
    }

    libbpf_set_print(libbpf_print_fn);
    bump_memlock_rlimit();

    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);

    obj = bpf_object__open_file(argv[1], NULL);
    if (libbpf_get_error(obj)) {
        fprintf(stderr, "Failed to open BPF object %s: %s\n", argv[1], strerror(errno));
        return 1;
    }

    err = bpf_object__load(obj);
    if (err) {
        fprintf(stderr, "Failed to load BPF object: %d (%s)\n", err, strerror(-err));
        goto cleanup;
    }

    prog = bpf_object__find_program_by_name(obj, "test_cpumask_ops");
    if (!prog) {
        fprintf(stderr, "Failed to find BPF program test_cpumask_ops\n");
        err = -ENOENT;
        goto cleanup;
    }

    link = bpf_program__attach(prog);
    if (libbpf_get_error(link)) {
        err = libbpf_get_error(link);
        fprintf(stderr, "Failed to attach BPF program: %d (%s)\n", err, strerror(-err));
        link = NULL;
        goto cleanup;
    }

    printf("BPF program loaded and attached successfully.\n");
    printf("Testing bpf_cpumask_set_cpu kfunc...\n");
    printf("Press Ctrl+C to exit.\n");
    printf("Monitor output with: cat /sys/kernel/debug/tracing/trace_pipe\n\n");

    while (!exiting) {
        sleep(1);
    }

cleanup:
    if (link)
        bpf_link__destroy(link);
    if (obj)
        bpf_object__close(obj);

    return err != 0;
}