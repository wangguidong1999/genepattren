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
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module offset_array#(parameter WIDTH = 64,parameter ASIZE = 512)
(clk, reset, add_element, read, data_in, data_out);
    input wire clk;
    input wire reset;
    input wire add_element;
    input wire read;
    input wire [WIDTH-1:0]data_in;
    output reg [WIDTH-1:0]data_out;
    
    reg [WIDTH-1:0] array [0:ASIZE-1];
    reg [WIDTH-1:0] head;
    reg [WIDTH-1:0] tail;

    reg [WIDTH-1:0] next_tail;
    reg read_count;
    always@(posedge clk)
    begin
        if (reset)
        begin
            head <= 0;
            tail <= 0;
            read_count <= 0;
        end
        if (add_element)
        begin
            array[tail] <= data_in;
            tail <= (tail+1)%ASIZE;
        end
        if (read_count == ASIZE)
        begin
            read_count <= 0;
        end
        if (read)
        begin
            data_out <= array[read_count];
            read_count = read_count+1;
        end
    end

endmodule
