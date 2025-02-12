#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A minimal kernel module for testing");
MODULE_VERSION("0.1");

static int __init min_mod_init(void)
{
    printk(KERN_INFO "Minimal Module loaded\n");
    return 0;
}

static void __exit min_mod_exit(void)
{
    printk(KERN_INFO "Minimal Module unloaded\n");
}

module_init(min_mod_init);
module_exit(min_mod_exit);

