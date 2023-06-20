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


module GenePattern(
  input [63:0] current_trace_addr,
  input [63:0] last_trace_addr,
  input enable,
  input clk,
  input [63:0] recent_trace_value,
  input [63:0] recent_last_trace_value,
  input history_trace_is_stride,
  input [63:0] offset,
  input [63:0] last_stride,
  input [63:0] last_trace_address2,
  input reset,
  input [63:0] data_in,
  output [63:0] data_out,
  output full,
  output empty,
  output reg pointer_or_not,
  output reg [15:0] static_confidence_out,
  output reg [15:0] indirect_confidence_out,
  output reg [15:0] pointer_chase_confidence_out,
  output reg [15:0] stride_confidence_out,
  output reg [15:0] struct_pointer_confidence_out
);

//  // instantiate modules
//  static_pattern static_pattern_inst(
//    .current_trace_addr(current_trace_addr),
//    .last_trace_addr(last_trace_addr),
//    .enable(enable),
//    .clk(clk),
//    .static_confidence_in(16'd8),
//    .static_confidence_out(static_confidence_out)
//  );

//  indirect_pattern indirect_pattern_inst(
//    .current_trace_addr(current_trace_addr),
//    .last_trace_addr(last_trace_addr),
//    .recent_trace_value(recent_trace_value),
//    .recent_last_trace_value(recent_last_trace_value),
//    .history_trace_is_stride(history_trace_is_stride),
//    .enable(enable),
//    .clk(clk),
//    .indirect_confidence_in(16'd8),
//    .indirect_confidence_out(indirect_confidence_out)
//  );

//  pointer_array_pattern pointer_array_pattern_inst(
//    .current_trace_addr(current_trace_addr),
//    .recent_trace_value(recent_trace_value),
//    .enable(enable),
//    .clk(clk),
//    .pointer_or_not(pointer_or_not)
//  );

//  pointer_chase_pattern pointer_chase_pattern_inst(
//    .current_trace_value(current_trace_value),
//    .current_trace_addr(current_trace_addr),
//    .offset(offset),
//    .enable(enable),
//    .clk(clk),
//    .pointer_chase_confidence_in(16'd8),
//    .pointer_chase_confidence_out(pointer_chase_confidence_out)
//  );

//  stride_pattern stride_pattern_inst(
//    .clk(clk),
//    .enable(enable),
//    .current_trace_address(current_trace_address),
//    .last_stride(last_stride),
//    .last_trace_address2(last_trace_address2),
//    .stride(stride),
//    .stride_confidence_in(16'd8),
//    .stride_confidence_out(stride_confidence_out)
//  );

//  struct_pointer_pattern struct_pointer_pattern_inst(
//    .current_trace_addr(current_trace_addr),
//    .recent_trace_value(recent_trace_value),
//    .enable(enable),
//    .clk(clk),
//    .struct_pointer_confidence_in(16'd8),
//    .struct_pointer_confidence_out(struct_pointer_confidence_out)
//  );

//  offset_history_queue offset_history_queue_inst(
//    .clk(clk),
//    .reset(reset),
//    .enq(enq),
//    .deq(deq),
//    .data_in(data_in),
//    .data_out(data_out),
//    .full(full),
//    .empty(empty)
//  );
endmodule
