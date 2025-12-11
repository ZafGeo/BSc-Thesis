`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 02:31:21 AM
// Design Name: 
// Module Name: Address_Generator_tb
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

module Address_Generator_tb
    #(datalength = 8, array_dim = 8, address_size = 8, input_dim = 32)
    ();
    
    logic CLK_tb, Reset_tb;
    statetype Mode_In_tb;
    logic [datalength-1 : 0] input_dim_tb, tile_num_tb;
    logic Element_Valid_In_tb;
    logic [datalength-1 : 0] Tile_A_tb, Tile_B_tb;
    logic host_ready_tb;
    logic element_last_tb;
    logic [1 : 0][address_size-1 : 0] Address_tb;
    logic WE_IBram_A_tb, WE_IBram_B_tb, WE_OBram_tb;
    logic Enable_IBram_A_tb, Enable_IBram_B_tb, Enable_OBRam_tb;

    int tile_num = input_dim/array_dim;
    
    
    Address_Generator #(datalength, array_dim, address_size) uut(CLK_tb, Reset_tb,
                                                                 Mode_In_tb,
                                                                 input_dim_tb, tile_num_tb,
                                                                 Element_Valid_In_tb,
                                                                 Tile_A_tb, Tile_B_tb,
                                                                 host_ready_tb,
                                                                 element_last_tb,
                                                                 Address_tb,
                                                                 WE_IBram_A_tb, WE_IBram_B_tb, WE_OBram_tb,
                                                                 Enable_IBram_A_tb, Enable_IBram_B_tb, Enable_OBRam_tb);
                                                                 
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
        
        Reset_tb = 1;
        Mode_In_tb <= Idle;
        input_dim_tb <= 0;
        tile_num_tb <= 0;
        Element_Valid_In_tb <= 0;
        Tile_A_tb <= 0;
        Tile_B_tb <= 0;
        host_ready_tb <= 0;
        #20;
        
        Reset_tb = 0;
        #20;        
        
        // Collect_Inputs
        Mode_In_tb <= Collect_Inputs;
        input_dim_tb <= input_dim;
        tile_num_tb <= tile_num;
        host_ready_tb <= 1;
        #20;
        
        Element_Valid_In_tb <= 1;
        #(2 * (input_dim**2) * 20);
        
        Element_Valid_In_tb <= 0;
        
        for (int i = 0; i < tile_num + 1; i++)
            for (int j = 0; j < tile_num; j++) begin
                
                if (i == 0 && j == 0)
                    continue;
                
                if (i == tile_num && j == 1)
                    break;
                    
                // Feed_Inputs
                Mode_In_tb <= Feed_Inputs;
                #(20 * (input_dim+1));
                
                // Catch_Outputs
                Mode_In_tb <= Catch_Outputs;
                Tile_A_tb <= i;
                Tile_B_tb <= j;
                #((3*array_dim + 1) * 20);
                
                // Collect_Outputs
                Mode_In_tb <= Collect_Outputs;
                #((array_dim + 1) * 20);
        
        end
        
        Mode_In_tb <= Output_Results;
        #(input_dim**2 * 20);
        
        Mode_In_tb <= Idle;
        
    end
    
endmodule
