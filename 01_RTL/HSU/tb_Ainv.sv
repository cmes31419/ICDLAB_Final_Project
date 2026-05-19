`timescale 1ns / 1ps

parameter CYCLE = 10;

module tb_A_inv;

    // --- Inputs ---
    reg i_clk;
    reg i_rst_n;
    reg i_mode;
    reg i_4or6;
    reg [5:0] i_gf_mul0_in1;
    reg [5:0] i_gf_mul1_in1;
    reg [5:0] i_gf_mul2_in1;
    reg [5:0] i_gf_mul3_in1;
    reg [1:0] i_undecoded_idx_1;
    reg [1:0] i_undecoded_idx_2;

    // --- Outputs ---
    wire [5:0] o_HS_1;
    wire [5:0] o_HS_2;
    wire [5:0] o_HS_3;
    wire [5:0] o_HS_4;

    // --- Instantiate the Device Under Test (DUT) ---
    A_inv uut (
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_mode(i_mode), 
        .i_4or6(i_4or6),
        .i_gf_mul0_in1(i_gf_mul0_in1), 
        .i_gf_mul1_in1(i_gf_mul1_in1),
        .i_gf_mul2_in1(i_gf_mul2_in1),
        .i_gf_mul3_in1(i_gf_mul3_in1),
        .i_undecoded_idx_1(i_undecoded_idx_1), 
        .i_undecoded_idx_2(i_undecoded_idx_2), 
        .o_HS_1(o_HS_1), 
        .o_HS_2(o_HS_2),
        .o_HS_3(o_HS_3),
        .o_HS_4(o_HS_4)
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
    // NOTE: Output has 1-cycle register latency
    // Timing: @(negedge) set input -> @(posedge) calc -> @(posedge) read output
    initial begin
        // Initialize Inputs
        i_clk = 0;
        i_rst_n = 0;
        i_mode = 0;
        i_4or6 = 0;
        i_gf_mul0_in1 = 6'd0;
        i_gf_mul1_in1 = 6'd0;
        i_gf_mul2_in1 = 6'd0;
        i_gf_mul3_in1 = 6'd0;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd0;

        // Apply Reset
        #CYCLE;
        i_rst_n = 1;
        #CYCLE;

        // ========================================================
        // Test Case 1: Square Mode - Complex values
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC1] Square Mode Input (negedge)");
        $display("[TC1] Inputs: 001101, 010011, 100101, 110001");
        i_mode = 0;  // Square mode
        i_gf_mul0_in1 = 6'b001101;
        i_gf_mul1_in1 = 6'b010011;
        i_gf_mul2_in1 = 6'b100101;
        i_gf_mul3_in1 = 6'b110001;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd0;
        
        @(posedge i_clk)  // First posedge: comb logic calculates, register updates
        @(posedge i_clk)  // Second posedge: read registered output
        $display("[TC1] Output: o_HS_1=%b, o_HS_2=%b, o_HS_3=%b, o_HS_4=%b", 
                 o_HS_1, o_HS_2, o_HS_3, o_HS_4);
        #CYCLE;

        // ========================================================
        // Test Case 2: Matrix Mode (S_4, Index [0,1])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC2] Matrix S_4 [0,1] Input (negedge)");
        $display("[TC2] Syndrome: 101011, 011101, 110010, 001111");
        $display("[TC2] Matrix: [[a+1, a], [a, a]] = [[000011, 000010], [000010, 000010]]");
        i_mode = 1;
        i_4or6 = 1'b0;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd1;
        i_gf_mul0_in1 = 6'b101011;
        i_gf_mul1_in1 = 6'b011101;
        i_gf_mul2_in1 = 6'b110010;
        i_gf_mul3_in1 = 6'b001111;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC2] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 3: Matrix Mode (S_4, Index [1,2])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC3] Matrix S_4 [1,2] Input (negedge)");
        $display("[TC3] Syndrome: 111001, 010101, 100011, 001010");
        $display("[TC3] Matrix: [[a+1, 111101], [a, 111101]]");
        i_mode = 1;
        i_4or6 = 1'b0;
        i_undecoded_idx_1 = 2'd1;
        i_undecoded_idx_2 = 2'd2;
        i_gf_mul0_in1 = 6'b111001;
        i_gf_mul1_in1 = 6'b010101;
        i_gf_mul2_in1 = 6'b100011;
        i_gf_mul3_in1 = 6'b001010;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC3] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 4: Matrix Mode (S_4, Index [2,3])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC4] Matrix S_4 [2,3] Input (negedge)");
        $display("[TC4] Syndrome: 001001, 110110, 101000, 011110");
        $display("[TC4] Matrix: [[a+1, 010111], [a, 010111]]");
        i_mode = 1;
        i_4or6 = 1'b0;
        i_undecoded_idx_1 = 2'd2;
        i_undecoded_idx_2 = 2'd3;
        i_gf_mul0_in1 = 6'b001001;
        i_gf_mul1_in1 = 6'b110110;
        i_gf_mul2_in1 = 6'b101000;
        i_gf_mul3_in1 = 6'b011110;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC4] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 5: Matrix Mode (S_6, Index [0,1])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC5] Matrix S_6 [0,1] Input (negedge)");
        $display("[TC5] Syndrome: 110101, 101010, 011001, 100110");
        $display("[TC5] Matrix: [[101101, 101100], [101100, 101100]]");
        i_mode = 1;
        i_4or6 = 1'b1;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd1;
        i_gf_mul0_in1 = 6'b110101;
        i_gf_mul1_in1 = 6'b101010;
        i_gf_mul2_in1 = 6'b011001;
        i_gf_mul3_in1 = 6'b100110;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC5] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 6: Matrix Mode (S_6, Index [1,3])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC6] Matrix S_6 [1,3] Input (negedge)");
        $display("[TC6] Syndrome: 010110, 101101, 110011, 001100");
        $display("[TC6] Matrix: [[100010, 010000], [100011, 010000]]");
        i_mode = 1;
        i_4or6 = 1'b1;
        i_undecoded_idx_1 = 2'd1;
        i_undecoded_idx_2 = 2'd3;
        i_gf_mul0_in1 = 6'b010110;
        i_gf_mul1_in1 = 6'b101101;
        i_gf_mul2_in1 = 6'b110011;
        i_gf_mul3_in1 = 6'b001100;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC6] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 7: Square Mode - Edge cases
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC7] Square Mode Edge Cases Input (negedge)");
        $display("[TC7] Inputs: 000001, 111111, 011111, 100000");
        i_mode = 0;
        i_gf_mul0_in1 = 6'b000001;
        i_gf_mul1_in1 = 6'b111111;
        i_gf_mul2_in1 = 6'b011111;
        i_gf_mul3_in1 = 6'b100000;
        i_4or6 = 1'bx;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC7] Output: o_HS_1=%b, o_HS_2=%b, o_HS_3=%b, o_HS_4=%b", 
                 o_HS_1, o_HS_2, o_HS_3, o_HS_4);
        #CYCLE;

        // ========================================================
        // Test Case 8: Matrix Mode (S_4, Index [0,2])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC8] Matrix S_4 [0,2] Input (negedge)");
        $display("[TC8] Syndrome: 010010, 100100, 001001, 010011");
        $display("[TC8] Matrix: [[a^2+1, a^2], [a^2, a^2]]");
        i_mode = 1;
        i_4or6 = 1'b0;
        i_undecoded_idx_1 = 2'd0;
        i_undecoded_idx_2 = 2'd2;
        i_gf_mul0_in1 = 6'b010010;
        i_gf_mul1_in1 = 6'b100100;
        i_gf_mul2_in1 = 6'b001001;
        i_gf_mul3_in1 = 6'b010011;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC8] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        // ========================================================
        // Test Case 9: Matrix Mode (S_6, Index [2,3])
        // ========================================================
        @(negedge i_clk)
        $display("\n[TC9] Matrix S_6 [2,3] Input (negedge)");
        $display("[TC9] Syndrome: 111000, 000111, 101101, 010010");
        $display("[TC9] Matrix: [[101101, 101001], [101100, 101001]]");
        i_mode = 1;
        i_4or6 = 1'b1;
        i_undecoded_idx_1 = 2'd2;
        i_undecoded_idx_2 = 2'd3;
        i_gf_mul0_in1 = 6'b111000;
        i_gf_mul1_in1 = 6'b000111;
        i_gf_mul2_in1 = 6'b101101;
        i_gf_mul3_in1 = 6'b010010;
        
        @(posedge i_clk)
        @(posedge i_clk)
        $display("[TC9] Output: o_HS_1=%b, o_HS_2=%b", o_HS_1, o_HS_2);
        #CYCLE;

        $display("\n=== Simulation Completed ===");
        #(CYCLE*5.0);
        $finish;
    end
    
    // --- Monitor Outputs ---
    initial begin
        $monitor("Time=%0t | o_HS=[%b,%b,%b,%b]", 
                 $time, o_HS_1, o_HS_2, o_HS_3, o_HS_4);
    end

endmodule
