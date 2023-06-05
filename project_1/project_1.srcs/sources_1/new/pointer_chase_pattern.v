`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 15:46:30
// Design Name: 
// Module Name: random_pattern
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


module pointer_chase_pattern(
    input [63:0] last_same_PC_value,
    input [63:0] current_trace_addr,
    input [63:0] offset,
    input enable,
    input clk,
    
    input [15:0] pointer_chase_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] pointer_chase_confidence_out, //[9:0] confidence,  [15] true, [14] false
    output reg [63:0] new_offset
    );
    
    always@(posedge clk)
    begin
        if (current_trace_addr == (last_same_PC_value + offset))
        begin
            pointer_chase_confidence_out  <= pointer_chase_confidence_in + 1'b1;
            new_offset <= offset;
            if (pointer_chase_confidence_out [9] == 1'b1 )//threshhold>=512, 9bit
                begin
                    pointer_chase_confidence_out[15] <= 1'b1;
                    pointer_chase_confidence_out[14] <= 1'b0;
                end
        end
        
        else begin
            if (pointer_chase_confidence_out [8:0] > 9'd3)
            begin
                pointer_chase_confidence_out [8:0] <= pointer_chase_confidence_in [8:0] >> 1 ;
            end
            
            if (pointer_chase_confidence_out [8:0] <= 9'd3)
            begin
                pointer_chase_confidence_out[14] <= 1'b1;
                pointer_chase_confidence_out[15] <= 1'b0;
            end
        end
    end
    
endmodule