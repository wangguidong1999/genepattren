`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/16 16:43:01
// Design Name: 
// Module Name: GenePattern
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


module GenePattern#(parameter DATA_WIDTH=64)
();
    reg [DATA_WIDTH-1:0] current_trace_PC;
    reg [DATA_WIDTH-1:0] current_trace_addr;
    reg [DATA_WIDTH-1:0] current_trace_value;
    reg clk;
    reg enable;
    reg PC_meta_data_reset;
    reg indirect_pattern_reset;
    //confidenceµÄ¶Á³ö



endmodule
