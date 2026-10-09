#include "dma_accel.h"
#include "xil_printf.h"


// Initialize the DMA interface
void dma_init(XAxiDma* dma_inst)
{
	XAxiDma_Config* dma_config_var;

    dma_config_var = XAxiDma_LookupConfig(DMA_ADDRESS);

    if (!dma_config_var)
    	xil_printf("ERROR: No hardware configuration found for AXI DMA.\r\n");

    if (XAxiDma_CfgInitialize(dma_inst, dma_config_var) != XST_SUCCESS)
    	xil_printf("ERROR: Initialization of AXI DMA failed.\r\n");

    if (XAxiDma_HasSg(dma_inst))
    	xil_printf("WARNING: DMA is in Scatter Gather mode.\r\n");

    xil_printf("AXI DMA was initialized.\r\n");
}


// Begin the DMA transfer from the memory to the accelerator
u32 dma_transfer(XAxiDma* dma_inst, void* buffer, int no_bytes)
{
	u32 xstatus;

	// Flush the input buffer intended to be transferred to the accelerator into the memory (from CPU caches)
	Xil_DCacheFlushRange((int) buffer, no_bytes * sizeof(s8));

	if ((xstatus = XAxiDma_SimpleTransfer(dma_inst, (int) buffer, no_bytes * sizeof(s8), XAXIDMA_DMA_TO_DEVICE)) != XST_SUCCESS)
		xil_printf("ERROR: Failed to kick off MM2S transfer! Status is %ld.\n\r", xstatus);
		
	return xstatus;
}


// Begin the DMA transfer from the accelerator to the memory
u32 dma_receive(XAxiDma* dma_inst, void* buffer, int no_bytes)
{
	u32 xstatus;

	// Invalidate the output buffer used to store the accelerator's results from the CPU caches (Next time will be brought from memory)
	Xil_DCacheInvalidateRange((int) buffer, no_bytes * sizeof(s8));

	if ((xstatus = XAxiDma_SimpleTransfer(dma_inst, (int) buffer, no_bytes * sizeof(s8), XAXIDMA_DEVICE_TO_DMA)) != XST_SUCCESS)
		xil_printf("ERROR: Failed to kick off S2MM transfer! Status is %ld.\n\r", xstatus);

	return xstatus;
}


// Wait for both transfers to finish
void dma_wait(XAxiDma* dma_inst)
{
	while(XAxiDma_Busy(dma_inst, XAXIDMA_DMA_TO_DEVICE) || XAxiDma_Busy(dma_inst, XAXIDMA_DEVICE_TO_DMA))
		continue;
}


// Wait for the transfer memory to accelerator to finish
void dma_wait_transfer(XAxiDma* dma_inst)
{
	while(XAxiDma_Busy(dma_inst, XAXIDMA_DMA_TO_DEVICE))
		continue;
}
