`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 03:52:57 PM
// Design Name: 
// Module Name: Output_Buffer_tb
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


module Output_Buffer_tb
    #(parameter datalength = 16, array_dim = 4)
    ();
    
    logic CLK_tb, Reset_tb;
    logic [array_dim-1 : 0][datalength-1 : 0] Result_In_tb;
    logic [array_dim-1 : 0] Result_Valid_In_tb;
    statetype Mode_In_tb;
    logic [array_dim-1 : 0][datalength-1 : 0] Result_Out_tb;
    
    Output_Buffer #(datalength, array_dim) uut(CLK_tb, Reset_tb,
                                              Result_In_tb,
                                              Result_Valid_In_tb,
                                              Mode_In_tb,
                                              Result_Out_tb);

    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
    
    initial
    begin
        
        Reset_tb = 1;
        Result_In_tb <= '0;
        Result_Valid_In_tb <= '0;
        Mode_In_tb <= Idle;
        #20;
        
        Reset_tb = 0;
        Result_In_tb <= '1;
        Result_Valid_In_tb <= '1;
        Mode_In_tb <= Idle;
        #100;
        
        
        Mode_In_tb <= Catch_Outputs;
        
        for (int i = 0; i < array_dim; i++) begin
            for (int j = 0; j < array_dim; j++) begin
                Result_In_tb[j] <= i*array_dim + j + 1;
                Result_Valid_In_tb[j] <= 0;
            end
            #20;
        end
        
//        for (int j = 0; j < array_dim; j++) begin
//            for (int k = 0; k < array_dim; k++) begin
//                Result_In_tb[k] = (k <= j) ? j+k+1 : 0;
//                Result_Valid_In_tb[k] = (k <= j);
//            end
//            #20;
//        end
        
//        for (int i = 0; i < array_dim; i++) begin
//            for (int j = 0; j < array_dim; j++) begin
//                Result_In_tb[j] = i*array_dim + j + 1;
//                Result_Valid_In_tb[j] = 1;
//            end
//            #20;
//        end
        
//        for (int j = 0; j < array_dim; j++) begin
//            for (int k = 0; k < array_dim; k++) begin
//                Result_In_tb[k] = (k >= j) ? j+k+1 : 0;
//                Result_Valid_In_tb[k] = (k >= j);
//            end    
//            #20;
//        end
        
        Result_Valid_In_tb <= '0;
        Mode_In_tb <= Collect_Outputs;
        
    end
    
endmodule
