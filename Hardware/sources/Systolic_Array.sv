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

//typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Feed_Outputs, Output_Results} statetype;

module Systolic_Array
    #(parameter input_datalength = 8, output_datalength = 32, array_dim = 16)
    (input logic CLK, Reset,
     input logic signed[array_dim-1 : 0][input_datalength-1 : 0] A_In,
     input logic signed[array_dim-1 : 0][input_datalength-1 : 0] B_In,
     input logic [array_dim-1 : 0] Input_Valid_A,
     input statetype Mode_In,
     input logic signed [array_dim-1 : 0][output_datalength-1 : 0] Results_In,
     output logic [array_dim-1 : 0] Output_Valid_A,
     output logic signed [array_dim-1 : 0][output_datalength-1 : 0] Results_Out
    );
    
    genvar i, j, k;
    logic propagate_results;
    
    // Internal signals signals used for the PE outupts.    
    logic signed [array_dim-1 : 0][array_dim : 0][input_datalength-1 : 0] PE_Out_A;
    logic signed [array_dim : 0][array_dim-1 : 0][input_datalength-1 : 0] PE_Out_B;
    logic [array_dim-1 : 0][array_dim : 0] Valid_A;
    logic signed [array_dim : 0][array_dim-1 : 0][output_datalength-1 : 0] Results_in;
    
        
    generate

        // West inputs for the systolic array.
        for (k = 0; k < array_dim; k++) begin
            assign PE_Out_A[k][0] = Input_Valid_A[k] ? A_In[k] : '0;
            assign Valid_A[k][0] = Input_Valid_A[k];
        end
        
        // North inputs for the systolic array.
        for (k = 0; k < array_dim; k++) 
            assign PE_Out_B[0][k] = Input_Valid_A[k] ? B_In[k] : '0;
        
        // Result inputs for the systolic array.
        assign Results_in[0] = (Mode_In == Catch_Outputs ||
                                Mode_In == Collect_Outputs) ? '0 : Results_In;
        
        // Internal connections between PEs.
        for (i = 0; i < array_dim; i++) begin: row
            for (j = 0; j < array_dim; j++) begin: column
                PE #(input_datalength, output_datalength) unit(.A_In(PE_Out_A[i][j]), .B_In(PE_Out_B[i][j]),
                                                               .CLK(CLK), .Reset(Reset),
                                                               .Result_In(Results_in[array_dim-i-1][j]),
                                                               .Input_Valid_A(Valid_A[i][j]),
                                                               .Result_Valid_In(propagate_results),
                                                               .A_Out(PE_Out_A[i][j+1]), .B_Out(PE_Out_B[i+1][j]),
                                                               .Result_Out(Results_in[array_dim-i][j]),
                                                               .Output_Valid_A(Valid_A[i][j+1]));
            end
        end
        
        // Output is collected from the East side of the array.
        for (k = 0; k < array_dim; k++) begin
            assign Results_Out[k] = Results_in[array_dim][k];
            assign Output_Valid_A[k] = Valid_A[k][array_dim];
        end
        
    endgenerate
    
    
    // Result propagation control signal logic for catching and feeding outputs.
    always_ff@(posedge CLK)
    begin
        
        if (!Reset)
            propagate_results <= 1'b0;
        
        else
        
            if (Mode_In == Catch_Outputs)
                
                if (Valid_A[array_dim-1][array_dim-1] == 0 && Valid_A[0][array_dim-2] == 0)
                    propagate_results <= 1'b1;
                else
                    propagate_results <= 1'b0;
            
            else if (Mode_In == Feed_Outputs)
                propagate_results <= 1'b1;
            
            else
                propagate_results <= 1'b0;
    end
    
    
endmodule
