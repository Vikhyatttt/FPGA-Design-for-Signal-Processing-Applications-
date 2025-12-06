`timescale 1ns / 1ps

module systolicarray_1(
clk,
rst,
mi0,
mi1,
mor
    );

parameter size=8;
parameter decimal=4;

input clk,rst;
input[4*size-1:0] mi0;
input[4*size-1:0] mi1;
output reg[4*size-1:0] mor;

wire[4*size-1:0] mo;

always@(posedge clk or negedge rst)begin
    if(~rst)begin
        mor<=0;
    end
    else begin
        mor<=mo;
    end
end

wire[size-1:0] umi1[7:0];
wire[size-1:0] umi2[7:0];
wire[size-1:0] uai[7:0];
wire[size-1:0] uoutmi1[7:0];
wire[size-1:0] uoutmi2[7:0];
wire[size-1:0] uout[7:0];

genvar gi;

generate
    for(gi=0;gi<8;gi=gi+1)begin : genu
        systolicarray_1_unit #(.size(size),.decimal(decimal)) ui(umi1[gi],umi2[gi],uai[gi],uoutmi1[gi],uoutmi2[gi],uout[gi]);
    end
endgenerate

// Start of your code.
// Break out A (mi0) and B (mi1) elements (row-major bytes)
wire [size-1:0] a11 = mi0[ 7:0];
wire [size-1:0] a12 = mi0[15:8];
wire [size-1:0] a21 = mi0[23:16];
wire [size-1:0] a22 = mi0[31:24];

wire [size-1:0] b11 = mi1[ 7:0];
wire [size-1:0] b12 = mi1[15:8];
wire [size-1:0] b21 = mi1[23:16];
wire [size-1:0] b22 = mi1[31:24];

// ---------- 8 combinational units (two-stage sum for each Cij) ----------
// c11 = a11*b11 + a12*b21
assign umi1[0] = a11; assign umi2[0] = b11; assign uai[0] = {size{1'b0}};       // stage 1
assign umi1[1] = a12; assign umi2[1] = b21; assign uai[1] = uout[0];            // stage 2 -> c11

// c12 = a11*b12 + a12*b22
assign umi1[2] = a11; assign umi2[2] = b12; assign uai[2] = {size{1'b0}};       // stage 1
assign umi1[3] = a12; assign umi2[3] = b22; assign uai[3] = uout[2];            // stage 2 -> c12

// c21 = a21*b11 + a22*b21
assign umi1[4] = a21; assign umi2[4] = b11; assign uai[4] = {size{1'b0}};       // stage 1
assign umi1[5] = a22; assign umi2[5] = b21; assign uai[5] = uout[4];            // stage 2 -> c21

// c22 = a21*b12 + a22*b22
assign umi1[6] = a21; assign umi2[6] = b12; assign uai[6] = {size{1'b0}};       // stage 1
assign umi1[7] = a22; assign umi2[7] = b22; assign uai[7] = uout[6];            // stage 2 -> c22

// Pack outputs as row-major bytes: [7:0]=c11, [15:8]=c12, [23:16]=c21, [31:24]=c22
assign mo[ 7:0]  = uout[1];  // c11
assign mo[15:8]  = uout[3];  // c12
assign mo[23:16] = uout[5];  // c21
assign mo[31:24] = uout[7];  // c22

// End of your code.

endmodule
