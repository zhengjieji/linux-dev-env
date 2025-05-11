#include <bpf/bpf_helpers.h>
#include <linux/bpf.h>
#include <vmlinux.h>

#include "bpf_experimental.h"

char _license[] SEC("license") = "GPL";

struct bar {
  struct bpf_list_node node;
  int data;
};

struct foo {
  struct bpf_list_node node;
  struct bpf_list_head head __contains(bar, node);
  struct bpf_spin_lock lock;
  int data;
  struct bpf_list_node node2;
};

struct bpf_spin_lock glock;

SEC("tp/syscalls/sys_enter_getcwd")
int empty(void *ctx) {
  struct bpf_list_node *n;
  struct foo *f;
  f = bpf_obj_new(typeof(*f));
  if (!f)
    return 2;
  bpf_obj_drop(f);

  return 0;
}
