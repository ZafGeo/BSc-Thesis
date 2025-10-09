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
    #(parameter datalength = 32, rows = 3, columns = 3)
    (input logic signed[rows-1 : 0][datalength-1 : 0] A_In,
     input logic signed[columns-1 : 0][datalength-1 : 0] B_In,
     input logic CLK, Reset,
     input logic [rows-1 : 0] Input_Valid_A,
     input logic [columns-1 : 0] Input_Valid_B,
     input statetype Mode_In,
     output logic signed[rows-1 : 0][datalength-1 : 0] A_Out,
//     output logic signed[columns-1 : 0][datalength-1 : 0] B_Out,
     output logic [rows-1 : 0] Output_Valid_A
//     output logic [columns-1 : 0] Output_Valid_B
    );
    
    genvar i, j, k;
    
    // Internal signals signals used for the PE outupts.    
    logic signed[rows-1 : 0][columns : 0][datalength-1 : 0] PE_Out_A;
    logic signed[rows : 0][columns-1 : 0][datalength-1 : 0] PE_Out_B;
    logic [rows-1 : 0][columns : 0] Valid_A;
    logic [rows : 0][columns-1 : 0] Valid_B;
    
    statetype PE_Mode;
        
    generate

        // West inputs for the systolic array.
        for (k = 0; k < rows; k++) begin
            assign PE_Out_A[k][0] = A_In[k];
            assign Valid_A[k][0] = Input_Valid_A[k];
        end
        
        // North inputs for the systolic array.
        for (k = 0; k < columns; k++) begin
            assign PE_Out_B[0][k] = B_In[k];
            assign Valid_B[0][k] = Input_Valid_B[k];
        end
        
        // Internal connections between PEs.
        for (i = 0; i < rows; i++) begin: row
            for (j = 0; j < columns; j++) begin: column
                PE #(datalength) unit(.A_In(PE_Out_A[i][j]), .B_In(PE_Out_B[i][j]),
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
        for (k = 0; k < rows; k++) begin
            assign A_Out[k] = PE_Out_A[k][columns];
            assign Output_Valid_A[k] = Valid_A[k][columns];
        end
        
        // Output is collected from the South side of the array.    
//        for (k = 0; k < columns; k++) begin
//            assign B_Out[k] = PE_Out_B[rows][k];
//            assign Output_Valid_A[k] = Valid_A[rows][k];
//        end
    
    endgenerate
    
    always_ff@(posedge CLK)
    begin
        
        if (Reset)
            PE_Mode <= Idle;
        
        else
        
            if (Mode_In == Catch_Outputs)
                
                if (Valid_A[rows-1][columns-1] == 0 && Valid_A[0][columns-2] == 0)
                    PE_Mode <= Catch_Outputs;
                else
                    PE_Mode <= Feed_Inputs;
            else
                PE_Mode <= Mode_In;
    end
    
endmodule
