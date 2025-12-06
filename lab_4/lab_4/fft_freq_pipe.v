`timescale 1ns / 1ps

module fft_freq_pipe(
clk,
rst,
fr,
fi,
Fr,
Fi
    );

parameter width=8;
parameter decimal=4;

input clk,rst;

input [8*width-1:0] fr,fi;
output reg[8*width-1:0] Fr,Fi;

wire[width-1:0] o0r[7:0];
wire[width-1:0] o0i[7:0];

// Registered outputs of level 1
reg[width-1:0] r0r[7:0];
reg[width-1:0] r0i[7:0];

wire[width-1:0] o1r[7:0];
wire[width-1:0] o1i[7:0];

// Registered outputs of level 2
reg[width-1:0] r1r[7:0];
reg[width-1:0] r1i[7:0];

wire [8*width-1:0] Fwr,Fwi;


// Start of your code
//-----------------------------level 1---------------------------//
butterfly_freq #(.width(width),.decimal(decimal)) bf0(fr[1*width-1:0*width], fi[1*width-1:0*width], fr[5*width-1:4*width], fi[5*width-1:4*width], (1<<decimal), 0, o0r[0], o0i[0], o0r[4], o0i[4]);
butterfly_freq #(.width(width),.decimal(decimal)) bf1(fr[2*width-1:1*width], fi[2*width-1:1*width], fr[6*width-1:5*width], fi[6*width-1:5*width], 11, -11, o0r[1], o0i[1], o0r[5], o0i[5]);
butterfly_freq #(.width(width),.decimal(decimal)) bf2(fr[3*width-1:2*width], fi[3*width-1:2*width], fr[7*width-1:6*width], fi[7*width-1:6*width], 0, -16, o0r[2], o0i[2], o0r[6], o0i[6]);
butterfly_freq #(.width(width),.decimal(decimal)) bf3(fr[4*width-1:3*width], fi[4*width-1:3*width], fr[8*width-1:7*width], fi[8*width-1:7*width], -11, -11, o0r[3], o0i[3], o0r[7], o0i[7]);

// First pipeline stage: Register the outputs of level 1
integer i;
always@(posedge clk or negedge rst) begin
    if(~rst) begin
        for(i=0; i<8; i=i+1) begin
            r0r[i] <= 0;
            r0i[i] <= 0;
        end
    end
    else begin
        for(i=0; i<8; i=i+1) begin
            r0r[i] <= o0r[i];
            r0i[i] <= o0i[i];
        end
    end
end



//-----------------------------level 2---------------------------//
butterfly_freq #(.width(width),.decimal(decimal)) bf4(r0r[0], r0i[0], r0r[2], r0i[2], (1<<decimal), 0, o1r[0], o1i[0], o1r[2], o1i[2]);
butterfly_freq #(.width(width),.decimal(decimal)) bf5(r0r[1], r0i[1], r0r[3], r0i[3], 0, -16, o1r[1], o1i[1], o1r[3], o1i[3]);
butterfly_freq #(.width(width),.decimal(decimal)) bf6(r0r[4], r0i[4], r0r[6], r0i[6], (1<<decimal), 0, o1r[4], o1i[4], o1r[6], o1i[6]);
butterfly_freq #(.width(width),.decimal(decimal)) bf7(r0r[5], r0i[5], r0r[7], r0i[7], 0, -16, o1r[5], o1i[5], o1r[7], o1i[7]);

// Second pipeline stage: Register the outputs of level 2
always@(posedge clk or negedge rst) begin
    if(~rst) begin
        for(i=0; i<8; i=i+1) begin
            r1r[i] <= 0;
            r1i[i] <= 0;
        end
    end
    else begin
        for(i=0; i<8; i=i+1) begin
            r1r[i] <= o1r[i];
            r1i[i] <= o1i[i];
        end
    end
end




//-----------------------------level 3---------------------------//
butterfly_freq #(.width(width),.decimal(decimal)) bf8(r1r[0], r1i[0], r1r[1], r1i[1], (1<<decimal), 0, Fwr[1*width-1:0*width], Fwi[1*width-1:0*width], Fwr[5*width-1:4*width], Fwi[5*width-1:4*width]);
butterfly_freq #(.width(width),.decimal(decimal)) bf9(r1r[2], r1i[2], r1r[3], r1i[3], (1<<decimal), 0, Fwr[3*width-1:2*width], Fwi[3*width-1:2*width], Fwr[7*width-1:6*width], Fwi[7*width-1:6*width]);
butterfly_freq #(.width(width),.decimal(decimal)) bf10(r1r[4], r1i[4], r1r[5], r1i[5], (1<<decimal), 0, Fwr[2*width-1:1*width], Fwi[2*width-1:1*width], Fwr[6*width-1:5*width], Fwi[6*width-1:5*width]);
butterfly_freq #(.width(width),.decimal(decimal)) bf11(r1r[6], r1i[6], r1r[7], r1i[7], (1<<decimal), 0, Fwr[4*width-1:3*width], Fwi[4*width-1:3*width], Fwr[8*width-1:7*width], Fwi[8*width-1:7*width]);

// Final output register stage
always@(posedge clk or negedge rst) begin
    if(~rst) begin
        Fr <= 0;
        Fi <= 0;
    end
    else begin
        Fr <= Fwr;
        Fi <= Fwi;
    end
end



// End of your code


endmodule
