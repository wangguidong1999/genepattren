`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/07 16:01:56
// Design Name: 
// Module Name: offset_history_queue
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


module offset_history_queue(
  input clk,
  input reset,
  input enq,
  input deq,
  input [63:0] data_in,
  output [63:0] data_out,
  output full,
  output empty
);

  parameter QSIZE = 512;  // queue size
  parameter ADDR_WIDTH = $clog2(QSIZE); // 计算QSIZE的2的对数
  
  reg [63:0] q [0:QSIZE-1]; // queue data
  reg [ADDR_WIDTH-1:0] head = 0;  // head index
  reg [ADDR_WIDTH-1:0] tail = 0;  // tail index
  wire [ADDR_WIDTH-1:0] next_head = (head + 1) % QSIZE;
  wire [ADDR_WIDTH-1:0] next_tail = (tail + 1) % QSIZE;
  
  reg full_reg = 0;
  reg empty_reg = 1;
  
  assign full = full_reg;
  assign empty = empty_reg;
  assign data_out = q[tail];
  
  always @(posedge clk) begin
    if (reset) begin
      head <= 0;
      tail <= 0;
      full_reg <= 0;
      empty_reg <= 1;
    end else begin
      if (enq && !full_reg) begin
        q[head] <= data_in;
        head <= next_head;
        empty_reg <= 0;
        if (next_head == tail) begin
          full_reg <= 1;
        end
      end
      
      if (deq && !empty_reg) begin
        tail <= next_tail;
        full_reg <= 0;
        if (next_tail == head) begin
          empty_reg <= 1;
        end
      end
    end
  end
  
endmodule
