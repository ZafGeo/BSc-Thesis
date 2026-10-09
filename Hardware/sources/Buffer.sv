`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 12:54:51 AM
// Design Name: 
// Module Name: Buffer
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

module Input_Buffer
    #(parameter datalength = 16, array_dim = 16)
    (input logic CLK, Reset,
     input logic [array_dim-1 : 0][datalength-1 : 0] Element_In,
     input statetype Mode_In,
     output logic [array_dim-1 : 0][datalength-1 : 0] Out,
     output logic [array_dim-1 : 0] Out_Valid);
     
     logic [array_dim-1 : 0][array_dim : 0][datalength : 0] queue_connect;
     logic [array_dim-1 : 0][array_dim-1 : 0] WE;
     
     
     // Registers for input storage and delay insertion.
     for (genvar i = 0; i < array_dim; i++) begin: row
        for (genvar j = 0; j <= i; j++) begin: column
            Register #(datalength + 1) reg_unit(.CLK(CLK), .Reset(Reset), .WE(WE[i][j]), .d(queue_connect[i][j]), .q(queue_connect[i][j+1]));
        end
     end
     
     
     // Connect outputs.
     for (genvar i = 0; i < array_dim; i++) begin
        assign Out[i] = queue_connect[i][i+1];
        assign Out_Valid[i] = queue_connect[i][i+1][datalength];
     end
                
     
     // Connect the first column of registers to the input elements.
     for (genvar i = 0; i < array_dim; i++) begin
        assign queue_connect[i][0][datalength-1 : 0] = Element_In[i];
        assign queue_connect[i][0][datalength] = (Mode_In == Feed_Inputs);
     end
     
     // Enable write for storing elements in registers.
     always_ff@(posedge CLK)
     begin
        
        if (!Reset) begin
            WE <= '0;
        end
        
        else begin
            
            if (Mode_In == Feed_Inputs || Mode_In == Catch_Outputs)
                
                for (int i = 0; i < array_dim; i++)
                    for (int j = 0; j < i+1; j++)
                        WE[i][j] <= 1;
                    
            else
                WE <= '0;
            
        end
        
     end
     
endmodule
