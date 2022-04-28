`timescale 1ns/1ps
module mips_test();
reg clk, rst;
mips U_MIPS(
         .clk(clk),
         .reset(rst)
     );

initial begin
    clk = 1;
    rst = 0;
    #5;
    rst = 1;
    #20;
    rst = 0;
end

always
    #(50) clk = ~clk;
endmodule