`timescale 1ns / 1ps
`include "ctrl_encode_def.v" 
//��չģ��
module Extend( Imm16, EXTOp, Imm32 );
//ָ���е� 16 λ������
input [15: 0] Imm16;
//��չ����
input [1: 0]EXTOp;
//��չ������
output reg [31: 0] Imm32;

always @( * ) begin
    case (EXTOp)
        //0��չ
        `EXT_ZERO:
            Imm32 = {16'd0, Imm16};
        //������չ
        `EXT_SIGNED:
            Imm32 = {{16{Imm16[15]}}, Imm16};
        //`EXT_HIGHPOS: Imm32 = {Imm16,16'd0};//lui
        default:
            ;
    endcase
end

endmodule
