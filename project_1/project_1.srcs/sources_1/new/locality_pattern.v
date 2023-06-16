`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 15:45:57
// Design Name: 
// Module Name: locality_pattern
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


module regional_random_pattern #(parameter len = 128, parameter WIDTH = 64, parameter T = 16384,parameter COUNT_WIDTH = $clog2(len))// 阈值设置16K
(current_trace_addr, last_trace_addr, max_addr, min_addr, offset, PC, enable, clk, reset, regional_random_confidence_in, 
regional_random_confidence_out, new_max_addr, new_min_addr, add_element, read, offset_now);
    input wire [WIDTH-1:0] current_trace_addr;
    input wire [WIDTH-1:0] last_trace_addr;
    
    input wire [WIDTH-1:0] max_addr;//monoqueue
    input wire [WIDTH-1:0] min_addr;// 皆以第一条trace 的地址赋初值
    input wire [WIDTH-1:0] offset;// offsetList
    input wire [WIDTH-1:0] PC;
    input wire enable;
    input wire clk;
    input wire reset;
    input wire [15:0] regional_random_confidence_in; //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] regional_random_confidence_out; //[9:0] confidence,  [15] true, [14] false
    output reg [WIDTH-1:0] new_max_addr;
    output reg [WIDTH-1:0] new_min_addr;
    output reg add_element;
    output reg read;
   
    output reg [WIDTH-1:0]offset_now;
    reg with_same_offset;
    reg have_changed;
    reg loop_finish;
    reg larger_than_threshold;
    reg [COUNT_WIDTH:0]count; 
    
    reg [1:0] compare_state;
    always@(posedge clk) 
        begin
            if (reset)
            begin
                with_same_offset <= 1'b0;
                have_changed <= 1'b0;
                loop_finish <= 1'b0;
                larger_than_threshold  <= 1'b0;
                count <= 8'b0;
                compare_state <= 2'b00;
            end
            case(compare_state)
                2'b00:
                begin
                    if (enable == 1'b1)
                    begin
                        offset_now <= current_trace_addr - last_trace_addr;
                        read <= 1;
                        if(offset_now == offset)
                        begin
                            with_same_offset <= 1'b1;
                        end
                        count <= count +1;
                        if (count == len)
                        begin
                            compare_state <= 1;
                        end
                    end
                end
                2'b01:
                begin
                    add_element <= 1'b1;
                    compare_state <= 2'b10;
                end
            endcase
        end

    always@(posedge clk) 
        begin
            if (current_trace_addr > max_addr && enable == 1'b1)// 只记录最大最小值来实现一个单调队列的功能
            begin
                new_max_addr <= current_trace_addr;
                new_min_addr <= min_addr;
                if (new_max_addr-new_min_addr > T)
                begin
                    larger_than_threshold  <= 1'b1;
                    new_min_addr = new_max_addr - T;
                end
            end
            else if (current_trace_addr < min_addr && enable == 1'b1)
            begin
                new_min_addr <= current_trace_addr;
                new_max_addr <= max_addr;
                if (new_max_addr-new_min_addr > T)
                begin
                    larger_than_threshold <= 1'b1;
                    new_max_addr = new_min_addr + T;
                end
            end
            else if (enable == 1'b1)
            begin
                new_max_addr <= max_addr;
                new_min_addr <= min_addr;
            end

            if((larger_than_threshold == 1'b1 || with_same_offset == 1'b1) && have_changed == 1'b0 && enable == 1'b1)
            begin
                if (regional_random_confidence_in[8:0] > 9'd3)
                begin
                    regional_random_confidence_out[15:0] <= regional_random_confidence_in [15:0] >> 1 ;
                end
                
                if (regional_random_confidence_in[8:0] <= 9'd3)
                begin
                    regional_random_confidence_out[14] <= 1'b1;
                    regional_random_confidence_out[15] <= 1'b0;
                end
                have_changed = 1'b1;
            end
            else if(have_changed == 1'b0 && enable == 1'b1 && count == len)   
            begin
                regional_random_confidence_out  <= regional_random_confidence_in + 1'b1;
                have_changed = 1'b1;
                if (regional_random_confidence_out[9] == 1'b1)//thresh hold>=512, 9bit
                 begin
                     regional_random_confidence_out[15] <= 1'b1;
                     regional_random_confidence_out[14] <= 1'b0;
                 end
            end
        end
        //offset_array U(.clk(clk), .reset(), .add_element(add_element), .read(read), .data_in(offset_now), .data_out(offset));
endmodule
