`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2025 01:41:26 AM
// Design Name: 
// Module Name: Sys_Array_test
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


module Sys_Array_test
    #(parameter input_datalength = 8, output_datalength = 32, array_dim = 16, address_size = 13)
    (input logic CLK, mem_Reset, Reset,
     input logic[7 : 0] Switches,
     output logic[7 : 0] LEDS
//     output logic acc_ready
    );
    
    wire [31 : 0] Element_ROM;
    wire [output_datalength-1 : 0] Element_acc, Element_RAM;
    wire Element_V_ROM, Element_l_ROM, Element_V_acc, Element_l_acc, acc_ready_in;
    
    Test_ROM #(8) ROM_component(.CLK(CLK), .Reset(mem_Reset),
                                               .Element_Out(Element_ROM),
                                               .Element_Valid_Out(Element_V_ROM),
                                               .Element_last(Element_l_ROM));
    
    
    Accelerator #(input_datalength, output_datalength, array_dim, address_size, 32) acc_component(.CLK(CLK), .Reset(Reset),
                                                                                              .Element_In(Element_ROM),
                                                                                              .Element_Valid_In(Element_V_ROM),
                                                                                              .Element_In_last(Element_l_ROM),
                                                                                              .host_ready(1'b1),
                                                                                              .Element_Out(Element_acc),
                                                                                              .Element_Valid_Out(Element_V_acc),
                                                                                              .Element_Out_last(Element_l_acc),
                                                                                              .acc_ready(acc_ready_in));
    
    
    Test_RAM #(output_datalength, address_size) RAM_component(.CLK(CLK), .Reset(mem_Reset),
                                                              .Element_In(Element_acc),
                                                              .Element_Valid_In(Element_V_acc),
                                                              .Element_last(Element_l_acc),
                                                              .Address(Switches),
                                                              .Element_Out(Element_RAM));
    
    
    assign LEDS = Element_RAM;
//    assign acc_ready = acc_ready_in;
    
endmodule
