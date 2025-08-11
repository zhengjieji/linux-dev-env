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
    struct bpf_map *map;
    int err = 0;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <bpf_object_file> [target_pid]\n", argv[0]);
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

    prog = bpf_object__find_program_by_name(obj, "test_send_signal_task");
    if (!prog) {
        fprintf(stderr, "Failed to find BPF program test_send_signal_task\n");
        err = -ENOENT;
        goto cleanup;
    }

    // Get the map and optionally set target PID
    map = bpf_object__find_map_by_name(obj, "target_pid_map");
    if (map) {
        int map_fd = bpf_map__fd(map);
        if (argc >= 3) {
            __u32 key = 0;
            __u32 target_pid = atoi(argv[2]);
            err = bpf_map_update_elem(map_fd, &key, &target_pid, BPF_ANY);
            if (err == 0) {
                printf("Set target PID to %d\n", target_pid);
            } else {
                printf("Failed to set target PID: %s\n", strerror(errno));
            }
        }
        
        // Pin the map so trigger program can access it
        err = bpf_map__pin(map, "/sys/fs/bpf/target_pid_map");
        if (err && err != -EEXIST) {
            printf("Warning: Failed to pin map: %s\n", strerror(-err));
        } else {
            printf("Map pinned to /sys/fs/bpf/target_pid_map\n");
        }
    }

    link = bpf_program__attach(prog);
    if (libbpf_get_error(link)) {
        err = libbpf_get_error(link);
        fprintf(stderr, "Failed to attach BPF program: %d (%s)\n", err, strerror(-err));
        link = NULL;
        goto cleanup;
    }

    printf("BPF tracepoint program loaded and attached successfully.\n");
    printf("Press Ctrl+C to exit.\n");
    printf("Monitor output with: cat /sys/kernel/debug/tracing/trace_pipe\n\n");

    while (!exiting) {
        sleep(1);
    }

cleanup:
    // Unpin the map on exit
    unlink("/sys/fs/bpf/target_pid_map");
    
    if (link)
        bpf_link__destroy(link);
    if (obj)
        bpf_object__close(obj);

    return err != 0;
}