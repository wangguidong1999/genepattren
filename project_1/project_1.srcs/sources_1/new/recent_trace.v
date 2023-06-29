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
(current_trace_addr,current_trace_value,current_trace_PC,stride_confidence_in,stride_finish,clk,write,reset,read,add_finish,recent_trace_addr_out,
recent_trace_value_out,end_write,end_read,end_initial);
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
    output reg [WIDTH-1:0] recent_trace_addr_out;
    output reg [WIDTH-1:0] recent_trace_value_out;//输出stride的
    output reg end_write;
    output reg end_read;
    output reg end_initial;
    reg [WIDTH-1:0] array [0:PC_SIZE-1][0:WINDOW-1][0:3];//PC||mem_addr||value||count，只记录跨步型访存的信息
    reg [WIDTH-1:0] array2 [0:PC_SIZE-1][0:3];//PC||mem_addr||value||count,记录同一个PC的上一条trace
    reg [9:0] initial_count1;
    reg [8:0] initial_count2;
    reg [9:0] initial_count3;
    reg [1:0] initial_state;
    reg [1:0] initial_state2;
    reg [2:0] write_state;
    reg [1:0] write_state2;
    reg [1:0] read_state;
    reg [1:0] read_stride_state;
    reg [10:0] index;
    reg [10:0] same_PC_index;
    reg [10:0] same_PC_evict_index;
    reg [10:0] read_count;
    reg [15:0] hash;
    reg [10:0] stride_index;
    reg [10:0] stride_read_count;
    reg [WIDTH-1:0] min_count1;
    reg [WIDTH-1:0] min_count2;
    reg [10:0] min_index1;
    reg [10:0] min_index2;
    always@(*)
    begin
        hash <= current_trace_PC[15:0]^current_trace_PC[31:16]^current_trace_PC[47:32]^current_trace_PC[63:48];
    end
    always@(posedge clk)
    begin
        if(reset)
        begin
            initial_state <= 2'b00;
            initial_state2 <= 2'b00;
            initial_count1 <= 0;
            initial_count2 <= 0;
            initial_count3 <= 0;
            end_initial <= 0;
            end_write <= 0;
            end_read <= 1;
            same_PC_evict_index <= 0;
            min_count1 <= 64'd18446744073709551615;
            min_count2 <= 64'd18446744073709551615;
        end
        case(initial_state)
        2'b00:
        begin
            array[initial_count1][initial_count2][0] <= 0;//PC||mem_addr||value||count
            array[initial_count1][initial_count2][1] <= 0;
            array[initial_count1][initial_count2][2] <= 0;
            array[initial_count1][initial_count2][3] <= 0;
            initial_count2 <= initial_count2 + 1;
            if (initial_count2 == WINDOW-1 && initial_count1 != PC_SIZE-1)
            begin
                initial_count1 <= initial_count1 + 1;
                initial_count2 <= 0;
            end
            else if (initial_count2 == WINDOW-1 && initial_count1 == PC_SIZE-1)
            begin
                initial_state <= 2'b01;
            end
        end
        2'b01:
        begin
            end_initial <= 1;
        end
        default:
        begin
            end_initial <= 0;
        end
        endcase
        case(initial_state2)
        2'b00://初始化array
        begin
            array2[initial_count3][0] <= 0;//PC||mem_addr||value||count
            array2[initial_count3][1] <= 0;
            array2[initial_count3][2] <= 0;
            array2[initial_count3][3] <= 0;//记录该PC的出现次数
            initial_count3 <= initial_count3 + 1;
            if (initial_count3 == 10'd1023)
            begin
                initial_state2 <= 2'b01;
            end
        end
        default:
        begin
            end_initial <= 0;
        end
        endcase
        
        if (write)
        begin
            if (stride_confidence_in[15] == 1)
            begin
                write_state <= 3'b000;
            end
            write_state2 <= 2'b00;
            index <= hash;
            end_write <= 0;
        end
        
        case(write_state2)
        2'b00:
        begin
            if(array2[index][0] == 0)//这个位置空余
            begin
                array2[index][0] <= current_trace_PC;
                array2[index][1] <= current_trace_addr;
                array2[index][2] <= current_trace_value;
                array2[index][3] <= array2[index][3] + 1;
                write_state2 <= 2'b10;
            end
            else if (array2[index][0] == current_trace_PC)
            begin
                array2[index][0] <= current_trace_PC;
                array2[index][1] <= current_trace_addr;
                array2[index][2] <= current_trace_value;
                write_state2 <= 2'b10;
            end
            else
            begin
                write_state2 <= 2'b01;
            end
        end
        2'b01:
        begin
            index <= index + 1;
            if(index == PC_SIZE-1)//没找到空位也没找到历史数据
            begin
                write_state2 <= 2'b11;
                index <= 0;
            end
        end
        2'b10:
        begin
            end_write <= 1;
        end
        2'b11:
        begin
            //需要找到出现次数最少的PC数据替换
            if (array2[index][3] < min_count2)
            begin
                min_count2 <= array2[index][3];
                min_index2 <= index;
            end
            index <= index + 1;
            if (index == PC_SIZE-1)
            begin
                array2[min_index2][0] <= current_trace_PC;
                array2[min_index2][1] <= current_trace_addr;
                array2[min_index2][2] <= current_trace_value;
                array2[min_index2][3] <= 1;
                write_state2 <= 2'b10;
            end
        end
        endcase
        
        case(write_state)
        3'b000:
        begin
            if(array[index][0][0] == 0)//这个位置空余
            begin
                array[index][0][0] <= current_trace_PC;//PC||mem_addr||value||count
                array[index][0][1] <= current_trace_addr;
                array[index][0][2] <= current_trace_value;
                array[index][0][3] <= array[index][0][3] + 1;
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
            if(index != PC_SIZE-1)
            begin
                write_state <= 3'b000;
            end
            else//启动替换
            begin
                index <= 0;
                write_state <= 3'b100;
            end
        end
        3'b010://已经有了同一个PC位置的记录
        begin
            if(array[index][same_PC_index][0] == 0)//有空位
            begin
                array[index][same_PC_index][0] <= current_trace_PC;
                array[index][same_PC_index][1] <= current_trace_addr;
                array[index][same_PC_index][2] <= current_trace_value;
                array[index][same_PC_index][3] <= array[index][same_PC_index][3] + 1;
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
            if (same_PC_index != PC_SIZE-1)
            begin
                write_state <= 3'b010;
            end
            else
            begin//遍历了一圈也没找到空位，类似随机的找个位置顶替
                same_PC_evict_index <= same_PC_evict_index + 1;
                array[index][same_PC_evict_index][0] <= current_trace_PC;
                array[index][same_PC_evict_index][1] <= current_trace_addr;
                array[index][same_PC_evict_index][2] <= current_trace_value;
                array[index][same_PC_evict_index][3] <= 1;//尽管没用，仍然记录
                write_state <= 3'b111;
            end
        end
        3'b100:
        begin
            if (array[index][0][3] < min_count1)
            begin
                min_count1 <= array[index][0][3];
                min_index1 <= index;
            end
            index <= index + 1;
            if (index == PC_SIZE-1)
            begin
                array[min_index1][0][0] <= current_trace_PC;
                array[min_index1][0][1] <= current_trace_addr;
                array[min_index1][0][2] <= current_trace_value;
                array[min_index1][0][3] <= 1;
                write_state <= 3'b111;
            end
        end
        3'b111:
        begin
            end_write <= 1;
        end
        default:
        begin
            end_write <= 0;
        end
        endcase
        
        if (read)
        begin
            read_state <= 2'b00;//读取同一PC的上一条trace信息
            read_count <= 0;
            index <= 0;
            read_stride_state <= 2'b00;//读取跨步型的信息
            stride_index <= 0;
            stride_read_count <= 0;
            end_read <= 0;
        end
        case(read_stride_state)
        2'b00:
        begin
            if (array[index][stride_read_count][2] != 0)
            begin
                recent_trace_value_out <= array[index][stride_read_count][2];
                read_stride_state <= 2'b01;
            end
        end
        2'b01:
        begin
            stride_read_count <= stride_read_count + 1;
            if (stride_read_count == WINDOW-1)
            begin
                stride_read_count <= 0;
                read_stride_state <= 2'b10;
            end
            else
            begin
                read_stride_state <= 2'b00;
            end
        end
        2'b10:
        begin
            index <= index + 1;
            if (index == PC_SIZE-1)
            begin
                read_stride_state <= 2'b11;
            end
            else
            begin
                read_stride_state <= 2'b00;
            end
        end
        default:
        begin
            read_stride_state <= read_stride_state;
        end
        endcase
        
        case(read_state)//读取同一个PC的上一条trace,存在array2中
        2'b00:
        begin
            if (array2[index][0] == current_trace_PC)
            begin
                recent_trace_addr_out <= array2[index][1];
                read_state <= 2'b11;
            end
            else
            begin
                read_state <= 2'b01;
            end
        end
        2'b01:
        begin
            index <= index + 1;
            if (index == PC_SIZE-1)
            begin
                read_state <= 2'b10;
            end
            else
            begin
                read_state <= 2'b00;
            end
        end
        2'b10:
        begin
            recent_trace_addr_out <= 0;//没有找到同一个PC的上一条trace的地址
            read_state <= 2'b11;
        end
        2'b11:
        begin
            end_read <= 1;
        end
//        3'b000:
//        begin
//            if (array[index][read_count][0] == current_trace_PC && array[index][read_count][2] != 0)//cond3 = array[index][read_count][0] == current_trace_PC && array[index][read_count][2] != 0;找到同一个PC的数据
//            begin
//                recent_trace_addr_out <= array[index][same_PC_evict_index][1];
////                recent_trace_value_out <= array[index][read_count][2];
////                recent_trace_stride_confidence_out <= array[index][read_count][3];
//                read_state <= 3'b011;
//            end
//            else if (array[index][read_count][0] == current_trace_PC && array[index][read_count][2] == 0)//cond4 = array[index][read_count][0] == current_trace_PC && array[index][read_count][2] == 0;读到空的位置
//            begin
//                recent_trace_addr_out <= 0;
//                recent_trace_value_out <= 0;//表示没有读出
//                read_state <= 3'b011;
//            end
//            else
//            begin
//                read_state <= 3'b001;
//            end
//        end
//        3'b001:
//        begin
//            index <= index + 1;
//            if (index == PC_SIZE && hash != 0)//cond5 = index == PC_SIZE && hash != 0;
//            begin
//                index <= 0;
//            end
//            if ((index == hash-1 && hash != 0) || (index == PC_SIZE && hash == 0))//(index == hash-1 && hash != 0) || (index == PC_SIZE && hash == 0);遍历结束都没有找到相同的PC
//            begin
//                read_state <= 3'b010;
//            end
//        end
//        3'b010:
//        begin
//            recent_trace_value_out <= 0;//表示没有读出
//            read_state <= 3'b011;
//        end
//        3'b011:
//        begin
//            end_read <= 1;
//        end
//        3'b100:
//        begin
//            read_count <= read_count + 1;
//            read_state <= 3'b000;
//            if (read_count == WINDOW && same_PC_index != 0)// cond7 = read_count == WINDOW && same_PC_index != 0;
//            begin
//                read_count <= 0;
//            end
//            if ((read_count == same_PC_index - 1 && same_PC_index != 0) || (read_count == WINDOW && same_PC_index == 0))// cond8 = (read_count == same_PC_index - 1 && same_PC_index != 0) || (read_count == WINDOW && same_PC_index == 0);
//            begin
//                read_state <= 3'b011;
//            end
//        end
//        default:
//        begin
//            end_read <= end_read;
//        end
        endcase
        
    end
    
endmodule
