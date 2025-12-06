`timescale 1ns / 1ps
 
module IIR_fold(
clk, rst, a,b,c,d, x, y
);
 
input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x;
output[7:0] y;
 
/*************** Your code here ***************/
 
//One-hot counter for folding order
reg [1:0] folding_order;
always @(posedge clk or negedge rst)
    if(!rst)
        folding_order <= 0;
    else
        folding_order <= folding_order + 1;
 
//Delayed
reg [7:0] x_d[4:0];
reg [7:0] add_d[4:0];
reg [7:0] mul_d[1:0];
wire [7:0] add_out, mul_out;
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        {x_d[0],x_d[1],x_d[2],x_d[3],x_d[4]} <= 0;
        {add_d[0],add_d[1],add_d[2],add_d[3],add_d[4]} <= 0;
        {mul_d[0],mul_d[1]} <= 0;
    end else begin
        {x_d[0],x_d[1],x_d[2],x_d[3],x_d[4]} <= {x,x_d[0],x_d[1],x_d[2],x_d[3]};
        {add_d[0],add_d[1],add_d[2],add_d[3],add_d[4]} <= {add_out,add_d[0],add_d[1],add_d[2],add_d[3]};
        {mul_d[0],mul_d[1]} <= {mul_out,mul_d[0]};
    end
end
 
//Input Selection for Functional Units.
reg [7:0] mul_in0, mul_in1;
reg [7:0] add_in0, add_in1;
always @(*) begin
    case(folding_order)
        2'd0  : begin
                            mul_in0 = a;
                            mul_in1 = x;
add_in0 = mul_d[0];
                            add_in1 = mul_d[1];
                            end
        2'd1 : begin
                            mul_in0 = x_d[4];
                            mul_in1 = b;
                            add_in0 = add_d[2];
                            add_in1 = add_d[0];                            
                           end
        2'd2 : begin
                            mul_in0 = add_d[4];
                            mul_in1 = d;
                            add_in0 = mul_d[0];
                            add_in1 = mul_d[1];                           
                           end                           
        2'd3 : begin
                            mul_in0 = add_d[1];
                            mul_in1 = c;
                            add_in0 = 0;
                            add_in1 = 0;                            
                           end
        endcase
end                                  
assign add_out = add_in0 + add_in1;
multiply u0(mul_in0, mul_in1, mul_out); 
assign y = add_d[2];
 
/********************* Done *********************/
 
endmodule
 
