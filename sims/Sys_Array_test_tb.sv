`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2025 01:58:21 AM
// Design Name: 
// Module Name: Sys_Array_test_tb
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


module Sys_Array_test_tb
    #(parameter input_datalength = 8, output_datalength = 32, array_dim = 4, address_size = 6)
    ();
    
    logic CLK_tb , Reset_tb;
    logic[7 : 0] Switches_tb, LEDS_tb;
    int fd;
    string str;
    int res;
    logic[7 : 0] run_index = 0;
        
    Sys_Array_test #(input_datalength, output_datalength, array_dim, address_size) uut(CLK_tb, Reset_tb, Switches_tb, LEDS_tb);
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
    
    assign Switches_tb = run_index;
    
    initial
    begin
    
        // Initializing Systolic Array
        run_index = 0;
        Reset_tb = 1; #20;
        
        Reset_tb = 0;
//        #6000;
        
//        fd = $fopen("/home/saphi/Desktop/Output Stationary/systolic_array/output.csv", "r");
//        for (int i = 0; i < 8; i++) begin
//            for (int i = 0; i < 7; i++) begin
//                $fscanf(fd, "%d, ", res);
                
//                if (res != LEDS_tb) begin
//                    $display("Results are not valid!");
//                    $display("Expected result: %d, output: %d.", res, LEDS_tb);
//                end
                
//                run_index = run_index + 1;
//                #20;
                
//            end
            
//            $fscanf(fd, "%d", res);
                
//            if (res != LEDS_tb) begin
//                $display("Results are not valid!");
//                $display("Expected result: %d, output: %d.", res, LEDS_tb);
//            end
            
//            run_index = run_index + 1;
//            #20;
                         
//        end
        
//        $fclose(fd);
//        $display("Testing Complete");
        
    end
    
    
endmodule
