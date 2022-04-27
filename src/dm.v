`timescale 1ns / 1ps
module dm_4k( addr, din, DMWr, clk, dout );
input [11: 2] addr;
input [31: 0] din;
input DMWr;
input clk;
output reg [31: 0] dout;

reg [31: 0] mem[1023: 0];
integer i;

initial begin
    for (i = 0; i < 1024; i = i + 1) begin
        mem[i] = 0;
    end
end

always @(negedge clk) begin
    if (DMWr == 1) begin
        mem[addr] = din;
    end
    else begin
        dout <= mem[addr];
    end
end

endmodule
