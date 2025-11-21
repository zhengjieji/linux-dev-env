/*
 * Test 2: Loop Unrolling
 *
 * Description: Tests compiler's ability to unroll loops with known bounds,
 * eliminating loop control overhead.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Unroll small loops completely
 * - Partially unroll larger loops
 * - Eliminate loop counter increments and comparisons
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 10000000
#define ARRAY_SIZE 8

// Small loop that should be completely unrolled
int sum_small_array(int arr[ARRAY_SIZE]) {
    int sum = 0;

    // This loop should be completely unrolled at -O2/-O3
    for (int i = 0; i < ARRAY_SIZE; i++) {
        sum += arr[i];
    }

    return sum;
}

// Medium loop that might be partially unrolled
int process_array(int arr[ARRAY_SIZE]) {
    int result = 0;

    for (int i = 0; i < ARRAY_SIZE; i++) {
        result += arr[i] * 2;
        result -= arr[i] / 2;
    }

    return result;
}

long benchmark_loop_unrolling() {
    int arr[ARRAY_SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    long total = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        total += sum_small_array(arr);
        total += process_array(arr);
    }

    return total;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_loop_unrolling();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_loop_unrolling();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Loop Unrolling Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
