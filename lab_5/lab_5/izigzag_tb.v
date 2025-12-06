module izigzag_tb();

reg clk, rst;
reg [32*64-1:0] zigzag;
wire [32*64-1:0] outdata;
wire finish;

izigzag izigzag_0 (
    clk,
    rst,
    zigzag,
    outdata,
    finish
);

integer i;

initial begin
    clk=0;
    rst = 0;

    for (i=0;i<64;i=i+1)
    begin
        zigzag[32*(i)+16 +: 16]=i+1;
    end

    #4
    rst = 1;
    
    #10;
    $display("The original data is %d, %d, %d, %d, %d, %d, %d, %d", zigzag[31:16], zigzag[63:48], zigzag[95:80], zigzag[127:112], zigzag[159:144], zigzag[191:176], zigzag[223:208], zigzag[255:240]);
    $display("The transformed data is %d, %d, %d, %d, %d, %d, %d, %d", outdata[31:16], outdata[63:48], outdata[95:80], outdata[127:112], outdata[159:144], outdata[191:176], outdata[223:208], outdata[255:240]);
end

always #1 begin
    clk<=~clk;
end

endmodule