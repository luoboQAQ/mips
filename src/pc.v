`timescale 1ns/10ps 
//PCģ��
module pc(
    //��һ��ָ���ַ�����ڸ���PC�������λ����
    input [31: 2] NPC,
    //ʱ���ź�
    input Clk,
    //�����ź�
    input Reset,
    //��ǰָ���ַ
    output reg [31: 2] PC
);

//��ʼ����ַ��ע����������֤�Ĳ��Թ��߻�ο�����ƥ��
initial begin
    PC = 30'h00100000;
end

always @ (posedge Clk or posedge Reset) begin
    if (Reset == 1'b1) begin
        //��ʼ��
        PC <= 30'h00100000;
    end
    else begin
        //����һ��ָ���ַ���� pc
        PC <= NPC;
    end
end

endmodule