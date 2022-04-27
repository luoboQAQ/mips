`timescale 1ns / 1ps
module alu_p(A_i, B_i, ALUOp_i, A_o, B_o, ALUOp_o);
input [31: 0] A_i;
input [31: 0] B_i;
input [4: 0] ALUOp_i;
output reg [31: 0] A_o;
output reg [31: 0] B_o;
output reg [4: 0] ALUOp_o;

//保证同时进入 alu
always@( * ) begin
    A_o <= A_i;
    B_o <= B_i;
    ALUOp_o <= ALUOp_i;
end

endmodule