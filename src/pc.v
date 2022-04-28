`timescale 1ns/10ps 
//PCģ��
module pc(NPC, Clk, Reset, PC);
//��һ��ָ���ַ�����ڸ���PC
input [31: 0] NPC;
//ʱ���ź�
input Clk;
//�����ź�
input Reset;
//��ǰָ���ַ
output reg [31: 0] PC;

//��ʼ����ַ��ע����������֤�Ĳ��Թ��߻�ο�����ƥ��
initial begin
    PC = 32'h0000_3000;
end

always @ (posedge Clk or posedge Reset) begin
    if (Reset == 1'b1) begin
        //��ʼ��
        PC <= 32'h0000_3000;
    end
    else begin
        //����һ��ָ���ַ���� pc
        PC <= NPC;
    end
end

endmodule