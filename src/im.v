`timescale 1ns/10ps 
//ָ��Ĵ���
module im_4k(addr, dout);
//�ڴ��ַ��Ѱַ��Χ2^10
input [11: 0] addr;
//���ָ��
output [31: 0] dout;
reg [31: 0] im[1023: 0];
integer i;

//��ʼ��ָ��Ĵ���
initial begin
    for (i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end

    //�� test.txt ��ȡָ� im ��
    $readmemh("test.txt", im);
end

//������ʵ��CPU��8λ�洢,��������32λ�洢,������Ҫ��4�õ���ʵ�ĵ�ַ�±�
wire [11: 0] add;
assign add = addr == 0 ? 0 : addr / 4;
//��������ĵ�ַ�����Ӧ������
assign dout = im[add];
endmodule