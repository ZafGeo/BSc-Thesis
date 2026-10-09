`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2025 06:55:23 PM
// Design Name: 
// Module Name: PE
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


module PE
    #(parameter input_datalength = 8, output_datalength = 32) 
    (input logic CLK, Reset,
     input logic signed [input_datalength-1 : 0] A_In, B_In,
     input logic signed [output_datalength-1 : 0] Result_In,
     input logic Input_Valid_A, Result_Valid_In,
     output logic signed [input_datalength-1 : 0] A_Out, B_Out,
     output logic signed [output_datalength-1 : 0] Result_Out,
     output logic Output_Valid_A);
    
    logic signed [output_datalength-1 : 0] temp_result_In;    // PE Output Register input
    logic signed [output_datalength-1 : 0] temp_result_Out;   // PE Output Register output
    (* use_dsp = "yes" *) logic signed [output_datalength-1 : 0] mac_result;
    
    
    assign temp_result_In = Result_Valid_In ? Result_In : mac_result;
    
    
    // Signals propagate through the array with one cycle delay per PE.
    always_ff@(posedge CLK)
        
        if (!Reset) begin
            A_Out <= '0;
            B_Out <= '0;
            Output_Valid_A <= 1'b0;
        end
        
        else begin
            A_Out <= A_In;
            B_Out <= B_In;
            Output_Valid_A <= Input_Valid_A;
        end
    
    
    // Result propagation used before and after MAC calculation.    
    assign Result_Out = temp_result_Out;
    
    // Result calculation and output logic
    always_ff@(posedge CLK)
    begin
    
        if (!Reset) begin
            temp_result_Out <= '0;
        end
        
        else begin
            
            if (Result_Valid_In)
                temp_result_Out <= Result_In;
            else
                temp_result_Out <= mac_result;

        end
    
    end

    
    // MAC unit DSP infered
    always_ff@(posedge CLK)
        if (!Reset)
            mac_result <= '0;
        else
            mac_result <= temp_result_In + A_In * B_In;
    

endmodule
