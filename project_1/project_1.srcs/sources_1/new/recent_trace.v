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


module recent_trace#(parameter WINDOW = 512,parameter WIDTH = 64,parameter WINDOW_WIDTH = $clog2(512),parameter PC_SIZE=1024)
(current_trace_addr,current_trace_value,current_trace_PC,stride_confidence_in,stride_finish,clk,write,reset,read,add_finish,
recent_trace_value_out,recent_trace_stride_confidence_out,end_write,end_read,end_initial);
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
    output reg [WIDTH-1:0] recent_trace_stride_confidence_out;
    output reg end_write;
    output reg end_read;
    output reg end_initial;
    reg [WIDTH-1:0] array [0:PC_SIZE-1][0:WINDOW-1][0:3];//PC||mem_addr||value||stride_confidence
    reg [10:0] initial_count1;
    reg [10:0] initial_count2;
    reg [1:0] initial_state;
    reg [2:0] write_state;
    reg [2:0] read_state;
    reg [10:0] index;
    reg [10:0] same_PC_index;
    reg [10:0] same_PC_evict_index;
    reg [10:0] read_count;
    reg [15:0] hash;
    always@(*)
    begin
        hash <= current_trace_PC[15:0]^current_trace_PC[31:16]^current_trace_PC[47:32]^current_trace_PC[63:48];
    end
    always@(posedge clk)
    begin
        if(reset)
        begin
            initial_state <= 2'b00;
            initial_count1 <= 0;
            initial_count2 <= 0;
            end_initial <= 0;
            end_write <= 0;
            end_read <= 1;
            same_PC_evict_index <= 0;
        end
        case(initial_state)
        2'b00://初始化array
        begin
            array[initial_count1][initial_count2][0] <= 0;
            array[initial_count1][initial_count2][1] <= 0;
            array[initial_count1][initial_count2][2] <= 0;
            array[initial_count1][initial_count2][3] <= 3;
            initial_count2 <= initial_count2 + 1;
            if(initial_count2 == WINDOW && initial_count1 != PC_SIZE-1)
            begin
                initial_count2 <= 0;
                initial_count1 <= initial_count1 + 1;
            end
            if(initial_count2 == WINDOW && initial_count1 == PC_SIZE-1)
            begin
                initial_state <= 2'b01;
            end
        end
        2'b01:
        begin
            end_initial <= 1;
        end
        endcase
        
        if (write)
        begin
            write_state <= 3'b000;
            index <= hash;
            end_write <= 0;
        end
        
        case(write_state)
        3'b000:
        begin
            if(array[index][0][0] == 0)//这个位置空余
            begin
                array[index][0][0] <= current_trace_PC;
                array[index][0][1] <= current_trace_addr;
                array[index][0][2] <= current_trace_value;
                write_state <= 3'b111;
                
            end
            else if (array[index][0][0] == current_trace_PC)//已经有了同一个PC位置的记录
            begin
                write_state <= 3'b010;
                same_PC_index <= 0;
            end
            else
            begin
                write_state <= 3'b001;
            end
        end
        3'b001:
        begin
            index <= index + 1;
            if(index != PC_SIZE)
            begin
                write_state <= 3'b000;
            end
        end
        3'b010://已经有了同一个PC位置的记录
        begin
            if(array[index][same_PC_index][0] == 0)//有空位
            begin
                array[index][same_PC_index][0] <= current_trace_PC;
                array[index][same_PC_index][1] <= current_trace_addr;
                array[index][same_PC_index][2] <= current_trace_value;
                write_state <= 3'b111;
            end
            else
            begin
                write_state <= 3'b011;
            end
        end
        3'b011:
        begin
            same_PC_index <= same_PC_index + 1;
            if (same_PC_index != PC_SIZE)
            begin
                write_state <= 3'b010;
            end
            else
            begin//遍历了一圈也没找到空位，需要顶替最远的recent trace
                same_PC_evict_index <= same_PC_evict_index + 1;
                array[index][same_PC_index][0] <= current_trace_PC;
                array[index][same_PC_index][1] <= current_trace_addr;
                array[index][same_PC_index][2] <= current_trace_value;
                write_state <= 3'b111;
            end
        end
        3'b111:
        begin
            if (stride_finish)
                begin
                    array[index][0][3] <= stride_confidence_in;//confidence固定放在第一个位置的第四个
                    end_write <= 1;
                end
        end
        endcase
        if (read)
        begin
            read_state <= 3'b000;
            read_count <= same_PC_index;//初始化索引为最近的一条trace信息
            index <= hash;
        end
        case(read_state)
        3'b000:
        begin
            if (array[index][read_count][0] == current_trace_PC && array[index][read_count][2] != 0)
            begin
                recent_trace_value_out <= array[index][read_count][2];
                recent_trace_stride_confidence_out <= array[index][read_count][3];
                read_state <= 3'b100;
            end
            else if (array[index][read_count][0] == current_trace_PC && array[index][read_count][2] == 0)//读到空的位置
            begin
                recent_trace_value_out <= 0;//表示没有读出
                recent_trace_stride_confidence_out <= 3;//给出一个默认值
                read_state <= 3'b011;
            end
            else
            begin
                read_state <= 3'b001;
            end
        end
        3'b001:
        begin
            index <= index + 1;
            if (index == PC_SIZE && hash != 0)
            begin
                index <= 0;
            end
            if ((index == hash-1 && hash != 0) || (index == PC_SIZE && hash == 0))//遍历结束都没有找到相同的PC
            begin
                read_state <= 3'b010;
            end
        end
        3'b010:
        begin
            recent_trace_value_out <= 0;//表示没有读出
            recent_trace_stride_confidence_out <= 3;//给出一个默认值
            read_state <= 3'b011;
        end
        3'b011:
        begin
            end_read <= 1;
        end
        3'b100:
        begin
            read_count <= read_count + 1;
            read_state <= 3'b000;
            if (read_count == WINDOW && same_PC_index != 0)
            begin
                read_count <= 0;
            end
            if ((read_count == same_PC_index - 1 && same_PC_index != 0) || (read_count == WINDOW && same_PC_index == 0))
            begin
                read_state <= 3'b011;
            end
        end
        endcase
        
    end
    
endmodule
