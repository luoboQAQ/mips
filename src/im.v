`timescale 1ns/10ps
module im_4k(addr, dout);//���� im_4k ģ�飬�üĴ���ʵ�ֵ� 4k ֻ���ڴ�
input [11:2] addr;//�ڴ��ַ��Ѱַ��Χ2^10, �� �� 0 �� ʼ �� �� �� һ �� һ �� �� 00 ��01.10.11,4B=32b
output [31:0] dout;//���ָ��
reg [31:0] im[1023:0]; //ʵ�ִ洢���ܵ���ʱ�Ĵ�������
integer i;//�������ͱ��� i
/*
��ʼ��ָ��Ĵ���
*/
initial begin
    for(i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end
    $readmemh("test.txt", im);//�� test.txt ��ȡָ� im ��
end
assign dout = im[addr]; //��������ĵ�ַ�����Ӧ������
endmodule