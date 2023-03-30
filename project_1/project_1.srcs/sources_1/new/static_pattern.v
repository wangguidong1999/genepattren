`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 16:16:27
// Design Name: 
// Module Name: static_pattern
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


module static_pattern(
    input [63:0] current_trace_addr,
    input [63:0] last_trace_addr,
    input enable,
    input clk,
    
    input [15:0] static_confidence_in, //initial value = 8, low bound (false) <= 3  , upper bound >= 512(9bit);
    output reg [15:0] static_confidence_out //[9:0] confidence,  [15] true, [14] false
    );
    
    always@(posedge clk) 
    begin
        if(current_trace_addr == last_trace_addr)
        begin
            static_confidence_out  <= static_confidence_in + 1'b1;
            if (static_confidence_out[9] == 1'b1 )//threshhold>=512, 9bit
             begin
                 static_confidence_out[15] <= 1'b1;
                 static_confidence_out[14] <= 1'b0;
             end
        end
        
        else begin
            if (static_confidence_out[8:0] > 9'd3)
            begin
                static_confidence_out[8:0] <= static_confidence_in [8:0] >> 1 ;
            end
            
            if (static_confidence_out[8:0] <= 9'd3)
            begin
                static_confidence_out[14] <= 1'b1;
                static_confidence_out[15] <= 1'b0;
            end
        end
    end
endmodule
