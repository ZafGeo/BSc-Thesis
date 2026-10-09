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

//typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Feed_Outputs, Output_Results} statetype;

module Output_Buffer
    #(parameter datalength = 32, array_dim = 16)
    (input logic CLK, Reset,
     input logic [array_dim-1 : 0][datalength-1 : 0] Result_In,
     input logic [array_dim-1 : array_dim-2] Result_Valid_In,
     input statetype Mode_In,
     output logic [array_dim-1 : 0][datalength-1 : 0] Result_Out,
     output logic element_last);
    
    logic [array_dim-1 : 0][array_dim-1 : 0][datalength-1 : 0] mem;
    int run_i = 0;
    logic temp_flag;
    
    always_ff@(posedge CLK)
    begin
    
        if (!Reset) begin
            mem <= '0;
            Result_Out <= '0;
            run_i <= 0;
        end
            
        else begin
        
            case (Mode_In)
                
                Catch_Outputs: begin
                    
                    if (temp_flag) begin
                        
                        // Counting rows inserted into memory buffer.
                        if (run_i == array_dim-1)
                            run_i <= 0;
                        else
                            run_i <= run_i + 1;
                        
                        // Shift Systolic Array results one row at a time into buffer.
                        for (int j = 0; j < array_dim; j++) begin
                        
                            for (int i = 0; i < array_dim-1; i++)
                                mem[i][j] <= mem[i+1][j];
                        
                            mem[array_dim-1][j] <= Result_In[j];
                            
                        end
                        
                    end
                    
                end
                
                // Output results into Output Block RAM.
                Collect_Outputs: begin
                    
                    Result_Out <= mem[run_i];
                    
                    if (run_i == array_dim)
                        run_i <= 0;
                    else
                        run_i <= run_i + 1;
                    
                end
                
            endcase
            
        end
    
    end
    
    
    // Control signal "temp_flag" logic for enabling shift memory.
    always_ff@(posedge CLK)
    
        if (!Reset)
            temp_flag <= 1'b0;
        
        else
            if (!Result_Valid_In[array_dim-2] && Result_Valid_In[array_dim-1])
                temp_flag <= 1'b1;
            else if (Mode_In != Catch_Outputs)
                temp_flag <= 1'b0;
    
    
    // Control signal "element_last" logic for changing Mode.
    always_comb
        
        if (run_i == array_dim-1 && temp_flag)
            element_last = 1'b1;
        else
            element_last = 1'b0;
    
            
endmodule
