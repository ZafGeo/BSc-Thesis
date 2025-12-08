`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2025 06:00:17 PM
// Design Name: 
// Module Name: test
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

typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs} statetype;

module test
    #(array_dim= 16, address_size = 6)
    (input logic CLK, Reset,
     input statetype Mode_In,
     input logic [address_size-1 : 0] input_dim,
     input logic Element_Valid_In,
     input logic [address_size-1 : 0] Tile_A, Tile_B,
     output logic element_last,
     output logic [2*array_dim-1 : 0][address_size-1 : 0] Address,
     output logic WE_IBram_A, WE_IBram_B, WE_OBram
    );
    
    logic [2*array_dim-1 : 0][address_size-1 : 0] temp_Address = 0;
    int run_row_index = 0, run_column_index = 0;
    logic BRAM_A_B = 0;
    int index_A = 0, index_B = 0, index_output = 0;
    int run_index_A = 0, run_index_B = 0, run_index_output = 0;
    
    
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
        end
        
        else begin
            
            case (Mode_In)
                
                Idle:
                    temp_Address <= '0;
                
                Collect_Inputs: begin
                    
                    if (Element_Valid_In) begin
                        
                        temp_Address[0] <= temp_Address[0] + 1;
                        
                        if (run_column_index == input_dim - 1) begin
                            
                            run_column_index <= 0;
                            
                            if (run_row_index == input_dim - 1) begin
                                run_row_index <= 0;
                                temp_Address[0] <= 0;
                            end
                            
                            else
                                run_row_index <= run_row_index + 1;
                            
                        end
                        
                        else
                            run_column_index <= run_column_index + 1;
                    
                    end
                    
                    run_index_A <= index_A;
                    run_index_B <= index_B;
                    run_index_output <= index_output;
                    
                end
                
                Feed_Inputs: begin
                    
                    for (int i = 0; i < array_dim; i++) begin
                        temp_Address[i] <= run_index_A + i;
                        temp_Address[i+array_dim] <= run_index_B + i;
                    end
                    
                    run_index_A <= run_index_A + input_dim;
                    run_index_B <= run_index_B + input_dim;
                    
                    if (run_column_index == array_dim - 1)
                        run_column_index <= 0;
                    else
                        run_column_index <= run_column_index + 1;
                    
                end
                
                Catch_Outputs:
                    
                    if (run_column_index == array_dim - 1) begin
                        
                        run_column_index <= 0;
                        
                        for (int i = 0; i < array_dim; i++) begin
                            temp_Address[i] <= run_index_output + i;
                            temp_Address[i+array_dim] <= run_index_output + i + input_dim;
                        end
                        
                        
                        
                    end
                    
                    else
                        run_column_index <= run_column_index + 1;
                    
                Collect_Outputs: begin
                
                    for (int i = 0; i < array_dim; i++) begin
                        temp_Address[i] <= run_index_output + i;
                        temp_Address[i+array_dim] <= run_index_output + i + input_dim;
                    end
                    
                    run_index_output <= run_index_output + (input_dim << 1);
                    
                    if (run_column_index == array_dim - 1)
                        run_column_index <= 0;
                    else
                        run_column_index <= run_column_index + 2;
                        
                end
                
            endcase
            
        end
        
    end
    
    always@(Tile_A, Tile_B, input_dim)
    begin
        index_A = Tile_A << $clog2(array_dim);
        index_B = Tile_B << $clog2(array_dim);
        index_output = (index_A * input_dim) + index_B;
    end
    
    always_comb
    begin
        
        WE_IBram_A = 0;
        WE_IBram_B = 0;
        WE_OBram = 0;
        element_last = 0;
        
        case (Mode_In)
            
            Collect_Inputs: begin
                
                if (Element_Valid_In)
                
                    if (BRAM_A_B)
                        WE_IBram_B = 1;
                    else
                        WE_IBram_A = 1;
                    
            end
            
            Feed_Inputs || Catch_Outputs:
                
                if (run_column_index == array_dim - 1)
                    element_last = 1;
                    
            Collect_Outputs:
                
                if (run_column_index == array_dim - 1)
                    element_last = 1;
            
        endcase
        
    end
    
endmodule
