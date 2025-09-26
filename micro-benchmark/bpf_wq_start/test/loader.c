#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/resource.h>
#include <net/if.h>

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
    struct bpf_program *prog;
    struct bpf_map *map;
    int prog_fd, map_fd;
    int err = 0;
    int ifindex;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <bpf_object_file> [interface]\n", argv[0]);
        return 1;
    }

    const char *iface = argc > 2 ? argv[2] : "lo";
    ifindex = if_nametoindex(iface);
    if (!ifindex) {
        fprintf(stderr, "Failed to get ifindex for %s\n", iface);
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

    /* Initialize the workqueue map */
    map = bpf_object__find_map_by_name(obj, "wq_map");
    if (!map) {
        fprintf(stderr, "Failed to find wq_map\n");
        err = -ENOENT;
        goto cleanup;
    }

    map_fd = bpf_map__fd(map);
    if (map_fd < 0) {
        fprintf(stderr, "Failed to get map fd\n");
        err = map_fd;
        goto cleanup;
    }

    /* Initialize map element - struct bpf_wq is 16 bytes */
    struct elem {
        char work[16];  /* struct bpf_wq */
        int counter;
    } value = {0};
    int key = 0;

    err = bpf_map_update_elem(map_fd, &key, &value, BPF_ANY);
    if (err) {
        fprintf(stderr, "Failed to initialize map element: %d\n", err);
        goto cleanup;
    }

    prog = bpf_object__find_program_by_name(obj, "test_wq_init");
    if (!prog) {
        fprintf(stderr, "Failed to find BPF program test_wq_init\n");
        err = -ENOENT;
        goto cleanup;
    }

    prog_fd = bpf_program__fd(prog);
    if (prog_fd < 0) {
        fprintf(stderr, "Failed to get program fd\n");
        err = prog_fd;
        goto cleanup;
    }

    /* Attach to TC */
    DECLARE_LIBBPF_OPTS(bpf_tc_hook, hook, .ifindex = ifindex, .attach_point = BPF_TC_INGRESS);
    DECLARE_LIBBPF_OPTS(bpf_tc_opts, opts, .prog_fd = prog_fd);

    err = bpf_tc_hook_create(&hook);
    if (err && err != -EEXIST) {
        fprintf(stderr, "Failed to create TC hook: %d\n", err);
        goto cleanup;
    }

    err = bpf_tc_attach(&hook, &opts);
    if (err) {
        fprintf(stderr, "Failed to attach TC program: %d\n", err);
        goto cleanup;
    }

    printf("BPF TC program attached to %s successfully.\n", iface);
    printf("Testing bpf_wq_start kfunc...\n");
    printf("Press Ctrl+C to exit.\n");
    printf("Monitor output with: cat /sys/kernel/debug/tracing/trace_pipe\n\n");

    while (!exiting) {
        sleep(1);
    }

    /* Detach */
    opts.prog_fd = 0;
    opts.prog_id = 0;
    bpf_tc_detach(&hook, &opts);
    bpf_tc_hook_destroy(&hook);

cleanup:
    if (obj)
        bpf_object__close(obj);

    return err != 0;
}