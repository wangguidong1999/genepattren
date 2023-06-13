`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 12:08:23
// Design Name: 
// Module Name: offset_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 先进先出的循环数组
//todo:输入只通过top 模块连接，offset都是current_trace_addr - last_trace_addr；
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module offset_array#(parameter WIDTH = 64,parameter ASIZE = 512, parameter ROW_SIZE= 64'd65536)
(clk, reset, add_element, read, data_in, data_out,PC);
    input wire clk;
    input wire reset;
    input wire add_element;
    input wire read;
    input wire [WIDTH-1:0]data_in;
    input wire [WIDTH-1:0]PC;
    output reg [WIDTH-1:0]data_out;
    
    reg [WIDTH-1:0] array [0:ROW_SIZE-1][0:ASIZE-1];
    reg [WIDTH-1:0] tail;

    reg [WIDTH-1:0] read_count;
    always@(posedge clk)
    begin
        if (reset)
        begin
            tail <= 0;
            read_count <= 0;
        end
        if (add_element)
        begin
            array[PC][tail] <= data_in;
            tail <= (tail+1)%ASIZE;
        end
        if (read_count == ASIZE)
        begin
            read_count <= 0;
        end
        if (read)
        begin
            data_out <= array[PC][read_count];
            read_count = read_count+1;
        end
    end

endmodule
