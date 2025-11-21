// SPDX-License-Identifier: GPL-2.0
/* Simple trigger for custom kfunc test - just makes syscalls */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	int iterations = 5;

	if (argc > 1) {
		iterations = atoi(argv[1]);
	}

	printf("Triggering custom kfunc tests (%d getcwd calls)\n", iterations);

	char buf[256];

	for (int i = 0; i < iterations; i++) {
		/* Call getcwd to trigger the BPF program */
		getcwd(buf, 256);
		printf("Trigger %d/%d\n", i + 1, iterations);
		usleep(10000); /* 10ms delay */
	}

	printf("\nDone! Check trace output.\n");

	return 0;
}
