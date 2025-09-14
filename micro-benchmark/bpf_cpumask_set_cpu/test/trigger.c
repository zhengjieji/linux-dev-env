// SPDX-License-Identifier: GPL-2.0
/* Trigger program for bpf_cpumask_set_cpu test */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
	int iterations = 10;
	pid_t pid;
	int i;
	
	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}
	
	printf("Starting bpf_cpumask_set_cpu trigger test\n");
	printf("Iterations: %d\n\n", iterations);
	
	for (i = 0; i < iterations; i++) {
		/* Fork to trigger task_newtask tracepoint */
		pid = fork();
		if (pid == 0) {
			/* Child process - just exit */
			exit(0);
		} else if (pid < 0) {
			perror("fork");
			return 1;
		}
		
		/* Parent - wait for child */
		wait(NULL);
		
		printf("Iteration %d/%d completed\n", i + 1, iterations);
		
		/* Small delay between iterations */
		usleep(10000); /* 10ms */
	}
	
	printf("\nTest completed: triggered %d task_newtask events\n", iterations);
	
	return 0;
}