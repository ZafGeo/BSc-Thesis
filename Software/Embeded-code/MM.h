#ifndef MM_H
#define MM_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define BM 64
#define BN 64
#define BK 64

#define A_IDX(i, k, K) ((i) * (K) + (k))
#define B_IDX(k, j, N) ((k) * (N) + (j))
#define C_IDX(i, j, N) ((i) * (N) + (j))


#define MIN_VAL -128
#define MAX_VAL 127


int rand_int();


void fill_matrix(int8_t* , int , int );


int compare_matrices(int32_t* , int32_t* , int , int );


// Function to multiply matrices
void multiply_matrices(int8_t *, int8_t *, int32_t *, int , int , int );


void matmul_blocked(const int8_t *, const int8_t *, int32_t *, int , int , int );


void print_int32_matrix(int32_t* , int , int );


void print_int8_matrix(int8_t* , int , int );

#endif