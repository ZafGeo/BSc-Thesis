This folder contains the code running on the host-PC, outside the FPGA, that transfers the input matrices to the FPGA.
The C file "matrix_generator.c" produces a .csv file with a randomly generated matrix, with integer values between -128 and 127.
The python file "host._prog.py" transfers the input matrix files to the FPGA by UART.
