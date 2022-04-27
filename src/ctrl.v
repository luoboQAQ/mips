`timescale 1ns/10ps
`include "ctrl_encode_def.v"
`include "instruction_def.v"
//����ģ��
module ctrl(opcode, funct, rt, nop, Zero, RFWr, ALUOp, NPCOp, BSel, EXTOp, ASel, GPRSel, WDSel);
//ָ���ź�
input [5: 0] opcode;
input [5: 0] funct;
input [4: 0] rt;
//��ָ�����ָ֧���ж�
input nop, Zero;
//ͨ�üĴ���д�ź�
output reg RFWr;
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

//������չ
wire SignExtend;
//��λ�ź�
wire shamt_sign;
//�����źţ���ʱ����
reg flush;

//ָ�������ж�
//r-r
assign RType = (opcode == `INSTR_RTYPE_OP) & !nop;
//r-i
assign addi = (opcode == `INSTR_ADDI_OP);
assign Rori = (opcode == `INSTR_ORI_OP);
assign IType = addi | Rori;
//brtype
assign beq = (opcode == `INSTR_BEQ_OP);
assign BrType = beq;
//jump
assign j = (opcode == `INSTR_J_OP);
assign JType = j;
//other
assign Type_other = (!JType && !RType && !IType && !BrType);

//��Ҫ������չ��ָ��
assign SignExtend = addi;
//��Ҫ������λ����
assign shamt_sign = (opcode == `INSTR_RTYPE_OP) && (funct == `INSTR_SLL_FUNCT);
reg DMWr;

always @( * ) begin
    if (nop) begin
        //���ǿ�ָ�����
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
    else if (RType) begin
        //���� R ָ�����
        //NPC ѡ��˳��ִ�е�ָ��
        NPCOp = `NPC_PLUS4;
        //ͨ�üĴ���д�ź�Ϊ1������д
        RFWr = 1'b1;
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
                `INSTR_SUBU_FUNCT:
                    ALUOp = `ALUOp_SUBU;
                `INSTR_SLT_FUNCT:
                    ALUOp = `ALUOp_SLT;
                `INSTR_SLL_FUNCT:
                    ALUOp = `ALUOp_SLL;
                default:
                    ALUOp = `ALUOp_ERROR;
            endcase
        end
    end
    else if (IType == 1'b1) begin
        //���� I ����ָ�����
        NPCOp = `NPC_PLUS4;
        RFWr = 1;

        //��Ҫ������չ
        if (SignExtend)
            EXTOp = `EXT_SIGNED;
        else
            EXTOp = 0;
        //ѡ�� rt ��ΪĿ��Ĵ�����ַ
        GPRSel = `GPRSel_RT;
        WDSel = `WDSel_FromALU;
        //ѡ����չ�����������Ϊ B Դ������
        BSel = 1'b1;
        ASel = 1'b0;
        flush = 0;
        //ָ�� ALU ��������
        if (addi)
            ALUOp = `ALUOp_ADDI;
        if (Rori)
            ALUOp = `ALUOp_OR;
    end
    else if (BrType ) begin
        //���Ƿ�ָ֧�����Ͳ���
        //Zero Ϊ 1 ��ʾ������ת���� NPCOp ѡ����ת������˳��ִ��
        NPCOp = (Zero) ? `NPC_BRANCH : `NPC_PLUS4;
        RFWr = 1'b0;
        EXTOp = 0;
        GPRSel = `GPRSel_RD;
        WDSel = `WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        flush = 0;
        begin
            if (beq)
                ALUOp = `ALUOp_BEQ;
        end
    end
    else if (JType) begin
        NPCOp = `NPC_JUMP;
        RFWr = 1'b0;
        EXTOp = `EXT_SIGNED;
        GPRSel = 0;
        WDSel = `WDSel_FromPC;
        BSel = 1'b0;
        ASel = 1'b0;
        ALUOp = 0;
        flush = 0;

        case (opcode)
            `INSTR_J_OP:
                ALUOp = `ALUOp_ERROR;
            default:
                ALUOp = `ALUOp_ERROR;
        endcase
    end
    else if (Type_other) begin
        NPCOp = `NPC_EXCEPT;
        RFWr = 1'b0;
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