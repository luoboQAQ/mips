`timescale 1ns / 1ps
module mux2 (d0, d1, s, y);//二选一选择器
input [31:0] d0, d1;
input s;
output [31:0] y;
assign y = ( s == 1'b1 ) ? d1:d0;
endmodule
    //mux4
    module mux4 (d0, d1, d2, d3, s, y);//四选一选择器
input [31:0] d0, d1,d2,d3;
input [1:0] s;
output [31:0] y;
//s[][]-d,11-3,10-2,01-1,00-0
assign y = ( s[1] == 1'b1 ) ?
       ((s[0] == 1'b1) ? d3:d2):
       ((s[0] == 1'b1) ? d1:d0);
endmodule