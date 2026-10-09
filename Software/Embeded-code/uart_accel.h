#ifndef UART_ACCEL_H
#define UART_ACCEL_H

#include "xuartps.h"
#include "xparameters.h"


#define UART_ADDRESS XPAR_PS7_UART_1_DEVICE_ID
#define UART_BASE_ADDRESS XPAR_PS7_UART_1_BASEADDR

#define SETUP_PACKET_BYTE_LENGTH 4+4+4 // 1 byte for keep flag & finished flag, 4 bytes each for m, k and n


void uart_init(XUartPs* );


void uart_send(XUartPs* , void* , int );


void uart_receive(XUartPs* , void* , int );


void receive_setup_packet(XUartPs* , int* , int* , int* );


void receive_matrices(XUartPs* , s8** , s8** , int* , int* , int* );

#endif