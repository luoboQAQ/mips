`timescale 1ns/10ps
//ָ��Ĵ���
module im_4k(addr, dout);
//�ڴ��ַ��Ѱַ��Χ2^10,01λΪ��ʹ+1�൱��+4
input [11:2] addr;
//���ָ��
output [31:0] dout;
reg [31:0] im[1023:0];
integer i;

//��ʼ��ָ��Ĵ���
initial begin
    for(i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end
    //�� test.txt ��ȡָ� im ��
    $readmemh("test.txt", im);
end
//��������ĵ�ַ�����Ӧ������
assign dout = im[addr];
endmodule