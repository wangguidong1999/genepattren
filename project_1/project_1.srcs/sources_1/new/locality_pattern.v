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

parameter len = 512;// length of offsetList
parameter WIDTH = 64;
module regional_random_pattern(
    input [WIDTH-1:0] current_trace_addr,
    input [WIDTH-1:0] last_trace_addr,
    
    input [WIDTH-1:0] max_addr,//monoqueue
    input [WIDTH-1:0] min_addr,// 皆以第一条trace 的地址赋初值
    input [WIDTH*len-1:0] offset,// offsetList
    input enable,
    input clk,
    
    input [15:0] regional_random_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] regional_random_confidence_out, //[9:0] confidence,  [15] true, [14] false
    output reg [WIDTH-1:0] new_max_addr,
    output reg [WIDTH-1:0] new_min_addr
    );
    
    parameter T = 32768;  // 
    reg [WIDTH-1:0]offset_now;
    reg with_same_offset = 1'b0;// 等于2表示遍历完毕
    reg have_changed = 1'b0;
    reg loop_finish = 1'b0;
    reg larger_than_threshold  = 1'b0;
    
    generate
    genvar i;
    for (i = 0; i < len; i = i+1) begin: gen_block
        always@(posedge clk) 
        begin
            offset_now <= current_trace_addr - last_trace_addr;
            if(offset_now == offset[(i+1)*WIDTH-1:i*WIDTH])
            begin
                with_same_offset <= 1'b1;
            end
            if (i == len-1)
            begin
                loop_finish <= 1'b1;
            end
        end
    end
   endgenerate
    always@(posedge clk) 
        begin
            if (loop_finish == 1'b1 && current_trace_addr > max_addr)// 只记录最大最小值来实现一个单调队列的功能
            begin
                new_max_addr <= current_trace_addr;
                new_min_addr <= min_addr;
                if (new_max_addr-new_min_addr > T)
                begin
                    larger_than_threshold  <= 1'b1;
                    new_min_addr = new_max_addr - T;
                end
            else if (loop_finish == 1'b1 && current_trace_addr < min_addr)
            begin
                new_min_addr <= current_trace_addr;
                new_max_addr <= max_addr;
                if (new_max_addr-new_min_addr > T)
                begin
                    larger_than_threshold <= 1'b1;
                    new_max_addr = new_min_addr + T;
                end
            end
            end
            if((max_addr - min_addr > T || with_same_offset == 1'b1) && have_changed == 1'b0 && loop_finish == 1'b1)
            begin
                if (regional_random_confidence_out[8:0] > 9'd3)
                begin
                    regional_random_confidence_out[8:0] <= regional_random_confidence_in [8:0] >> 1 ;
                end
                
                if (regional_random_confidence_out[8:0] <= 9'd3)
                begin
                    regional_random_confidence_out[14] <= 1'b1;
                    regional_random_confidence_out[15] <= 1'b0;
                end
                have_changed = 1'b1;
            end
            
            else if(have_changed == 1'b0 && loop_finish == 1'b1)   
            begin
                regional_random_confidence_out  <= regional_random_confidence_in + 1'b1;
                have_changed = 1'b1;
                if (regional_random_confidence_out[9] == 1'b1 )//thresh hold>=512, 9bit
                 begin
                     regional_random_confidence_out[15] <= 1'b1;
                     regional_random_confidence_out[14] <= 1'b0;
                 end
            end
        end
    
    
    
    
endmodule
