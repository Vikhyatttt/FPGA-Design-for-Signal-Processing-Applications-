`timescale 1ns / 1ps

module viterbi(
    clk,
    rst,
    codein,   // Encoded input sequence (10 bits long)
    states,   // Possible state transitions (16-bit encoding table)
    codeout,  // Final decoded bit sequence (5 bits)
    finish    // Output flag that goes high when decoding is complete
);

//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
parameter r = 2;       // Number of parity bits generated per input bit
parameter K = 3;       // Constraint length (memory size of encoder)
parameter lenin = 10;  // Input code word length (number of encoded bits)
parameter lenout = 5;  // Output decoded message length (number of decoded bits)

// Bit masks to handle state and code extraction
parameter maskcode = (1 << r) - 1;     // 2-bit mask for parity code
parameter maskstate = (1 << (K-1)) - 1;// 2-bit mask for encoder state
parameter maskpath = (1 << K) - 1;     // 3-bit mask for full path tracking

//////////////////////////////////////////////////////////////////////////////////
// I/O and Internal Registers
//////////////////////////////////////////////////////////////////////////////////
input clk, rst;
input [lenin-1:0] codein;                        // Incoming encoded bits
input [(1<<(K-1))*2*r-1:0] states;               // State transition table
output reg [lenout-1:0] codeout;                 // Decoded bit sequence
output reg finish;                               // Goes high when decoding finishes

// FSM and counters
reg [7:0] state;          // FSM state for sequencing steps
reg [7:0] code_count;     // Keeps track of how many encoded pairs are processed
reg [7:0] count;          // General-purpose counter for loops or timing
reg [7:0] i;              // Loop iterator
reg [7:0] mindis;         // Minimum path metric value (lowest error)
reg [7:0] mins;           // Index of the state with minimum metric
reg [r-1:0] code;         // Holds the current 2-bit encoded input segment

// BMU + PMU communication signals
wire [(1<<(K-1))*2*r-1:0] dis_path_out;          // Output of BMU: branch distances
wire [(1<<(K-1))*K-1:0] pmu_path_out;            // Output of PMU: updated survivor paths
wire [(1<<(K-1))*8-1:0] pmu_dis_out;             // Output of PMU: updated path metrics

// Storage for path metrics and survivor paths
reg [lenout*K-1:0] paths[(1<<(K-1))-1:0];        // Each entry stores possible decoded paths
reg [(1<<(K-1))*8-1:0] dis[1:0];                 // Holds path metric values for two time steps


//////////////////////////////////////////////////////////////////////////////////
// Branch Metric Unit (BMU)
// Calculates how "different" each possible branch output is from the received code.
//////////////////////////////////////////////////////////////////////////////////
bmu #(.r(r), .K(K)) b0(
    clk,
    rst,
    code,
    states,
    dis_path_out
);

//////////////////////////////////////////////////////////////////////////////////
// Path Metric Unit (PMU)
// Chooses the best (minimum error) path entering each state and records the survivor.
//////////////////////////////////////////////////////////////////////////////////
pmu #(.r(r), .K(K)) p0(
    clk,
    rst,
    dis[1],          // Previous path metrics (from earlier iteration)
    dis_path_out,    // New branch metrics (computed by BMU)
    pmu_path_out,    // Updated survivor paths (per state)
    pmu_dis_out      // Updated path metrics (per state)
);

//////////////////////////////////////////////////////////////////////////////////
// Main Control FSM
// Controls the flow of decoding through multiple stages.
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
    if (~rst) begin
        // When reset, clear everything and start from idle state
        state <= 0;
        code_count <= 0;
        code <= 0;
        count <= 0;
        codeout <= 0;
        i <= 0;
        mindis <= 8'hff;  // start with large distance
        mins <= 8'hff;
        finish <= 0;

        // Initialize survivor paths and path metrics
        paths[0] <= 0;
        paths[1] <= 0;
        paths[2] <= 0;
        paths[3] <= 0;
        dis[0] <= {24'hffffff, 8'h00};  // state 0 starts with 0 metric
        dis[1] <= {32'hffffffff};       // others start with high metric
    end
    else begin
        case (state)
            //------------------------------------------------------------------
            // STATE 0: Load next encoded bits and prepare BMU
            //------------------------------------------------------------------
            0: begin
                // Shift previous path metrics and reset current metrics
                dis[1] <= dis[0];
                dis[0] <= {32'hffffffff};

                // Extract next 2-bit encoded pair from input stream
                code <= (codein >> (8 - (2 * code_count))) & 'hff;

                // Move to waiting state to allow BMU computations to settle
                state <= 1;
            end

            //------------------------------------------------------------------
            // STATE 1: Small delay for BMU outputs to stabilize
            //------------------------------------------------------------------
            1: begin
                count <= count + 1;
                if (count == 2) begin
                    count <= 0;
                    state <= 2; // Move on to PMU update stage
                end
            end

            //------------------------------------------------------------------
            // STATE 2: Update path metrics and survivor paths using PMU output
            //------------------------------------------------------------------
            2: begin
                // Store new path metrics from PMU output
                dis[0] <= pmu_dis_out;

                // Append survivor path information for each state
                for (i = 0; i < 4; i = i + 1) begin
                    // Each path is 3 bits representing direction + state history
                    paths[i] = paths[i] | ((pmu_path_out >> (3 * i)) & 3'h7) << (3 * code_count);
                end

                // If all encoded symbols are processed, move to traceback stage
                if (code_count == 4) begin
                    code_count <= 0;
                    state <= 3;
                end
                else begin
                    code_count = code_count + 1;
                    state <= 0;  // Continue to next encoded input
                end
            end

            //------------------------------------------------------------------
            // STATE 3: Find the minimum distance path (best decoded sequence)
            //------------------------------------------------------------------
            3: begin
                // Compare path metrics to find the one with the smallest distance
                if (((dis[0] >> (8 * count)) & 8'h0f) < mindis) begin
                    mindis <= (dis[0] >> (8 * count)) & 8'h0f;
                    mins <= count; // Record index of minimum metric state
                end

                // Move to traceback when all states are checked
                if (count == 3) begin
                    state <= 4;
                end
                else begin
                    count <= count + 1;
                end
            end

            //------------------------------------------------------------------
            // STATE 4: Traceback stage — reconstruct decoded bits
            //------------------------------------------------------------------
            4: begin
                if (finish == 0) begin
                    // Pick decoded bit from survivor path of min-metric state
                    codeout <= codeout | ((paths[mins] >> (14 - (3 * code_count))) & 1'h1) << code_count;

                    // Move to previous state in traceback history
                    mins <= (paths[mins] >> (12 - (3 * code_count))) & 8'h03;

                    // If all bits traced back, decoding is complete
                    if (code_count == 4) begin
                        finish <= 1;
                    end
                    else begin
                        code_count = code_count + 1;
                    end
                end
            end
        endcase
    end
end

endmodule
