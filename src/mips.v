`timescale 1ns/10ps
`include "ctrl_encode_def.v" 
//�����ļ�
module mips(clk, reset);
//ʱ��Ƶ��
input clk;
//��λ�ź�
input reset;

//��ǰָ���ַ
wire [31: 0] PC; 
//��һ��ָ���ַ
wire [31: 0] NPC;
//ָ��
wire [31: 0] Instr;
//ͨ�üĴ���������RD1����
wire [31: 0] gpr_read1;
//RD2����
wire [31: 0] gpr_read2;
//�� 16 λ��������չ�õ��� 32 λ������
wire [31: 0] Imme32;
//ALU ��ԭ������ A
wire [31: 0] ALU_A, A;
//ALU ��ԭ������ B
wire [31: 0] ALU_B, B;
//ALU ������
wire [31: 0] alu_output;
//�洢���Ĵ����еĵ�ַ
wire [4: 0] waddr;
//�洢������
wire [31: 0] inputdata;
//��һ��ָ���ַ�仯���Ϳ����ź�
wire [2: 0] NPCOp;
//��չ���Ϳ����ź�
wire [1: 0]EXTOp;
//A ������ѡ�����Ϳ����ź�
wire ASel;
//B ������ѡ�����Ϳ����ź�
wire BSel;
wire [4: 0] ALUOp, ALU_ALUOp;
//�ж��Ƿ�Ϊ��ָ֧��
wire Zero;
//ͨ�üĴ���д����ѡ������ź�
wire [2: 0]WDSel;
//ͨ�üĴ���дʹ�ܿ����ź�
wire RFWr;
//ͨ�üĴ���д��ַѡ������ź�
wire [1: 0]GPRSel;
//ָ���ж�Ӧ���ֶ�
wire [5: 0] OP;
wire [4: 0] RS;
wire [4: 0] RT;
wire [4: 0] RD;
wire [4: 0] Shamt;
wire [5: 0] Funct;
//16 λ������
wire [15: 0] Imme16;
//26 λ��ַ
wire [25: 0] Addr26;
wire nop;
assign OP = Instr[31: 26];
assign RS = Instr[25: 21];
assign RT = Instr[20: 16];
assign RD = Instr[15: 11];
assign Shamt = Instr[10: 6];
assign Funct = Instr[5: 0];
assign Imme16 = Instr[15: 0];
assign Addr26 = Instr[25: 0];
assign nop = (Instr == 32'b0);

//PCģ��,�ṩָ���ַ
pc mips_pc(
       .NPC(NPC),
       .Clk(clk),
       .Reset(reset),
       .PC(PC)
   );
//NPCģ��,������һ��ָ���ַ
npc mips_npc(
        .PC(PC),
        .NPCOp(NPCOp),
        .IMM(Addr26),
        .RS(gpr_read1),
        .NPC(NPC)
    );
//ָ��Ĵ���ģ��,�ṩָ��
im_4k mips_im_4k(
          .addr(PC[11: 0]),
          .dout(Instr)
      );
//�������ģ��
ctrl mips_ctrl(
         .opcode(OP),
         .funct(Funct),
         .rt(RT),
         .nop(nop),
         .Zero(Zero),
         .RFWr(RFWr),
         .ALUOp(ALUOp),
         .NPCOp(NPCOp),
         .BSel(BSel),
         .EXTOp(EXTOp),
         .ASel(ASel),
         .GPRSel(GPRSel),
         .WDSel(WDSel)
     );
//ͨ�üĴ���ģ��,Ҳ����$0~$31�Ĵ���
gpr mips_gpr(
        .clk(clk),
        .reset(reset),
        .we(RFWr),
        .addr1(RS),
        .addr2(RT),
        .addr3(waddr),
        .inputdata(inputdata),
        .RD1(gpr_read1),
        .RD2(gpr_read2)
    );
//ѡ������
mux4 MUX_RPR_WD(
         .d0(alu_output),
         .d1(32'b0),
         .d2(PC + 4),
         .s(WDSel),
         .y(inputdata)
     );
//ѡ���ַ
mux4 MUX_GPR_WA(
         .d0(RD),
         .d1(RT),
         .d2(5'd31),
         .d3(5'd0),
         .s({GPRSel}),
         .y(waddr)
     );
//d1 Ϊ��λ��
mux2 MUX_ALU_A(
         .d0(gpr_read1),
         .d1({27'd0, Shamt}),
         .s(ASel),
         .y(A)
     );
mux2 MUX_ALU_B(
         .d0(gpr_read2),
         .d1(Imme32),
         .s(BSel),
         .y(B)
     );
//������չ
Extend EXTEND(
           .Imm16(Imme16),
           .EXTOp(EXTOp),
           .Imm32(Imme32)
       );
//ALU ǰ����ʹ ALU ִ����ȷ�Ĳ��� ��֪��Ϊʲô?
alu_p mips_alu_32_p(
          .A_i(A),
          .B_i(B),
          .ALUOp_i(ALUOp),
          .A_o(ALU_A),
          .B_o(ALU_B),
          .ALUOp_o(ALU_ALUOp)
      );
alu_32 mips_alu_32(
           .A(ALU_A),
           .B(ALU_B),
           .ALUOp(ALU_ALUOp),
           .C(alu_output),
           .Zero(Zero)
       );
endmodule