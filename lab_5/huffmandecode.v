`timescale 1ns / 1ps

module huffmandecode(
clk,
rst,
code,
hufftable,
huffsymbol,
data,
length,
finish
    );
input clk,rst;
input[15:0] code;
input[8*16-1:0] hufftable;
input[8*256-1:0] huffsymbol;
output reg[7:0] data;
output reg[7:0] length;
output reg finish;

reg[7:0] count;

wire[15:0] UB;
wire[15:0] SC;
reg[15:0] UB_old;
reg[15:0] dis;
reg[15:0] index;
wire[15:0] code_tmp;
wire[15:0] huff_table_tmp;
wire[15:0] huff_symbol_tmp;
wire[15:0] symbol_idx; 

assign code_tmp   = code >> (16 -(count+1));
assign huff_table_tmp  = (hufftable  >> (8 *  count )                    ) & 8'hFF;
assign huff_symbol_tmp = (huffsymbol >> (8 * symbol_idx)                 ) & 8'hFF;

assign symbol_idx = index + (code_tmp - SC);

assign SC = (UB_old << 1);
assign UB = (UB_old << 1) + huff_table_tmp;
   
always@(posedge clk or negedge rst)begin
    if(~rst)begin
    // Start of your code ====================================
        length <= 0;
        finish <= 0;
        data   <= 0;

        UB_old <= 0;
        dis    <= 0;
        index  <= 0;
        count  <= 0;

    // End of your code ======================================
    end
    else if(finish==0)begin
        //finish <= 1;
	if(count<=15)begin
        	// Start of your code ====================================
            UB_old <= UB;
            if (  (SC <= code_tmp) && (code_tmp < UB)) begin
                length <= count+1;
                finish <= 1;  
                data   <= huff_symbol_tmp;
            end 
            index <= index + huff_table_tmp;
        	// End of your code ======================================    
            count <= count + 1;
        end // end of if count <= 15
        else begin
            length<=0;
            finish<=1;
            data<='hff;
        end   
    end
end

//always@(posedge clk or negedge rst)begin
//    if(~rst)begin
//    // Start of your code ====================================
//        length <= 0;
//        finish <= 0;
//        data   <= 0;
//
//        count  <= 1;
//    // End of your code ======================================
//    end
//    else if(finish==0)begin
//	    if(count<=15)begin
//        	// Start of your code ====================================
//            
//        	// End of your code ======================================    
//	        count = count + 1;
//        end // end of if count <= 15
//        else begin
//            length<=0;
//            finish<=1;
//            data<='hff;
//        end   
//    end
//end

endmodule
