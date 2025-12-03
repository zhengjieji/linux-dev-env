// SPDX-License-Identifier: GPL-2.0
/* Trigger for tp_btf/task_newtask - forks child processes to trigger the tracepoint */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
	int iterations = 1;

	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}

	printf("Triggering tp_btf/task_newtask (%d fork calls)\n", iterations);

	for (int i = 0; i < iterations; i++) {
		pid_t pid = fork();
		if (pid < 0) {
			perror("fork");
			continue;
		} else if (pid == 0) {
			/* Child process - exit immediately */
			_exit(0);
		} else {
			/* Parent - wait for child */
			waitpid(pid, NULL, 0);
		}

		if ((i + 1) % 100 == 0 || i == 0) {
			printf("Trigger %d/%d\n", i + 1, iterations);
		}

		usleep(1000); /* 1ms delay */
	}

	printf("\nDone! Triggered %d times.\n", iterations);
	printf("Check outputs for trace and dmesg logs.\n");

	return 0;
}
