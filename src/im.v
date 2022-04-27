`timescale 1ns/10ps
//指令寄存器
module im_4k(addr, dout);
//内存地址，寻址范围2^10,01位为空使+1相当于+4
input [11:2] addr;
//输出指令
output [31:0] dout;
reg [31:0] im[1023:0];
integer i;

//初始化指令寄存器
initial begin
    for(i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end
    //从 test.txt 读取指令到 im 中
    $readmemh("test.txt", im);
end
//根据输入的地址输出对应的数据
assign dout = im[addr];
endmodule