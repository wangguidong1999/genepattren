`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:28:17
// Design Name: 
// Module Name: static_pattern_testbench
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


module static_pattern_testbench();
    reg clk;
    reg [64:0] current_trace_addr;
    reg [64:0] last_trace_addr;
    reg enable;
    
    wire static_or_not;
    
    initial begin
        clk = 1'b1;
        enable = 1'b0;
        
        #20 current_trace_addr = 64'b1;
        last_trace_addr = 64'b1;
        
        #20 current_trace_addr = 64'b101010;
        last_trace_addr = 64'b010101;
    end
    always@(clk)
    begin
        #10 clk <= ~clk;
    end
    
    static_pattern static_pattern_check(
    .current_trace_addr (current_trace_addr),
    .last_trace_addr (last_trace_addr),
    .enable (enable),
    .clk(clk),
    
    .static_or_not (static_or_not)
    );
endmodule
