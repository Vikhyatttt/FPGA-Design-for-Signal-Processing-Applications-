`timescale 1ns / 1ps

module systolicarray_1_tb(

    );

parameter size=8;
parameter decimal=4;

localparam [31:0] EXPECT = 32'h40285038;

reg clk,rst;
reg[4*size-1:0] mi0;
reg[4*size-1:0] mi1;
wire[4*size-1:0] mor;

systolicarray_1 s1(clk,rst,mi0,mi1,mor);

initial begin
clk=0;
rst=0;

 
mi0=8|(16<<8)|(16<<16)|(8<<24);     //  mi0 = [8][16][16][8] = [0.5][1][1][0.5].
mi1=16|(32<<8)|(48<<16)|(64<<24);   //  mi1 = [64][48][32][16] = [4][3][2][1].

#4 rst=1;

// Wait 2 clock cycles for registered output (mor)
    @(posedge clk);
    @(posedge clk);

    // Expected result:  [[3.5, 5.0], [2.5, 4.0]]


    if (mor !== EXPECT) begin
        $display("3D SA FAIL: mor=%h   expected=%h", mor, EXPECT);
        $fatal; // stop simulation
    end
    else begin
        $display("3D SA PASS: mor=%h", mor);
        $display("c11=%0f  c12=%0f  c21=%0f  c22=%0f",
            $itor($signed(mor[7:0]))/16.0,
            $itor($signed(mor[15:8]))/16.0,
            $itor($signed(mor[23:16]))/16.0,
            $itor($signed(mor[31:24]))/16.0 );
    end

    #10 $finish;


end

always #1 begin
    clk<=~clk;
end

endmodule

`timescale 1ns / 1ps

module systolicarray_2_tb();

parameter size=8;
parameter decimal=4;

localparam [31:0] EXPECT = 32'h40285038; // [[3.5,5.0],[2.5,4.0]] in Q4.4

reg clk,rst;
reg [4*size-1:0] mi0;
reg [4*size-1:0] mi1;
wire[4*size-1:0] mo;

systolicarray_2 dut(clk,rst,mi0,mi1,mo);

initial begin
    clk=0;
    forever #1 clk = ~clk;
end

initial begin
    rst=0;

    // A = [[0.5,1.0],[1.0,0.5]] ? {a22,a21,a12,a11} = 08 10 10 08
    mi0 = 8 | (16<<8) | (16<<16) | (8<<24);

    // B = [[1,2],[3,4]] ? {b22,b21,b12,b11} = 40 30 20 10
    mi1 = 16 | (32<<8) | (48<<16) | (64<<24);

    #4 rst=1;

    // Give time for 4 solution cycles including propagation
    repeat (6) @(posedge clk);

    if (mo !== EXPECT) begin
        $display("2D SA FAIL: mo=%h   expected=%h", mo, EXPECT);
        $fatal;
    end else begin
        $display("2D SA PASS: mo=%h", mo);
        $display("c11=%0f  c12=%0f  c21=%0f  c22=%0f",
            $itor($signed(mo[7:0]))/16.0,
            $itor($signed(mo[15:8]))/16.0,
            $itor($signed(mo[23:16]))/16.0,
            $itor($signed(mo[31:24]))/16.0 );
    end

    #10 $finish;
end

endmodule
