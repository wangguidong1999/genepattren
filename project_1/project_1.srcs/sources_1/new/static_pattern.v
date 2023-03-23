`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:16:27
// Design Name: 
// Module Name: static_pattern
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


module static_pattern(
    input [63:0] current_trace_addr,
    input [63:0] last_trace_addr,
    input enable,
    input clk,
    
    output reg static_or_not
    );
    
    always@(posedge clk) 
    begin
        if(current_trace_addr == last_trace_addr)
        begin
            static_or_not = 1'b1; 
        end
        else 
        begin
            static_or_not = 1'b0;
        end
    end
endmodule
