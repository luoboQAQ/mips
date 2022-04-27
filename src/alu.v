`timescale 1ns/10ps
`include "ctrl_encode_def.v"
module alu_32(A, B, ALUOp, C,Zero);
input [31:0] A; //���� 32 λԴ������
input [31:0] B;
input [4:0] ALUOp; //�ӿ��Ƶ�Ԫ���Ŀ����źţ���������ѡ��
output [31:0] C; //32 λ������
output Zero; //��ָ֧����ж�
reg [31:0] C;//���
wire [32:0]AS={A[31],A[31:0]};
wire [32:0]AZ={1'd0,A[31:0]};
wire [32:0] BZ={1'd0,B[31:0]};
wire [32:0] BS={B[31],B[31:0]};
reg extend_f=0;
always @( ALUOp or A or B ) begin
    C=0;
    //#1;
    case ( ALUOp )
        `ALUOp_ADD:
            {extend_f,C} = AS + BS;
        `ALUOp_ADDI:
            {extend_f,C} = AS + BS;
        `ALUOp_SUBU:
            C=A-B;
        `ALUOp_SLT:
            C=(A[31]&&B[31]||!A[31]&&!B[31])?(A<B)?1:0:(A[31]&&!B[31])?1:0;
        `ALUOp_OR:
            C = A | B;
        `ALUOp_SLL:
            C=B<<A[4:0];
        `ALUOp_BEQ:
            C=(A==B)?32'd1:32'd0;
        default:
            C=0 ;
    endcase
end // end always;
assign Zero=C[0];
endmodule