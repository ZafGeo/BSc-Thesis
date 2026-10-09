#include <stdlib.h>

#include "uart_accel.h"
#include "xil_printf.h"


// Initialize the UART interfaces
void uart_init(XUartPs* uart_inst)
{
	XUartPs_Config* uart_config_var;

    uart_config_var = XUartPs_LookupConfig(UART_ADDRESS);
    if (uart_config_var == NULL)
    	xil_printf("ERROR: No hardware configuration found for UART.\r\n");

    if (XUartPs_CfgInitialize(uart_inst, uart_config_var, uart_config_var->BaseAddress) != XST_SUCCESS)
    	xil_printf("ERROR: Initialization of UART failed.\r\n");

    if (XUartPs_SelfTest(uart_inst) != XST_SUCCESS)
    	xil_printf("ERROR: UART Self Test failed.\r\n");

    xil_printf("UART was initialized.\r\n");
}


// Send bytes through the UART
void uart_send(XUartPs* uart_inst, void* buffer, int no_bytes)
{
    int bytes_sent = 0;

    while (bytes_sent < no_bytes) {
        bytes_sent += XUartPs_Send(uart_inst,
                                   (u8*)buffer + bytes_sent,
								   no_bytes - bytes_sent);
    }

    while (XUartPs_IsSending(uart_inst));
}


// Receive bytes through the UART
void uart_receive(XUartPs* uart_inst, void* buffer, int expected_no_bytes)
{

    /* Do not call this function directly.*/
    int bytes_received = 0;

    while(bytes_received < expected_no_bytes)
        bytes_received += XUartPs_Recv(uart_inst,
	                                (u8*)buffer + bytes_received,
								    expected_no_bytes - bytes_received);

}


// Receive the setup packet containing the dimensions of the input matrices to store them properly
void receive_setup_packet(XUartPs* uart_inst, int* m, int* k, int* n)
{

    u8* setup_packet_buffer = (u8*) malloc(SETUP_PACKET_BYTE_LENGTH * sizeof(u8));
    if(!setup_packet_buffer) {
    	xil_printf("ERROR: Space could not be allocated for the setup packet - host pc to FPGA!\r\n");
    	return;
    }

    uart_receive(uart_inst, setup_packet_buffer, SETUP_PACKET_BYTE_LENGTH);

    *m = (int) setup_packet_buffer[0] |
         ((int) setup_packet_buffer[1] << 8) |
         ((int) setup_packet_buffer[2] << 16) |
		 ((int) setup_packet_buffer[3] << 24);

    *k = (int) setup_packet_buffer[4] |
         ((int) setup_packet_buffer[5] << 8) |
         ((int) setup_packet_buffer[6] << 16) |
		 ((int) setup_packet_buffer[7] << 24);

	*n = (int) setup_packet_buffer[8] |
         ((int) setup_packet_buffer[9] << 8) |
         ((int) setup_packet_buffer[10] << 16) |
		 ((int) setup_packet_buffer[11] << 24);

    free(setup_packet_buffer);

}


// Receive the input matrices
void receive_matrices(XUartPs* uart_inst, s8** A, s8** B, int* m, int* k, int* n)
{

	while (!XUartPs_IsReceiveData(UART_BASE_ADDRESS));

    // receive_header();

    // Setup packet reception
    receive_setup_packet(uart_inst, m, k, n);

    int matrix_A_size = (*m) * (*k);
    int matrix_B_size = (*k) * (*n);

    *A = (s8*) malloc(sizeof(s8) * matrix_A_size);
    if (!(*A)) {
    	xil_printf("ERROR: Space could not be allocated for input matrix A!\r\n");
       	return;
    }

    *B = (s8*) malloc(sizeof(s8) * matrix_B_size);
    if (!(*B)) {
    	xil_printf("ERROR: Space could not be allocated for input matrix B!\r\n");
    	free(*A);
    	return;
    }

    // Payload reception
    uart_receive(uart_inst, *A, matrix_A_size);
    uart_receive(uart_inst, *B, matrix_B_size);

}
