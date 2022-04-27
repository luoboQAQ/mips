`timescale 1ns/10ps 
//PC模块
module pc(
    //下一条指令地址，用于更新PC，最后两位补零
    input [31: 2] NPC,
    //时钟信号
    input Clk,
    //重置信号
    input Reset,
    //当前指令地址
    output reg [31: 2] PC
);

//初始化地址，注意与用来验证的测试工具或参考数据匹配
initial begin
    PC = 30'h00100000;
end

always @ (posedge Clk or posedge Reset) begin
    if (Reset == 1'b1) begin
        //初始化
        PC <= 30'h00100000;
    end
    else begin
        //将下一条指令地址赋给 pc
        PC <= NPC;
    end
end

endmodule