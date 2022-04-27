`timescale 1ns/10ps 
//定义 pc 模块，指令地址传送部件，将下一条指令的地址赋给 pc
module pc(NPC, Clk, Reset, PC);
//下一条指令地址，用于更新PC，最后两位补零
input [31: 2] NPC;
//时钟信号
input Clk;
//重置信号
input Reset;
//当前指令地址，将输出定义为寄存器型变量，表示过程块语句 always 内的指定信号
output reg [31: 2] PC;

/*
初始化地址，注意与用来验证的测试工具或参考数据匹配
*/
initial begin
    PC = 30'h00100000; //初始化，不同 mips 汇编器 PC 初始值不同，此处为通用 mars 编译器的PC 初始值
end

always @ (posedge Clk or posedge Reset) begin //高电平触发
    if (Reset == 1'b1) begin //重置 pc
        PC <= 30'h00100000; //30'h00000c00;
    end
    else begin //将下一条指令地址赋给 pc
        PC <= NPC;
    end
end

endmodule