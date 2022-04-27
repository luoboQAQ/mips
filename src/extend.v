`timescale 1ns / 1ps
`include "ctrl_encode_def.v"
module Extend( Imm16, EXTOp, Imm32 );//������չģ��
input [15:0] Imm16;//ָ���е� 16 λ������
input [1:0]EXTOp;//��չ����
output [31:0] Imm32;//��չ������
reg [31:0] Imm32;
always @(*) begin
    case (EXTOp)
        `EXT_ZERO:
            Imm32 = {16'd0,
                     Imm16}; //0 ��չ
        `EXT_SIGNED:
            Imm32 =
            {{16{Imm16[15]}}, Imm16}; //������չ
        //`EXT_HIGHPOS: Imm32 = {Imm16,16'd0};//lui
        default: ;
    endcase
end // end always
endmodule
