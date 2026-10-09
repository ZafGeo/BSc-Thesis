`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 03:52:57 PM
// Design Name: 
// Module Name: Buffer_tb
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


module Buffer_tb
    #(parameter datalength = 16, array_dim = 4)
    ();
    
    logic CLK_tb, Reset_tb;
    logic [array_dim-1 : 0][datalength-1 : 0] Element_In_tb;
    statetype Mode_In_tb;
    logic [array_dim-1 : 0][datalength-1 : 0] Out_tb;
    logic [array_dim-1 : 0] Out_Valid_tb;
    
    int i = 0, j = 0, k = 0;
    
    Input_Buffer #(datalength, array_dim) uut(CLK_tb, Reset_tb,
                                                         Element_In_tb,
                                                         Mode_In_tb,
                                                         Out_tb,
                                                         Out_Valid_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
        
        Reset_tb = 1;
        Element_In_tb <= '0;
        Mode_In_tb <= Idle;
        #20;
        
        Reset_tb = 0;
        Mode_In_tb <= Feed_Inputs;
        #20;
        
//        for (i = 0; i < elements; i++)
//            for (j = 0; j < depth; j=j+k-1)
//                for (k = 0; k < input_num; k++) begin
//                    Element_In_tb[k] = i*elements + j + k;
//                    #20;
//                end
        
        for (i = 0; i < array_dim; i++) begin
            for (j = 0; j < array_dim; j++)
                Element_In_tb[j] <= i*array_dim + j + 1;
            #20;
        end
            
        Mode_In_tb <= Catch_Outputs;
        
    end
endmodule
