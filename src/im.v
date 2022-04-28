`timescale 1ns/10ps 
//指令寄存器
module im_4k(addr, dout);
//内存地址，寻址范围2^10
input [11: 0] addr;
//输出指令
output [31: 0] dout;
reg [31: 0] im[1023: 0];
integer i;

//初始化指令寄存器
initial begin
    for (i = 0; i < 1024; i = i + 1) begin
        im[i] = 32'h00000000;
    end

    //从 test.txt 读取指令到 im 中
    $readmemh("test.txt", im);
end

//由于真实的CPU是8位存储,而这里是32位存储,所以需要除4得到真实的地址下标
wire [11: 0] add;
assign add = addr == 0 ? 0 : addr / 4;
//根据输入的地址输出对应的数据
assign dout = im[add];
endmodule