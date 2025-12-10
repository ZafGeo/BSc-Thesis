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
    #(parameter datalength = 32)
    ();

    logic signed[datalength-1 : 0] A_In_tb, B_In_tb;
    logic CLK_tb, Reset_tb, Input_Valid_A_tb, Input_Valid_B_tb;
    statetype mode_tb;  
    logic signed[datalength-1 : 0] A_Out_tb, B_Out_tb;
    logic Output_Valid_A_tb, Output_Valid_B_tb;
    
    PE uut(CLK_tb, Reset_tb, A_In_tb, B_In_tb, mode_tb, Input_Valid_A_tb, Input_Valid_B_tb, A_Out_tb, B_Out_tb, Output_Valid_A_tb, Output_Valid_B_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
    
        // Initializing PE
        mode_tb <= Idle;
        Input_Valid_A_tb <= 0;
        Input_Valid_B_tb <= 0;
        A_In_tb <= '0;
        B_In_tb <= '0;
        Reset_tb = 1; #20;
        
        // Random input values test 1
        mode_tb <= Feed_Inputs;
        A_In_tb <= 'd6;
        B_In_tb <= 'd2;
        Input_Valid_A_tb <= 1;
        Input_Valid_B_tb <= 1;
        Reset_tb = 0; #20;
        
        // Random input values test 2
        A_In_tb <= 'd7;
        B_In_tb <= 'd3;
        #20;
        
        // Random input values test 3
        A_In_tb <= 'd1;
        B_In_tb <= 'd5;
        #20;
        
        Input_Valid_A_tb <= 0;
        Input_Valid_B_tb <= 0; #20;
        
        // Switch to output collection 
        A_In_tb <= 'd23;
        B_In_tb <= 'd56;
        mode_tb <= Catch_Outputs; #20;
        
        A_In_tb <= 'd13;
        B_In_tb <= 'd32; #20;
        
        A_In_tb <= 'd4;
        B_In_tb <= 'd68; #20;
    
    end
    
endmodule
