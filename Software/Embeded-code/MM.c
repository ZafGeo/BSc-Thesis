#include "MM.h"

// Random integer in [-128, 127]
int rand_int() {
    return (rand() % (MAX_VAL - MIN_VAL + 1)) + MIN_VAL;
}

// Fill matrix
void fill_matrix(int8_t* M, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        M[i] = rand_int();
    }
}

// Compare matrices
int compare_matrices(int32_t* C1, int32_t* C2, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        if (C1[i] != C2[i]) return 0;
    }
    return 1;
}

// Naive function to multiply matrices
void multiply_matrices(int8_t *A, int8_t *B, int32_t *result, int m, int k, int n) {
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            result[i * n + j] = 0;
            for (int l = 0; l < k; l++) {
                result[i * n + j] += A[i * k + l] * B[l * n + j];
            }
        }
    }
}


// Function to multiply matrices using cache blocking
void matmul_blocked(const int8_t *A, const int8_t *B, int32_t *C, int M, int N, int K)
{
    // Initialize C
    for (int i = 0; i < M * N; i++) {
        C[i] = 0;
    }

    for (int ii = 0; ii < M; ii += BM) {
        for (int kk = 0; kk < K; kk += BK) {
            for (int jj = 0; jj < N; jj += BN) {

                int i_max = (ii + BM < M) ? ii + BM : M;
                int k_max = (kk + BK < K) ? kk + BK : K;
                int j_max = (jj + BN < N) ? jj + BN : N;

                for (int i = ii; i < i_max; i++) {
                    for (int k = kk; k < k_max; k++) {

                        int32_t a_val = (int32_t)A[A_IDX(i, k, K)];

                        // Inner loop: contiguous access in B and C
                        for (int j = jj; j < j_max; j++) {
                            C[C_IDX(i, j, N)] +=
                                a_val * (int32_t)B[B_IDX(k, j, N)];
                        }
                    }
                }

            }
        }
    }
}


// Print an int32 matrix based on their dimensions
void print_int32_matrix(int32_t* matrix, int rows, int columns)
{

	for (int i = 0; i < rows; i++){
    	for (int j = 0; j < columns; j++)
       		printf("%ld, ", matrix[i*columns + j]);
    	printf("\r\n");
    }

}


// Print an int8 matrix based on their dimensions
void print_int8_matrix(int8_t* matrix, int rows, int columns)
{

	for (int i = 0; i < rows; i++){
    	for (int j = 0; j < columns; j++)
       		printf("%d, ", matrix[i*columns + j]);
    	printf("\r\n");
    }

}
