`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2025 07:06:55 PM
// Design Name: 
// Module Name: Output_Buffer
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

module Output_Buffer
    #(parameter datalength = 16, array_dim = 4)
    (input logic CLK, Reset,
     input logic [array_dim-1 : 0][datalength-1 : 0] Result_In,
     input logic [array_dim-1 : 0] Result_Valid_In,
     input statetype Mode_In,
     output logic [datalength-1 : 0] Result_Out);
    
    logic [array_dim-1 : 0][array_dim-1 : 0][datalength-1 : 0] mem;
    int run_i = 0, run_j = 0;
    
    always_ff@(posedge CLK)
    begin
    
        if (Reset) begin
            mem <= '0;
            Result_Out <= '0;
            run_i <= 0;
            run_j <= 0;
        end
            
        else begin
        
            case (Mode_In)
                
                Catch_Outputs: begin
                    
                    if (Result_Valid_In[0] == 1'b0 && Result_Valid_In[array_dim-1] == 1'b0) begin
                        
                        for (int i = 0; i < array_dim; i++) begin
                        
                            for (int j = array_dim-1; j > 0; j--)
                                mem[i][j] <= mem[i][j-1];
                        
                            mem[i][0] <= Result_In[i];
                            
                        end
                        
                    end
                    
                    run_i <= 0;
                    run_j <= 0;
                    
                end
                
                Collect_Outputs: begin
                    
                    Result_Out <= mem[run_i][run_j];
                    
                    if (run_j == array_dim - 1) begin
                        run_j <= 0;
                        run_i <= run_i + 1;
                    end
                    
                    else
                        run_j <= run_j + 1;
                    
                end
                
            endcase
            
        end
    
    end
    
endmodule
