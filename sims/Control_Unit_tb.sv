`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 02:14:49 PM
// Design Name: 
// Module Name: Control_Unit_tb
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


module Control_Unit_tb
    #(datalength = 16, address_size = 9, array_dim = 4, input_size = 9)
    ();
    
    logic CLK_tb, Reset_tb;
    logic [datalength-1 : 0] Element_In_tb;
    logic Element_Valid_In_tb;
    logic Element_last_tb;
    logic change_mode_tb;
    statetype Mode_Out_tb;
    logic [address_size-1 : 0] Tile_A_tb, Tile_B_tb;
    logic[address_size-1 : 0] input_dim_tb;
    
    
    Control_Unit #(datalength, address_size, array_dim) uut(CLK_tb, Reset_tb,
                                                            Element_In_tb,
                                                            Element_Valid_In_tb,
                                                            Element_last_tb,
                                                            change_mode_tb,
                                                            Mode_Out_tb,
                                                            Tile_A_tb, Tile_B_tb,
                                                            input_dim_tb);
    
    
    // Clock Production
    always
    begin
        CLK_tb = 1; #10;
        CLK_tb = 0; #10;
    end
        
    initial
    begin
        
        // Initial Reset
        Reset_tb = 1;
        Element_In_tb <= '0;   
        Element_Valid_In_tb <= 0;
        change_mode_tb <= 0;
        Element_last_tb <= 0;
        #20;
        
        // Idle
        Reset_tb = 0;
        #40;
        
        Element_In_tb <= input_size;   
        Element_Valid_In_tb <= 1;
        change_mode_tb <= 0;
        #20;
        
        // Collecting Inputs
        for (int i = 0; i < 9; i++) begin
            Element_In_tb <= i+1;
            #20;
        end
        
        Element_In_tb <= 10;
        Element_last_tb <= 1;
        #20;
        
        Element_last_tb <= 0;
        
        for (int i = 0; i < 9; i++)
        begin
        
            // Feeding Inputs
            change_mode_tb <= 0;
            Element_In_tb <= input_size;   
            Element_Valid_In_tb <= 0;
            #200;
            
            change_mode_tb <= 1;
            #20;
            
            // Catching Outputs
            change_mode_tb <= 0;
            #200;
            
            change_mode_tb <= 1;
            #20;
            
            // Collecting Outputs
            change_mode_tb <= 0;
            #200;
            
            change_mode_tb <= 1;
            #20;
            
        end
        
        change_mode_tb <= 0;
        
    end
    
endmodule
