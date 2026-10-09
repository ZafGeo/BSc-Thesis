`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2025 05:56:03 PM
// Design Name: 
// Module Name: Control_Unit
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

//typedef enum logic[2:0] {Idle, Collect_Inputs, Feed_Inputs, Catch_Outputs, Collect_Outputs, Feed_Outputs, Output_Results} statetype;

module Control_Unit
    #(address_size = 13, array_dim = 16)
    (input logic CLK, Reset,
     input logic [address_size+array_dim+1 : 0] Element_In,
     input logic Element_Valid_In,
     input logic Element_last,
     input logic change_mode,
     input logic unsigned [address_size : 0] tile_num,
     output statetype state,
     output logic unsigned [address_size : 0] Tile_A, Tile_B,
     output logic unsigned [address_size+array_dim : 0] input_dim,
     output logic Element_Out_last, acc_ready);
     
     statetype nextstate;
     logic temp_enable;
     logic [address_size-1 : 0] run_Tile_A, run_Tile_B;
     logic keep_results, first_keep_n;
     
     
     always_ff@(posedge CLK)
     begin
     
        if (!Reset) begin
            state <= Idle;
            input_dim <= 0;
            keep_results <= 1'b0;
            first_keep_n <= 1'b0;
        end
        
        else begin
            
            if (state == Idle) begin
            
                if (Element_Valid_In) begin
                    input_dim <= Element_In[address_size+array_dim : 0];
                    keep_results <= Element_In[address_size+array_dim+1];
                    
                    if (keep_results)
                        first_keep_n <= 1'b1;
                    else
                        first_keep_n <= 1'b0;
                        
                end
                
            end
            
            state <= nextstate;
            
        end
     
     end
     
     always_comb
     begin
        
        Element_Out_last = 0;
        acc_ready = 0;
        
        case (state)
       
            Idle: begin
            
                acc_ready = 1;
                
                if (Element_Valid_In)
                    nextstate = Collect_Inputs;
                else
                    nextstate = Idle;
                    
            end
                
            Collect_Inputs: begin
                
                acc_ready = 1;
                
                if (Element_last)
                    
                    if (first_keep_n)
                        nextstate = Feed_Outputs;
                    else
                        nextstate = Feed_Inputs;
                        
                else
                    nextstate = Collect_Inputs;
                
            end
            
            Feed_Inputs: begin
                
                if (change_mode)
                    nextstate = Catch_Outputs;
                else
                    nextstate = Feed_Inputs;
            end
            
            Catch_Outputs: begin
                
                if (change_mode)
                    nextstate = Collect_Outputs;
                else
                    nextstate = Catch_Outputs;
                     
            end
            
            Collect_Outputs: begin
                
                if (change_mode)
                    
                    if (run_Tile_A == tile_num)
                        
                        if (keep_results)
                            nextstate = Idle;
                        else
                            nextstate = Output_Results;
                            
                    else
                        
                        if (first_keep_n)
                            nextstate = Feed_Outputs;
                        else
                            nextstate = Feed_Inputs;
                        
                else
                     nextstate = Collect_Outputs;
                
            end
            
            Feed_Outputs: begin
                
                if (change_mode)
                    nextstate = Feed_Inputs;
                else
                    nextstate = Feed_Outputs;
                
            end
            
            Output_Results: begin
                
                if (change_mode) begin
                    nextstate = Idle;
                    Element_Out_last = 1;
                end
                
                else
                    nextstate = Output_Results;
                
            end
            
            default:
                nextstate = Idle;
            
        endcase
     end
     
     
     always_ff@(posedge CLK)
     begin
        
        if (!Reset) begin
            Tile_A <= '0;
            Tile_B <= '0;
            temp_enable <= 0;
            run_Tile_A <= '0;
            run_Tile_B <= '0;
        end
        
        else begin
            
            Tile_A <= run_Tile_A;
            Tile_B <= run_Tile_B;
            
            case (state)
                
                Idle: begin
                    run_Tile_A <= 0;
                    run_Tile_B <= 0;
                end
                
                Feed_Inputs:
                    temp_enable <= 1;
                
                Catch_Outputs: begin
                    
                    if (temp_enable) begin
                    
                        temp_enable <= 0;
                    
                        if (run_Tile_B == tile_num - 1) begin
                            run_Tile_A <= run_Tile_A + 1;
                            run_Tile_B <= 0;
                        end
                        
                        else
                            run_Tile_B <= run_Tile_B + 1;
                    
                    end
                        
                end
               
            endcase
                
        end
        
     end
     
endmodule
