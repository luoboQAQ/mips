`timescale 1ns/10ps 
//�Ĵ���ģ��
module gpr(clk, reset, we, addr1, addr2, addr3, addr4,inputdata, RD1, RD2,RD3);
input clk;
input reset; //�����ź�
input we; //�ӿ��Ƶ�Ԫ���Ķ�д�����ź�
input [4: 0] addr1; //rs
input [4: 0] addr2; //rt
input [4: 0] addr3; //rd
input [4: 0] addr4; //shamt
input [31: 0] inputdata; //����[rd]������
output [31: 0] RD1; //[rs]����
output [31: 0] RD2; //[rt]����
output [31: 0] RD3; //[shamt]����
reg [31: 0] registers [31: 0]; //�Ĵ����ѵ�ʵ��
integer i = 0;

//���� addr3==addr1||addr3==addr2 ʱ�����RD1,RD2 ����  Ϊʲô��
assign RD1 = (clk == 1) ? registers[addr1] : RD1; //�ӼĴ����ж�Ӧ��ַ addr1 ��λ��ȡ���ݵ� RD1
assign RD2 = (clk == 1) ? registers[addr2] : RD2; //�ӼĴ����ж�Ӧ��ַ addr2 ��λ��ȡ���ݵ� RD2
assign RD3 = (clk == 1) ? registers[addr4] : RD3; //�ӼĴ����ж�Ӧ��ַ addr2 ��λ��ȡ���ݵ� RD2

//��ʼ���Ĵ���
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'h00000000;
    end
end

always @ ( posedge reset or negedge clk) begin //�͵�ƽ��������
    //����Ƿ�λ
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h00000000;
        end
    end
    else if (we & addr3 != 5'h00) begin //�� 0 �żĴ������ɱ�����
        //������д��rd��ַ��Ӧ�ļĴ���
        registers[addr3] <= inputdata;
        // $display("addr: %d, data: %4h",addr3, inputdata);
    end
end
endmodule