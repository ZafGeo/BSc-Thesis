`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2025 11:19:21 AM
// Design Name: 
// Module Name: BRAM_I_O_tb
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


module BRAM_I_O_tb
    #(datalength = 8, input_dim = 8, output_dim = 1)
    ();

    logic CLK_tb, Reset_tb;
    logic [input_dim-1 : 0][datalength-1 : 0] Elements_In_tb;
    logic Valid_In_tb;
    logic [output_dim-1 : 0][datalength-1 : 0] Elements_Out_tb;
    logic Valid_Out_tb;


    BRAM_I_O #(datalength, input_dim, output_dim) uut(CLK_tb, Reset_tb,
                                                      Elements_In_tb,
                                                      Valid_In_tb,
                                                      Elements_Out_tb,
                                                      Valid_Out_tb);

    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end


    if (max(input_dim, output_dim))

        initial
        begin

            Reset_tb <= 1;
            Elements_In_tb <= '0;
            Valid_In_tb <= 0;
            #20;
            
            for (int i = 0; i < 3; i++) begin
                Reset_tb <= 0;
                for (int j = 0; j < input_dim; j++)
                    Elements_In_tb[j] <= i * (j + 1);
                Valid_In_tb <= 1;
                #(20 * input_dim);
            end

            Valid_In_tb <= 0;
            #20;

        end
    
    else

        initial
        begin

            Reset_tb <= 1;
            Elements_In_tb <= '0;
            Valid_In_tb <= 0;
            #20;
            
            for (int i = 0; i < 3; i++) begin
                Reset_tb <= 0;
                for (int j = 0; j < input_dim; j++)
                    Elements_In_tb[j] <= i * (j + 1);
                Valid_In_tb <= 1;
                #(20 * output_dim);
            end

            Valid_In_tb <= 0;
            #20;

        end

endmodule