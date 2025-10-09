`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 01:10:48 AM
// Design Name: 
// Module Name: Test_ROM
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


module Test_ROM
    #(parameter datalength = 16)
    (input logic CLK, Reset,
     output logic [datalength-1 : 0] Element_Out,
     output logic Element_Valid_Out, Element_last
    );
    
    reg [datalength-1 : 0] mem [0 : 128];
    assign mem = {
    16'd8, // input dimension
    // Matrix A
    16'd8, 16'd5, 16'd5, 16'd7, 16'd3, 16'd9, 16'd4, 16'd4,
    16'd6, 16'd5, 16'd6, 16'd6, 16'd2, 16'd6, 16'd0, 16'd7,
    16'd7, 16'd6, 16'd1, 16'd6, 16'd2, 16'd3, 16'd7, 16'd2,
    16'd6, 16'd7, 16'd3, 16'd3, 16'd5, 16'd9, 16'd4, 16'd4,
    16'd7, 16'd0, 16'd6, 16'd6, 16'd1, 16'd1, 16'd0, 16'd6,
    16'd3, 16'd3, 16'd0, 16'd5, 16'd0, 16'd6, 16'd9, 16'd5,
    16'd7, 16'd5, 16'd6, 16'd4, 16'd6, 16'd3, 16'd8, 16'd8,
    16'd9, 16'd0, 16'd4, 16'd9, 16'd9, 16'd6, 16'd5, 16'd1,
    // Matrix B
    16'd1, 16'd1, 16'd5, 16'd3, 16'd2, 16'd4, 16'd0, 16'd4,
    16'd7, 16'd0, 16'd4, 16'd7, 16'd7, 16'd7, 16'd7, 16'd8,
    16'd4, 16'd1, 16'd5, 16'd6, 16'd7, 16'd4, 16'd2, 16'd3,
    16'd1, 16'd6, 16'd4, 16'd2, 16'd3, 16'd6, 16'd3, 16'd9,
    16'd9, 16'd7, 16'd6, 16'd0, 16'd7, 16'd5, 16'd9, 16'd2,
    16'd4, 16'd9, 16'd3, 16'd6, 16'd4, 16'd1, 16'd1, 16'd0,
    16'd9, 16'd0, 16'd8, 16'd2, 16'd3, 16'd7, 16'd3, 16'd5,
    16'd4, 16'd9, 16'd3, 16'd9, 16'd0, 16'd1, 16'd9, 16'd1};
    
    int run_index = 0;
    
    always_ff@(posedge CLK)
        
        if (Reset)
            run_index <= 0;
        
        else
            
            if (run_index <= 128)
                run_index <= run_index + 1;

    
    always_comb
    begin
        
        if (run_index < 128) begin
            Element_Out = mem[run_index];
            Element_Valid_Out = 1;
            Element_last = 0;
        end
        
        else if (run_index == 128) begin
            Element_Out = mem[run_index];
            Element_Valid_Out = 1;
            Element_last = 1;
        end
        
        else begin
            Element_Out = '0;
            Element_Valid_Out = 0;
            Element_last = 0;
        end
        
    end
        
endmodule