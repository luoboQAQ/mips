`timescale 1ns/10ps
`include "ctrl_encode_def.v"
module npc(PC, NPCOp,IMM, NPC);
//��ǰָ���ַ
input [31:2] PC;
//��һ��ָ���ַ�仯����,����ctrl
input [2:0] NPCOp;
//ָ���еĵ�ַ��Ϣ
input [25:0] IMM;
//��һ��ָ���ַ
output reg [31:2] NPC;

always @(*) begin
    case (NPCOp)//����ָ��ʱ�������������Ĳ���������ֻ�õ���������
        `NPC_PLUS4:
            NPC = PC + 1;//˳�� Ϊʲô+1����+4?
        //�������������Ǻ����
        `NPC_BRANCH:
            NPC=PC+1+{{14{IMM[15]}},
                      IMM[15:0]};//��֧
        `NPC_JUMP:
            NPC = {PC[31:28],
                   IMM[25:0]};//��ת
        default:
            NPC = PC ;//����
    endcase
end
endmodule