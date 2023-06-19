`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/30 21:57:48
// Design Name: 
// Module Name: pointer_array_pattern
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


module pointer_array_pattern#(parameter window = 500,window_width = $clog2(window),PC_SIZE = 1024,PC_WIDTH=$clog2(PC_SIZE))
(current_trace_addr,recent_trace_value,recent_trace_value_PC,trace_value_PC_confidence,enable,clk,reset,
pointer_array_confidence_in,pointer_array_confidence_out,finish,begin_find_PC);
    input wire [63:0] current_trace_addr;
    input wire [63:0] recent_trace_value;//����Ҫ��������һϵ��recent_trace_value
    input wire [63:0] recent_trace_value_PC;// valueֵԴ�Ե�ָ��PC,���Ժ�valueһ���Ϊ128λ��
    input wire [63:0] trace_value_PC_confidence;//PC||mem_addr||value||8*confidenceһ��棬ͬʱ���recent��
    input wire enable;
    input wire clk;
    input wire reset;
    input wire [15:0] pointer_array_confidence_in;
    output reg [15:0] pointer_array_confidence_out;
    output reg finish;
    output reg begin_find_PC;
    reg [1:0] state;
    reg [window_width:0] count_window;
    reg [PC_WIDTH:0] count_find_PC;
    always @(posedge clk)
    begin
        if(reset)
        begin
            state <= 2'b00;
            count_window <= 0;
            pointer_array_confidence_out <= 0;
            finish <= 0;
            begin_find_PC <= 0;
        end
        case(state)
            2'b00://ָ�����жϣ���recent_trace_value�ṹ�������Ƿ�����ȡ�����ڸõ�ַ��ֵ��trace
            begin
                if (current_trace_addr == recent_trace_value)
                begin
                    state <= 2'b01;//�ҵ��˷��ϵ�ֵ
                end
                count_window <= count_window + 1;
                if (count_window == window)
                begin
                    state <= 2'b10;//û�ҵ����ʵ�ֵ
                end
            end
            2'b01:
            begin
                if(trace_value_PC_confidence[15] == 1)//����ָ��������
                begin
                    pointer_array_confidence_out <= pointer_array_confidence_in + 1;
                    if (pointer_array_confidence_out[9] == 1)
                    begin
                        pointer_array_confidence_out[15] <= 1;
                        pointer_array_confidence_out[14] <= 0;
                    end
                end
                else
                begin
                    state <= 2'b10;
                end
            end
            2'b10://����������
            begin
                if (pointer_array_confidence_in[8:0] > 9'd3)
                begin
                    pointer_array_confidence_out [8:0] <= pointer_array_confidence_in[8:0] >> 1 ;
                end
                
                if (pointer_array_confidence_in [8:0] <= 9'd3)
                begin
                    pointer_array_confidence_out[14] <= 1'b1;
                    pointer_array_confidence_out[15] <= 1'b0;
                end
                state <= 2'b11;
            end
            2'b11:
            begin
                finish <= 1;
            end
        endcase
    end
endmodule
