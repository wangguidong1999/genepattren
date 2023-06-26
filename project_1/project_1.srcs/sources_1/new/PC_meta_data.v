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


module PC_meta_data#(parameter PC_SIZE=1024,parameter PC_WIDTH=$clog2(PC_SIZE),parameter WIDTH=64,parameter WINDOW=500)
(current_trace_addr,current_trace_value,current_trace_PC,pointer_array_confidence_in,pointer_array_finish,indirect_confidence_in,indirect_finish,
pointer_chase_confidence_in,pointer_chase_finish,pointer_confidence_in,pointer_finish,regional_random_confidence_in,regional_random_finish,
static_confidence_in,static_finish,stride_confidence_in,stride_finish,struct_pointer_confidence_in,struct_pointer_finish,clk,enable,reset,read,write,write_finish,
recent_trace_value,pointer_array_confidence_out,indirect_confidence_out,pointer_chase_confidence_out,pointer_confidence_out,regional_random_confidence_out,static_confidence_out,
stride_confidence_out,struct_pointer_confidence_out,read_finish);
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
    input wire read;
    input wire write;
    output reg write_finish;
    output reg [WIDTH-1:0] recent_trace_value;
    output reg [15:0] pointer_array_confidence_out;
    output reg [15:0] indirect_confidence_out;
    output reg [15:0] pointer_chase_confidence_out;
    output reg [15:0] pointer_confidence_out;
    output reg [15:0] regional_random_confidence_out;
    output reg [15:0] static_confidence_out;
    output reg [15:0] stride_confidence_out;
    output reg [15:0] struct_pointer_confidence_out;
    output reg read_finish;
    reg [WIDTH-1:0] array [0:PC_SIZE-1][0:WINDOW-1][0:11];//PC||mem_addr||value||8*confidence||count一起存，同时存进recent里
    reg [15:0] hash;
    reg [15:0] index;
    reg [2:0] write_state;
    reg [2:0] read_state;
    reg [10:0] initial_count1;
    reg [10:0] initial_count2;
    reg [WIDTH-1:0] min_count;
    reg [10:0] find_min_count;
    reg [15:0] min_index;
    reg [10:0] same_PC_index;
    reg [10:0] last_same_PC_evict_index;//记录同一个PC上一次被驱逐的index
    always@(*)
    begin
        hash <= current_trace_PC[15:0]^current_trace_PC[31:16]^current_trace_PC[47:32]^current_trace_PC[63:48];
    end
    always@(posedge clk)
    begin
        if (reset)
        begin
            write_finish <= 0;
            read_finish <= 0;
            initial_count1 <= 0;
            initial_count2 <= 0;
            write_state <= 3'b000;
            min_count <= 64'd18446744073709551615;
            last_same_PC_evict_index <= 0;
        end
        if(write)
        begin
            write_state <= 3'b001;
            index <= hash;
        end
        case(write_state)
        3'b000://初始化所有的array元素为0
        begin
            array[initial_count1][initial_count2][0] <= 0;
            array[initial_count1][initial_count2][1] <= 0;
            array[initial_count1][initial_count2][2] <= 0;
            array[initial_count1][initial_count2][11] <= 0;
            //置信计数器初始设置为3
            array[initial_count1][initial_count2][3] <= 64'd3;
            array[initial_count1][initial_count2][4] <= 64'd3;
            array[initial_count1][initial_count2][5] <= 64'd3;
            array[initial_count1][initial_count2][6] <= 64'd3;
            array[initial_count1][initial_count2][7] <= 64'd3;
            array[initial_count1][initial_count2][8] <= 64'd3;
            array[initial_count1][initial_count2][9] <= 64'd3;
            array[initial_count1][initial_count2][10] <= 64'd3;
            initial_count2 <= initial_count2 + 1;
            if (initial_count2 == WINDOW && initial_count1 != PC_SIZE-1)
            begin
                initial_count1 <= initial_count1+1;
                initial_count2 <= 0;
            end
            if (initial_count1 == PC_SIZE-1 && initial_count2 == WINDOW)
            begin
                write_state <= 3'b011;
            end
        end
        3'b001://找到PC应该存放的位置
        begin
            if(array[index][0][0] == 0)//哈希有空位
            begin
                array[index][0][0] <= current_trace_PC;
                array[index][0][1] <= current_trace_addr;
                array[index][0][2] <= current_trace_value;
                array[index][0][11] <= array[index][0][11] + 1; 
                write_state <= 3'b010;
            end
            else if (array[index][0][0] == current_trace_PC)//同一个PC已经被记录
            begin
                write_state <= 3'b110;
                same_PC_index <= 0;
            end
            else
            begin
                index <= index + 1;
                if (index == PC_SIZE)
                begin
                    index <= 0;
                end
                else if (index == hash - 1)//没有合适的位置则考虑驱逐出现次数最少的PC的元数据
                begin
                    write_state <= 3'b100;
                    find_min_count <= 0;
                end
            end
        end
        3'b010://接收confidence，无论什么情况，所有的置信计数器总是记录在第一个位置
        begin
            if(pointer_array_finish)
            begin
                array[index][0][3] <= pointer_array_confidence_in;
            end
            if(indirect_finish)
            begin
                array[index][0][4] <= indirect_confidence_in;
            end
            if(pointer_chase_finish)
            begin
                array[index][0][5] <= pointer_chase_confidence_in;
            end
            if(pointer_finish)
            begin
                array[index][0][6] <= pointer_confidence_in;
            end
            if(regional_random_finish)
            begin
                array[index][0][7] <= regional_random_confidence_in;
            end
            if(static_finish)
            begin
                array[index][0][8] <= static_confidence_in;
            end
            if(stride_finish)
            begin
                array[index][0][9] <= stride_confidence_in;
            end
            if(struct_pointer_finish)
            begin
                array[index][0][10] <= struct_pointer_confidence_in;
            end
            if (pointer_array_finish && indirect_finish && pointer_chase_finish && pointer_finish && 
            regional_random_finish && static_finish && stride_finish && struct_pointer_finish)
            begin
                write_state <= 3'b011;
            end
        end
        3'b011:
        begin
            write_finish <= 1;
        end
        3'b100://驱逐出现次数最少的PC占据元数据的位置
        begin
            if (array[find_min_count][0][11] < min_count)
            begin
                min_count <= array[find_min_count][0][11];
                min_index <= find_min_count;
            end
            find_min_count <= find_min_count + 1;
            if (find_min_count == PC_SIZE)
            begin
                index <= min_index;
                write_state <= 3'b101;
            end
        end
        3'b101://替换最小
        begin
            array[index][0][0] <= current_trace_PC;
            array[index][0][1] <= current_trace_addr;
            array[index][0][2] <= current_trace_value;
            array[index][0][11] <= array[index][0][11] + 1; 
            write_state <= 3'b010;
        end
        3'b110://index处已经记录了同一个PC的数据，现在需要找到合适的空位
        begin
            if (array[index][same_PC_index][0] == 0)//找到空位
            begin
                array[index][same_PC_index][0] <= current_trace_PC;
                array[index][same_PC_index][1] <= current_trace_addr;
                array[index][same_PC_index][2] <= current_trace_value;
                array[index][0][11] <= array[index][0][11] + 1; //count仍然加在第一个位置
                write_state <= 3'b010;
            end
            same_PC_index <= same_PC_index + 1;
            if (same_PC_index == PC_SIZE)//到达array的长度了也没找到合适的
            begin
                //驱逐出上一次驱逐的index的下一位，即直接替换掉数据
                array[index][last_same_PC_evict_index][0] <= current_trace_PC;
                array[index][last_same_PC_evict_index][1] <= current_trace_addr;
                array[index][last_same_PC_evict_index][2] <= current_trace_value;
                array[index][0][11] <= array[index][0][11] + 1; //count仍然加在第一个位置
                last_same_PC_evict_index <= last_same_PC_evict_index + 1;
                write_state <= 3'b010;
            end
        end
        endcase
        if(read)
        begin
            read_state <= 3'b000;
            index <= 0;
        end
        case(read_state)//只输出置信计数器
        3'b000:
        begin
            if (array[index][0][0] == current_trace_PC)
            begin
                read_state <= 3'b011;
                pointer_array_confidence_out <= array[index][0][3];
                indirect_confidence_out <= array[index][0][4];
                pointer_chase_confidence_out <= array[index][0][5];
                pointer_confidence_out <= array[index][0][6];
                regional_random_confidence_out<= array[index][0][7];
                static_confidence_out <= array[index][0][8];
                stride_confidence_out <= array[index][0][9];
                struct_pointer_confidence_out <= array[index][0][10];
            end
            else
            begin
                read_state <= 3'b001;
            end
        end
        3'b001:
        begin
            index <= index + 1;
            if(index == PC_SIZE)
            begin
                read_state <= 3'b010;//没找到此PC的元数据
            end
            else
            begin
                read_state <= 3'b000;//继续回到000状态找到符合的PC
            end
        end
        3'b010:
        begin
            pointer_array_confidence_out <= 64'd3;
            indirect_confidence_out <= 64'd3;
            pointer_chase_confidence_out <= 64'd3;
            pointer_confidence_out <= 64'd3;
            regional_random_confidence_out<= 64'd3;
            static_confidence_out <= 64'd3;
            stride_confidence_out <= 64'd3;
            struct_pointer_confidence_out <= 64'd3;
            read_state <= 3'b011;
        end
        3'b011:
        begin
            read_finish <= 1;
        end
        endcase
    end
    
endmodule
