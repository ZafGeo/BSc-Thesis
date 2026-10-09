`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 01:36:18 AM
// Design Name: 
// Module Name: BRAM_tb
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


module BRAM_tb
    #(parameter datalength = 16, dimension = 16, input_num = 1, output_num = 4)
    ();
    
    logic CLK_tb, Reset_tb;                                           
    logic[output_num-1 : 0][$clog2(dimension**2)-1 : 0] Address_tb;
    logic[datalength-1 : 0] Element_In_tb;                         
    logic WE_tb;                                                   
    logic[output_num-1 : 0][datalength-1 : 0] Elements_Out_tb;
    
    
    BRAM #(datalength, dimension, input_num, output_num) uut (CLK_tb, Reset_tb,
                                                   Address_tb,
                                                   Element_In_tb,
                                                   WE_tb,
                                                   Elements_Out_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
        
        Reset_tb = 1;
        Address_tb <= '0;
        Element_In_tb <= '0;
        WE_tb <= 0;  #20;
        
        Reset_tb = 0;
        Element_In_tb <= 23;
        WE_tb <= 1;  #20;
        
        Address_tb <= 1;
        Element_In_tb <= 62;
        WE_tb <= 1;  #20;
        
        Address_tb <= 2;
        Element_In_tb <= 35;
        WE_tb <= 1;  #20;
        
        Address_tb <= 3;
        Element_In_tb <= 43;
        WE_tb <= 1;  #20;
        
        for (int i = 0; i < output_num; i++)
            Address_tb[i] <= i;
        Element_In_tb <= 33;
        WE_tb <= 0;  #20;
        
    end
    
    
endmodule
