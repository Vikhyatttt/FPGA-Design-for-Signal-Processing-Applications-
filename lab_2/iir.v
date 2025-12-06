`timescale 1ns / 1ps

module IIR(
clk,
rst,
x,
y,
pll_lock,
pll_clock
);

input clk,rst;
//input[7:0] a,b,c,d;
input[7:0] x;
output reg [7:0] y;
output pll_lock, pll_clock;

// These are the fixed coefficients for this filter
reg[7:0] a = 0.5*16;
reg[7:0] b = 256 - 1.5*16;
reg[7:0] c = 2*16;
reg[7:0] d = 256 - 16;

    // Registers to store past input and output samples, creating the delay.
reg[7:0] x_1; 
reg[7:0] y_1,y_2;

wire[7:0] r0, r1, r2, r3;

/*************** Your code here ***************/
// Pipelined registers for multiplier outputs
// These registers hold the results of the multiplications for one clock cycle
// to improve timing and increase the maximum operating frequency.
reg [7:0] r0_reg, r1_reg, r2_reg, r3_reg;
// Register to hold the calculated sum of the pipelined terms.
reg [7:0] y_in;

// PLL instance to generate the core clock.
clk_wiz_0 pll_inst_core (
    .clk_in1(clk),
    .clk_out1(pll_clock),
    .reset(~rst),
    .locked(pll_lock)
);

// Multipliers
multiply m0(a, x, r0);
multiply m1(b, x_1, r1);
multiply m2(c, y_1, r2);
multiply m3(d, y_2, r3);

// Pipeline stage: register multiplier outputs
always @(posedge pll_clock or negedge rst) begin
    if (~rst) begin
        r0_reg <= 0;
        r1_reg <= 0;
        r2_reg <= 0;
        r3_reg <= 0;
    end else begin
        r0_reg <= r0;
        r1_reg <= r1;
        r2_reg <= r2;
        r3_reg <= r3;
    end
end

// Sum of products after pipeline
always @(posedge pll_clock or negedge rst) begin
    if (~rst)
        y_in <= 0;
    else
        y_in <= r0_reg + r1_reg + r2_reg + r3_reg;
end

// Update previous samples
always @(posedge pll_clock or negedge rst) begin
    if (~rst) begin
        x_1 <= 0;
        y_1 <= 0;
        y_2 <= 0;
        y <= 0;
    end else begin
  // Update the delayed input and output registers
        x_1 <= x;
        y_1 <= y_in;
        y_2 <= y_1;
  // The final output is also registered to remove glitches.
        y <= y_in;
    end
end

endmodule

/********************* Done *********************/