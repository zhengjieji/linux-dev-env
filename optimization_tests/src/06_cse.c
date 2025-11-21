/*
 * Test 6: Common Subexpression Elimination (CSE)
 *
 * Description: Tests compiler's ability to identify and eliminate redundant
 * calculations by reusing previously computed values.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Identify repeated subexpressions
 * - Calculate them only once and reuse the result
 * - Store intermediate results in registers when possible
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 50000000

// Function with common subexpressions
int compute_with_redundancy(int x, int y) {
    int a, b, c, d;

    // Common subexpression: (x + y) appears multiple times
    a = (x + y) * 2;
    b = (x + y) * 3;
    c = (x + y) + 10;

    // Common subexpression: (x * 2 + y * 3)
    a += (x * 2 + y * 3) * 4;
    b += (x * 2 + y * 3) * 5;

    // Common subexpression: (a + b)
    c = (a + b) / 2;
    d = (a + b) / 3;

    return a + b + c + d;
}

// Optimized version showing what CSE should produce
int compute_optimized(int x, int y) {
    // Compiler should calculate common subexpressions once
    int temp1 = x + y;          // CSE: x + y
    int temp2 = x * 2 + y * 3;  // CSE: x * 2 + y * 3

    int a = temp1 * 2;
    int b = temp1 * 3;
    int c = temp1 + 10;

    a += temp2 * 4;
    b += temp2 * 5;

    int temp3 = a + b;          // CSE: a + b
    c = temp3 / 2;
    int d = temp3 / 3;

    return a + b + c + d;
}

// More complex example with nested expressions
int complex_computation(int x, int y, int z) {
    int result = 0;

    // Multiple uses of the same complex expression
    result += (x * x + y * y) * 2;
    result += (x * x + y * y) / 3;
    result += (x * x + y * y) - z;

    // Another common pattern
    result += (x + y + z) * (x + y + z);  // Should square once

    return result;
}

long benchmark_cse() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        sum += compute_with_redundancy(i, i + 1);
        sum += complex_computation(i, i + 1, i + 2);
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_cse();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_cse();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Common Subexpression Elimination Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
