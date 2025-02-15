// test_func_driver.user.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>

static void usage(const char *prog)
{
    printf("Usage: %s <bpf_obj_file> <prog_name>\n", prog);
}

int main(int argc, char **argv)
{
    struct bpf_object *obj;
    struct bpf_program *prog;
    int err;

    if (argc != 3) {
        usage(argv[0]);
        return 1;
    }

    const char *bpf_obj_file = argv[1];
    const char *prog_name = argv[2];

    obj = bpf_object__open_file(bpf_obj_file, NULL);
    if (!obj) {
        fprintf(stderr, "Failed to open BPF object file: %s\n", bpf_obj_file);
        return 1;
    }

    err = bpf_object__load(obj);
    if (err) {
        fprintf(stderr, "Failed to load BPF object: %d\n", err);
        return 1;
    }

    prog = bpf_object__find_program_by_name(obj, prog_name);
    if (!prog) {
        fprintf(stderr, "Failed to find BPF program with name %s\n", prog_name);
        return 1;
    }

    // Attach 程序到 kprobe "__do_sys_getcwd"
    struct bpf_link *link = bpf_program__attach_kprobe(prog, false, "__do_sys_getcwd");
    if (!link) {
        fprintf(stderr, "Failed to attach BPF program\n");
        return 1;
    }

    printf("BPF program attached. Now, trigger getcwd (e.g. run a process that calls getcwd).\n");
    printf("Press Ctrl+C to exit...\n");
    while (1)
        sleep(1);

    bpf_link__destroy(link);
    bpf_object__close(obj);
    return 0;
}

