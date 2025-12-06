`timescale 1ns / 1ps
//===========================================================
//  Huffman Decoder (Lab 5 - JPEG Decoder)
//===========================================================
module huffmandecode(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] code,
    input  wire [8*16-1:0] hufftable,   // 16 bytes: number of codes for each bit length
    input  wire [8*256-1:0] huffsymbol, // 256 bytes: Huffman symbols
    output reg  [7:0]  data,
    output reg  [7:0]  length,
    output reg         finish
);

    // internal registers
    reg [7:0]  count;        // bit length iterator (1-16)
    reg [15:0] start_code;   // start code for current length
    reg [15:0] base_index;   // starting index in symbol table
    reg [15:0] index;        // computed index for symbol
    reg [15:0] prefix;       // top <count> bits of input code
    reg [7:0]  num_codes;    // number of codes of current length

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            data       <= 0;
            length     <= 0;
            finish     <= 0;
            count      <= 1;
            start_code <= 0;
            base_index <= 0;
            index      <= 0;
            prefix     <= 0;
        end
        else if(finish == 0) begin
            if(count <= 16) begin
                // number of codes with this bit length
                num_codes = hufftable[(count-1)*8 +: 8];

                // starting code and base index update
                if(count == 1) begin
                    start_code = 0;
                    base_index = 0;
                end 
                else begin
                    start_code = (start_code + hufftable[(count-2)*8 +: 8]) << 1;
                    base_index = base_index + hufftable[(count-2)*8 +: 8];
                end

                // extract the upper 'count' bits of code (left-aligned in 16 bits)
                prefix = code >> (16 - count);

                // check if prefix matches a valid code
                if(prefix >= start_code && prefix < start_code + num_codes) begin
                    index  = base_index + (prefix - start_code);
                    data   <= huffsymbol[(index*8) + 7 -: 8];
                    length <= count;
                    finish <= 1;
                end
                else begin
                    count <= count + 1;
                end
            end
            else begin
                // no match found
                data   <= 8'hFF;
                length <= 0;
                finish <= 1;
            end
        end
    end
endmodule
