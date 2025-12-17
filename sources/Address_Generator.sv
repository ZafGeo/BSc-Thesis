`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 02:51:36 PM
// Design Name: 
// Module Name: Address_Generator
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

module Address_Generator
    #(datalength = 16, array_dim = 16, address_size = 6)
    (input logic CLK, Reset,
     input statetype Mode_In,
     input logic [datalength-1 : 0] input_dim, tile_num,
     input logic Element_Valid_In,
     input logic [datalength-1 : 0] Tile_A, Tile_B,
     input logic host_ready,
     output logic element_last,
     output logic [1 : 0][address_size-1 : 0] Address,
     output logic WE_IBram_A, WE_IBram_B, WE_OBram,
     output logic Enable_IBram_A, Enable_IBram_B, Enable_OBram
    );
    
    logic [1 : 0][address_size-1 : 0] temp_Address = '0;
    int run_row_index = 0, run_column_index = 0;
    logic BRAM_A_B = 0;
    int index_output = 0;
    int run_index_A = 0, run_index_B = 0, run_index_output = 0;
    int BRAM_I_counter = 0;
    
    
    assign Address = Reset ? '0 : temp_Address;
    
    always_ff@(posedge CLK)
    begin
    
        if (Reset) begin
            temp_Address <= '0;
            run_row_index <= 0;
            run_column_index <= 0;
            BRAM_A_B <= 0;
            run_index_A <= 0;
            run_index_B <= 0;
            run_index_output <= 0;
            BRAM_I_counter <= 0;
        end
        
        else begin
            
            case (Mode_In)
                
                Idle: begin
                    temp_Address <= '0;
                    run_index_A <= 0;
                    run_index_B <= 0;
                    BRAM_A_B <= 0;
                end
                
                Collect_Inputs: begin
                    
                    if (Element_Valid_In) begin
                        
                        if (BRAM_I_counter == array_dim - 1) begin
                            BRAM_I_counter <= 0;
                            temp_Address[0] <= temp_Address[0] + 1;
                            temp_Address[1] <= temp_Address[1] + 1;
                        end
                        
                        else
                            BRAM_I_counter <= BRAM_I_counter + 1;
                        
                        if (run_column_index == input_dim - 1) begin
                            
                            run_column_index <= 0;
                            
                            if (run_row_index == input_dim - 1) begin
                                run_row_index <= 0;
                                temp_Address[0] <= 0;
                                temp_Address[1] <= 0;
                                BRAM_A_B <= 1;
                            end
                            
                            else
                                run_row_index <= run_row_index + 1;
                            
                        end
                        
                        else
                            run_column_index <= run_column_index + 1;
                    
                    end

                end
                
                Feed_Inputs: begin
                    
                    temp_Address[0] <= run_index_A;
                    temp_Address[1] <= run_index_B;
                    
                    run_index_A <= run_index_A + tile_num;
                    run_index_B <= run_index_B + tile_num;
                    
                    if (run_column_index == input_dim)
                        run_column_index <= 0;
                    else
                        run_column_index <= run_column_index + 1;
                    
                    run_index_output <= index_output;
                    
                end
                
                Catch_Outputs:
                    
                    if (run_column_index == 3*array_dim + 1)
                        run_column_index <= 0;
                    
                    else
                        run_column_index <= run_column_index + 1;
                    
                Collect_Outputs: begin
                
                    temp_Address[0] <= run_index_output;
                    
                    run_index_output <= run_index_output + tile_num;

                    if (run_row_index == array_dim) begin
                        run_row_index <= 0;
                        temp_Address[0] <= '0;
                    end
                    
                    else
                        run_row_index <= run_row_index + 1;

                    run_index_A <= Tile_A;
                    run_index_B <= Tile_B;
                        
                end
                
                Output_Results: begin
                    
                    if (host_ready) begin
                        
                        if (BRAM_I_counter == array_dim - 1) begin
                            BRAM_I_counter <= 0;
                            temp_Address[0] <= temp_Address[0] + 1;
                        end

                        else
                            BRAM_I_counter <= BRAM_I_counter + 1;

                        if (run_column_index == input_dim - 1) begin
                            
                            run_column_index <= 0;
                            
                            if (run_row_index == input_dim - 1)
                                run_row_index <= 0;
                            else
                                run_row_index <= run_row_index + 1;
                            
                        end
                        
                        else
                            run_column_index <= run_column_index + 1;
                    
                    end
                    
                end
                
            endcase
            
        end
        
    end
    
    // Output element index (BRAM Address) Calculation
    always@(Tile_A, Tile_B, input_dim)
        index_output = (Tile_A * input_dim) + Tile_B; // array_dim * tile_num = input_dim
    
    // BRAM Control Signals (BRAM_Enable/Write) Toggle
    always_comb
    begin
        
        WE_IBram_A = 1'b0;
        WE_IBram_B = 1'b0;
        WE_OBram = 1'b0;
        
        Enable_IBram_A = 1'b0;
        Enable_IBram_B = 1'b0;
        Enable_OBram = 1'b0;
        
        element_last = 1'b0;
        
        case (Mode_In)
            
            Collect_Inputs: begin
                
                if (Element_Valid_In)
                
                    if (BRAM_A_B) begin
                        WE_IBram_B = 1'b1;
                        Enable_IBram_B = 1'b1;
                    end
                    
                    else begin
                        WE_IBram_A = 1'b1;
                        Enable_IBram_A = 1'b1;
                    end
                    
            end
            
            Feed_Inputs: begin
                
                if (run_column_index == input_dim)
                    element_last = 1'b1;
                
                Enable_IBram_A = 1'b1;
                Enable_IBram_B = 1'b1;
                
            end
            
            Catch_Outputs:
            
                if (run_column_index == 3*array_dim + 1)
                    element_last = 1'b1;
                    
            Collect_Outputs: begin
                
                if (run_row_index == array_dim)
                    element_last = 1'b1;
                    
                WE_OBram = 1'b1;
                Enable_OBram = 1'b1;
                
            end
            
            Output_Results: begin
            
                if (run_row_index == input_dim - 1 && run_column_index == input_dim - 1)
                    element_last = 1'b1;
                
                Enable_OBram = 1'b1;
            
            end
            
        endcase
        
    end
    
endmodule
