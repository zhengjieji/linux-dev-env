#include "vmlinux.h"
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "GPL";

extern struct task_struct *bpf_task_from_pid(int pid) __ksym;
extern void bpf_task_release(struct task_struct *p) __ksym;

/* Use our custom kfunc instead of the original */
extern int custom_send_signal_task(struct task_struct *task, int sig, enum pid_type type, u64 value) __ksym;

#define SIGUSR1 10

struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__uint(max_entries, 1);
	__type(key, u32);
	__type(value, u32);
} target_pid_map SEC(".maps");

SEC("tp/syscalls/sys_enter_getcwd")
int test_custom_send_signal(void *ctx)
{
	struct task_struct *task;
	u32 key = 0;
	u32 *target_pid_ptr;
	int current_pid, target_pid, ret;

	current_pid = bpf_get_current_pid_tgid() >> 32;
	
	target_pid_ptr = bpf_map_lookup_elem(&target_pid_map, &key);
	if (!target_pid_ptr || *target_pid_ptr == 0) {
		bpf_printk("No target PID set in map");
		return 0;
	}
	
	target_pid = *target_pid_ptr;
	
	// Don't send signal to ourselves
	if (current_pid == target_pid) {
		return 0;
	}
	
	task = bpf_task_from_pid(target_pid);
	if (!task) {
		bpf_printk("bpf_task_from_pid failed for pid %d", target_pid);
		return 0;
	}

	/* Using custom_send_signal_task instead of bpf_send_signal_task */
	ret = custom_send_signal_task(task, SIGUSR1, PIDTYPE_PID, 0);
	if (ret < 0) {
		bpf_printk("custom_send_signal_task failed: %d", ret);
	} else {
		bpf_printk("custom_send_signal_task success: sent SIGUSR1 from %d to %d", current_pid, target_pid);
	}

	bpf_task_release(task);
	return 0;
}