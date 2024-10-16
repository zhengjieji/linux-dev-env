#include <unistd.h>
#include <linux/unistd.h>

int main(void)
{
	// triggers the tracepoint for syscalls/sys_hello
        return syscall(451);
}
