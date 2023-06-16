`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/07 12:08:23
// Design Name: 
// Module Name: offset_array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// �Ƚ��ȳ���ѭ������
//todo:����ֻͨ��top ģ�����ӣ�offset����current_trace_addr - last_trace_addr��
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module offset_array#(parameter WIDTH = 64,parameter ASIZE = 128, parameter PC_SIZE= 64'd1024, parameter A_WIDTH=$clog2(ASIZE))
(clk, reset, add_element, read, data_in, data_out,PC,end_add, end_reset,end_read);
    input wire clk;
    input wire reset;
    input wire add_element;
    input wire read;
    input wire [WIDTH-1:0]data_in;
    input wire [WIDTH-1:0]PC;
    output reg [WIDTH-1:0]data_out;
    output reg end_add;
    output reg end_reset;
    output reg end_read;
    reg [WIDTH-1:0] array [0:PC_SIZE-1][0:ASIZE-1];
    reg [WIDTH-1:0] tail;
    reg [WIDTH-1:0] read_count;
    reg [WIDTH-1:0] reset_count_1;
    reg [A_WIDTH:0] reset_count_2;
    
    reg [15:0] hash;
    reg [15:0] index;
    
    reg [1:0] add_state;
    reg [1:0] reset_state;
    reg [1:0] read_state;
    always@(*)
    begin
        hash <= data_in[15:0]^data_in[31:16]^data_in[47:32]^data_in[63:48];
    end
    
    always@(posedge clk)
    begin
        if (reset)
        begin
            reset_state <= 2'b00;
            reset_count_1 <= 0;
            reset_count_2 <= 0;
        end
        case(reset_state)
            2'b00:begin
                array[reset_count_1][reset_count_2] <= 64'b0;
                reset_count_2 <= reset_count_2 + 1;
                if (reset_count_2 == ASIZE)
                begin
                    reset_state <= 2'b01;
                    reset_count_2 <= 0;
                end 
            end
            2'b01:begin
                reset_count_1 <= reset_count_1 + 1;
                array[reset_count_1][reset_count_2] <= 64'b0;
                if (reset_count_1 == PC_SIZE)
                begin
                    reset_state <= 2'b10;
                end
                else
                begin
                    reset_state <= 2'b00;
                end
            end
            2'b10:
            begin
                end_reset <= 1;
            end
        endcase
        if (add_element)
        begin
            end_add <= 0;
            add_state <= 2'b00;   
            tail <= 1;    
        end
        if (read)
        begin
            end_read <= 0;
            read_state <= 2'b00;
            index <= hash;
            read_count <= 1;
        end
        case(read_state)
            2'b00:
            begin
                if (array[hash][0] == PC)
                begin
                    data_out <= array[hash][read_count];
                    read_count <= read_count+1;
                    if (read_count == ASIZE)
                    begin
                        read_state <= 2'b10;
                    end
                end
                else
                begin
                    read_state <= 2'b01;
                end
            end
            2'b01:
            begin
                if (array[index][0] == PC)
                begin
                    data_out <= array[index][read_count];
                    read_count <= read_count+1;
                    if (read_count == ASIZE)
                    begin
                        read_state <= 2'b10;
                    end
                end
                else
                begin
                    index <= index+1;
                end
                if (index == PC_SIZE)
                begin
                    data_out <= 64'b0;
                    read_state <= 2'b10;
                end
            end
            2'b10:
            begin
                end_read <= 1;
            end
        endcase
        case(add_state)
            2'b00:begin
                if (array[hash][1] == 64'b0)// ���λ��δ����κ�����
                begin
                    array[hash][0] <= PC;
                    array[hash][1] <= data_in;
                    add_state <= 2'b10;
                end
                else if (array[hash][0] == PC)//��λ���Ѿ����ͬ��PC������
                begin
                    add_state <= 2'b11;
                end
                else if (array[hash][1] != 64'b0)//��λ�ô�Ź�����PC�����ݣ���Ҫ����
                begin
                    index <= hash+1;
                    add_state <= 2'b01;
                end
            end
            2'b01:begin
                if (array[index][1] == 64'b0)//������һ��λ�ã����ǿ�λ
                begin
                    array[index][0] <= PC;
                    array[index][1] <= data_in;
                    add_state <= 2'b10;
                end
                else if (array[index][1] != 64'b0)//�����ǿ�λ
                begin
                    index <= index+1;
                end
            end
            2'b10:
            begin
                end_add <= 1'b1;// ��֪�ϲ�ģ����������
            end
            2'b11:
            begin
                if(array[hash][tail] == 64'b0)
                begin
                    array[hash][tail] <= data_in;
                    add_state <= 2'b10;
                end
                else if (array[hash][tail] != 64'b0 && tail+1!=ASIZE)
                begin
                    tail <= tail+1;
                end
                else if (array[hash][tail] != 64'b0 && tail+1==ASIZE)
                begin
                    tail <= 1;
                end
            end
        endcase
    end

endmodule
