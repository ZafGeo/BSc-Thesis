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

//typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Output_Results} statetype;

module PE
    #(parameter input_datalength = 8, output_datalength = 32) 
    (input logic CLK, Reset,
     input logic signed[output_datalength-1 : 0] A_In, B_In,
     input statetype Mode_In,
     input logic Input_Valid_A, Input_Valid_B,
     output logic signed[output_datalength-1 : 0] A_Out, B_Out,
     output logic Output_Valid_A, Output_Valid_B);
    
    logic signed[output_datalength-1 : 0] temp_result_In;    // PE Output Register input
    logic signed[output_datalength-1 : 0] temp_result_Out;   // PE Output Register output
    
    assign temp_result_In = temp_result_Out;
    
    // PE Output Register.
    always_ff@(posedge CLK)
        
        if (Reset) begin
            temp_result_Out <= '0;
            A_Out <= '0;
            B_Out <= '0;
            Output_Valid_A <= 0;
            Output_Valid_B <= 0;
        end
        
        else begin
        
            // Signals propagate through the array with one cycle delay per PE.
            
            Output_Valid_A <= Input_Valid_A;
            Output_Valid_B <= Input_Valid_B;
            
            
            if (Mode_In == Feed_Inputs) begin
                
                if (Input_Valid_A) begin
                    temp_result_Out <= temp_result_In + (A_In[input_datalength-1 : 0] * B_In[input_datalength-1 : 0]);
                    A_Out <= A_In;
                    B_Out <= B_In;
                end
                
                else begin
                    A_Out <= temp_result_Out;
                    B_Out <= temp_result_Out;
                end
                
            end
            
            else if (Mode_In == Catch_Outputs) begin
                A_Out <= A_In;
                B_Out <= B_In;
            end
            
            else begin
                temp_result_Out <= '0;
                A_Out <= '0;
                B_Out <= '0;
            end
            
        end
        
endmodule
