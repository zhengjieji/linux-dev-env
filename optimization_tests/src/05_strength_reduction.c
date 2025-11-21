/*
 * Test 5: Strength Reduction
 *
 * Description: Tests compiler's ability to replace expensive operations
 * with cheaper equivalent ones.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Replace multiplication by power of 2 with left shift
 * - Replace division by power of 2 with right shift
 * - Replace expensive operations with cheaper alternatives
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 100000000

// Function with operations that can be strength-reduced
int compute_with_expensive_ops(int x) {
    int result = 0;

    // Multiplication by powers of 2 -> should become shifts
    result += x * 2;      // x << 1
    result += x * 4;      // x << 2
    result += x * 8;      // x << 3
    result += x * 16;     // x << 4

    // Division by powers of 2 -> should become shifts
    result += x / 2;      // x >> 1
    result += x / 4;      // x >> 2

    // Modulo by power of 2 -> should become AND
    result += x % 8;      // x & 7

    // Multiplication in loop can be replaced with addition
    int sum = 0;
    for (int i = 0; i < 10; i++) {
        sum += i * 3;     // Can be replaced with i += 3 each iteration
    }
    result += sum;

    return result;
}

// Function showing what the optimized code might look like
int compute_optimized(int x) {
    int result = 0;

    // Shifts instead of multiplication/division
    result += x << 1;
    result += x << 2;
    result += x << 3;
    result += x << 4;
    result += x >> 1;
    result += x >> 2;
    result += x & 7;

    // Loop with strength reduction
    int sum = 0;
    int i_times_3 = 0;
    for (int i = 0; i < 10; i++) {
        sum += i_times_3;
        i_times_3 += 3;
    }
    result += sum;

    return result;
}

long benchmark_strength_reduction() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        sum += compute_with_expensive_ops(i);
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_strength_reduction();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_strength_reduction();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Strength Reduction Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
