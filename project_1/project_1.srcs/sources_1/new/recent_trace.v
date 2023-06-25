`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/21 13:45:47
// Design Name: 
// Module Name: recent_trace
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


module recent_trace#(parameter WINDOW = 512,parameter WIDTH = 64,parameter WINDOW_WIDTH = $clog2(512))
(current_trace_addr,current_trace_value,current_trace_PC,stride_confidence_in,stride_finish,clk,write,reset,read,add_finish,
recent_trace_value_out,recent_trace_PC_out,recent_trace_stride_confidence_out,end_write,end_read,end_initial);
    input wire [WIDTH-1:0] current_trace_addr;
    input wire [WIDTH-1:0] current_trace_value;
    input wire [WIDTH-1:0] current_trace_PC;
    input wire [15:0] stride_confidence_in; 
    input wire stride_finish; //跨步型
    input wire clk;
    input wire write;
    input wire reset;
    input wire read;
    output reg add_finish;
    output reg [WIDTH-1:0] recent_trace_value_out;
    output reg [WIDTH-1:0] recent_trace_PC_out;
    output reg [WIDTH-1:0] recent_trace_stride_confidence_out;
    output reg end_write;
    output reg end_read;
    output reg end_initial;
    reg [WIDTH-1:0] array [0:WINDOW-1][0:3];//PC||mem_addr||value||stride_confidence
    reg [10:0] initial_count1;
    reg [3:0] initial_count2;
    reg [1:0] initial_state;
    reg [1:0] write_state;
    reg [1:0] read_state;
    reg [WINDOW_WIDTH-1:0] p;
    reg [WINDOW_WIDTH-1:0] read_count;

    always@(posedge clk)
    begin
        if(reset)
        begin
            initial_state <= 2'b00;
            initial_count1 <= 0;
            initial_count2 <= 0;
            end_initial <= 0;
            p <= -1;
            end_write <= 0;
            end_read <= 1;
        end
        case(initial_state)
        2'b00://初始化array
        begin
            array[initial_count1][initial_count2] <= 0;
            initial_count2 <= initial_count2 + 1;
            if(initial_count2 == 11 && initial_count1 != WINDOW)
            begin
                initial_state <= 2'b01;
            end
        end
        2'b01:
        begin
            initial_count1 <= initial_count1 + 1;
            if (initial_count1 == WINDOW)//初始化结束
            begin
                initial_state <= 2'b10;
            end
            else
            begin
                initial_state <= 2'b00;
            end
        end
        2'b10:
        begin
            end_initial <= 1;
        end
        endcase
        if (write)
        begin
            write_state <= 2'b00;
            p <= p+1;
            if (p == WINDOW)
            begin
                p <= 0;
            end
        end
        
        case(write_state)
        2'b00:
        begin
            array[p][0] <= current_trace_PC;
            array[p][1] <= current_trace_addr;
            array[p][2] <= current_trace_value;
            if(stride_finish)
            begin
                array[p][3] <= stride_confidence_in;
                write_state <= 2'b01;
            end
        end
        2'b01:
        begin
            end_write <= 1;
        end
        endcase
        if (read)//从p开始-1，0的下一个是511，一直循环输出到p+1
        begin
            read_state <= 2'b00;
        end
        case(read_state)
        2'b00:
        begin
            read_count <= p;//初始化索引为最近的一条trace信息
            read_state <= 2'b01;
        end
        2'b01:
        begin
            recent_trace_PC_out <= array[read_count][0];
            recent_trace_value_out <= array[read_count][2];
            recent_trace_stride_confidence_out <= array[read_count][3];
            read_state <= 2'b10;
        end
        2'b10:
        begin
            if(read_count != 0)
            begin
                read_count <= read_count - 1;
            end
            else
            begin
                read_count <= 511;
            end
            
            if (read_count == p)
            begin
                read_state <= 2'b11;
            end
            else
            begin
                read_state <= 2'b01;
            end
        end
        2'b11:
        begin
            end_read <= 1;
        end
        endcase
        
    end
    
endmodule
