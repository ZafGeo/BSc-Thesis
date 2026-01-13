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
#include <stdint.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xuartps.h"
#include "static_data.h"

#define DMA_ADD XPAR_AXIDMA_0_DEVICE_ID
#define UART_ADD XPAR_XUARTPS_0_DEVICE_ID


int main()
{
    init_platform();

    print("Hello World\n\r");


    // Initializing input, output buffers
    input_d *input_buffer;
	int32_t *output_buffer;
    input_buffer = (input_d*) malloc(sizeof(input_d) * (2*ARRAY_SIZE + 1));

    if (input_buffer == NULL)
    	xil_printf("ERROR: Input buffer space could not be allocated.\r\n");

    output_buffer = (int32_t*) malloc(sizeof(int32_t) * ARRAY_SIZE);
    if (output_buffer == NULL)
    	xil_printf("ERROR: Output buffer space could not be allocated.\r\n");

    memcpy(input_buffer, input_data, sizeof(input_d) * (2*ARRAY_SIZE + 1));

    xil_printf("Input and output buffers were initialized.\r\n");


    // Initializing AXI DMA
    XAxiDma* dma_var;
    dma_var = (XAxiDma*) malloc(sizeof(XAxiDma));

    XAxiDma_Config* dma_config_var;

    dma_config_var = XAxiDma_LookupConfig(DMA_ADD);

    if (!dma_config_var)
    	xil_printf("ERROR: No hardware configuration found for AXI DMA.\r\n");

    if (XAxiDma_CfgInitialize(dma_var, dma_config_var) != XST_SUCCESS)
    	xil_printf("ERROR: Initialization of AXI DMA failed.\r\n");

    if (XAxiDma_HasSg(dma_var))
    	xil_printf("WARNING: DMA is in Scatter Gather mode.\r\n");

    xil_printf("AXI DMA was initialized.\r\n");


    // Initializing UART
    XUartPs* uart_var;
    uart_var = (XUartPs*) malloc(sizeof(XUartPs));

    XUartPs_Config* uart_config_var;

    uart_config_var = XUartPs_LookupConfig(UART_ADD);
    if (uart_config_var == NULL)
    	xil_printf("ERROR: No hardware configuration found for UART.\r\n");

    if (XUartPs_CfgInitialize(uart_var, uart_config_var, uart_config_var->BaseAddress) != XST_SUCCESS)
    	xil_printf("ERROR: Initialization of UART failed.\r\n");

    if (XUartPs_SelfTest(uart_var) != XST_SUCCESS)
    	xil_printf("ERROR: UART Self Test failed.\r\n");

    xil_printf("UART was initialized.\r\n");


    // Data transfer and acceleration
    Xil_DCacheFlushRange((int) input_buffer, (2*ARRAY_SIZE+1) * sizeof(input_d));
    Xil_DCacheInvalidateRange((int) output_buffer, ARRAY_SIZE * sizeof(int32_t));

    if (XAxiDma_SimpleTransfer(dma_var, (int) input_buffer, (2*ARRAY_SIZE+1) * sizeof(input_d), XAXIDMA_DMA_TO_DEVICE) != XST_SUCCESS)
    	xil_printf("ERROR: Failed to kick off MM2S transfer!\n\r");

    if (XAxiDma_SimpleTransfer(dma_var, (int) output_buffer, ARRAY_SIZE * sizeof(int32_t), XAXIDMA_DEVICE_TO_DMA) != XST_SUCCESS)
        	xil_printf("ERROR: Failed to kick off S2MM transfer!\n\r");


    // Print results
    while(XAxiDma_Busy(dma_var, XAXIDMA_DMA_TO_DEVICE) || XAxiDma_Busy(dma_var, XAXIDMA_DEVICE_TO_DMA))
    	continue;	// wait for DMA to finish transferring

    xil_printf("Printing Accelerator results -----------------------------\r\n");
    for (int i = 0; i < ARRAY_SIZE; i++)
    	xil_printf("Element(%d) = %d\r\n", i, output_buffer[i]);


    free(input_buffer);
    free(output_buffer);
    free(dma_var);
    free(uart_var);

    xil_printf("Acceleration finished successfully.\r\n");

    cleanup_platform();
    return 0;
}
