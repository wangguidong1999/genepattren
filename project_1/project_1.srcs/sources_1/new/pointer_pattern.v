`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:26:48
// Design Name: 
// Module Name: pointer_pattern
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

module pointer_pattern(
    input [63:0] current_trace_addr,
    input [63:0] recent_trace_value,//这里要传进的是一系列recent_trace_value
    input enable,
    input clk,
    
    input [15:0] pointer_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] pointer_confidence_out //[9:0] confidence,  [15] true, [14] false
    );
    
<<<<<<< HEAD
        always@(posedge clk)
    begin
        if (current_trace_addr == recent_trace_value)
        begin
            pointer_confidence_out  <= pointer_confidence_in + 1'b1;
            if (pointer_confidence_out [9] == 1'b1 )//threshhold>=512, 9bit
                begin
                    pointer_confidence_out[15] <= 1'b1;
                    pointer_confidence_out[14] <= 1'b0;
                end
        end
        
        else begin
            if (pointer_confidence_out [8:0] > 9'd3)
            begin
                pointer_confidence_out [8:0] <= pointer_confidence_in [8:0] >> 1 ;
            end
            
            if (pointer_confidence_out [8:0] <= 9'd3)
            begin
                pointer_confidence_out[14] <= 1'b1;
                pointer_confidence_out[15] <= 1'b0;
            end
        end
    end
    
=======
    always@(posedge clk)
    begin
        if (recent_trace_value == current_trace_addr)
        begin
            pointer_or_not <= 1'b1;
        end
        else
        begin
            pointer_or_not <= 1'b0;
        end
    end
>>>>>>> 0fd8e00f05869baa2ed36444c428994786910fe6
endmodule
