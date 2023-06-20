`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/19 21:21:03
// Design Name: 
// Module Name: PC_meta_data
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


module PC_meta_data#(parameter PC_SIZE=1024,parameter PC_WIDTH=$clog2(PC_SIZE),parameter WIDTH=64)
(current_trace_addr,current_trace_value,current_trace_PC,pointer_array_confidence_in,pointer_array_finish,indirect_confidence_in,indirect_finish,
pointer_chase_confidence_in,pointer_chase_finish,pointer_confidence_in,pointer_finish,regional_random_confidence_in,regional_random_finish,
static_confidence_in,static_finish,stride_confidence_in,stride_finish,struct_pointer_confidence_in,struct_pointer_finish,clk,enable,reset,add_finish);
    input wire [WIDTH-1:0] current_trace_addr;
    input wire [WIDTH-1:0] current_trace_value;
    input wire [WIDTH-1:0] current_trace_PC;
    input wire [15:0] pointer_array_confidence_in;
    input wire pointer_array_finish;//指针数组型
    input wire [15:0] indirect_confidence_in;
    input wire indirect_finish;//间接性
    input wire [15:0] pointer_chase_confidence_in;
    input wire pointer_chase_finish;//指针追逐型
    input wire [15:0] pointer_confidence_in;
    input wire pointer_finish;//指针型
    input wire [15:0] regional_random_confidence_in;
    input wire regional_random_finish;//区域随机型
    input wire [15:0] static_confidence_in; 
    input wire static_finish;//静态型
    input wire [15:0] stride_confidence_in; 
    input wire stride_finish; //跨步型
    input wire [15:0] struct_pointer_confidence_in;
    input wire struct_pointer_finish;
    input wire clk;
    input wire enable;
    input wire reset;
    output reg add_finish;
    reg [WIDTH-1:0] array [0:PC_SIZE-1][0:10];//PC||mem_addr||value||8*confidence一起存，同时存进recent里
    reg [15:0] hash;
    reg [15:0] index;
    reg [1:0] state;
    reg [10:0] initial_count1;
    reg [3:0] initial_count2;
    always@(*)
    begin
        hash <= current_trace_PC[15:0]^current_trace_PC[31:16]^current_trace_PC[47:32]^current_trace_PC[63:48];
    end
    always@(posedge clk)
    begin
        if (reset)
        begin
            add_finish <= 0;
            state <= 2'b00;
            initial_count1 <= 0;
            initial_count2 <= 0;
            index <= hash;
        end
        case(state)
       2'b00://初始化所有的array元素为0
        begin
            array[initial_count1][initial_count2] <= 0;
            initial_count2 <= initial_count2 + 1;
            if (initial_count2 == 11 && initial_count1 != PC_SIZE)
            begin
                initial_count1 <= initial_count1 +1;
                initial_count2 <= 0;
            end
            else if (initial_count2 == 11 && initial_count1 == PC_SIZE)
            begin
                state <= 2'b01;
            end
        end
        2'b01://找到PC应该存放的位置
        begin
            if(array[index][0] == 0)//哈希有空位
            begin
                array[index][0] <= current_trace_PC;
                array[index][1] <= current_trace_addr;
                array[index][2] <= current_trace_value;
                state <= 2'b10;
            end
            index <= index + 1;
        end
        2'b10://接收confidence
        begin
            if(pointer_array_finish)
            begin
                array[index][3] <= pointer_array_confidence_in;
            end
            if(indirect_finish)
            begin
                array[index][4] <= indirect_confidence_in;
            end
            if(pointer_chase_finish)
            begin
                array[index][5] <= pointer_chase_confidence_in;
            end
            if(pointer_finish)
            begin
                array[index][6] <= pointer_confidence_in;
            end
            if(regional_random_finish)
            begin
                array[index][7] <= regional_random_confidence_in;
            end
            if(static_finish)
            begin
                array[index][8] <= static_confidence_in;
            end
            if(stride_finish)
            begin
                array[index][9] <= stride_confidence_in;
            end
            if(struct_pointer_finish)
            begin
                array[index][10] <= struct_pointer_confidence_in;
            end
            if (pointer_array_finish && indirect_finish && pointer_chase_finish && pointer_finish && 
            regional_random_finish && static_finish && stride_finish && struct_pointer_finish)
            begin
                state <= 2'b11;
            end
        end
        2'b11:
        begin
            add_finish <= 1;
        end
        endcase
    end
    
endmodule
