/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/unistd.h>
#include "platform.h"
#include "MM.h"
#include "timer.h"
#include "SA.h"


int main()
{
    init_platform();
    printf("Hello World\r\n");

    // Initializing Timer
    static XTime xtimer;
    float timer;

    // Initializing AXI DMA
    static XAxiDma dma_var;
    dma_init(&dma_var);
    sleep(1);

    // Initializing UART
    static XUartPs uart_var;
    uart_init(&uart_var);
    sleep(1);


    while(1)
    {

		s8* A = NULL;
		s8* B = NULL;
		int m, k, n;

		receive_matrices(&uart_var, &A, &B, &m, &k, &n);

		s32* C1 = (s32*) malloc(m * n * sizeof(s32));
		if (!C1) {
			printf("ERROR: Could not allocate space for C1.\r\n");
			return 1;
		}

		s32* C2 = (s32*) malloc(m * n * sizeof(s32));
		if (!C2) {
			printf("ERROR: Could not allocate space for C2.\r\n");
			free(C1);
			return 1;
		}


		// Timing CPU multiplication (Naive)
		timer = timer_time(&xtimer);

		multiply_matrices(A, B, C1, m, k, n);

		printf("CPU Multiplication (Naive) took %f seconds.\r\n", time_diff(timer, timer_time(&xtimer)));


		// Timing CPU multiplication (Blocking)
	    timer = timer_time(&xtimer);

	    matmul_blocked(A, B, C2, m, n, k);

	    printf("CPU Multiplication (Blocking) took %f seconds.\r\n", time_diff(timer, timer_time(&xtimer)));

	    if (!compare_matrices(C1, C2, m, n)) {
	        printf("FAIL: Naive Vs Blocking implementations\r\n");
	    }


		// Timing Accelerator multiplication
		timer = timer_time(&xtimer);

		if (Accelerate_Multiplication(&dma_var, A, B, C2, m, k, n)) {
			free(A);
			free(B);
			free(C1);
			free(C2);
			printf("Multiplication Acceleration failed!\r\n");
			return 1;
		}

		printf("Accelerator Multiplication took %f seconds.\r\n", time_diff(timer, timer_time(&xtimer)));


		if (compare_matrices(C1, C2, m, n))
			printf("SUCCESS: A(%dx%d) * B(%dx%d)\r\n", m, k, k, n);
		else
			printf("FAIL: A(%dx%d) * B(%dx%d)\r\n", m, k, k, n);

	//    printf("Accelerator Results:\r\n");
	//    print_int32_matrix(C1, m, n);
	//
	//    printf("CPU Results:\r\n");
	//    print_int32_matrix(C2, m, n);

		free(A);
		free(B);

		free(C1);
		free(C2);

		printf("Application finished successfully.\r\n\n\n");
    
    }

    cleanup_platform();
    return 0;
}
