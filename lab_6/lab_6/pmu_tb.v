`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/22 14:53:29
// Design Name: 
// Module Name: pmu_tb
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


module pmu_tb(

    );
    
parameter r=2;
parameter K=3;

parameter ns=1<<(K-1); // ns = 4.
parameter mask=ns-1; // mask = 3 = 'b11.

reg clk,rst;

reg[(1<<(K-1))*8-1:0] dis;//...[second state curr dis 15:8][first state curr dis 7:0]
reg[(1<<(K-1))*2*r-1:0] dis_path; // length: 16. represents 8 hamming distances.
wire [(1<<(K-1))*K-1:0] path_out;
wire [(1<<(K-1))*8-1:0] dis_out;

pmu #(.r(r),.K(K)) p0(
clk,
rst,
dis,
dis_path,
path_out,
dis_out
    );
initial begin
clk=0;
rst=0;
dis = 'hffffffff;
dis_path = 'h0000;
#4 rst=1;
dis = 'hffffff00;
dis_path = 'h5258;
#10 dis = 'hff00ff02;
dis_path = 'h5258;
#10 dis = 'h0202004;
dis_path = 'h8525;
end

always #1 begin
    clk<=~clk;
end
endmodule
