`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/04 15:06:30
// Design Name: 
// Module Name: indirect_testbench
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


module indirect_testbench;
        // Inputs
    reg [63:0] current_trace_addr;
    reg [63:0] last_trace_addr;
    reg [63:0] recent_trace_value;
    reg [63:0] recent_last_trace_value;
    reg history_trace_is_stride;
    reg enable;
    reg clk;

    // Outputs
    wire [15:0] indirect_confidence_out;

    // Instantiate the Unit Under Test (UUT)
    indirect_pattern uut (
        .current_trace_addr(current_trace_addr),
        .last_trace_addr(last_trace_addr),
        .recent_trace_value(recent_trace_value),
        .recent_last_trace_value(recent_last_trace_value),
        .history_trace_is_stride(history_trace_is_stride),
        .enable(enable),
        .clk(clk),
        .indirect_confidence_in(16'h0008),
        .indirect_confidence_out(indirect_confidence_out)
    );

    initial begin
        // Initialize inputs
        current_trace_addr = 64'h0000000000000000;
        last_trace_addr = 64'h0000000000000000;
        recent_trace_value = 64'h0000000000000000;
        recent_last_trace_value = 64'h0000000000000000;
        history_trace_is_stride = 1'b0;
        enable = 1'b1;
        clk = 1'b0;

        // Wait for a few clock cycles
        #10;

        // Toggle clock signal to start simulation
        forever #5 clk = ~clk;

    end

    always @ (posedge clk) begin
        // Update inputs
        current_trace_addr <= $random;
        last_trace_addr <= $random;
        recent_trace_value <= $random;
        recent_last_trace_value <= $random;
        history_trace_is_stride <= $random;
        enable <= $random;

        // Wait for a few clock cycles
        #10;

        // Display outputs
        $display("indirect_confidence_out = %h", indirect_confidence_out);

    end


endmodule
