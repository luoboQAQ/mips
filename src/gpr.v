`timescale 1ns/10ps 
//寄存器模块
module gpr(clk, reset, we, addr1, addr2, addr3, addr4,inputdata, RD1, RD2,RD3);
input clk;
input reset; //重置信号
input we; //从控制单元来的读写控制信号
input [4: 0] addr1; //rs
input [4: 0] addr2; //rt
input [4: 0] addr3; //rd
input [4: 0] addr4; //shamt
input [31: 0] inputdata; //存入[rd]的数据
output [31: 0] RD1; //[rs]数据
output [31: 0] RD2; //[rt]数据
output [31: 0] RD3; //[shamt]数据
reg [31: 0] registers [31: 0]; //寄存器堆的实现
integer i = 0;

//保障 addr3==addr1||addr3==addr2 时输出的RD1,RD2 不变  为什么？
assign RD1 = (clk == 1) ? registers[addr1] : RD1; //从寄存器中对应地址 addr1 的位置取数据到 RD1
assign RD2 = (clk == 1) ? registers[addr2] : RD2; //从寄存器中对应地址 addr2 的位置取数据到 RD2
assign RD3 = (clk == 1) ? registers[addr4] : RD3; //从寄存器中对应地址 addr2 的位置取数据到 RD2

//初始化寄存器
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'h00000000;
    end
end

always @ ( posedge reset or negedge clk) begin //低电平触发保存
    //检测是否复位
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h00000000;
        end
    end
    else if (we & addr3 != 5'h00) begin //第 0 号寄存器不可被更改
        //将数据写入rd地址对应的寄存器
        registers[addr3] <= inputdata;
        // $display("addr: %d, data: %4h",addr3, inputdata);
    end
end
endmodule