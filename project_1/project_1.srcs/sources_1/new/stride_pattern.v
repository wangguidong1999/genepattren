`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:20:31
// Design Name: 
// Module Name: stride_pattern
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


module stride_pattern(
    input clk,
    input enable,
    input [63:0] current_trace_address,
    input [63:0] last_stride,
    input [63:0] last_trace_address2,
        
    output [63:0] stride,
    
<<<<<<< HEAD
    input [15:0] stride_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] stride_confidence_out //[9:0] confidence,  [15] true, [14] false

=======
    output reg stride_or_not,
    output reg [63:0] stride
>>>>>>> 0fd8e00f05869baa2ed36444c428994786910fe6
    );
    
    always@(posedge clk)
    begin
        if (last_stride == current_trace_address-last_trace_address2)
        begin
<<<<<<< HEAD
            stride_confidence_out  <= stride_confidence_in + 1'b1;
            if (stride_confidence_out[9] == 1'b1 )//threshhold>=512, 9bit
             begin
                 stride_confidence_out[15] <= 1'b1;
                 stride_confidence_out[14] <= 1'b0;
             end
=======
            stride_or_not <= 1'b1;
            stride <= current_trace_address-last_trace_address2;
>>>>>>> 0fd8e00f05869baa2ed36444c428994786910fe6
        end
        
        else begin
            if (stride_confidence_out[8:0] > 9'd3)
            begin
                stride_confidence_out[8:0] <= stride_confidence_in [8:0] >> 1 ;
            end
            
            if (stride_confidence_out[8:0] <= 9'd3)
            begin
                stride_confidence_out[14] <= 1'b1;
                stride_confidence_out[15] <= 1'b0;
            end
        end
    end
endmodule
