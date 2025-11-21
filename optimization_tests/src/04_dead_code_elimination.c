/*
 * Test 4: Dead Code Elimination (DCE)
 *
 * Description: Tests compiler's ability to remove code that does not affect
 * the program's output.
 *
 * Expected optimization: With -O2/-O3, the compiler should:
 * - Remove unused variables and computations
 * - Eliminate code whose results are never used
 * - Reduce binary size and execution time
 */

#include <stdio.h>
#include <time.h>

#define ITERATIONS 100000000

// Function with dead code that should be eliminated
int compute_with_dead_code(int x) {
    int result = x;

    // Dead code: these variables are never used
    int unused1 = 42;
    int unused2 = unused1 * 2;
    int unused3 = unused2 + 100;

    // Used computation
    result = result * 2;

    // Dead code: this computation's result is overwritten
    result = result + 50;
    result = result * 3;  // Previous result is not used

    // Dead code: computation with no side effects
    int temp = x * x;
    temp = temp + 10;
    // temp is never used

    // Final result
    result = x + 10;

    return result;
}

// Optimized version (what compiler should generate)
int compute_optimized(int x) {
    // Compiler should reduce to just this
    return x + 10;
}

long benchmark_dead_code_elimination() {
    long sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        sum += compute_with_dead_code(i);
    }

    return sum;
}

int main() {
    struct timespec start, end;

    // Warmup
    volatile long result = benchmark_dead_code_elimination();

    // Actual benchmark
    clock_gettime(CLOCK_MONOTONIC, &start);
    result = benchmark_dead_code_elimination();
    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - start.tv_sec) +
                     (end.tv_nsec - start.tv_nsec) / 1e9;

    printf("Dead Code Elimination Test\n");
    printf("Result: %ld\n", result);
    printf("Time: %.6f seconds\n", elapsed);
    printf("Iterations: %d\n", ITERATIONS);

    return 0;
}
