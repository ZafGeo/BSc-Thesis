`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2025 01:58:21 AM
// Design Name: 
// Module Name: Sys_Array_test_tb
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


module Sys_Array_test_tb
    #(parameter datalength = 16, array_dim = 4, address_size = 7)
    ();
    
    logic CLK_tb , Reset_tb;
    logic[7 : 0] Switches_tb, LEDS_tb;
        
    Sys_Array_test #(datalength, array_dim, address_size) uut(CLK_tb, Reset_tb, Switches_tb, LEDS_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
    
    initial
    begin
    
        // Initializing Systolic Array
        Switches_tb = '0;
        Reset_tb = 1; #20;
        
        Reset_tb = 0;

    end

endmodule
