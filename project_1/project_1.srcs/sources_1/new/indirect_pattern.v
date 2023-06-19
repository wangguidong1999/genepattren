`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 15:48:16
// Design Name: 
// Module Name: indirect_pattern
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


module indirect_pattern#(parameter window = 500)
(current_trace_addr,last_trace_addr,recent_trace_value,recent_last_trace_value,enable,clk,reset,indirect_confidence_in,indirect_confidence_out,finish);
    input [63:0] current_trace_addr;
    input [63:0] last_trace_addr;//store the last trace of every PC, last_trace_addr is the last trace address of the same PC 
    input [63:0] recent_trace_value;//history_trace_is_stride1
    input [63:0] recent_last_trace_value;//history_trace_is_stride2
    input enable;
    input clk;
    input reset;
    input [15:0] indirect_confidence_in; //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] indirect_confidence_out; //[9:0] confidence,  [15] true, [14] false
    output reg finish;
    
    reg [1:0]state;
    reg [8:0]window_count;
    
    always@(posedge clk)
    begin
        if (reset)
        begin
            state <= 2'b00;
            window_count <= 0;
            finish <= 0;
            indirect_confidence_out <= 0;
        end
        case(state)
        2'b00:
        begin
            if (current_trace_addr - last_trace_addr == recent_trace_value - recent_last_trace_value ||
            current_trace_addr - last_trace_addr == (recent_trace_value - recent_last_trace_value) << 1 ||
            current_trace_addr - last_trace_addr == (recent_trace_value - recent_last_trace_value) << 2 ||
            current_trace_addr - last_trace_addr == (recent_trace_value - recent_last_trace_value) << 3)
            begin
                indirect_confidence_out  <= indirect_confidence_in + 1'b1;
                if (indirect_confidence_out [9] == 1'b1 )//threshhold>=512, 9bit
                    begin
                        indirect_confidence_out[15] <= 1'b1;
                        indirect_confidence_out[14] <= 1'b0;
                    end
            end
            window_count <= window_count + 1;
            if(window_count == window)// ËÑË÷×î½üwindowÌõrecent_trace_value
            begin
                state <= 2'b01;
            end
        end
        2'b01:
        begin
            if (indirect_confidence_in[8:0] > 9'd3)
            begin
                indirect_confidence_out [8:0] <= indirect_confidence_in [8:0] >> 1 ;
            end
            
            if (indirect_confidence_in[8:0] <= 9'd3)
            begin
                indirect_confidence_out[14] <= 1'b1;
                indirect_confidence_out[15] <= 1'b0;
            end
            state <= 2'b10;
        end
        2'b10:
        begin
            finish <= 1;
        end
        endcase
    end
    
    
endmodule
