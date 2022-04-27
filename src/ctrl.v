`timescale 1ns/10ps
`include "ctrl_encode_def.v" //����ͷ�ļ�����ʹ�ú궨�壬��������`��ͷ�Ĵ�д�ַ���ȫ�����Ǻ궨�壬�þ������������ַ��滻�˶����Ʋ������������˳���Ŀɶ��Ժ���ά���ԣ�������Ĳ��������ڶ�Ӧ��ͷ�ļ��в鿴
`include "instruction_def.v"
module ctrl(opcode, funct,rt,nop,Zero, RFWr, ALUOp,NPCOp, BSel,EXTOp,ASel,GPRSel,WDSel); // �������ģ��
/*
*ȷ��ָ������
*/
input [5:0] opcode;//opcode �� funct �ֶ���������ָ������;
input [5:0] funct;
input [4:0] rt;
/*
*�����ź�
*/
input nop,Zero;//��ָ�����ָ֧���ж�
output RFWr;//ͨ�üĴ���д�ź�
output [4:0] ALUOp;//alu ��������
output [2:0] NPCOp;//��һ��ָ���ַ�仯����
output ASel,BSel;//alu ������ѡ��
output [1:0]EXTOp;//��չ��������
output [1:0]GPRSel,WDSel;//�洢����ѡ��,�ֱ�ѡ��ͨ�üĴ����ı�š�����Ĵ���������
wire RType; // Type of R-Type Instruction
wire IType; // Tyoe of Imm Instruction
wire BrType; // Type of Branch Instruction
wire JType; // Type of Jump Instruction
wire Type_other;
/*
*�����ź�
*/
wire SignExtend;//������չ
wire shamt_sign;//��λ�ź�
reg flush;//�����źţ���ʱ����
/* instructions judgement */
wire addi;// Type of I-Type Instruction
wire Rori;
wire beq;// Type of B-Type Instruction
wire j;// Type of J-Type Instruction
//r-r
assign RType = (opcode == `INSTR_RTYPE_OP)&!nop;//ָ�������ж���䣬����� R ָ�� Rtype=1������ Rtype=0������д��Ϊ�˼�������Ҫ�õ��жϵ����ĸ����ԣ������˳���Ŀɶ���
//r-i
assign addi =(opcode ==`INSTR_ADDI_OP);//addi �����ж����
assign Rori=(opcode==`INSTR_ORI_OP);
assign IType = addi|Rori;//����addi��ori��������ָ������Ϊ I ���ͣ�������ָ���Ҳ��Ӧ�����Ӹ���Ļ����������ͬ��
//brtype
assign beq =(opcode == `INSTR_BEQ_OP);
assign BrType=beq;
//jump
assign j =(opcode == `INSTR_J_OP);
assign JType=j;
//other
assign Type_other=(!JType&&!RType&&!IType&&!BrType);
assign SignExtend = addi ;//addi ������Ҫ������չ��������������Ҫ������չ��ָ�����Ҳ��Ҫ���ӡ�
assign shamt_sign =(opcode == `INSTR_RTYPE_OP)&&(funct ==`INSTR_SLL_FUNCT);//��ָ���� sll������Ҫ������λ����
reg RFWr;//�������Ϊ�Ĵ����ͱ���
reg DMWr;
reg [1:0] EXTOp;
reg [4:0] ALUOp;
reg [2:0] NPCOp;
reg [1:0] GPRSel;
reg [2:0] WDSel;
reg BSel;
reg ASel;
always @(*) begin
    if(nop) begin //���ǿ�ָ�����
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
    else if (RType) begin//���� R ָ�����
        NPCOp = `NPC_PLUS4;//NPC ѡ��˳��ִ�е�ָ��
        RFWr = 1'b1;//ͨ�üĴ���д�ź�Ϊ1������д
        EXTOp = 0;
        GPRSel = `GPRSel_RD;//ѡ������д��ļĴ������üĴ�����ַ����� rd ��
        WDSel = `WDSel_FromALU;//д��ͨ�üĴ������������� alu ��������
        BSel <= 1'b0;//ALU �������� B Դ����������ͨ�üĴ����� readD2
        ASel <= (shamt_sign)?1'b1:1'b0;//������λ�������� A Դ���������� shamt �ֶΣ���һ�������������� A Դ������ѡ�� readD1
        flush = 0;
        begin
            case (funct)
                `INSTR_ADD_FUNCT:
                    ALUOp= `ALUOp_ADD; //ALU ���� add ����
                `INSTR_SUBU_FUNCT:
                    ALUOp= `ALUOp_SUBU; //ALU ���� subu ����
                `INSTR_SLT_FUNCT:
                    ALUOp =`ALUOp_SLT; //ALU ���� slt ����
                `INSTR_SLL_FUNCT:
                    ALUOp=`ALUOp_SLL;
                //ALU ���� sll ����
                default:
                    ALUOp=`ALUOp_ERROR;
            endcase
        end
    end
    else if (IType == 1'b1) begin//���� I ����
        NPCOp = `NPC_PLUS4;
        RFWr = 1;
        if (SignExtend) //��Ҫ������չ
            EXTOp = `EXT_SIGNED;
        else
            EXTOp = 0;
        GPRSel = `GPRSel_RT;//ѡ�� rt ��ΪĿ��Ĵ�����ַ
        WDSel = `WDSel_FromALU;
        BSel = 1'b1;//ѡ����չ�����������Ϊ B Դ������
        ASel = 1'b0;
        flush = 0;
        if(addi)
            ALUOp =`ALUOp_ADDI;
        //ALU ���� addi ����
        if(Rori)
            ALUOp=`ALUOp_OR; //ALU���� or ����
    end
    else if(BrType ) begin//���Ƿ�ָ֧������
        NPCOp =(Zero)?`NPC_BRANCH:`NPC_PLUS4;//Zero Ϊ 1 ��ʾ������ת���� NPCOp ѡ����ת������˳��ִ��
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