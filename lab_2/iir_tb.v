`timescale 1ns / 1ps

module IIR_tb(y);

//your code here=============
reg clk,rst;
reg[7:0] x;
output[7:0] y;
wire pll_locked, pll_clock;

IIR iir1(
clk,
rst,
x,
y,
pll_locked,  // Output to indicate pll lock state
pll_clock   // 200MHz Clock
);

initial begin
    clk = 0;
    rst = 0;
    x = 0;
    #16 rst = 1;
end

always #4 begin
    clk = ~clk;
end

integer n = -5;
always@(posedge pll_clock)begin
    if(rst && pll_locked)begin
        if(n<6)begin
            x<=256 + n*16;
            n<= n + 1;
        end
    end
end
//your code here=============

endmodule