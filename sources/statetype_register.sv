`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2025 04:25:30 PM
// Design Name: 
// Module Name: statetype_register
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

//typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Output_Results} statetype;

module statetype_register
    (input logic CLK, Reset, WE,
     input statetype d,
     output statetype q);
     
     always_ff@(posedge CLK, posedge Reset)
        if (Reset) q <= Idle;
        else if (WE) q <= d;
endmodule
