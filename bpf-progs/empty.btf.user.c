#include "empty.skel.h"
#include <bpf/libbpf.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

static int libbpf_print_fn(enum libbpf_print_level level, const char *format,
                           va_list args) {
  return vfprintf(stderr, format, args);
}

int main() {
  struct empty_kern *skel;
  int err;

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