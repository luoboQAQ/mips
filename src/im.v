`timescale 1ns/10ps
module im_4k(addr, dout);//定义 im_4k 模块，用寄存器实现的 4k 只读内存
input [11:2] addr;//内存地址，寻址范围2^10, 不 错 0 开 始 ， 刚 好 一 次 一 条 ， 00 、01.10.11,4B=32b
output [31:0] dout;//输出指令
reg [31:0] im[1023:0]; //实现存储功能的临时寄存器变量
integer i;//定义整型变量 i
/*
初始化指令寄存器
*/
initial begin
    for(i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end
    $readmemh("test.txt", im);//从 test.txt 读取指令到 im 中
end
assign dout = im[addr]; //根据输入的地址输出对应的数据
endmodule