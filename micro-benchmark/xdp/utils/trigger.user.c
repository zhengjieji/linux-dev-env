// SPDX-License-Identifier: GPL-2.0
/* Trigger for TC - sends packets to loopback interface */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char **argv)
{
	int iterations = 1;
	int sock;
	struct sockaddr_in addr;

	if (argc > 1) {
		iterations = atoi(argv[1]);
		if (iterations <= 0) {
			fprintf(stderr, "Invalid iteration count: %s\n", argv[1]);
			return 1;
		}
	}

	printf("Triggering XDP BPF program (%d packets to loopback)\n", iterations);

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

	/* Send packets */
	for (int i = 0; i < iterations; i++) {
		char msg[64];
		snprintf(msg, sizeof(msg), "TC test packet %d", i);

		if (sendto(sock, msg, strlen(msg), 0,
		           (struct sockaddr *)&addr, sizeof(addr)) < 0) {
			perror("sendto");
		}

		if ((i + 1) % 100 == 0 || i == 0) {
			printf("Sent packet %d/%d\n", i + 1, iterations);
		}

		usleep(1000); /* 1ms delay */
	}

	close(sock);
	printf("\nDone! Triggered %d times.\n", iterations);
	printf("Check outputs for trace and dmesg logs.\n");

	return 0;
}
