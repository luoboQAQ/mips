`timescale 1ns / 1ps
`include "ctrl_encode_def.v" 
//扩展模块
module Extend( Imm16, EXTOp, Imm32 );
//指令中的 16 位立即数
input [15: 0] Imm16;
//拓展类型
input [1: 0]EXTOp;
//拓展后数据
output reg [31: 0] Imm32;

always @( * ) begin
    case (EXTOp)
        //0拓展
        `EXT_ZERO:
            Imm32 = {16'd0, Imm16};
        //符号拓展
        `EXT_SIGNED:
            Imm32 = {{16{Imm16[15]}}, Imm16};
        //`EXT_HIGHPOS: Imm32 = {Imm16,16'd0};//lui
        default:
            ;
    endcase
end

endmodule
