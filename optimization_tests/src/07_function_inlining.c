/*
 * Test 7: Function Inlining
 *
 * Description: Tests compiler's ability to inline small functions, eliminating
 * function call overhead.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Inline small frequently-called functions
 * - Eliminate call/return overhead
 * - Enable further optimizations on inlined code
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 100000000

// Small functions that should be inlined
static inline int add(int a, int b) {
    return a + b;
}

static inline int multiply(int a, int b) {
    return a * b;
}

static inline int square(int x) {
    return x * x;
}

// Small function with multiple operations
static inline int calculate(int x) {
    return (x * 2) + 10;
}

// Function that calls many small functions
int compute_with_calls(int x) {
    int result = 0;

    // Multiple small function calls - should all be inlined
    result = add(result, x);
    result = multiply(result, 2);
    result = add(result, square(x));
    result = add(result, calculate(x));

    return result;
}

// Larger function that may or may not be inlined
int larger_function(int x, int y) {
    int result = 0;

    for (int i = 0; i < 5; i++) {
        result += x * i;
        result -= y / (i + 1);
    }

    return result;
}

// Function that calls larger function
int compute_with_larger_call(int x) {
    return larger_function(x, x + 1);
}

long benchmark_inlining() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        sum += compute_with_calls(i);
    }

    return sum;
}

// Benchmark with larger function calls
long benchmark_larger_calls() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS / 10; i++) {
        sum += compute_with_larger_call(i);
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_inlining();

    // Benchmark small function inlining
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_inlining();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed1 = (end.tv_sec - start.tv_sec) +
                      (end.tv_nsec - start.tv_nsec) / 1e9;

    // Benchmark larger function calls
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_larger_calls();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed2 = (end.tv_sec - start.tv_sec) +
                      (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Function Inlining Test\n");
    printf("Small functions time: %.6f seconds (%d iterations)\n",
           elapsed1, ITERATIONS);
    printf("Larger function time: %.6f seconds (%d iterations)\n",
           elapsed2, ITERATIONS / 10);
    printf("Result: %ld\n", result);

    return 0;
}
