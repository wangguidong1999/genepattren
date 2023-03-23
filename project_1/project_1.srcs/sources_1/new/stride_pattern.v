`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:20:31
// Design Name: 
// Module Name: stride_pattern
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


module stride_pattern(
    input clk,
    input enable,
    input [63:0] current_trace_address,
    input [63:0] last_stride,
    input [63:0] last_trace_address2,
    
    output reg stride_or_not,
    output [63:0] stride
    );
    
    always@(posedge clk)
    begin
        if (last_stride == current_trace_address-last_trace_address2)
        begin
            stride_or_not = 1'b1;
        end
        else begin
            stride_or_not = 1'b0;
        end
    end
endmodule
