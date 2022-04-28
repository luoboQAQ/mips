// OP
`define INSTR_RTYPE_OP      6'b000000

`define INSTR_ADDI_OP       6'b001000
`define INSTR_ADDIU_OP      6'b001001
`define INSTR_ANDI_OP       6'b001100
`define INSTR_ORI_OP        6'b001101
`define INSTR_XORI_OP       6'b001110
`define INSTR_LUI_OP        6'b001111
// 还少lw.sw
`define INSTR_BEQ_OP        6'b000100
`define INSTR_BNE_OP        6'b000101
`define INSTR_SLTI_OP       6'b001010
`define INSTR_SLTIU_OP      6'b001011

`define INSTR_J_OP          6'b000010
`define INSTR_JAL_OP        6'b000011
// Funct
`define INSTR_ADD_FUNCT     6'b100000
`define INSTR_ADDU_FUNCT    6'b100001
`define INSTR_SUB_FUNCT     6'b100010
`define INSTR_SUBU_FUNCT    6'b100011
`define INSTR_AND_FUNCT     6'b100100
`define INSTR_OR_FUNCT      6'b100101
`define INSTR_XOR_FUNCT     6'b100110
`define INSTR_NOR_FUNCT     6'b100111
`define INSTR_SLT_FUNCT     6'b101010
`define INSTR_SLTU_FUNCT    6'b101011
`define INSTR_SLL_FUNCT     6'b000000
`define INSTR_SRL_FUNCT     6'b000010
`define INSTR_SRA_FUNCT     6'b000011
`define INSTR_SLLV_FUNCT    6'b000100
`define INSTR_SRLV_FUNCT    6'b000110
`define INSTR_SRAV_FUNCT    6'b000111
`define INSTR_JR_FUNCT      6'b001000