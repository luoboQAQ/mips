`timescale 1ns/10ps 
//���� pc ģ�飬ָ���ַ���Ͳ���������һ��ָ��ĵ�ַ���� pc
module pc(NPC, Clk, Reset, PC);
//��һ��ָ���ַ�����ڸ���PC�������λ����
input [31: 2] NPC;
//ʱ���ź�
input Clk;
//�����ź�
input Reset;
//��ǰָ���ַ�����������Ϊ�Ĵ����ͱ�������ʾ���̿���� always �ڵ�ָ���ź�
output reg [31: 2] PC;

/*
��ʼ����ַ��ע����������֤�Ĳ��Թ��߻�ο�����ƥ��
*/
initial begin
    PC = 30'h00100000; //��ʼ������ͬ mips ����� PC ��ʼֵ��ͬ���˴�Ϊͨ�� mars ��������PC ��ʼֵ
end

always @ (posedge Clk or posedge Reset) begin //�ߵ�ƽ����
    if (Reset == 1'b1) begin //���� pc
        PC <= 30'h00100000; //30'h00000c00;
    end
    else begin //����һ��ָ���ַ���� pc
        PC <= NPC;
    end
end

endmodule