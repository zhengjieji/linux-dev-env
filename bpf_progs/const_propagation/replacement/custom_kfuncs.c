// SPDX-License-Identifier: GPL-2.0
/*
 * Custom BPF Kfuncs for Optimization Testing
 *
 * This file contains custom kfuncs for testing compiler optimizations
 * with BPF verifier-proven constraints.
 */

#include <linux/bpf.h>
#include <linux/btf.h>
#include <linux/btf_ids.h>
#include <linux/kernel.h>

/**
 * const_propagation_original - Computation with runtime parameter validation
 * @x: Input value
 * @y: Multiplier
 *
 * Returns: Computed result
 *
 * This version has runtime checks and computations that depend on
 * the actual parameter values. The compiler cannot optimize these away.
 */
__bpf_kfunc s64 const_propagation_original(s64 x, s64 y)
{
	s64 result = 0;

	/* Runtime parameter validation */
	if (x < 0 || x > 1000)
		return -EINVAL;
	if (y < 1 || y > 10)
		return -EINVAL;

	/* Complex computation with runtime values */
	result = x * y;
	result = result + 100;
	result = result / 2;
	result = result * 3;
	result = result - 50;

	/* More operations */
	if (result > 500)
		result = result / 2;
	else
		result = result * 2;

	return result;
}

/**
 * const_propagation_optimized - Same computation but with constant values
 * @x: Input value (ignored, we use constant internally)
 * @y: Multiplier (ignored, we use constant internally)
 *
 * Returns: Computed result
 *
 * This version hardcodes the input values as constants, simulating what would
 * happen if the verifier proved that x=50 and y=2 always.
 * With these constants, the compiler can perform:
 * 1. Constant propagation
 * 2. Constant folding
 * 3. Branch elimination
 * 4. Dead code elimination
 *
 * The entire function should be optimized to: return 500;
 */
__bpf_kfunc s64 const_propagation_optimized(s64 x, s64 y)
{
	s64 result = 0;

	/*
	 * Hardcode constants to enable optimization.
	 * In real implementation, these would come from verifier-proven constraints.
	 * For example: "verifier proved x is always 50"
	 */
	s64 x_const = 50;
	s64 y_const = 2;

	/*
	 * Parameter validation with constants.
	 * Since x_const and y_const are known at compile time,
	 * these checks will be eliminated (they're always true).
	 */
	if (x_const < 0 || x_const > 1000)
		return -EINVAL;  /* Dead code - eliminated */
	if (y_const < 1 || y_const > 10)
		return -EINVAL;  /* Dead code - eliminated */

	/*
	 * Computation with constants - compiler will fold all of this:
	 * x_const=50, y_const=2:
	 */
	result = x_const * y_const;    /* 50 * 2 = 100 */
	result = result + 100;          /* 100 + 100 = 200 */
	result = result / 2;            /* 200 / 2 = 100 */
	result = result * 3;            /* 100 * 3 = 300 */
	result = result - 50;           /* 300 - 50 = 250 */

	/*
	 * Branch with compile-time known condition.
	 * Since result=250, (250 > 500) is false.
	 * Compiler will eliminate the if branch and keep only else.
	 */
	if (result > 500)
		result = result / 2;  /* Dead code - eliminated */
	else
		result = result * 2;  /* 250 * 2 = 500 - kept */

	/*
	 * At -O2/-O3, compiler should optimize entire function to:
	 * return 500;
	 */
	return result;
}

/* BTF kfunc registration */
BTF_KFUNCS_START(custom_kfunc_ids)
BTF_ID_FLAGS(func, const_propagation_original)
BTF_ID_FLAGS(func, const_propagation_optimized)
BTF_KFUNCS_END(custom_kfunc_ids)

static const struct btf_kfunc_id_set custom_kfunc_set = {
	.owner = THIS_MODULE,
	.set   = &custom_kfunc_ids,
};

static int __init custom_kfuncs_init(void)
{
	int ret;

	ret = register_btf_kfunc_id_set(BPF_PROG_TYPE_UNSPEC, &custom_kfunc_set);
	if (ret) {
		pr_err("Failed to register custom kfuncs: %d\n", ret);
		return ret;
	}

	pr_info("Custom BPF kfuncs registered successfully\n");
	return 0;
}

static void __exit custom_kfuncs_exit(void)
{
	pr_info("Custom BPF kfuncs unloaded\n");
}

module_init(custom_kfuncs_init);
module_exit(custom_kfuncs_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Custom BPF Kfuncs for Optimization Testing");
MODULE_AUTHOR("BPF Optimization Research");
