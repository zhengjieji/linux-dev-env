// SPDX-License-Identifier: GPL-2.0
/* Simple trigger for XDP csum test - sends packets to trigger XDP program */

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

	if (argc > 1) {
		iterations = atoi(argv[1]);
	}

	printf("Triggering XDP csum test (%d packets to loopback)\n", iterations);

	/* Create UDP socket */
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		perror("socket");
		return 1;
	}

	/* Setup loopback address */
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(9999);
	addr.sin_addr.s_addr = inet_addr("127.0.0.1");

	/* Send packets to trigger XDP program */
	for (int i = 0; i < iterations; i++) {
		char msg[64];
		snprintf(msg, sizeof(msg), "XDP test packet %d", i);

		if (sendto(sock, msg, strlen(msg), 0,
		           (struct sockaddr *)&addr, sizeof(addr)) < 0) {
			perror("sendto");
		} else {
			printf("Sent packet %d/%d\n", i + 1, iterations);
		}

		usleep(50000); /* 50ms delay */
	}

	close(sock);
	printf("\nDone! Check trace output: sudo cat /sys/kernel/debug/tracing/trace_pipe\n");

	return 0;
}
