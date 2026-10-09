#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <rows> <cols>\n", argv[0]);
        return 1;
    }

    int rows = atoi(argv[1]);
    int cols = atoi(argv[2]);

    if (rows <= 0 || cols <= 0) {
        fprintf(stderr, "Error: rows and cols must be positive integers.\n");
        return 1;
    }

    FILE *file = fopen("matrix.csv", "w");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    // Parallel region
    #pragma omp parallel
    {
        // Thread-local RNG seed
        unsigned int seed = (unsigned int) time(NULL) ^ omp_get_thread_num();

        // Allocate buffer for one row (large enough)
        char *row_buffer = malloc(cols * 6); // enough for "-128," etc.
        if (!row_buffer) {
            fprintf(stderr, "Memory allocation failed\n");
            exit(1);
        }

        #pragma omp for ordered schedule(static)
        for (int i = 0; i < rows; i++) {
            int offset = 0;

            for (int j = 0; j < cols; j++) {
                int value = (rand_r(&seed) % 256) - 128;
                offset += sprintf(row_buffer + offset, "%d", value);

                if (j < cols - 1) {
                    row_buffer[offset++] = ',';
                }
            }
            row_buffer[offset++] = '\n';
            row_buffer[offset] = '\0';

            // Ensure rows are written in order
            #pragma omp critical
            {
                fputs(row_buffer, file);
            }
        }

        free(row_buffer);
    }

    fclose(file);

    printf("Parallel matrix written to matrix.csv (%dx%d)\n", rows, cols);
    return 0;
}