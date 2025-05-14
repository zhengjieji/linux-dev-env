#include "vmlinux.h"

#include <bpf/bpf_core_read.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

#define __contains(name, node) __attribute__((btf_decl_tag("contains:" #name ":" #node)))

#define bpf_obj_new(type)                                                      \
  ((type *)bpf_obj_new_impl(bpf_core_type_id_local(type), NULL))

#define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)

char _license[] SEC("license") = "GPL";

struct bar {
  struct bpf_list_node node;
  int data;
};

struct foo {
  struct bpf_list_node node;
  struct bpf_spin_lock lock;
  int data;
  struct bpf_list_node node2;
  struct bpf_list_head head __contains(bar, node);
};


SEC("tp_btf/task_newtask")
int empty(void *ctx) {
  struct foo *f;
  f = bpf_obj_new(typeof(*f));
  if (f == NULL)
    return 1;
  bpf_obj_drop(f);
  return 0;
}
