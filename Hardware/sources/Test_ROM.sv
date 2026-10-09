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
     output logic [3 : 0][datalength-1 : 0] Element_Out,
     output logic Element_Valid_Out, Element_last
    );
    
    reg [datalength-1 : 0] mem [0 : 291];
    assign mem = {
    8'd12, 8'd0, 8'd0, 8'b10000000, // input dimension
    // Matrix A
    8'd0, 8'd5, 8'd8, 8'd8, 8'd5, 8'd4, 8'd3, 8'd5, 8'd9, 8'd0, 8'd0, 8'd0,
    8'd6, 8'd0, 8'd7, 8'd6, 8'd9, 8'd3, 8'd4, 8'd0, 8'd2, 8'd0, 8'd0, 8'd0,
    8'd1, 8'd9, 8'd8, 8'd5, 8'd0, 8'd5, 8'd8, 8'd3, 8'd4, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd7, 8'd8, 8'd3, 8'd0, 8'd0, 8'd8, 8'd4, 8'd1, 8'd0, 8'd0, 8'd0,
    8'd3, 8'd6, 8'd5, 8'd1, 8'd6, 8'd3, 8'd0, 8'd9, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd9, 8'd4, 8'd3, 8'd6, 8'd7, 8'd1, 8'd0, 8'd7, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd7, 8'd7, 8'd5, 8'd5, 8'd2, 8'd5, 8'd1, 8'd7, 8'd5, 8'd0, 8'd0, 8'd0,
    8'd7, 8'd5, 8'd7, 8'd8, 8'd9, 8'd3, 8'd6, 8'd9, 8'd5, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    // Matrix B
    8'd4, 8'd9, 8'd9, 8'd1, 8'd5, 8'd7, 8'd4, 8'd3, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd8, 8'd3, 8'd8, 8'd5, 8'd3, 8'd7, 8'd9, 8'd9, 8'd3, 8'd0, 8'd0, 8'd0,
    8'd7, 8'd9, 8'd7, 8'd9, 8'd4, 8'd6, 8'd3, 8'd1, 8'd5, 8'd0, 8'd0, 8'd0,
    8'd9, 8'd4, 8'd7, 8'd1, 8'd7, 8'd7, 8'd7, 8'd2, 8'd9, 8'd0, 8'd0, 8'd0,
    8'd7, 8'd7, 8'd2, 8'd0, 8'd3, 8'd6, 8'd6, 8'd9, 8'd7, 8'd0, 8'd0, 8'd0,
    8'd5, 8'd3, 8'd9, 8'd4, 8'd3, 8'd2, 8'd0, 8'd7, 8'd9, 8'd0, 8'd0, 8'd0,
    8'd6, 8'd8, 8'd2, 8'd6, 8'd8, 8'd3, 8'd6, 8'd8, 8'd9, 8'd0, 8'd0, 8'd0,
    8'd4, 8'd7, 8'd4, 8'd9, 8'd3, 8'd2, 8'd9, 8'd3, 8'd8, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,
    8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    
    int run_index = 0, delay_counter = 0;
    
    always_ff@(posedge CLK)
        
        if (Reset) begin
            run_index <= 0;
            delay_counter <= 0;
            mem[3][7] <= !mem[3][7];
        end
        
        else begin
            
            if (run_index == 0)
                if (delay_counter == 15) begin
                    delay_counter <= 0;
                    run_index <= run_index + 4;
                end
                else
                    delay_counter <= delay_counter + 1;
            
            else if (run_index == 68)
                if (delay_counter == 15) begin
                    delay_counter <= 0;
                    run_index <= run_index + 4;
                end
                else
                    delay_counter <= delay_counter + 1;
                    
            else if (run_index < 292)
                run_index <= run_index + 4;
            
            
        end
    
    always_comb
    begin
    
        for (int i = 0; i < 4; i++)
            Element_Out[i] = mem[run_index+i];
        
        if (delay_counter != 0) begin
            Element_Valid_Out = 0;
            Element_last = 0;
        end
        
        else if (run_index < 288) begin
            Element_Valid_Out = 1;
            Element_last = 0;
        end
        
        else if (run_index == 288) begin
            Element_Valid_Out = 1;
            Element_last = 1;
        end
        
        else begin
            Element_Valid_Out = 0;
            Element_last = 0;
        end
        
    end
        
endmodule