`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/22 14:12:11
// Design Name: 
// Module Name: bmu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bmu_tb(

    );
    
parameter r=2;
parameter K=3;
parameter lenin=10;
parameter lenout=5;

reg clk,rst;
reg [r-1:0] code;
reg [(1<<(K-1))*2*r-1:0] state_out;
wire [(1<<(K-1))*2*r-1:0] dis_out;
bmu #(.r(r),.K(K)) b0(clk,rst,code,state_out,dis_out);

initial begin
clk=0;
rst=0;
code = 'b00;
state_out = 'b1001001101101100;
#4 rst=1;

code = 'b11;
#10  code = 'b11;
#10  code = 'b01;
#10  code = 'b00;
#10  code = 'b01;
end

always #1 begin
    clk<=~clk;
end

endmodule
