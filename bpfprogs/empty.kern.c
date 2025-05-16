#include "vmlinux.h"

#include <bpf/bpf_core_read.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

#define __contains(name, node) __attribute__((btf_decl_tag("contains:" #name ":" #node)))

#define bpf_obj_new(type)                                                      \
  ((type *)bpf_obj_new_impl(bpf_core_type_id_local(type), NULL))

#define bpf_obj_drop(kptr) bpf_obj_drop_impl(kptr, NULL)

char _license[] SEC("license") = "GPL";

struct foo {
  struct bpf_list_node node;
  int data;
};

struct bpf_list_head head __contains(foo, node);
struct bpf_spin_lock lock;

SEC("?tc")
int empty(void *ctx) {
  struct bpf_list_node *n;
  struct foo *f;
  f = bpf_obj_new(typeof(*f));
  if (!f)
    return 2;
  bpf_spin_lock(&lock);
  n = bpf_list_pop_front(&head);
  bpf_spin_unlock(&lock);
  bpf_obj_drop(container_of(n, struct foo, node));
  bpf_obj_drop(f);
  return 0;
}
