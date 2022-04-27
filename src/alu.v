`timescale 1ns/10ps
`include "ctrl_encode_def.v" 
//ALU����ģ��
module alu_32(A, B, ALUOp, C, Zero);
//���� 32 λԴ������
input [31: 0] A;
input [31: 0] B;
//�ӿ��Ƶ�Ԫ���Ŀ����źţ���������ѡ��
input [4: 0] ALUOp;
//32 λ������
output reg [31: 0] C;
//��ָ֧����ж�
output Zero;
assign Zero = C[0];

//S��ʾ�з�����,Z��ʾ�޷�����
wire [32: 0] AS = {A[31], A[31: 0]};
wire [32: 0] AZ = {1'd0, A[31: 0]};
wire [32: 0] BZ = {1'd0, B[31: 0]};
wire [32: 0] BS = {B[31], B[31: 0]};
reg extend_f = 0;
always @( ALUOp or A or B ) begin
    C = 0;
    case ( ALUOp )
        `ALUOp_ADD:
            {extend_f, C} = AS + BS;
        `ALUOp_ADDI:
            {extend_f, C} = AS + BS;
        `ALUOp_SUBU:
            C = A - B;
        `ALUOp_SLT:
            C = (A[31] && B[31] || !A[31] && !B[31]) ? (A < B) ? 1 : 0 : (A[31] && !B[31]) ? 1 : 0;
        `ALUOp_OR:
            C = A | B;
        `ALUOp_SLL:
            C = B << A[4: 0];
        `ALUOp_BEQ:
            C = (A == B) ? 32'd1 : 32'd0;
        default:
            C = 0;
    endcase
end
endmodule