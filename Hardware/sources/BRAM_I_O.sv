`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2025 05:52:22 PM
// Design Name: 
// Module Name: BRAM_I_O
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


// Max function
function bit max (input int a, b);
    if (a > b)
        return 1'b1;
    else if (a < b)
        return 1'b0;
    else begin
        $display("Error: \"input_dim\" and \"output_dim\" must be different.");
        return 1'bX;
    end
endfunction


module BRAM_I_O
    #(datalength = 8, input_dim = 1, output_dim = 1)
    (input logic CLK, Reset,
     input logic [input_dim-1 : 0][datalength-1 : 0] Elements_In,
     input logic Enable, Valid_In,
     output logic [output_dim-1 : 0][datalength-1 : 0] Elements_Out,
     output logic Valid_Out
    );
    
    int run_index = 0;
    
    // input_dim > output_dim
    if (max(input_dim, output_dim)) begin
        
        for (genvar i = 0; i < output_dim; i++)
            assign Elements_Out[i] = Elements_In[run_index + i];
        
        always@(posedge CLK)
        begin
            
            if (!Reset) begin
                run_index <= 0;
                Valid_Out <= 1'b0;
            end
            
            else if (Enable) begin
                
                Valid_Out <= Valid_In;
                
                if (Valid_In) begin
                
                    if (run_index == input_dim - output_dim)
                        run_index <= 0;
                    
                    else
                        run_index <= run_index + output_dim;
                    
                end
                
            end
            
        end
    
    end
    
    // output_dim > input_dim 
    else begin
        
        logic reg_Valid_In = 1'b0;
        
        always@(posedge CLK)
        begin
            
            if (!Reset) begin
                Elements_Out <= '0;
                run_index <= 0;
                reg_Valid_In <= 1'b0;
            end
            
            else if (Enable) begin
                
                reg_Valid_In <= Valid_In;
                
                for (int i = 0; i < input_dim; i++)
                    Elements_Out[run_index + i] <= Elements_In[i];
                
                if (Valid_In)
                
                    if (run_index == output_dim - input_dim)
                        run_index <= 0;
                    
                    else
                        run_index <= run_index + input_dim;
                
            end
            
        end
        
        
        always_comb
            
            if (reg_Valid_In && run_index == 0)
                Valid_Out <= 1'b1;
            else
                Valid_Out <= 1'b0;
    
    end
        
endmodule
