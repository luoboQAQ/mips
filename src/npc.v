`timescale 1ns/10ps
`include "ctrl_encode_def.v" //类似 C 语言的包含头文件，功能上也是类似的
module npc(PC, NPCOp,IMM, NPC);//定义 npc 模块，
input [31:2] PC;//当前指令地址
input [2:0] NPCOp;//下一条指令地址变化类型
input [25:0]IMM;//指令中的地址信息
output [31:2] NPC;//下一条指令地址
reg [31:2] NPC;//输出为寄存器型变量
always @(*) begin//*号表示对所有的输入变量得变化都会触发
    case (NPCOp)//增加指令时，还会有其他的操作，这里只用到下面三种。
        `NPC_PLUS4:
            NPC = PC + 1;//顺序
        `NPC_BRANCH:
            NPC=PC+1+{{14{IMM[15]}},
                      IMM[15:0]};//分支
        `NPC_JUMP:
            NPC = {PC[31:28],
                   IMM[25:0]};//跳转
        default:
            NPC = PC ;//不变
    endcase
end // end always
endmodule