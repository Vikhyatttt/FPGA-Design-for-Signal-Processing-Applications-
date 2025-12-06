`timescale 1ns / 1ps
//===========================================================
//  Inverse ZigZag Transform for 8x8 block (Lab 5 - JPEG Decoder)
//===========================================================
module izigzag(
    input  wire             clk,
    input  wire             rst,
    input  wire [32*64-1:0] zigzag,   // [64th][...][1st] each 32-bit
    output reg  [32*64-1:0] outdata,
    output reg              finish
);

    // Mapping table (position in normal 8x8 order → zigzag index)
    integer map [0:63];
    integer i;

    initial begin
        // Zigzag index mapping (same as JPEG standard)
        map[0]=0;   map[1]=1;   map[2]=5;   map[3]=6;   map[4]=14;  map[5]=15;  map[6]=27;  map[7]=28;
        map[8]=2;   map[9]=4;   map[10]=7;  map[11]=13; map[12]=16; map[13]=26; map[14]=29; map[15]=42;
        map[16]=3;  map[17]=8;  map[18]=12; map[19]=17; map[20]=25; map[21]=30; map[22]=41; map[23]=43;
        map[24]=9;  map[25]=11; map[26]=18; map[27]=24; map[28]=31; map[29]=40; map[30]=44; map[31]=53;
        map[32]=10; map[33]=19; map[34]=23; map[35]=32; map[36]=39; map[37]=45; map[38]=52; map[39]=54;
        map[40]=20; map[41]=22; map[42]=33; map[43]=38; map[44]=46; map[45]=51; map[46]=55; map[47]=60;
        map[48]=21; map[49]=34; map[50]=37; map[51]=47; map[52]=50; map[53]=56; map[54]=59; map[55]=61;
        map[56]=35; map[57]=36; map[58]=48; map[59]=49; map[60]=57; map[61]=58; map[62]=62; map[63]=63;
    end

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            outdata <= 0;
            finish  <= 0;
        end
        else begin
            for(i=0;i<64;i=i+1) begin
                outdata[(i+1)*32-1 -: 32] <= zigzag[(map[i]+1)*32-1 -: 32];
            end
            finish <= 1;
        end
    end
endmodule
