`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2025 03:54:23 PM
// Design Name: 
// Module Name: Accelerator
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

typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Output_Results} statetype;

module Accelerator
    #(parameter datalength = 16, array_dim = 8, address_size = 6)
    (input logic CLK, Reset,
     input logic [datalength-1 : 0] Element_In,
     input logic Element_Valid_In, Element_In_last, host_ready,
     output logic [datalength-1 : 0] Element_Out,
     output logic Element_Valid_Out, Element_Out_last, acc_ready
    );
    
    statetype mode_CU, mode_reg_1, mode_reg_2, mode_reg_3;
    wire Element_V_CU, Element_V_reg_1, Element_V_reg_2;
    wire Element_l_CU, Element_l_reg;
    wire [datalength-1 : 0] tile_A, tile_B, input_dim_in;
    wire last_AG, acc_ready_in;
    wire [2*array_dim-1 : 0][address_size-1 : 0] address_AG;
    wire WE_IB_A_in, WE_IB_B_in, WE_OB_in;
    wire Enable_IBram_A_in, Enable_IBram_B_in, Enable_OBram_in;
    wire [array_dim-1 : 0][datalength-1 : 0] Element_IBram_A, Element_IBram_B;
    wire [array_dim-1 : 0][datalength-1 : 0] Element_IBuf_A, Element_IBuf_B;
    wire [array_dim-1 : 0] IBuf_V_A, IBuf_V_B;
    wire [array_dim-1 : 0][datalength-1 : 0] res_SA;
    wire [array_dim-1 : 0] valid_SA;
    wire [datalength-1 : 0] res_OBuf;
    wire [datalength-1 : 0] res_OBram;
    
    Control_Unit #(datalength, address_size, array_dim) CU_component(.CLK(CLK), .Reset(Reset),
                                                                     .Element_In(Element_In),
                                                                     .Element_Valid_In(Element_Valid_In),
                                                                     .Element_last(Element_In_last),
                                                                     .change_mode(last_AG),
                                                                     .Mode_Out(mode_CU),
                                                                     .Tile_A(tile_A), .Tile_B(tile_B),
                                                                     .input_dim(input_dim_in),
                                                                     .Element_Valid_Out(Element_V_CU),
                                                                     .Element_Out_last(Element_l_CU),
                                                                     .acc_ready(acc_ready_in)); 
    
    
    statetype_register Mode_reg_1(.CLK(CLK), .Reset(Reset),
                                  .WE(1'b1),
                                  .d(mode_CU),
                                  .q(mode_reg_1));
    
    
    Register #(1'b1) element_valid_reg_1(.CLK(CLK), .Reset(Reset),
                                       .WE(1'b1),
                                       .d(Element_V_CU),
                                       .q(Element_V_reg_1));
    
    
    Register #(1'b1) element_last_reg(.CLK(CLK), .Reset(Reset),
                                      .WE(1'b1),
                                      .d(Element_l_CU),
                                      .q(Element_l_reg));
    
    
    Address_Generator #(datalength, array_dim, address_size) AG_component(.CLK(CLK), .Reset(Reset),
                                                              .Mode_In(mode_CU),
                                                              .input_dim(input_dim_in),
                                                              .Element_Valid_In(Element_Valid_In),
                                                              .Tile_A(tile_A), .Tile_B(tile_B),
                                                              .host_ready(host_ready),
                                                              .element_last(last_AG),
                                                              .Address(address_AG),
                                                              .WE_IBram_A(WE_IB_A_in), 
                                                              .WE_IBram_B(WE_IB_B_in),
                                                              .WE_OBram(WE_OB_in),
                                                              .Enable_IBram_A(Enable_IBram_A_in),
                                                              .Enable_IBram_B(Enable_IBram_B_in),
                                                              .Enable_OBRam(Enable_OBram_in));
    
    
    BRAM #(datalength, address_size, array_dim) BRAM_A_component(.CLK(CLK),
                                                                 .Address(address_AG[array_dim-1 : 0]),
                                                                 .Element_In(Element_In),
                                                                 .WE(WE_IB_A_in),
                                                                 .Enable(Enable_IBram_A_in),
                                                                 .Elements_Out(Element_IBram_A));
    
    
    BRAM #(datalength, address_size, array_dim) BRAM_B_component(.CLK(CLK),
                                                                  .Address(address_AG[2*array_dim-1 : array_dim]),
                                                                  .Element_In(Element_In),
                                                                  .WE(WE_IB_B_in),
                                                                  .Enable(Enable_IBram_B_in),
                                                                  .Elements_Out(Element_IBram_B));
    
    
    Input_Buffer #(datalength, array_dim) IBuf_A_component(.CLK(CLK), .Reset(Reset),
                                                         .Element_In(Element_IBram_A),
                                                         .Mode_In(mode_reg_1),
                                                         .Out(Element_IBuf_A),
                                                         .Out_Valid(IBuf_V_A));
    
    
    Input_Buffer #(datalength, array_dim) IBuf_B_component(.CLK(CLK), .Reset(Reset),
                                                         .Element_In(Element_IBram_B),
                                                         .Mode_In(mode_reg_1),
                                                         .Out(Element_IBuf_B),
                                                         .Out_Valid(IBuf_V_B));
    
    
    Systolic_Array #(datalength, array_dim, array_dim) SA_component(.CLK(CLK), .Reset(Reset),
                                                                   .A_In(Element_IBuf_A),
                                                                   .B_In(Element_IBuf_B),
                                                                   .Input_Valid_A(IBuf_V_A),
                                                                   .Input_Valid_B(IBuf_V_B),
                                                                   .Mode_In(mode_CU),
                                                                   .A_Out(res_SA),
                                                                   .Output_Valid_A(valid_SA));
    
    
    Output_Buffer #(datalength, array_dim) OBuf_component(.CLK(CLK), .Reset(Reset),
                                                        .Result_In(res_SA),
                                                        .Result_Valid_In(valid_SA),
                                                        .Mode_In(mode_CU),
                                                        .Result_Out(res_OBuf));
    
    
    BRAM #(datalength, address_size, 1'b1) BRAM_Out_component(.CLK(CLK),
                                                              .Address(address_AG[0]),
                                                              .Element_In(res_OBuf),
                                                              .WE(WE_OB_in),
                                                              .Enable(Enable_OBram_in),
                                                              .Elements_Out(res_OBram));
    
   
   assign Element_Out = res_OBram;
   assign Element_Valid_Out = Element_V_reg_1;
   assign Element_Out_last = Element_l_reg; 
   assign acc_ready = acc_ready_in;
    
endmodule
