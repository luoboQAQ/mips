`timescale 1ns/10ps //在 verilog 中是没有默认timescale 的；一个没有指定 timescale 的 verilog 模块就有可能错误的继承了前面编译模块的无效timescale 参数。
// 所 以 推 荐 在 每 个module 的前面指定`timescale,timescale 用法请查看教材。
`include "ctrl_encode_def.v" //类似 C 语言的包含头文件，功能上也是类似的
module mips(clk, reset,out);//顶层文件
input clk;//定义输入，时钟频率
input reset;//定义输入，复位信号
output [15:0]out;//定义输出
assign out=0;
//定义连线型变量
wire [31:2] PC;//当前指令地址
wire [31:2] NPC;//下一条指令地址
wire [31:0] Instr;//指令
wire [31:0] gpr_read1;//通用寄存器读到的RD1 数据
wire [31:0] gpr_read2;//RD2 数据
wire [31:0] Imme32;//由 16 位立即数扩展得到的 32 位立即数
wire [31:0] ALU_A,A;//ALU 的原操作数 A
wire [31:0] ALU_B,B;//ALU 的原操作数 B
wire [31:0] alu_output;//ALU 输出结果
wire [4:0] waddr;//存储到寄存器中的地址
wire [31:0] inputdata;//存储的数据
wire [2:0] NPCOp;//下一条指令地址变化类型控制信号
wire [1:0]EXTOp;//拓展类型控制信号
wire ASel;//A 操作数选择类型控制信号
wire BSel;//B 操作数选择类型控制信号
wire [4:0] ALUOp,ALU_ALUOp;
wire Zero;//判断是否为分支指令
wire [2:0]WDSel;//通用寄存器写数据选择控制信号
wire RFWr;//通用寄存器写使能控制信号
wire [1:0]GPRSel;//通用寄存器写地址选择控制信号
wire [5:0] OP;//opcode
wire [4:0] RS;//指令序列中 rs 字段
wire [4:0] RT;//指令序列中 rt 字段
wire [4:0] RD;//指令序列中 rd 字段
wire [4:0] Shamt;//移位操作中 shamt 字段
wire [5:0] Funct;//funct
wire [15:0] Imme16;//16 位立即数
wire [25:0] Addr26;//26 位地址
wire nop;
assign OP = Instr[31:26];
assign RS = Instr[25:21];
assign RT = Instr[20:16];
assign RD = Instr[15:11];
assign Shamt = Instr[10:6];
assign Funct = Instr[5:0];
assign Imme16 = Instr[15:0];
assign Addr26 = Instr[25:0];
assign nop =(Instr== 32'b0);
/* main framework of mips-lite-2 *///下面相当于函数调用
pc mips_pc(
       .NPC(NPC),
       .Clk(clk),
       .Reset(reset),
       .PC(PC)
   );//提供 pc 给指令存储器取地址
npc mips_npc(
        .PC(PC),
        .NPCOp(NPCOp),
        .IMM(Addr26),
        .NPC(NPC)
    );//决定下一条指令地址的变化
im_4k mips_im_4k(
          .addr(PC[11:2]),
          .dout(Instr)
      );//提供指令
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
     );//译码控制模块
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
    );//通用寄存器
mux4 MUX_RPR_WD(
         .d0(alu_output),
         .d1(32'b0),
         .d2({PC+1,2'd0}),
         .s(WDSel),
         .y(inputdata)
     );//选择数据
mux4 MUX_GPR_WA(
         .d0(RD),
         .d1(RT),
         .d2(5'd31),
         .d3(5'd0),
         .s({GPRSel}),
         .y(waddr)
     );//选择地址
mux2 MUX_ALU_A(
         .d0(gpr_read1),
         .d1({27'd0,Shamt}),
         .s(ASel),
         .y(A)
     );//d1 为移位用
mux2 MUX_ALU_B(
         .d0(gpr_read2),
         .d1(Imme32),
         .s(BSel),
         .y(B)
     );
Extend EXTEND(
           .Imm16(Imme16),
           .EXTOp(EXTOp),
           .Imm32(Imme32)
       );//三类扩展
/*
*ALU 前处理，使 ALU 执行正确的操作
*/
alu_p mips_alu_32_p(
          .A_i(A),
          .B_i(B),
          .ALUOp_i(ALUOp),
          .A_o(ALU_A),
          .B_o(ALU_B),
          .ALUOp_o(ALU_ALUOp)
      );
alu_32 mips_alu_32(
           .A(ALU_A),//.A(A),no
           .B(ALU_B),//.B(B),no
           .ALUOp(ALU_ALUOp),//.ALUOp(ALUOp),no
           .C(alu_output),
           .Zero(Zero)
       );
endmodule