`timescale 1ns / 1ps

module systolicarray_2(
clk,
rst,
mi0,
mi1,
mo
    );

parameter size=8;
parameter decimal=4;

input clk,rst;


input[4*size-1:0] mi0;
input[4*size-1:0] mi1;
output[4*size-1:0] mo;

// Start of your code.

// Unpack A and B (Q4.4, signed 8-bit)
wire [size-1:0] a11 = mi0[ 7:0];
wire [size-1:0] a12 = mi0[15:8];
wire [size-1:0] a21 = mi0[23:16];
wire [size-1:0] a22 = mi0[31:24];

wire [size-1:0] b11 = mi1[ 7:0];
wire [size-1:0] b12 = mi1[15:8];
wire [size-1:0] b21 = mi1[23:16];
wire [size-1:0] b22 = mi1[31:24];

// Injection registers 
//  - b enters from the LEFT of each row and moves RIGHT (mi0 path)
//  - a enters from the TOP of each column and moves DOWN (mi1 path)
reg  [size-1:0] b_row1_in, b_row2_in;  // left edges (top row, bottom row)
reg  [size-1:0] a_col1_in, a_col2_in;  // top edges (left column, right column)
reg  [1:0]      t;                      // cycle counter: 0..3

// Interconnect wires
wire [size-1:0] right00, down00;
wire [size-1:0] right10, down01;
wire [size-1:0] c11, c12, c21, c22;

// Four PEs (mi0=b ?, mi1=a ?)
// Top-left PE (0,0) -> c11
systolicarray_2_unit #(.size(size),.decimal(decimal)) pe00(
    .clk(clk), .rst(rst),
    .mi0(b_row1_in), .mi1(a_col1_in), .ai({size{1'b0}}),
    .outmi0(right00), .outmi1(down00), .out(c11)
);

// Top-right (PE01) -- THIS OUTPUT IS c21 
systolicarray_2_unit #(.size(size),.decimal(decimal)) pe01(
    .clk(clk), .rst(rst),
    .mi0(right00), .mi1(a_col2_in), .ai({size{1'b0}}),
    .outmi0(/*unused*/), .outmi1(down01), .out(c21)   
);

// Bottom-left (PE10) -- THIS OUTPUT IS c12 
systolicarray_2_unit #(.size(size),.decimal(decimal)) pe10(
    .clk(clk), .rst(rst),
    .mi0(b_row2_in), .mi1(down00), .ai({size{1'b0}}),
    .outmi0(right10), .outmi1(/*unused*/), .out(c12)  
);

// Bottom-right PE (1,1) -> c22
systolicarray_2_unit #(.size(size),.decimal(decimal)) pe11(
    .clk(clk), .rst(rst),
    .mi0(right10), .mi1(down01), .ai({size{1'b0}}),
    .outmi0(/*unused*/), .outmi1(/*unused*/), .out(c22)
);

// Pack C (row-major): [7:0]=c11, [15:8]=c12, [23:16]=c21, [31:24]=c22
assign mo[ 7:0]  = c11;
assign mo[15:8]  = c12;
assign mo[23:16] = c21;
assign mo[31:24] = c22;


// End of your code.


always@(posedge clk or negedge rst)begin
    if(~rst)begin
    // Start of your code.
        b_row1_in <= {size{1'b0}};
        b_row2_in <= {size{1'b0}};
        a_col1_in <= {size{1'b0}};
        a_col2_in <= {size{1'b0}};
        t         <= 2'd0;

    // End of your code.
    end
    else begin
    // Start of your code.
    
    // Cycle 1 (t=0): feed a11 (top-left col) and b11 (left-top row)
    // Cycle 2 (t=1): hold/propagate stored values; inject a12 (top col1),
    //                a21 (top col2), b21 (left row1), b12 (left row2)
    // Cycle 3 (t=2): inject a22 on top col2 and b22 on left row2 (others zero)
    // Cycle 4+     : drive zeros (let values propagate/accumulate)
        case (t)
            2'd0: begin
                a_col1_in <= a11;    // ? into PE(0,0)
                a_col2_in <= {size{1'b0}};
                b_row1_in <= b11;    // ? into PE(0,0)
                b_row2_in <= {size{1'b0}};
                t         <= 2'd1;
            end
            2'd1: begin
                a_col1_in <= a12;    // ? into col1 (PE(0,0))
                a_col2_in <= a21;    // ? into col2 (PE(1,0))
                b_row1_in <= b21;    // ? into row1 (PE(0,0))
                b_row2_in <= b12;    // ? into row2 (PE(0,1))
                t         <= 2'd2;
            end
            2'd2: begin
                a_col1_in <= {size{1'b0}};
                a_col2_in <= a22;    // ? into col2 (PE(1,0))
                b_row1_in <= {size{1'b0}};
                b_row2_in <= b22;    // ? into row2 (PE(0,1))
                t         <= 2'd3;
            end
            default: begin
                a_col1_in <= {size{1'b0}};
                a_col2_in <= {size{1'b0}};
                b_row1_in <= {size{1'b0}};
                b_row2_in <= {size{1'b0}};
                t         <= t;      // hold
            end
        endcase

    // End of your code.
    end
end

endmodule
