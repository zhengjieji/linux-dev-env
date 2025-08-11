#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <errno.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>

static volatile int signal_count = 0;

void sigusr1_handler(int sig) {
    signal_count++;
    printf("Target process received SIGUSR1 (count: %d)\n", signal_count);
}

void dummy_target_process() {
    signal(SIGUSR1, sigusr1_handler);
    printf("Target process PID: %d (waiting for signals)\n", getpid());
    
    // Just wait for signals
    while (1) {
        sleep(1);
    }
}

int set_target_pid_in_map(int target_pid) {
    int map_fd, err;
    __u32 key = 0;
    __u32 value = target_pid;
    
    // Find the BPF map by name - this is a simplified approach
    // In practice, you'd get this from the loaded BPF object
    map_fd = bpf_obj_get("/sys/fs/bpf/target_pid_map");
    if (map_fd < 0) {
        printf("Warning: Could not find target_pid_map, using bpf_map_get_next_key approach\n");
        return -1;
    }
    
    err = bpf_map_update_elem(map_fd, &key, &value, BPF_ANY);
    if (err < 0) {
        printf("Failed to update map: %s\n", strerror(errno));
        close(map_fd);
        return -1;
    }
    
    close(map_fd);
    printf("Set target PID %d in BPF map\n", target_pid);
    return 0;
}

int main(int argc, char *argv[]) {
    int iterations = 10;
    char buf[256];
    pid_t child_pid;
    
    if (argc > 1) {
        iterations = atoi(argv[1]);
        if (iterations <= 0) iterations = 10;
    }
    
    printf("Trigger program PID: %d\n", getpid());
    
    // Fork a child process to be the signal target
    child_pid = fork();
    if (child_pid == 0) {
        // Child process - this will receive signals
        dummy_target_process();
        return 0;
    } else if (child_pid < 0) {
        perror("fork failed");
        return 1;
    }
    
    // Parent process
    printf("Created target process PID: %d\n", child_pid);
    sleep(1); // Give child time to set up signal handler
    
    // Try to set the target PID in the BPF map (may fail if map not pinned)
    set_target_pid_in_map(child_pid);
    
    printf("Calling getcwd() %d times to trigger bpf_send_signal_task...\n", iterations);
    
    for (int i = 0; i < iterations; i++) {
        getcwd(buf, sizeof(buf));
        usleep(500000); // 500ms delay
        printf("getcwd() call %d/%d\n", i+1, iterations);
    }
    
    // Wait a bit to see if child received signals
    sleep(2);
    
    // Kill child process
    kill(child_pid, SIGTERM);
    waitpid(child_pid, NULL, 0);
    
    printf("Completed %d getcwd() calls\n", iterations);
    return 0;
}