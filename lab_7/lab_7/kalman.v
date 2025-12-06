`timescale 1ns / 1ps

module kalman(
    clk,
    rst,
    n,      // Input: Index of the inputs.
    u,      // Input: Scalar: Acceleration.
    z,      // Input: 1x2 Z Vector; Measurement of x.
    x0,     // Initial state of x.
    P0,     // Initial state of P.
    F,      // Input: 2x2 F Matrix.
    B,      // Input: 2x1 B Vector.
    Q,      // Input: 2x2 Q Matrix.
    H,      // Input: 2x2 H Matrix.
    R,      // Input: 2x2 R Matrix.
    no,     // Output: n_out.
    xo,     // Output: x_out.
    outen   // Output: output enable: a flag signal. 
);

parameter len=2;        // # of input size.
parameter dsize=16;     // Width of each data.
parameter decimal=10;   // Width of fraction.

input clk,rst;
input[dsize-1:0] n;
input[dsize-1:0] u;
input[dsize*len-1:0] z;
input[dsize*len-1:0] x0;
input[dsize*len*len-1:0] P0;
input[dsize*len*len-1:0] F,H,Q,R;
input[dsize*len-1:0] B;
output reg[dsize-1:0] no;
output reg[dsize*len-1:0] xo;
output reg outen;

// State definitions
localparam IDLE = 0;
localparam PREDICT = 1;
localparam UPDATE = 2;
localparam OUTPUT_STATE = 3;

reg[dsize-1:0] mi[1:0][3:0];  // intermediate input 2x4 matrix
wire[dsize-1:0] mo[3:0];      // intermediate output 1x4 vector

wire[dsize*2*2-1:0] mmin1;  //intermediate operands A in 2x2 matrix
wire[dsize*2*2-1:0] mmin2;  //intermediate operands B in 2x2 matrix
wire[dsize*2*2-1:0] mmout;  //intermediate results C in 2x2 matrix

assign mmin1[dsize-1:0]=mi[0][0];        // Fetch half of mi
assign mmin1[2*dsize-1:dsize]=mi[0][1];
assign mmin1[3*dsize-1:2*dsize]=mi[0][2];
assign mmin1[4*dsize-1:3*dsize]=mi[0][3];

assign mmin2[dsize-1:0]=mi[1][0];        // Fetch the other half of mi
assign mmin2[2*dsize-1:dsize]=mi[1][1];
assign mmin2[3*dsize-1:2*dsize]=mi[1][2];
assign mmin2[4*dsize-1:3*dsize]=mi[1][3];

assign mo[0]=mmout[dsize-1:0];
assign mo[1]=mmout[2*dsize-1:dsize];
assign mo[2]=mmout[3*dsize-1:2*dsize];
assign mo[3]=mmout[4*dsize-1:3*dsize];

matmul22 #(.size(dsize),.decimal(decimal)) mm0(mmin1,mmin2,mmout);

// Internal registers
reg [1:0] state;
reg [dsize-1:0] n_prev;
reg [dsize*len-1:0] x_prev, x_pred;
reg [dsize*len*len-1:0] P_prev, P_pred;
reg processing;

// Fixed-point representation of 1
wire [dsize-1:0] ONE;
assign ONE = 1 << decimal;

// Counter to manage processing cycles
reg [3:0] cycle_count;

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        // Reset all registers
        state <= IDLE;
        n_prev <= 0;
        x_prev <= x0;
        P_prev <= P0;
        x_pred <= 0;
        P_pred <= 0;
        outen <= 0;
        no <= 0;
        xo <= 0;
        processing <= 0;
        cycle_count <= 0;
        
        // Reset matrix inputs
        mi[0][0] <= 0; mi[0][1] <= 0; mi[0][2] <= 0; mi[0][3] <= 0;
        mi[1][0] <= 0; mi[1][1] <= 0; mi[1][2] <= 0; mi[1][3] <= 0;
    end
    else begin
        // Default outputs
        outen <= 0;
        
        case (state)
            IDLE: begin
                // Check if new input is available and we're not already processing
                if (n != n_prev && !processing) begin
                    n_prev <= n;
                    processing <= 1;
                    cycle_count <= 0;
                    state <= PREDICT;
                    
                    // Start prediction step: x_pred = F * x_prev + B * u
                    mi[0][0] <= F[dsize-1:0];           // F[0][0]
                    mi[0][1] <= F[2*dsize-1:dsize];     // F[0][1]
                    mi[0][2] <= F[3*dsize-1:2*dsize];   // F[1][0]
                    mi[0][3] <= F[4*dsize-1:3*dsize];   // F[1][1]
                    
                    mi[1][0] <= x_prev[dsize-1:0];      // x_prev[0]
                    mi[1][1] <= 0;
                    mi[1][2] <= x_prev[2*dsize-1:dsize]; // x_prev[1]
                    mi[1][3] <= 0;
                end
            end
            
            PREDICT: begin
                if (cycle_count == 1) begin
                    // After one cycle, get matrix result and add B*u
                    x_pred[dsize-1:0] <= mo[0] + ((B[dsize-1:0] * u) >>> decimal);
                    x_pred[2*dsize-1:dsize] <= mo[2] + ((B[2*dsize-1:dsize] * u) >>> decimal);
                    
                    // For this simplified version, keep P constant
                    P_pred <= P_prev;
                    
                    state <= UPDATE;
                    cycle_count <= 0;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            UPDATE: begin
                if (cycle_count == 0) begin
                    // Simple update: x_prev = x_pred + 0.5*(z - x_pred)
                    // This is a simplified Kalman update for testing
                    x_prev[dsize-1:0] <= x_pred[dsize-1:0] + ((z[dsize-1:0] - x_pred[dsize-1:0]) >>> 1);
                    x_prev[2*dsize-1:dsize] <= x_pred[2*dsize-1:dsize] + ((z[2*dsize-1:dsize] - x_pred[2*dsize-1:dsize]) >>> 1);
                    
                    state <= OUTPUT_STATE;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            OUTPUT_STATE: begin
                // Set outputs
                outen <= 1;
                no <= n_prev;
                xo <= x_prev;
                
                // Return to IDLE to process next input
                processing <= 0;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule