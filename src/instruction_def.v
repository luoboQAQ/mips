// OP
`define INSTR_RTYPE_OP      6'b000000

`define INSTR_ADDI_OP       6'b001000
`define INSTR_ORI_OP        6'b001101
`define INSTR_BEQ_OP        6'b000100
`define INSTR_J_OP          6'b000010
// Funct
`define INSTR_ADD_FUNCT     6'b100000
`define INSTR_ADDU_FUNCT    6'b100001
`define INSTR_SUBU_FUNCT    6'b100011
`define INSTR_SLT_FUNCT     6'b101010
`define INSTR_SLL_FUNCT     6'b000000