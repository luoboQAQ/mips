`timescale 1ns/10ps
`include "ctrl_encode_def.v"
module npc(PC, NPCOp, IMM, RS, NPC);
//��ǰָ���ַ
input [31: 0] PC;
//��һ��ָ���ַ�仯����,����ctrl
input [2: 0] NPCOp;
//ָ���еĵ�ַ��Ϣ
input [25: 0] IMM;
//ָ���еĲ�����
input [31: 0] RS;
//��һ��ָ���ַ
output reg [31: 0] NPC;

always @( * ) begin
    case (NPCOp)
        //˳��
        `NPC_PLUS4:
            NPC = PC + 4;
        //��֧
        `NPC_BRANCH:
            NPC = PC + 4 + {{14{IMM[15]}}, IMM[15: 0], 2'b00};
        //��ת
        `NPC_JUMP:
            NPC = {PC[31: 28], IMM[25: 0], 2'b00};
        //JRָ��
        `NPC_JR:
            NPC = RS;
        default:
            NPC = PC;
    endcase
end
endmodule