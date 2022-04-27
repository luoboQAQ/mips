`timescale 1ns/1ps
module mips_test();
reg clk, rst;
mips U_MIPS(
         .clk(clk), .reset(rst)
     );
initial begin
    // $monitor("PC = 0x%8X, IR =0x%8X ,ALUOp = 0x%8X , HI = 0x%8X , LO =0x%8X", U_MIPS.U_PC.PC,U_MIPS.instr ,U_MIPS.U_ALU.ALUOp,U_MIPS.U_DIV.result1, U_MIPS.U_DIV.result2 );
    clk = 1 ;
    rst = 0 ;
    #5 ;
    rst = 1 ;
    #20 ;
    rst = 0 ;
end
always
    #(50) clk = ~clk;
endmodule