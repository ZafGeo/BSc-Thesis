`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 01:10:49 AM
// Design Name: 
// Module Name: Test_RAM
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


module Test_RAM
    #(parameter datalength = 32, address_size = 6)
    (input logic CLK, Reset,
     input logic [datalength-1 : 0] Element_In,
     input logic Element_Valid_In, Element_last,
     input logic [7 : 0] Address,
     output logic [datalength-1 : 0] Element_Out
    );
    
    logic [2**address_size-1 : 0][datalength-1 : 0] mem;
    int run_index = 0;
    
    always_ff@(posedge CLK)
        
        if (Reset) begin
            Element_Out <= '0;
            run_index <= 0;
            mem <= '0;
        end
        
        else begin
            
            if (Element_Valid_In) begin
                mem[run_index] <= Element_In;
                run_index <= run_index + 1;
            end
            
            else
                Element_Out <= mem[Address];
            
        end
endmodule
