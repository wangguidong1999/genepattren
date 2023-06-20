`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:26:48
// Design Name: 
// Module Name: pointer_pattern
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


module pointer_pattern#(parameter window = 500)
(current_trace_addr, recent_trace_value,enable,clk,reset,pointer_confidence_in,pointer_confidence_out);
    input wire [63:0] current_trace_addr;
    input wire [63:0] recent_trace_value;//这里要传进的是一系列recent_trace_value
    input wire enable;
    input wire clk;
    input wire reset;
    
    input wire [15:0] pointer_confidence_in; //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] pointer_confidence_out; //[9:0] confidence,  [15] true, [14] false
    
    reg [1:0] state;
    reg [8:0] count_window;
    always@(posedge clk)
    begin
        if (reset)
        begin
            state <= 2'b00;
            count_window <= 0;
        end
        case(state)
            2'b00://比对window条recent_trace_value
            begin
                if (current_trace_addr == recent_trace_value)
                begin
                    pointer_confidence_out  <= pointer_confidence_in + 1'b1;
                    if (pointer_confidence_out [9] == 1'b1)//threshhold>=512, 9bit
                        begin
                            pointer_confidence_out[15] <= 1'b1;
                            pointer_confidence_out[14] <= 1'b0;
                        end
                end
                count_window <= count_window + 1;
                if (count_window == window)
                begin
                    state <= 2'b01;
                end
            end
            2'b01:
            begin
                if (pointer_confidence_in[8:0] > 9'd3)
                begin
                    pointer_confidence_out [8:0] <= pointer_confidence_in [8:0] >> 1 ;
                end
                if (pointer_confidence_in[8:0] <= 9'd3)
                begin
                    pointer_confidence_out[14] <= 1'b1;
                    pointer_confidence_out[15] <= 1'b0;
                end
                state <= 2'b10;
            end
        endcase
    end
    
endmodule
