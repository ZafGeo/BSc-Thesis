#include "SA.h"


// Resize the input sub-matrix to fit the BRAM spacing requirements dictated by the accelerator
s8* resize_input(s8* matrix, int* m, int* n, int new_size, int log_q)
{

    int q = pow(2, log_q);
	int old_m = *m;
	int old_n = *n;

    // Make sub-matrix square and its dimensions a multiple of the Systolic Array's dimensions
    *m = ((new_size + q-1) / q) * q;
    *n = *m;

    // Initialize resized sub-matrix, zero-padded
    s8* resized = (s8*) calloc((*m) * (*n), sizeof(s8));
    if (resized == NULL) {
    	printf("ERROR: Failed to allocate space for resized input matrix!\r\n");
    	return NULL;
    }

    // Fill resized sub-matrix
    for (int i = 0; i < old_m; i++)
        for (int j = 0; j < old_n; j++)
            resized[i * (*n) + j] = matrix[i * old_n + j];

    free(matrix);

    return resized;

}


// Resize the zero-paddded output to the intended one
s32* resize_output(s32* result, s32* padded, int* padded_m, int* padded_n, int original_m, int original_n)
{

    // Fill original sub-matrix with the values of the padded one, without the zero padding
	for (int i = 0; i < original_m; i++)
        for (int j = 0; j < original_n; j++)
            result[i * original_n + j] = padded[i * (*padded_n) + j];

    // Change resized matrix's dimensions back to the original ones
    *padded_m = original_m;
    *padded_n = original_n;

    return result;

}


// Transpose matrices
void transpose_matrix(s8* matrix, s8* t_matrix, int rows, int cols)
{

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; j++) {
            t_matrix[j * rows + i] = matrix[i * cols + j];
        }
    }

}


// Prepare the setup packet for the input transfer to the accelerator
void first_element(s32 keep_flag, void* element, s32 dimension)
{
	s32* int_element = element;

    // Set the keep flag
	*int_element = keep_flag;
	*int_element = *int_element << 31;

    // Set the common dimension variable "k" of the sub-matrices to be to the accelerator
	*int_element |= dimension;
}


// Begin the transfers from and to the accelerator
int Systolic_Array(XAxiDma* dma_inst, void* input_buffer, void* output_buffer, int no_input_bytes, int no_output_bytes, char keep_flag)
{
    
    // If the keep flag is high, do not expect to receive results from the accelerator
    if (!keep_flag) {

        // Begin transfers from and to the accelerator concurrently
        if (dma_receive(dma_inst, output_buffer, no_output_bytes) || 
        dma_transfer(dma_inst, input_buffer, no_input_bytes))
            return 1;

        // Wait for DMA to finish transferring and receiving
        dma_wait(dma_inst);

    }

    else {
        
        // Begin the transfer to the accelerator
    	if (dma_transfer(dma_inst, input_buffer, no_input_bytes))
            return 1;

        // Wait for DMA to finish transferring
    	dma_wait_transfer(dma_inst);
        
    }

    return 0;

}


// Pad the input and output sub-matrices if necessary, prepare the setup packet
int Accelerate(XAxiDma* dma_inst, TileData* tile_data, s8* A, s8* B, s32* C, char keep_flag)
{

    int m = tile_data->A.sub_matrix.columns;
    int n = tile_data->B.sub_matrix.columns;
    int k = tile_data->A.sub_matrix.rows;

    int og_m = m, og_n = n;

    // Initialize setup packet
    s8* setup_packet = malloc(sizeof(s8) * 4);
    if (!setup_packet) {
        printf("ERROR: Memory allocation failed for setup packet.\r\n");
        return 1;
    }

    // Determine if the input sub-matrices need zero-padding
    if (m != tile_data->max_tile_dim_size || k!= tile_data->max_tile_dim_size || n != tile_data->max_tile_dim_size)
    {
        
        // Zero-pad the input matrices
        A = resize_input(A, &k, &m, MAX(m, k, n), SYSTOLIC_ARRAY_DIMENSION);
        if (!A) {
            free(setup_packet);
            return 1;
        }
        
        B = resize_input(B, &k, &n, MAX(m, k, n), SYSTOLIC_ARRAY_DIMENSION);
        if (!B) {
            free(setup_packet);
            free(A);
            return 1;
        }

    }
    
    // Calculate input matrices' size (common)
    int matrix_size = k * m;

    // Initialize the input buffer, which will store the data sent to the accelerator
    s8* input_buffer = (s8*) malloc((2*matrix_size+4) * sizeof(s8));
    if (!input_buffer) {
        free(setup_packet);
        free(A);
        free(B);
    	printf("ERROR: Memory allocation failed for input_buffer.\r\n");
        return 1;
    }
        
    // Prepare the input buffer with the setup packet and the input sub-matrices data
    first_element(keep_flag, setup_packet, (s32) k);
    memcpy(input_buffer, setup_packet, 4*sizeof(s8));
    memcpy(input_buffer+4, A, matrix_size*sizeof(s8));
    memcpy(input_buffer+4+matrix_size, B, matrix_size*sizeof(s8));

    free(A);
    free(B);

    int exit_status = 0;

    // If the keep flag is high, do not expect to receive results from the accelerator
    if (keep_flag)
    	exit_status = Systolic_Array(dma_inst, input_buffer, C, 2*matrix_size+4, m*n*4, 1);   // Set off data transfer

    else
    {
        
        // Initilaize new space to store the zero-padded result coming from the accelerator
        s32* C_padded = (s32*) malloc(m * n * sizeof(s32));
        if (!C_padded) {
            free(setup_packet);
            free(A);
            free(B);
            free(input_buffer);
            printf("ERROR: Memory allocation failed for C_padded.\r\n");
            return 1;
        }
        
        // Set off input and output transfer
        if (Systolic_Array(dma_inst, input_buffer, C_padded, 2*matrix_size+4, m*n*4, 0)) {
            free(setup_packet);
            free(A);
            free(B);
            free(input_buffer);
            free(C_padded);
            return 1;
        }

        // Resize the output received from the accelerator to exclude the zero-padding
        resize_output(C, C_padded, &m, &n, og_m, og_n);
        
        free(C_padded);

    }
    
    free(input_buffer);
    free(setup_packet);

    return exit_status;

}


// Gradually fill the output matrix C with the results, tile by tile
void fill_C(TileData* tile_data, s32* sub_C, int tile_A, int tile_B)
{

	s32* C = (s32 *) tile_data->C;

    for (int i = 0; i < tile_data->A.sub_matrix.columns; i++)
        memcpy(C + tile_A * (tile_data->max_tile_dim_size * (tile_data->B.columns)) +
                    tile_B * (tile_data->max_tile_dim_size) + 
                    i * (tile_data->B.columns),
                sub_C + i*(tile_data->B.sub_matrix.columns),
                4*(tile_data->B.sub_matrix.columns));

}


// Calculate and prepare the input sub-matrices sent to the accelerator tile by tile
int Accelerate_tile(XAxiDma* dma_inst, TileData* tile_data, int running_tile_A, int running_tile_B, int running_sub_tile, char keep_flag)
{

    int rows_tile_A = tile_data->A.sub_matrix.rows;
    int cols_tile_A = tile_data->A.sub_matrix.columns;
    int rows_tile_B = tile_data->B.sub_matrix.rows;
    int cols_tile_B = tile_data->B.sub_matrix.columns;
    s8* A = (s8 *) tile_data->A.matrix;
    s8* B = (s8 *) tile_data->B.matrix;

    // Initialize the sub-matrices to be transferred to the accelerator
    s8* sub_A = (s8 *) malloc(rows_tile_A * cols_tile_A * sizeof(s8));
    if (!sub_A) {
        printf("ERROR: Memory allocation failed for sub_A.\r\n");
        return 1;
    }

    s8* sub_B = (s8 *) malloc(rows_tile_B * cols_tile_B * sizeof(s8));
    if (!sub_B) {
        printf("ERROR: Memory allocation failed for sub_B.\r\n");
        free(sub_A);
        return 1;
    }
    
    // Copy the corresponding values of the input matrices to the sub-matrices
    for (int i = 0; i < rows_tile_A; i++)
    memcpy(sub_A + i*cols_tile_A,
        A + (running_tile_A * tile_data->max_tile_dim_size) +
                    (i * tile_data->A.columns) +
                    (running_sub_tile * tile_data->max_tile_dim_size * tile_data->A.columns),
                    cols_tile_A);

    for (int i = 0; i < rows_tile_B; i++)
        memcpy(sub_B + i*cols_tile_B,
                B + (running_tile_B * tile_data->max_tile_dim_size) +
                (i * tile_data->B.columns) +
                (running_sub_tile * tile_data->max_tile_dim_size * tile_data->B.columns),
                cols_tile_B);

    // If the keep flag is high, do not expect to receive results from the accelerator
    if (keep_flag)
        return Accelerate(dma_inst, tile_data, sub_A, sub_B, NULL, 1); // Send the input sub-matrices for transfer
        
    else
    {
            
        // Initialize the output sub-matrix to store the results of the accelerator
        s32* sub_C = (s32 *) malloc(cols_tile_A * cols_tile_B * sizeof(s32));
        if (!sub_C) {
            free(sub_A);
            free(sub_B);
            printf("ERROR: Memory allocation failed for sub_C.\r\n");
            return 1;
        }
        
        // Send the input sub-matrices for transfer and receive output sub-matrix
        if (Accelerate(dma_inst, tile_data, sub_A, sub_B, sub_C, 0)) {
            free(sub_A);
            free(sub_B);
            free(sub_C);
            return 1;
        }

        // Store the output sub-matrix results to the original output matrix C, based on the current tile
        fill_C(tile_data, sub_C, running_tile_A, running_tile_B);

        free(sub_C);

    }

    // No need to free sub_A or sub_B, as they are freed in Accelerate.

    return 0;

}


// Calculate the dimensions of the input sub-matrices to be sent to the accelerator recursively
int recursive_Accelerate(XAxiDma* dma_inst, TileData* tile_data, int running_tile_A, int running_tile_B, int running_sub_tile)
{

    // Recursion logic
    if (running_sub_tile == 0)
    {
        if (running_tile_B == 0)
        {
            if (running_tile_A != 0)
                if (recursive_Accelerate(dma_inst, tile_data, 
                    running_tile_A - 1, 
                    tile_data->B.no_tiles, 
                    tile_data->no_sub_tiles))
                        return 1;
        }
        else
            if (recursive_Accelerate(dma_inst, tile_data, 
                running_tile_A, 
                running_tile_B - 1, 
                tile_data->no_sub_tiles))
                    return 1;
    }
    else
        if (recursive_Accelerate(dma_inst, tile_data, 
            running_tile_A, 
            running_tile_B, 
            running_sub_tile - 1))
                return 1;


    // Values assignment logic
    char keep_flag;

    if (running_sub_tile == tile_data->no_sub_tiles) {
        tile_data->A.sub_matrix.rows = tile_data->mod_sub_tile_dim_size;
        tile_data->B.sub_matrix.rows = tile_data->mod_sub_tile_dim_size;
        keep_flag = 0;
    }
    else {
        tile_data->A.sub_matrix.rows = tile_data->max_tile_dim_size;
        tile_data->B.sub_matrix.rows = tile_data->max_tile_dim_size;
        keep_flag = 1;
    }


    if (running_tile_B == tile_data->B.no_tiles)
        tile_data->B.sub_matrix.columns = tile_data->B.mod_tile_dim_size;
    else
        tile_data->B.sub_matrix.columns = tile_data->max_tile_dim_size;


    if (running_tile_A == tile_data->A.no_tiles)
        tile_data->A.sub_matrix.columns = tile_data->A.mod_tile_dim_size;
    else
        tile_data->A.sub_matrix.columns = tile_data->max_tile_dim_size;


    // Send the input-matrices
    return Accelerate_tile(dma_inst, tile_data, running_tile_A, running_tile_B, running_sub_tile, keep_flag);

}


// Calculates and initializes all the information needed to split the input matrices into tiles 
    // to transfer to the accelerator
int Accelerate_Multiplication(XAxiDma* dma_inst, s8* A, s8* B, s32* C, int m, int k, int n)
{

    int first_d_tiles_A, first_d_tiles_B, second_d_tiles, BRAM_dimension_per_matrix;
    int mod_first_d_tiles_A, mod_first_d_tiles_B, mod_second_d_tiles;

    // Calculate the maximum dimension size per input matrix to fit the BRAM
        // and satisfy the accelerator spacing requirements
    BRAM_dimension_per_matrix =  pow(2, (SYSTOLIC_ARRAY_DIMENSION + SYSTOLIC_ARRAY_ADDRESS_SIZE - 1) / 2);

    // Initialize the transposed matrix A
    s8* A_t = (s8 *) malloc(m * k * sizeof(s8));
    if (!A_t) {
    	xil_printf("ERROR: Failed to allocate space for A_t.\r\n");
    	return 1;
    }

    transpose_matrix(A, A_t, m, k);

    // Calculate the number of tiles for each dimension of the matrices
    first_d_tiles_A = m / BRAM_dimension_per_matrix;
    first_d_tiles_B = n / BRAM_dimension_per_matrix;
    second_d_tiles = k / BRAM_dimension_per_matrix;

    // Calculate the size of the remaining tiles
    mod_first_d_tiles_A = m % BRAM_dimension_per_matrix;
    mod_first_d_tiles_B = n % BRAM_dimension_per_matrix;
    mod_second_d_tiles = k % BRAM_dimension_per_matrix;

    // When m, k, or n are multiples of BRAM_dimension_per_matrix
    if (!mod_first_d_tiles_A) {
        mod_first_d_tiles_A = BRAM_dimension_per_matrix;
        first_d_tiles_A -= 1;
    }

    if (!mod_first_d_tiles_B) {
        mod_first_d_tiles_B = BRAM_dimension_per_matrix;
        first_d_tiles_B -= 1;
    }

    if (!mod_second_d_tiles) {
        mod_second_d_tiles = BRAM_dimension_per_matrix;
        second_d_tiles -= 1;
    }

    // Prepare the structure used to store all the information about the matrices
    TileData* tile_data = (TileData *) malloc(sizeof(TileData));
    if (!tile_data) {
        free(A_t);
    	xil_printf("ERROR: Failed to allocate space for Tile Data.\r\n");
    	return 1;
    }
        tile_data->A.matrix = A_t;
        tile_data->A.rows = k;
        tile_data->A.columns = m;
        tile_data->A.no_tiles = first_d_tiles_A;
        tile_data->A.mod_tile_dim_size = mod_first_d_tiles_A;

        tile_data->B.matrix = B;
        tile_data->B.rows = k;
        tile_data->B.columns = n;
        tile_data->B.no_tiles = first_d_tiles_B;
        tile_data->B.mod_tile_dim_size = mod_first_d_tiles_B;

        tile_data->C = C;

        tile_data->max_tile_dim_size = BRAM_dimension_per_matrix;
        tile_data->mod_sub_tile_dim_size = mod_second_d_tiles;
        tile_data->no_sub_tiles = second_d_tiles;

    // Split the matrices into sub-matrices and begin transfer to the accelerator
    if (recursive_Accelerate(dma_inst, tile_data, first_d_tiles_A, first_d_tiles_B, second_d_tiles)) {
        free(A_t);
        free(tile_data);
        return 1;
    }

    free(A_t);
    free(tile_data);

    return 0;

}
