/*
 * Test 1: Constant Propagation
 *
 * Description: Tests compiler's ability to compute constant expressions at
 * compile time and propagate constants through the code.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Compute all constant expressions at compile time
 * - Replace variable reads with their constant values
 * - Eliminate unnecessary operations
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 100000000

// Function with constants that can be propagated
int compute_with_constants() {
    // These are constants, compiler should compute at compile time
    int a = 10;
    int b = 20;
    int c = 30;

    // Complex expression with constants
    int result = (a * b) + (c * 2) - (a + b);

    // More operations
    result = result * 2 + 15;
    result = result / 3;

    return result;
}

// Function that uses the result in a loop
long benchmark_const_propagation() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        sum += compute_with_constants();
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_const_propagation();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_const_propagation();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Constant Propagation Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
