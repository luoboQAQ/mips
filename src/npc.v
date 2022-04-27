`timescale 1ns/10ps
`include "ctrl_encode_def.v"
module npc(PC, NPCOp,IMM, NPC);
//当前指令地址
input [31:2] PC;
//下一条指令地址变化类型,来自ctrl
input [2:0] NPCOp;
//指令中的地址信息
input [25:0] IMM;
//下一条指令地址
output reg [31:2] NPC;

always @(*) begin
    case (NPCOp)//增加指令时，还会有其他的操作，这里只用到下面三种
        `NPC_PLUS4:
            NPC = PC + 1;//顺序 为什么+1不是+4?
        //下面这两个不是很理解
        `NPC_BRANCH:
            NPC=PC+1+{{14{IMM[15]}},
                      IMM[15:0]};//分支
        `NPC_JUMP:
            NPC = {PC[31:28],
                   IMM[25:0]};//跳转
        default:
            NPC = PC ;//不变
    endcase
end
endmodule