#include "empty.skel.h"
#include <bpf/libbpf.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

static int libbpf_print_fn(enum libbpf_print_level level, const char *format,
                           va_list args) {
  if (level >= LIBBPF_DEBUG)
    return 0;

  return vfprintf(stderr, format, args);
}

// void handle_event(void *ctx, int cpu, void *data, unsigned int data_sz) {
//   struct data_t *m = data;

//   printf("%-6d %-6d %-16s %-16s %s\n", m->pid, m->uid, m->command, m->path,
//          m->message);
// }

// void lost_event(void *ctx, int cpu, long long unsigned int data_sz) {
//   printf("lost event\n");
// }

int main() {
  struct empty_kern *skel;
  int err;
  struct perf_buffer *pb = NULL;

  libbpf_set_print(libbpf_print_fn);

  skel = empty_kern__open_and_load();
  if (!skel) {
    printf("Failed to open BPF object\n");
    return 1;
  }

  err = empty_kern__attach(skel);
  if (err) {
    fprintf(stderr, "Failed to attach BPF skeleton: %d\n", err);
    empty_kern__destroy(skel);
    return 1;
  }

  empty_kern__destroy(skel);
  return -err;
}