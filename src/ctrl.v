`timescale 1ns/10ps
`include "ctrl_encode_def.v" //引用头文件，以使用宏定义，下文中以`开头的大写字符段全部都是宏定义，用具体的有意义的字符替换了二进制操作符，增加了程序的可读性和以维护性，而具体的操作符可在对应的头文件中查看
`include "instruction_def.v"
module ctrl(opcode, funct,rt,nop,Zero, RFWr, ALUOp,NPCOp, BSel,EXTOp,ASel,GPRSel,WDSel); // 定义控制模块
/*
*确定指令类型
*/
input [5:0] opcode;//opcode 和 funct 字段用于区分指令类型;
input [5:0] funct;
input [4:0] rt;
/*
*控制信号
*/
input nop,Zero;//空指令与分支指令判断
output RFWr;//通用寄存器写信号
output [4:0] ALUOp;//alu 计算类型
output [2:0] NPCOp;//下一条指令地址变化类型
output ASel,BSel;//alu 操作数选择
output [1:0]EXTOp;//拓展数据类型
output [1:0]GPRSel,WDSel;//存储数据选择,分别选择通用寄存器的标号、存入寄存器的数据
wire RType; // Type of R-Type Instruction
wire IType; // Tyoe of Imm Instruction
wire BrType; // Type of Branch Instruction
wire JType; // Type of Jump Instruction
wire Type_other;
/*
*控制信号
*/
wire SignExtend;//数据扩展
wire shamt_sign;//移位信号
reg flush;//清零信号，暂时无用
/* instructions judgement */
wire addi;// Type of I-Type Instruction
wire Rori;
wire beq;// Type of B-Type Instruction
wire j;// Type of J-Type Instruction
//r-r
assign RType = (opcode == `INSTR_RTYPE_OP)&!nop;//指令类型判断语句，如果是 R 指令 Rtype=1，否则 Rtype=0，这样写是为了简化下面需要用到判断的语句的复杂性，增加了程序的可读性
//r-i
assign addi =(opcode ==`INSTR_ADDI_OP);//addi 操作判断语句
assign Rori=(opcode==`INSTR_ORI_OP);
assign IType = addi|Rori;//若是addi或ori操作，则指令类型为 I 类型，若增加指令，则也相应会增加更多的或操作。下面同理
//brtype
assign beq =(opcode == `INSTR_BEQ_OP);
assign BrType=beq;
//jump
assign j =(opcode == `INSTR_J_OP);
assign JType=j;
//other
assign Type_other=(!JType&&!RType&&!IType&&!BrType);
assign SignExtend = addi ;//addi 操作需要数据扩展，若增加其他需要数据扩展的指令，这里也需要增加。
assign shamt_sign =(opcode == `INSTR_RTYPE_OP)&&(funct ==`INSTR_SLL_FUNCT);//若指令是 sll，则需要进行移位操作
reg RFWr;//输出定义为寄存器型变量
reg DMWr;
reg [1:0] EXTOp;
reg [4:0] ALUOp;
reg [2:0] NPCOp;
reg [1:0] GPRSel;
reg [2:0] WDSel;
reg BSel;
reg ASel;
always @(*) begin
    if(nop) begin //若是空指令操作
        NPCOp = 0;
        RFWr = 1'b0;
        EXTOp = 0;
        GPRSel = 0;
        WDSel = 0;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 0;
    end
    else if (RType) begin//若是 R 指令操作
        NPCOp = `NPC_PLUS4;//NPC 选择顺序执行的指令
        RFWr = 1'b1;//通用寄存器写信号为1，允许写
        EXTOp = 0;
        GPRSel = `GPRSel_RD;//选择将数据写入的寄存器，该寄存器地址存放在 rd 中
        WDSel = `WDSel_FromALU;//写入通用寄存器的数据来自 alu 的运算结果
        BSel <= 1'b0;//ALU 运算器的 B 源操作数来自通用寄存器的 readD2
        ASel <= (shamt_sign)?1'b1:1'b0;//若是移位操作，则 A 源操作数来自 shamt 字段，是一个立即数；否则 A 源操作数选择 readD1
        flush = 0;
        begin
            case (funct)
                `INSTR_ADD_FUNCT:
                    ALUOp= `ALUOp_ADD; //ALU 进行 add 运算
                `INSTR_SUBU_FUNCT:
                    ALUOp= `ALUOp_SUBU; //ALU 进行 subu 运算
                `INSTR_SLT_FUNCT:
                    ALUOp =`ALUOp_SLT; //ALU 进行 slt 运算
                `INSTR_SLL_FUNCT:
                    ALUOp=`ALUOp_SLL;
                //ALU 进行 sll 运算
                default:
                    ALUOp=`ALUOp_ERROR;
            endcase
        end
    end
    else if (IType == 1'b1) begin//若是 I 类型
        NPCOp = `NPC_PLUS4;
        RFWr = 1;
        if (SignExtend) //需要符号扩展
            EXTOp = `EXT_SIGNED;
        else
            EXTOp = 0;
        GPRSel = `GPRSel_RT;//选择 rt 作为目标寄存器地址
        WDSel = `WDSel_FromALU;
        BSel = 1'b1;//选择扩展后的立即数作为 B 源操作数
        ASel = 1'b0;
        flush = 0;
        if(addi)
            ALUOp =`ALUOp_ADDI;
        //ALU 进行 addi 运算
        if(Rori)
            ALUOp=`ALUOp_OR; //ALU进行 or 运算
    end
    else if(BrType ) begin//若是分支指令类型
        NPCOp =(Zero)?`NPC_BRANCH:`NPC_PLUS4;//Zero 为 1 表示发生跳转，则 NPCOp 选择跳转；否则顺序执行
        RFWr = 1'b0;
        EXTOp = 0;
        GPRSel =`GPRSel_RD;
        WDSel = `WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        flush = 0;
        begin
            if(beq)
                ALUOp=`ALUOp_BEQ;
        end
    end
    else if (JType) begin
        NPCOp = `NPC_JUMP;
        RFWr = 1'b0;
        EXTOp = `EXT_SIGNED;
        GPRSel = 0;
        WDSel =`WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 0;
        case(opcode)
            `INSTR_J_OP:
                ALUOp=`ALUOp_ERROR;
            default:
                ALUOp=`ALUOp_ERROR;
        endcase
    end
    else if(Type_other) begin
        NPCOp = `NPC_EXCEPT;//
        RFWr = 1'b0;
        EXTOp = 0;
        GPRSel = 0;
        WDSel = 0;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 1;//
    end
    else begin
        NPCOp = 0;
        RFWr = 1'b0;
        EXTOp = 0;
        GPRSel = 0;
        WDSel = 0;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 0;
    end
end
endmodule