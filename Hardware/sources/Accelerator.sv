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

typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Feed_Outputs, Output_Results} statetype;

module Accelerator
    #(parameter input_datalength = 8, output_datalength = 32, array_dim = 16, address_size = 13, data_width = 32)
    (input logic CLK, Reset,
     input logic [data_width-1 : 0] Element_In,
     input logic Element_Valid_In, Element_In_last, host_ready,
     output logic [data_width-1 : 0] Element_Out,
     output logic Element_Valid_Out, Element_Out_last, acc_ready
    );
    
    statetype mode_CU, mode_reg_1, mode_reg_2;
    wire Element_l_CU, Element_l_reg_1;
    wire [address_size : 0] tile_A, tile_B, tile_num_in;
    wire [address_size+array_dim : 0] input_dim_in;
    wire last_AG, last_OB, acc_ready_in;
    wire [1 : 0][address_size-1 : 0] address_AG, address_reg;
    wire WE_IBram_in, WE_OBram_in;
    wire Enable_IBram_in, Enable_OBram_in;
    wire enable_IBram_reg, enable_OBram_reg;
    wire Valid_I_O_In, Valid_I_O_O_In, valid_I_O_O_In_reg_1;
    wire [array_dim-1 : 0][input_datalength-1 : 0] Element_IBram_I_O_In;
    wire [1 : 0][array_dim-1 : 0][input_datalength-1 : 0] Element_IBram;
    wire [array_dim-1 : 0][input_datalength-1 : 0] Element_IBuf_A, Element_IBuf_B;
    wire [array_dim-1 : 0] IBuf_V_A, IBuf_V_B;
    wire [array_dim-1 : 0][output_datalength-1 : 0] res_SA;
    wire [array_dim-1 : 0] valid_SA;
    wire [array_dim-1 : 0][output_datalength-1 : 0] res_OBuf;
    wire [array_dim-1 : 0][output_datalength-1 : 0] res_OBram;
    wire [output_datalength-1 : 0] res_OBram_I_O;
    wire Valid_I_O_Out;
    
    localparam elements_per_cycle = data_width / input_datalength;
    
    // Control Unit
    Control_Unit #(address_size, array_dim) CU_component(.CLK(CLK), .Reset(Reset),
                                                         .Element_In({Element_In[data_width-1], Element_In[address_size+array_dim : 0]}),
                                                         .Element_Valid_In(Element_Valid_In),
                                                         .Element_last(Element_In_last),
                                                         .change_mode(last_AG || last_OB),
                                                         .tile_num(tile_num_in),
                                                         .state(mode_CU),
                                                         .Tile_A(tile_A), .Tile_B(tile_B),
                                                         .input_dim(input_dim_in),
                                                         .Element_Out_last(Element_l_CU),
                                                         .acc_ready(acc_ready_in)); 
    //
    
    
    // Signal delay registers for synchronization
        
        // state register for Input Buffers
    statetype_register Mode_reg_1(.CLK(CLK), .Reset(Reset),
                                  .WE(1'b1),
                                  .d(mode_CU),
                                  .q(mode_reg_1));
    
    
    statetype_register Mode_reg_2(.CLK(CLK), .Reset(Reset),
                                  .WE(1'b1),
                                  .d(mode_reg_1),
                                  .q(mode_reg_2));
        //
    
    
        // last element signal register for accelerator output
    Register #(32'd1) element_last_reg_1(.CLK(CLK), .Reset(Reset),
                                         .WE(1'b1),
                                         .d(Element_l_CU),
                                         .q(Element_l_reg_1));
        //
    
    
    // Address Generator
    Address_Generator #(array_dim, address_size, elements_per_cycle) AG_component(.CLK(CLK), .Reset(Reset),
                                                                                  .Mode_In(mode_CU),
                                                                                  .input_dim(input_dim_in),
                                                                                  .Element_Valid_In(Element_Valid_In),
                                                                                  .Tile_A(tile_A), .Tile_B(tile_B),
                                                                                  .host_ready(host_ready),
                                                                                  .element_last(last_AG),
                                                                                  .Address(address_AG),
                                                                                  .WE_IBram(WE_IBram_in), 
                                                                                  .WE_OBram(WE_OBram_in),
                                                                                  .Enable_IBram(Enable_IBram_in),
                                                                                  .Enable_OBram(Enable_OBram_in),
                                                                                  .Valid_OBram_I_O(Valid_I_O_O_In),
                                                                                  .tile_num(tile_num_in));
    //
    
    
    // Address delay register
    Register #(2*address_size) Address_reg(.CLK(CLK), .Reset(Reset),
                                                        .WE(1'b1),
                                                        .d(address_AG),
                                                        .q(address_reg));
    //
    
    
    // Input Block RAM
        // Input Bunching
    BRAM_I_O #(input_datalength, elements_per_cycle, array_dim) BRAM_I_O_In(.CLK(CLK), .Reset(Reset),
                                                                            .Elements_In(Element_In),
                                                                            .Enable(1'b1),
                                                                            .Valid_In(WE_IBram_in),
                                                                            .Elements_Out(Element_IBram_I_O_In),
                                                                            .Valid_Out(Valid_I_O_In));
        //
   
   
        // enable signal delay register
    Register #(32'd1) Enable_IBram_reg(.CLK(CLK), .Reset(Reset),
                                        .WE(1'b1),
                                        .d(Enable_IBram_in),
                                        .q(enable_IBram_reg));
        //                   
    
    
        // BRAM instance
    BRAM #(input_datalength, address_size, array_dim, 32'd2) BRAM_In_component(.CLK(CLK),
                                                                            .Address(address_reg),
                                                                            .Element_In(Element_IBram_I_O_In),
                                                                            .WE(Valid_I_O_In),
                                                                            .Enable(enable_IBram_reg),
                                                                            .Elements_Out(Element_IBram));
        //
    //
    
    
    // Input Buffer A
    Input_Buffer #(input_datalength, array_dim) IBuf_A_component(.CLK(CLK), .Reset(Reset),
                                                         .Element_In(Element_IBram[0]),
                                                         .Mode_In(mode_reg_2),
                                                         .Out(Element_IBuf_A),
                                                         .Out_Valid(IBuf_V_A));
    //
    
    
    // Input Buffer B
    Input_Buffer #(input_datalength, array_dim) IBuf_B_component(.CLK(CLK), .Reset(Reset),
                                                         .Element_In(Element_IBram[1]),
                                                         .Mode_In(mode_reg_2),
                                                         .Out(Element_IBuf_B),
                                                         .Out_Valid(IBuf_V_B));
    //
    
    
    // Systolic Array
    Systolic_Array #(input_datalength, output_datalength, array_dim) SA_component(.CLK(CLK), .Reset(Reset),
                                                                                  .A_In(Element_IBuf_A),
                                                                                  .B_In(Element_IBuf_B),
                                                                                  .Input_Valid_A(IBuf_V_A),
                                                                                  .Mode_In(mode_reg_1),
                                                                                  .Results_In(res_OBram),
                                                                                  .Output_Valid_A(valid_SA),
                                                                                  .Results_Out(res_SA));
    //
    
    
    // Output Buffer
    Output_Buffer #(output_datalength, array_dim) OBuf_component(.CLK(CLK), .Reset(Reset),
                                                        .Result_In(res_SA),
                                                        .Result_Valid_In(valid_SA[array_dim-1 : array_dim-2]),
                                                        .Mode_In(mode_CU),
                                                        .Result_Out(res_OBuf),
                                                        .element_last(last_OB));
    //
    
    
    // Output Block RAM
    
    
        // enable signal delay register
    Register #(32'd1) Enable_OBram_reg(.CLK(CLK), .Reset(Reset),
                                       .WE(1'b1),
                                       .d(Enable_OBram_in),
                                       .q(enable_OBram_reg));
        //
        
        
        // BRAM instance
    BRAM #(output_datalength, address_size-1, array_dim, 32'd1) BRAM_Out_component(.CLK(CLK),
                                                                                .Address(address_AG[0][address_size-2 : 0]),
                                                                                .Element_In(res_OBuf),
                                                                                .WE(WE_OBram_in),
                                                                                .Enable(enable_OBram_reg),
                                                                                .Elements_Out(res_OBram));
        //
        
        
        // BRAM_I_O valid signal delay register
    Register #(32'd1) Valid_I_O_O_In_reg_1(.CLK(CLK), .Reset(Reset),
                                       .WE(1'b1),
                                       .d(Valid_I_O_O_In),
                                       .q(valid_I_O_O_In_reg_1));
        //
        
    
        // Output de-bunching
    BRAM_I_O #(output_datalength, array_dim, 32'd1) BRAM_I_O_O(.CLK(CLK), .Reset(Reset),
                                                               .Elements_In(res_OBram),
                                                               .Enable(1'b1),
                                                               .Valid_In(valid_I_O_O_In_reg_1 && host_ready),
                                                               .Elements_Out(res_OBram_I_O),
                                                               .Valid_Out(Valid_I_O_Out));
        //
   //                                                             
   
   
   // Accelerator output signals                                                           
   assign Element_Out = res_OBram_I_O;
   assign Element_Valid_Out = valid_I_O_O_In_reg_1 && host_ready;
   assign Element_Out_last = Element_l_reg_1 && host_ready; 
   assign acc_ready = acc_ready_in;
   //
   
endmodule
