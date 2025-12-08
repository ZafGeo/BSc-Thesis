`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2025 08:01:57 PM
// Design Name: 
// Module Name: BRAM
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


module BRAM
    #(datalength = 8, address_size = 4, input_num = 64, output_num = 1)
    (input logic CLK,
     input logic  [output_num-1 : 0][address_size-1 : 0] Address,
     input logic [input_num*datalength-1 : 0] Element_In,
     input logic WE, Enable,
     output logic [output_num-1 : 0][input_num*datalength-1 : 0] Elements_Out
    );
    
    (* RAM_STYLE = "block" *) reg [input_num*datalength-1 : 0] mem [0 : (2**address_size)-1];
    
    always@(posedge CLK)
    begin
        
        if (Enable)
            if (WE)
                mem[Address[0]] <= Element_In;
        
    end
    
    always@(posedge CLK)
    begin
        
        if (Enable)
            for (int i = 0; i < output_num; i++)
                Elements_Out[i] <= mem[Address[i]];
        
    end
    
endmodule
