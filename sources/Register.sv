`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2025 08:30:09 PM
// Design Name: 
// Module Name: Register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register
    #(parameter datalength = 32)
    (input logic CLK, Reset, WE,
     input logic [datalength-1 : 0] d,
     output logic [datalength-1 : 0] q);
     
     always_ff@(posedge CLK)
        if (Reset) q <= '0;
        else if (WE) q <= d;
endmodule
