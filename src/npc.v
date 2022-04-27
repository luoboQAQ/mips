`timescale 1ns/10ps
`include "ctrl_encode_def.v" //���� C ���Եİ���ͷ�ļ���������Ҳ�����Ƶ�
module npc(PC, NPCOp,IMM, NPC);//���� npc ģ�飬
input [31:2] PC;//��ǰָ���ַ
input [2:0] NPCOp;//��һ��ָ���ַ�仯����
input [25:0]IMM;//ָ���еĵ�ַ��Ϣ
output [31:2] NPC;//��һ��ָ���ַ
reg [31:2] NPC;//���Ϊ�Ĵ����ͱ���
always @(*) begin//*�ű�ʾ�����е���������ñ仯���ᴥ��
    case (NPCOp)//����ָ��ʱ�������������Ĳ���������ֻ�õ��������֡�
        `NPC_PLUS4:
            NPC = PC + 1;//˳��
        `NPC_BRANCH:
            NPC=PC+1+{{14{IMM[15]}},
                      IMM[15:0]};//��֧
        `NPC_JUMP:
            NPC = {PC[31:28],
                   IMM[25:0]};//��ת
        default:
            NPC = PC ;//����
    endcase
end // end always
endmodule