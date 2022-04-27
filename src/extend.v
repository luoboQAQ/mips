`timescale 1ns / 1ps
`include "ctrl_encode_def.v"
module Extend( Imm16, EXTOp, Imm32 );//定义扩展模块
input [15:0] Imm16;//指令中的 16 位立即数
input [1:0]EXTOp;//拓展类型
output [31:0] Imm32;//拓展后数据
reg [31:0] Imm32;
always @(*) begin
    case (EXTOp)
        `EXT_ZERO:
            Imm32 = {16'd0,
                     Imm16}; //0 拓展
        `EXT_SIGNED:
            Imm32 =
            {{16{Imm16[15]}}, Imm16}; //符号拓展
        //`EXT_HIGHPOS: Imm32 = {Imm16,16'd0};//lui
        default: ;
    endcase
end // end always
endmodule
