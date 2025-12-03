// SPDX-License-Identifier: GPL-2.0
/* Trigger for tp/syscalls/sys_enter_getcwd - calls getcwd syscall */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

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

	printf("Triggering tp/syscalls/sys_enter_getcwd (%d getcwd calls)\n", iterations);

	char buf[256];

	for (int i = 0; i < iterations; i++) {
		/* Call getcwd to trigger the tracepoint */
		if (getcwd(buf, sizeof(buf)) == NULL) {
			perror("getcwd");
			continue;
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
