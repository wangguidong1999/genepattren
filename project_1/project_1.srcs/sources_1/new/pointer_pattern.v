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

module pointer_pattern(
    input [63:0] current_trace_addr,
    input [63:0] recent_trace_value,//这里要传进的是一系列recent_trace_value
    input enable,
    input clk,
    
    output reg pointer_or_not
    );
    
    always@(posedge clk)
    begin
        if (recent_trace_value == current_trace_addr)
        begin
            pointer_or_not <= 1'b1;
        end
        else
        begin
            pointer_or_not <= 1'b0;
        end
    end
endmodule
