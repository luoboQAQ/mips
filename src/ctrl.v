`timescale 1ns/10ps
`include "ctrl_encode_def.v"
`include "instruction_def.v" 
//����ģ��
module ctrl(opcode, funct, rt, nop, Zero, RFWr, DMWr, ALUOp, NPCOp, BSel, EXTOp, ASel, GPRSel, WDSel);
//ָ���ź�
input [5: 0] opcode;
input [5: 0] funct;
input [4: 0] rt;
//��ָ�����ָ֧���ж�
input nop, Zero;
//ͨ�üĴ���д�ź�
output reg RFWr;
//���ݴ洢��д�ź�
output reg DMWr;
//alu����ָ��
output reg [4: 0] ALUOp;
//��һ��ָ���ַ�仯����
output reg [2: 0] NPCOp;
//alu ������ѡ��
output reg ASel, BSel;
//��չ��������
output reg [1: 0] EXTOp;
//�洢����ѡ��,�ֱ�ѡ��ͨ�üĴ����ı�š�����Ĵ���������
output reg [1: 0] GPRSel;
output reg [2: 0] WDSel;

//�����źţ���ʱ����
reg flush;

//ָ�������ж�
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

//��Ҫ������չ��ָ��
assign SignExtend = addi | addiu | lw | sw;
//��Ҫ������λ����
assign shamt_sign = (opcode == `INSTR_RTYPE_OP) && (
           funct == `INSTR_SLL_FUNCT ||
           funct == `INSTR_SRL_FUNCT ||
           funct == `INSTR_SRA_FUNCT);

always @( * ) begin
    if (nop) begin
        //���ǿ�ָ�����
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
        //���� R ָ�����
        //NPC ѡ��˳��ִ�е�ָ��
        NPCOp = `NPC_PLUS4;
        //ͨ�üĴ���д�ź�Ϊ1������д
        RFWr = 1'b1;
        DMWr = 1'b0;
        EXTOp = 0;
        //ѡ������д��ļĴ������üĴ�����ַ����� rd ��
        GPRSel = `GPRSel_RD;
        //д��ͨ�üĴ������������� alu ��������
        WDSel = `WDSel_FromALU;
        //ALU �������� B Դ����������ͨ�üĴ����� readD2
        BSel <= 1'b0;
        //������λ�������� A Դ���������� shamt �ֶΣ���һ�������������� A Դ������ѡ�� readD1
        ASel <= (shamt_sign) ? 1'b1 : 1'b0;
        flush = 0;
        begin
            //ָ�� ALU ��������
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
        //���� I ����ָ�����
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

        //��Ҫ������չ
        if (SignExtend)
            EXTOp = `EXT_SIGNED;
        else
            EXTOp = 0;
        //ѡ�� rt ��ΪĿ��Ĵ�����ַ
        GPRSel = `GPRSel_RT;
        //ѡ����չ�����������Ϊ B Դ������
        BSel = 1'b1;
        ASel = 1'b0;
        flush = 0;
        //ָ�� ALU ��������
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
        //���Ƿ�ָ֧�����Ͳ���
        //Zero Ϊ 1 ��ʾ������ת���� NPCOp ѡ����ת������˳��ִ��
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