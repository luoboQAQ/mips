`timescale 1ns/10ps
`include "ctrl_encode_def.v"
`include "instruction_def.v" 
//控制模块
module ctrl(opcode, funct, rt, nop, Zero, RFWr, DMWr, ALUOp, NPCOp, BSel, EXTOp, ASel, GPRSel, WDSel);
//指令信号
input [5: 0] opcode;
input [5: 0] funct;
input [4: 0] rt;
//空指令与分支指令判断
input nop, Zero;
//通用寄存器写信号
output reg RFWr;
//数据存储器写信号
output reg DMWr;
//alu控制指令
output reg [4: 0] ALUOp;
//下一条指令地址变化类型
output reg [2: 0] NPCOp;
//alu 操作数选择
output reg ASel, BSel;
//拓展数据类型
output reg [1: 0] EXTOp;
//存储数据选择,分别选择通用寄存器的标号、存入寄存器的数据
output reg [1: 0] GPRSel;
output reg [2: 0] WDSel;

//清零信号，暂时无用
reg flush;

//指令类型判断
//r-r
assign RType = (opcode == `INSTR_RTYPE_OP) & !nop;
//r-i
assign addi = (opcode == `INSTR_ADDI_OP);
assign addiu = (opcode == `INSTR_ADDIU_OP);
assign andi = (opcode == `INSTR_ANDI_OP);
assign ori = (opcode == `INSTR_ORI_OP);
assign xori = (opcode == `INSTR_XORI_OP);
assign lui = (opcode == `INSTR_LUI_OP);
assign lw = (opcode == `INSTR_LW_OP);
assign sw = (opcode == `INSTR_SW_OP);
assign slti = (opcode == `INSTR_SLTI_OP);
assign sltiu = (opcode == `INSTR_SLTIU_OP);
assign IType = addi | addiu | andi | ori | xori | lui | lw | sw | slti | sltiu;
//brtype
assign beq = (opcode == `INSTR_BEQ_OP);
assign bne = (opcode == `INSTR_BNE_OP);
assign BrType = beq | bne;
//jump
assign j = (opcode == `INSTR_J_OP);
assign jal = (opcode == `INSTR_JAL_OP);
assign JType = j | jal;
//other
assign Type_other = (!JType && !RType && !IType && !BrType);

//需要数据扩展的指令
assign SignExtend = addi | addiu | lw | sw;
//需要进行移位操作
assign shamt_sign = (opcode == `INSTR_RTYPE_OP) && (
           funct == `INSTR_SLL_FUNCT ||
           funct == `INSTR_SRL_FUNCT ||
           funct == `INSTR_SRA_FUNCT);

always @( * ) begin
    if (nop) begin
        //若是空指令操作
        NPCOp = 0;
        RFWr = 1'b0;
        DMWr = 1'b0;
        EXTOp = 0;
        GPRSel = 0;
        WDSel = 0;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 0;
    end
    else if (RType) begin
        //若是 R 指令操作
        //NPC 选择顺序执行的指令
        NPCOp = `NPC_PLUS4;
        //通用寄存器写信号为1，允许写
        RFWr = 1'b1;
        DMWr = 1'b0;
        EXTOp = 0;
        //选择将数据写入的寄存器，该寄存器地址存放在 rd 中
        GPRSel = `GPRSel_RD;
        //写入通用寄存器的数据来自 alu 的运算结果
        WDSel = `WDSel_FromALU;
        //ALU 运算器的 B 源操作数来自通用寄存器的 readD2
        BSel <= 1'b0;
        //若是移位操作，则 A 源操作数来自 shamt 字段，是一个立即数；否则 A 源操作数选择 readD1
        ASel <= (shamt_sign) ? 1'b1 : 1'b0;
        flush = 0;
        begin
            //指定 ALU 操作类型
            case (funct)
                `INSTR_ADD_FUNCT:
                    ALUOp = `ALUOp_ADD;
                `INSTR_ADDU_FUNCT:
                    ALUOp = `ALUOp_ADDU;
                `INSTR_SUB_FUNCT:
                    ALUOp = `ALUOp_SUB;
                `INSTR_SUBU_FUNCT:
                    ALUOp = `ALUOp_SUBU;
                `INSTR_AND_FUNCT:
                    ALUOp = `ALUOp_AND;
                `INSTR_OR_FUNCT:
                    ALUOp = `ALUOp_OR;
                `INSTR_XOR_FUNCT:
                    ALUOp = `ALUOp_XOR;
                `INSTR_NOR_FUNCT:
                    ALUOp = `ALUOp_NOR;
                `INSTR_SLT_FUNCT:
                    ALUOp = `ALUOp_SLT;
                `INSTR_SLTU_FUNCT:
                    ALUOp = `ALUOp_SLTU;
                `INSTR_SLL_FUNCT:
                    ALUOp = `ALUOp_SLL;
                `INSTR_SRL_FUNCT:
                    ALUOp = `ALUOp_SRL;
                `INSTR_SRA_FUNCT:
                    ALUOp = `ALUOp_SRA;
                `INSTR_SLLV_FUNCT:
                    ALUOp = `ALUOp_SLLV;
                `INSTR_SRLV_FUNCT:
                    ALUOp = `ALUOp_SRLV;
                `INSTR_SRAV_FUNCT:
                    ALUOp = `ALUOp_SRAV;
                `INSTR_JR_FUNCT: begin
                    NPCOp = `NPC_JR;
                    //ASel = 1'b0;
                    BSel = 1'b1;
                    ALUOp = `ALUOp_NOP;
                end
                default:
                    ALUOp = `ALUOp_ERROR;
            endcase
        end
    end
    else if (IType) begin
        //若是 I 类型指令操作
        NPCOp = `NPC_PLUS4;
        if(sw)
            RFWr = 0;
        else if(lw) begin
            RFWr = 1;
            WDSel = `WDSel_FromMem;
        end
        else begin
            RFWr = 1'b1;
            WDSel = `WDSel_FromALU;
        end
        DMWr = 1'b0;

        //需要符号扩展
        if (SignExtend)
            EXTOp = `EXT_SIGNED;
        else
            EXTOp = 0;
        //选择 rt 作为目标寄存器地址
        GPRSel = `GPRSel_RT;
        //选择扩展后的立即数作为 B 源操作数
        BSel = 1'b1;
        ASel = 1'b0;
        flush = 0;
        //指定 ALU 操作类型
        if (addi)
            ALUOp = `ALUOp_ADDI;
        else if (addiu)
            ALUOp = `ALUOp_ADDIU;
        else if (andi)
            ALUOp = `ALUOp_ANDI;
        else if (ori)
            ALUOp = `ALUOp_ORI;
        else if (xori)
            ALUOp = `ALUOp_XORI;
        else if (lui)
            ALUOp = `ALUOp_LUI;
        else if (slti)
            ALUOp = `ALUOp_SLTI;
        else if (sltiu)
            ALUOp = `ALUOp_SLTIU;
        else
            ALUOp = `ALUOp_ADD;
    end
    else if (BrType ) begin
        //若是分支指令类型操作
        //Zero 为 1 表示发生跳转，则 NPCOp 选择跳转；否则顺序执行
        NPCOp = (Zero) ? `NPC_BRANCH : `NPC_PLUS4;
        RFWr = 1'b0;
        DMWr = 1'b0;
        EXTOp = 0;
        GPRSel = `GPRSel_RD;
        WDSel = `WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        flush = 0;

        if (beq)
            ALUOp = `ALUOp_BEQ;
        else if (bne)
            ALUOp = `ALUOp_BNE;
    end
    else if (JType) begin
        NPCOp = `NPC_JUMP;
        EXTOp = `EXT_SIGNED;
        WDSel = `WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = `ALUOp_NOP;
        DMWr = 1'b0;
        flush = 0;

        if (jal) begin
            RFWr = 1'b1;
            GPRSel = `GPRSel_31;
        end
        else begin
            RFWr = 1'b0;
            GPRSel = `GPRSel_RD;
        end
    end
    else if (Type_other) begin
        NPCOp = `NPC_EXCEPT;
        RFWr = 1'b0;
        DMWr = 1'b0;
        EXTOp = 0;
        GPRSel = 0;
        WDSel = 0;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 1;
    end
    else begin
        NPCOp = 0;
        RFWr = 1'b0;
        DMWr = 1'b0;
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