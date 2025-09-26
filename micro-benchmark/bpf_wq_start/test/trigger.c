// SPDX-License-Identifier: GPL-2.0
/* Trigger program for bpf_wq_start test */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char **argv)
{
	int iterations = 10;
	int sock;
	struct sockaddr_in addr;
	const char *data = "test packet";

	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}

	printf("Starting bpf_wq_start trigger test\n");
	printf("Iterations: %d\n\n", iterations);

	/* Create UDP socket */
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		perror("socket");
		return 1;
	}

	/* Setup localhost address */
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(12345);
	inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

	for (int i = 0; i < iterations; i++) {
		/* Send packet to localhost to trigger TC ingress */
		sendto(sock, data, strlen(data), 0,
		       (struct sockaddr *)&addr, sizeof(addr));

		printf("Iteration %d/%d completed\n", i + 1, iterations);

		/* Small delay between iterations */
		usleep(10000); /* 10ms */
	}

	close(sock);

	printf("\nTest completed: triggered %d TC events\n", iterations);

	return 0;
}