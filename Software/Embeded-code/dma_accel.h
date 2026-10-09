#ifndef DMA_ACCEL_H
#define DMA_ACCEL_H

#include "xaxidma.h"
#include "xparameters.h"

#define DMA_ADDRESS XPAR_AXI_DMA_0_DEVICE_ID


void dma_init(XAxiDma* );

u32 dma_transfer(XAxiDma* , void* , int );

u32 dma_receive(XAxiDma* , void* , int );

void dma_wait(XAxiDma* );

void dma_wait_transfer(XAxiDma* );

#endif