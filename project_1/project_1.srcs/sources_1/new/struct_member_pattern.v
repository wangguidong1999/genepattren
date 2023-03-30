`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/24 16:46:17
// Design Name: 
// Module Name: struct_member_pattern
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


module struct_member_pattern(
    input clk,
    input enable,
    input [63:0] current_trace_addr,
    input [63:0] recent_trace_value,//这里要传进的是一系列recent_trace_value
    
    output reg struct_member_or_not
    );
    reg [63:0] positive_offset;
    reg [63:0] negative_offset;
    always@(posedge clk)
    begin
        positive_offset <= current_trace_addr - recent_trace_value;
        negative_offset <= recent_trace_value - current_trace_addr;
        if (positive_offset > 16'd32768 || negative_offset < -16'd32768)
        begin
            struct_member_or_not <= 1'b0;
        end
        else if (positive_offset > 0 && positive_offset < 16'd32768)
        begin
            struct_member_or_not <= 1'b1;
        end
        else if (negative_offset < 0 && negative_offset > -16'd32768)
        begin
            struct_member_or_not <= 1'b0;
        end
        else 
        begin
            struct_member_or_not <= 1'b0;
        end
    end
endmodule
