`timescale 1ns/10ps
`include "ctrl_encode_def.v"
module npc(PC, NPCOp, IMM, RS, NPC);
//当前指令地址
input [31: 0] PC;
//下一条指令地址变化类型,来自ctrl
input [2: 0] NPCOp;
//指令中的地址信息
input [25: 0] IMM;
//指令中的操作数
input [31: 0] RS;
//下一条指令地址
output reg [31: 0] NPC;

always @( * ) begin
    case (NPCOp)
        //顺序
        `NPC_PLUS4:
            NPC = PC + 4;
        //分支
        `NPC_BRANCH:
            NPC = PC + 4 + {{14{IMM[15]}}, IMM[15: 0], 2'b00};
        //跳转
        `NPC_JUMP:
            NPC = {PC[31: 28], IMM[25: 0], 2'b00};
        //JR指令
        `NPC_JR:
            NPC = RS;
        default:
            NPC = PC;
    endcase
end
endmodule