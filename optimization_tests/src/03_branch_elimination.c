/*
 * Test 3: Branch Elimination (Dead Branch Elimination)
 *
 * Description: Tests compiler's ability to eliminate branches when conditions
 * are known at compile time.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Eliminate branches with compile-time known conditions
 * - Keep only the taken branch path
 * - Reduce branch misprediction overhead
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 100000000
#define COMPILE_TIME_FLAG 1  // Known at compile time

// Function with compile-time known branch
int compute_with_known_branch(int x) {
    int result = x;

    // This branch should be eliminated at compile time
    if (COMPILE_TIME_FLAG) {
        result = result * 2 + 10;
    } else {
        result = result * 3 + 20;
    }

    // Another compile-time known condition
    if (COMPILE_TIME_FLAG == 1) {
        result += 5;
    }

    return result;
}

// Function with runtime branch for comparison
int compute_with_runtime_branch(int x, int flag) {
    int result = x;

    // This branch cannot be eliminated (runtime condition)
    if (flag) {
        result = result * 2 + 10;
    } else {
        result = result * 3 + 20;
    }

    if (flag == 1) {
        result += 5;
    }

    return result;
}

long benchmark_branch_elimination() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        // Known branch - should be optimized
        sum += compute_with_known_branch(i);
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_branch_elimination();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_branch_elimination();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Branch Elimination Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
