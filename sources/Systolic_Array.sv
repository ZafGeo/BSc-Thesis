`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 12:43:12 AM
// Design Name: 
// Module Name: Systolic_Array
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

module Systolic_Array
    #(parameter input_datalength = 8, output_datalength = 32, array_dim = 32)
    (input logic signed[array_dim-1 : 0][input_datalength-1 : 0] A_In,
     input logic signed[array_dim-1 : 0][input_datalength-1 : 0] B_In,
     input logic CLK, Reset,
     input logic [array_dim-1 : 0] Input_Valid_A,
     input logic [array_dim-1 : 0] Input_Valid_B,
     input statetype Mode_In,
     output logic signed[array_dim-1 : 0][output_datalength-1 : 0] A_Out,
//     output logic signed[array_dim-1 : 0][output_datalength-1 : 0] B_Out,
     output logic [array_dim-1 : 0] Output_Valid_A
//     output logic [array_dim-1 : 0] Output_Valid_B
    );
    
    genvar i, j, k;
    
    // Internal signals signals used for the PE outupts.    
    logic signed[array_dim-1 : 0][array_dim : 0][output_datalength-1 : 0] PE_Out_A;
    logic signed[array_dim : 0][array_dim-1 : 0][output_datalength-1 : 0] PE_Out_B;
    logic [array_dim-1 : 0][array_dim : 0] Valid_A;
    logic [array_dim : 0][array_dim-1 : 0] Valid_B;
    
    statetype PE_Mode;
        
    generate

        // West inputs for the systolic array.
        for (k = 0; k < array_dim; k++) begin
            assign PE_Out_A[k][0] = A_In[k];
            assign Valid_A[k][0] = Input_Valid_A[k];
        end
        
        // North inputs for the systolic array.
        for (k = 0; k < array_dim; k++) begin
            assign PE_Out_B[0][k] = B_In[k];
            assign Valid_B[0][k] = Input_Valid_B[k];
        end
        
        // Internal connections between PEs.
        for (i = 0; i < array_dim; i++) begin: row
            for (j = 0; j < array_dim; j++) begin: column
                PE #(output_datalength) unit(.A_In(PE_Out_A[i][j]), .B_In(PE_Out_B[i][j]),
                                                               .CLK(CLK), .Reset(Reset),
                                                               .Mode_In(PE_Mode),
                                                               .Input_Valid_A(Valid_A[i][j]),
                                                               .Input_Valid_B(Valid_B[i][j]),
                                                               .A_Out(PE_Out_A[i][j+1]), .B_Out(PE_Out_B[i+1][j]),
                                                               .Output_Valid_A(Valid_A[i][j+1]),
                                                               .Output_Valid_B(Valid_B[i+1][j]));
            end
        end
        
        // Output is collected from the East side of the array.
        for (k = 0; k < array_dim; k++) begin
            assign A_Out[k] = PE_Out_A[k][array_dim];
            assign Output_Valid_A[k] = Valid_A[k][array_dim];
        end
        
        // Output is collected from the South side of the array.    
//        for (k = 0; k < array_dim; k++) begin
//            assign B_Out[k] = PE_Out_B[array_dim][k];
//            assign Output_Valid_A[k] = Valid_A[array_dim][k];
//        end
    
    endgenerate
    
    always_ff@(posedge CLK)
    begin
        
        if (Reset)
            PE_Mode <= Idle;
        
        else
        
            if (Mode_In == Catch_Outputs)
                
                if (Valid_A[array_dim-1][array_dim-1] == 0 && Valid_A[0][array_dim-2] == 0)
                    PE_Mode <= Catch_Outputs;
                else
                    PE_Mode <= Feed_Inputs;
            else
                PE_Mode <= Mode_In;
    end
    
endmodule
