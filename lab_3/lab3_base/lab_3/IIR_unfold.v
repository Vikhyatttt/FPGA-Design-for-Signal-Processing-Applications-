`timescale 1ns / 1ps

module IIR_unfold(
clk,
rst,
a,b,c,d,
x2k,x2k1,
y2k,y2k1
);

input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x2k,x2k1;
output[7:0] y2k,y2k1;

reg[7:0] x_1;
reg[7:0] y_1,y_2;

wire[7:0] r0[1:0],r1[1:0],r2[1:0],r3[1:0];

multiply m0(a,x2k,r0[0]);
multiply m1(b,x_1,r1[0]);
multiply m2(c,y_1,r2[0]);
multiply m3(d,y_2,r3[0]);

multiply m4(a,x2k1,r0[1]);
multiply m5(b,x2k,r1[1]);
multiply m6(c,y2k,r2[1]);
multiply m7(d,y_1,r3[1]);

assign y2k=r0[0]+r1[0]+r2[0]+r3[0];
assign y2k1=r0[1]+r1[1]+r2[1]+r3[1];

always@(posedge clk or negedge rst)begin
    if(~rst)begin
        x_1<=0;
        y_1<=0;
        y_2<=0;
        
    end
    else begin
        x_1<=x2k1;
        y_1<=y2k1;
        y_2<=y2k;
        
    end
end

endmodule

