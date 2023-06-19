`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/30 21:42:50
// Design Name: 
// Module Name: struct_pointer_pattern
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


module struct_pointer_pattern#(parameter OFFSET = 32768)
(current_trace_addr,recent_trace_value,enable,clk,reset,struct_pointer_confidence_in,struct_pointer_confidence_out,finish);
    input [63:0] current_trace_addr;
    input [63:0] recent_trace_value;
    input enable;
    input clk;
    input reset;
    
    input [15:0] struct_pointer_confidence_in; //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] struct_pointer_confidence_out; //[9:0] confidence,  [15] true, [14] false
    output reg finish;
    reg [1:0] state;
    always@(posedge clk) 
    begin
        if(reset)
        begin
            state <= 2'b00;
            finish <= 0;
            struct_pointer_confidence_out <= 0;
        end
        case(state)
        2'b00:
        begin
            if((current_trace_addr - recent_trace_value >= 0 && current_trace_addr - recent_trace_value <= OFFSET)
            || (recent_trace_value - current_trace_addr >= 0 &&  recent_trace_value - current_trace_addr <= OFFSET))
            begin
                struct_pointer_confidence_out  <= struct_pointer_confidence_in + 1'b1;
                if (struct_pointer_confidence_out [9] == 1'b1 )//threshhold>=512, 9bit
                    begin
                        struct_pointer_confidence_out[15] <= 1'b1;
                        struct_pointer_confidence_out[14] <= 1'b0;
                    end
            end
            state <= 2'b01;
        end
        2'b01:
        begin
            if (struct_pointer_confidence_out [8:0] > 9'd3)
            begin
                struct_pointer_confidence_out [8:0] <= struct_pointer_confidence_in [8:0] >> 1 ;
            end
            
            if (struct_pointer_confidence_out [8:0] <= 9'd3)
            begin
                struct_pointer_confidence_out[14] <= 1'b1;
                struct_pointer_confidence_out[15] <= 1'b0;
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
