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
            {extend_f, C} <= AS + BS;
        `ALUOp_ADDU:
            {extend_f, C} <= AS + BS;
        `ALUOp_SUB:
            C <= A - B;
        `ALUOp_SUBU:
            C <= A - B;
        `ALUOp_AND:
            C <= A & B;
        `ALUOp_OR:
            C <= A | B;
        `ALUOp_XOR:
            C <= A ^ B;
        `ALUOp_NOR:
            C <= ~(A | B);
        `ALUOp_SLT:
            C <= (A[31] && B[31] || !A[31] && !B[31]) ? (A < B) ? 1 : 0 : (A[31] && !B[31]) ? 1 : 0;
        `ALUOp_SLTU:
            C <= (A[31] && B[31] || !A[31] && !B[31]) ? (A < B) ? 1 : 0 : (A[31] && !B[31]) ? 1 : 0;
        `ALUOp_SLL:
            C <= B << A[4: 0];
        `ALUOp_SRL:
            C <= B >> A[4: 0];
        `ALUOp_SRA:
            C <= $signed(B) >>> A[4: 0];
        `ALUOp_SLLV:
            C <= B << A[4: 0];
        `ALUOp_SRLV:
            C <= B >> A[4: 0];
        `ALUOp_SRAV:
            C <= $signed(B) >>> A[4: 0];

        `ALUOp_ADDI:
            {extend_f, C} <= AS + BS;
        `ALUOp_ADDIU:
            {extend_f, C} <= AS + BS;
        `ALUOp_ANDI:
            C <= A & B;
        `ALUOp_ORI:
            C <= A | B;
        `ALUOp_XORI:
            C <= A ^ B;
        `ALUOp_LUI:
            C <= (B << 16) & 32'hffff0000;
        `ALUOp_BEQ:
            C <= (A == B) ? 32'd1 : 32'd0;
        `ALUOp_BNE:
            C <= (A != B) ? 32'd1 : 32'd0;
        `ALUOp_SLTI:
            C <= (A[31] && B[31] || !A[31] && !B[31]) ? (A < B) ? 1 : 0 : (A[31] && !B[31]) ? 1 : 0;
        `ALUOp_SLTIU:
            C <= (A[31] && B[31] || !A[31] && !B[31]) ? (A < B) ? 1 : 0 : (A[31] && !B[31]) ? 1 : 0;

        default:
            C <= 0;
    endcase
end
endmodule