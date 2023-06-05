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


module regional_random_pattern(
    input [63:0] current_trace_addr,
    input [63:0] last_trace_addr,
    
    input [63:0] max_addr,//monoqueue
    input [63:0] min_addr,
    input [63:0] offset,// offsetList
    input enable,
    input clk,
    
    input [15:0] regional_random_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] regional_random_confidence_out //[9:0] confidence,  [15] true, [14] false
    );
    
    parameter T = 32768;  // 
    wire [63:0] offsetnow = current_trace_addr - last_trace_addr;

    always@(posedge clk) 
    begin
        if(max_addr - min_addr > T || offsetnow == offset)
   
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
        end
        
        else    
        begin
            regional_random_confidence_out  <= regional_random_confidence_in + 1'b1;
            if (regional_random_confidence_out[9] == 1'b1 )//thresh hold>=512, 9bit
             begin
                 regional_random_confidence_out[15] <= 1'b1;
                 regional_random_confidence_out[14] <= 1'b0;
             end
        end
    end
endmodule
