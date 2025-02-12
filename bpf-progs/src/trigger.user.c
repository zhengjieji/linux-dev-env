// trigger.user.c
#include <stdio.h>
#include <unistd.h>
#include <limits.h>
#include <stdlib.h>

int main(void)
{
    char buf[PATH_MAX];
    printf("Trigger process started: repeatedly calling getcwd()\n");
    while (1) {
        if (getcwd(buf, sizeof(buf)) == NULL) {
            perror("getcwd");
            exit(1);
        }
        sleep(1);
    }
    return 0;
}

