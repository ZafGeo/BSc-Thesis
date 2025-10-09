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

// Max function
function bit [$size(int)-1 : 0] max;
    input int a, b;
    if (a >= b)
        return a;
    else
        return b;
endfunction


module BRAM
#(datalength = 16, address_size = 4, output_num = 16)
    (input logic CLK,
     input logic [output_num-1 : 0][address_size-1 : 0] Address,
     input logic [datalength-1 : 0] Element_In,
     input logic WE, Enable,
     output logic [output_num-1 : 0][datalength-1 : 0] Elements_Out
    );
    
    (* RAM_STYLE = "block" *) reg [datalength-1 : 0] mem [0 : (2**address_size)-1];
    
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
