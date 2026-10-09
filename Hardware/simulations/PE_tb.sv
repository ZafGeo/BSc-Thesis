`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 01:09:16 AM
// Design Name: 
// Module Name: PE_tb
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


module PE_tb
    #(parameter input_datalength = 8, output_datalength = 32)
    ();

    logic signed[input_datalength-1 : 0] A_In_tb, B_In_tb;
    logic signed[output_datalength-1 : 0] Result_In_tb;
    logic CLK_tb, Reset_tb, Input_Valid_A_tb, Result_Valid_In;
    logic signed[input_datalength-1 : 0] A_Out_tb, B_Out_tb;
    logic signed[output_datalength-1 : 0] Result_Out_tb;
    logic Output_Valid_A_tb;
    
    PE #(input_datalength, output_datalength) uut(CLK_tb, Reset_tb, A_In_tb, B_In_tb, Result_In_tb, Input_Valid_A_tb, Result_Valid_In, A_Out_tb, B_Out_tb, Result_Out_tb, Output_Valid_A_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
    
        // Initializing PE
        Input_Valid_A_tb <= 0;
        Result_Valid_In <= 1'b0;
        Result_In_tb <= '0;
        A_In_tb <= '0;
        B_In_tb <= '0;
        Reset_tb = 1'b0; #20;
        
        // Random input values test 1
        A_In_tb <= -6;
        B_In_tb <= 'd2;
        Input_Valid_A_tb <= 1'b1;
        Reset_tb = 1'b1; #20;
        
        // Random input values test 2
        A_In_tb <= -7;
        B_In_tb <= 'd3;
        #20;
        
        // Random input values test 3
        A_In_tb <= -1;
        B_In_tb <= 'd5;
        #20;
        
        Input_Valid_A_tb <= 1'b0;
        
        // Switch to output collection
        Result_In_tb <= -33; 
        A_In_tb <= '0;
        B_In_tb <= '0; #20;
        
        Result_Valid_In <= 1'b1; #20;
        
        Result_In_tb <= -92;
        #20;
        
        Result_In_tb <= 'd12;
        #20;
    
    end
    
endmodule
