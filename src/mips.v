`timescale 1ns/10ps
`include "ctrl_encode_def.v" 
//顶层文件
module mips(clk, reset);
//时钟频率
input clk;
//复位信号
input reset;

//当前指令地址
wire [31: 0] PC; 
//下一条指令地址
wire [31: 0] NPC;
//指令
wire [31: 0] Instr;
//通用寄存器读到的RD1数据
wire [31: 0] gpr_read1;
//RD2数据
wire [31: 0] gpr_read2;
//由 16 位立即数扩展得到的 32 位立即数
wire [31: 0] Imme32;
//ALU 的原操作数 A
wire [31: 0] ALU_A, A;
//ALU 的原操作数 B
wire [31: 0] ALU_B, B;
//ALU 输出结果
wire [31: 0] alu_output;
//存储到寄存器中的地址
wire [4: 0] waddr;
//存储的数据
wire [31: 0] inputdata;
//下一条指令地址变化类型控制信号
wire [2: 0] NPCOp;
//拓展类型控制信号
wire [1: 0]EXTOp;
//A 操作数选择类型控制信号
wire ASel;
//B 操作数选择类型控制信号
wire BSel;
wire [4: 0] ALUOp, ALU_ALUOp;
//判断是否为分支指令
wire Zero;
//通用寄存器写数据选择控制信号
wire [2: 0]WDSel;
//通用寄存器写使能控制信号
wire RFWr;
//通用寄存器写地址选择控制信号
wire [1: 0]GPRSel;
//指令中对应的字段
wire [5: 0] OP;
wire [4: 0] RS;
wire [4: 0] RT;
wire [4: 0] RD;
wire [4: 0] Shamt;
wire [5: 0] Funct;
//16 位立即数
wire [15: 0] Imme16;
//26 位地址
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

//PC模块,提供指令地址
pc mips_pc(
       .NPC(NPC),
       .Clk(clk),
       .Reset(reset),
       .PC(PC)
   );
//NPC模块,决定下一条指令地址
npc mips_npc(
        .PC(PC),
        .NPCOp(NPCOp),
        .IMM(Addr26),
        .RS(gpr_read1),
        .NPC(NPC)
    );
//指令寄存器模块,提供指令
im_4k mips_im_4k(
          .addr(PC[11: 0]),
          .dout(Instr)
      );
//译码控制模块
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
//通用寄存器模块,也就是$0~$31寄存器
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
//选择数据
mux4 MUX_RPR_WD(
         .d0(alu_output),
         .d1(32'b0),
         .d2(PC + 4),
         .s(WDSel),
         .y(inputdata)
     );
//选择地址
mux4 MUX_GPR_WA(
         .d0(RD),
         .d1(RT),
         .d2(5'd31),
         .d3(5'd0),
         .s({GPRSel}),
         .y(waddr)
     );
//d1 为移位用
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
//三类扩展
Extend EXTEND(
           .Imm16(Imme16),
           .EXTOp(EXTOp),
           .Imm32(Imme32)
       );
//ALU 前处理，使 ALU 执行正确的操作 不知道为什么?
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