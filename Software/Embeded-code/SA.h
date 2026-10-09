#ifndef SA_H
#define SA_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "dma_accel.h"
#include "uart_accel.h"
#include "MM.h"

#define MAX(i, j, k) (((i) > (j)) ? (((i) > (k)) ? (i) : (k)) : (((j) > (k)) ? (j) : (k)))


#define SYSTOLIC_ARRAY_DIMENSION 4
#define SYSTOLIC_ARRAY_ADDRESS_SIZE 13


typedef struct SubMatrixData
{
    int rows;
    int columns;
} SubMatrixData;

typedef struct MatrixData
{
    int rows;
    int columns;

    int no_tiles;
    int mod_tile_dim_size;

    SubMatrixData sub_matrix;

    void* matrix;
} MatrixData;

typedef struct TileData
{
    int max_tile_dim_size;
    int no_sub_tiles;
    int mod_sub_tile_dim_size;
    MatrixData A;
    MatrixData B;
    void* C;
} TileData;


s8* resize_input(s8* , int* , int* , int , int );


s32* resize_output(s32* , s32* , int* , int* , int , int );


// Transpose matrices
void transpose_matrix(s8* , s8* , int , int );


void first_element(s32 , void* , s32 );


int Systolic_Array(XAxiDma* , void* , void* , int , int , char );


int Accelerate(XAxiDma* , TileData* , s8* , s8* , s32*, char );


void fill_C(TileData* , s32* , int , int );


int Accelerate_tile(XAxiDma* , TileData* , int , int , int , char );


int recursive_Accelerate(XAxiDma* , TileData* , int , int , int );


int Accelerate_Multiplication(XAxiDma* , s8* , s8* , s32* , int , int , int );


#endif
