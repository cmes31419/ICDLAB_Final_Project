`timescale 1ns / 1ps

parameter CYCLE = 10;

module tb_A_inv;

    // --- Inputs ---
    reg i_clk;
    reg i_rst_n;
    reg i_mode;
    reg i_4or6;
    reg i_0or1;
    reg [5:0] i_gf_mul0_in1;
    reg [5:0] i_gf_mul1_in1;
    reg [1:0] i_undecoded_idx_1;
    reg [1:0] i_undecoded_idx_2;

    // --- Outputs ---
    wire [5:0] o_HS_1;
    wire [5:0] o_HS_2;

    // --- Instantiate the Device Under Test (DUT) ---
    A_inv uut (
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_mode(i_mode), 
        .i_4or6(i_4or6), 
        .i_0or1(i_0or1), 
        .i_gf_mul0_in1(i_gf_mul0_in1), 
        .i_gf_mul1_in1(i_gf_mul1_in1), 
        .i_undecoded_idx_1(i_undecoded_idx_1), 
        .i_undecoded_idx_2(i_undecoded_idx_2), 
        .o_HS_1(o_HS_1), 
        .o_HS_2(o_HS_2)
    );

    // --------------------------
    // clock
    initial i_clk = 1;
    always #(CYCLE/2.0) i_clk = ~i_clk;

    initial begin
        $fsdbDumpfile("waveform.fsdb");
        $fsdbDumpvars("+mda");
    end

    // --- Test Sequence ---
    initial begin
        // Initialize Inputs
        i_clk = 0;
        i_rst_n = 0;
        i_mode = 0;
        i_4or6 = 0;
        i_0or1 = 0;
        i_gf_mul0_in1 = 6'd0;
        i_gf_mul1_in1 = 6'd0;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd0;

        // Apply Reset
        #CYCLE;
        i_rst_n = 1;
        #CYCLE;

        // --------------------------------------------------------
        // Test Case 1: Square Mode (i_mode = 0)
        // Expectation: gf_mul inputs are squared
        // --------------------------------------------------------
        @(posedge i_clk)
        $display("--- Test Case 1: Square Mode ---");
        i_mode = 0;
        i_gf_mul0_in1 = 6'b000010; // a
        i_gf_mul1_in1 = 6'b000100; // a^2
        
        // --------------------------------------------------------
        // Test Case 2: A Inverse Mode -> S_4, b1 (0or1 = 0)
        // Indices: 0 and 1
        // --------------------------------------------------------
        @(posedge i_clk)
        $display("--- Test Case 2: A_inv Mode (S_4, b1, Idx:0,1) ---");
        i_mode = 1;
        i_4or6 = 0;
        i_0or1 = 0;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd1;
        i_gf_mul0_in1 = 6'b000011; // Nested syndrome 1 (dummy value)
        i_gf_mul1_in1 = 6'b000001; // Nested syndrome 2 (dummy value)

        // --------------------------------------------------------
        // Test Case 3: A Inverse Mode -> S_6, b2 (0or1 = 1)
        // Indices: 1 and 3
        // --------------------------------------------------------
        @(posedge i_clk)
        $display("--- Test Case 3: A_inv Mode (S_6, b2, Idx:1,3) ---");
        i_mode = 1;
        i_4or6 = 1;
        i_0or1 = 1;
        i_undecoded_idx_1 = 2'd1;
        i_undecoded_idx_2 = 2'd3;
        i_gf_mul0_in1 = 6'b101010;
        i_gf_mul1_in1 = 6'b000001;
    
        // --------------------------------------------------------
        // Test Case 4: A Inverse Mode -> S_4, b2 (0or1 = 1)
        // Indices: 2 and 3
        // --------------------------------------------------------
        @(posedge i_clk)
        $display("--- Test Case 4: A_inv Mode (S_4, b2, Idx:2,3) ---");
        i_mode = 1;
        i_4or6 = 0;
        i_0or1 = 1;
        i_undecoded_idx_1 = 2'd2;
        i_undecoded_idx_2 = 2'd3;
        i_gf_mul0_in1 = 6'b111111;
        i_gf_mul1_in1 = 6'b000001;

        $display("Simulation completed.");
        #(CYCLE*5.0);
        $finish;
    end
    
    // --- Monitor Outputs ---
    initial begin
        $monitor("Time=%0t | mode=%b | 4or6=%b | 0or1=%b | idx={%d,%d} | o_HS_1=%b | o_HS_2=%b", 
                 $time, i_mode, i_4or6, i_0or1, i_undecoded_idx_1, i_undecoded_idx_2, o_HS_1, o_HS_2);
    end

endmodule

// // ====================================================================
// // Dummy Multiplier (Replace with your actual gf_mul module)
// // ====================================================================
// module gf_mul (
//     input  [5:0] in1,
//     input  [5:0] in2,
//     output [5:0] prod
// );
//     // Simple XOR for testing compilation and basic data flow.
//     // In reality, this should be the GF(2^6) mod (x^6+x+1) multiplier.
//     assign prod = in1 ^ in2; 
// endmodule