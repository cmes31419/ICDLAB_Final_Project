//=====================================================================
// nsu_tb.v
//
// Testbench for nsu_top.v
//
// Test vectors are generated from the Python golden model in testbench.py
// (Test 1: b=1, only c_1 undecoded, with errors as specified there).
//
// For undecoded interleaves, S inputs are random garbage to test flag
// gating: if NSU correctly gates them, output should still match expected.
//=====================================================================

`timescale 1ns/1ps

module nsu_tb;

    reg clk;
    reg rst;
    reg enable;

    // R inputs (test vectors)
    reg [5:0] R_j2_i0, R_j2_i1, R_j2_i2, R_j2_i3;
    reg [5:0] R_j3_i0, R_j3_i1, R_j3_i2, R_j3_i3;
    reg [5:0] R_j4_i0, R_j4_i1, R_j4_i2, R_j4_i3;
    reg [5:0] R_j5_i0, R_j5_i1, R_j5_i2, R_j5_i3;

    // S inputs (test vectors)
    reg [5:0] S_j2_i0, S_j2_i1, S_j2_i2, S_j2_i3;
    reg [5:0] S_j3_i0, S_j3_i1, S_j3_i2, S_j3_i3;
    reg [5:0] S_j4_i0, S_j4_i1, S_j4_i2, S_j4_i3;
    reg [5:0] S_j5_i0, S_j5_i1, S_j5_i2, S_j5_i3;

    // Flags
    reg f0, f1, f2, f3;

    // Outputs
    wire [5:0] Shat0_j2, Shat1_j2;
    wire [5:0] Shat0_j3, Shat1_j3;
    wire [5:0] Shat0_j4, Shat1_j4;
    wire [5:0] Shat0_j5, Shat1_j5;
    wire valid;

    // Expected values (from Python)
    reg [5:0] exp_Shat0_j2, exp_Shat1_j2;
    reg [5:0] exp_Shat0_j3, exp_Shat1_j3;
    reg [5:0] exp_Shat0_j4, exp_Shat1_j4;
    reg [5:0] exp_Shat0_j5, exp_Shat1_j5;

    integer errors;

    //-----------------------------------------------------------------
    // DUT
    //-----------------------------------------------------------------
    nsu_top u_dut (
        .clk(clk), .rst(rst), .enable(enable),
        .R_j2_i0(R_j2_i0), .R_j2_i1(R_j2_i1), .R_j2_i2(R_j2_i2), .R_j2_i3(R_j2_i3),
        .R_j3_i0(R_j3_i0), .R_j3_i1(R_j3_i1), .R_j3_i2(R_j3_i2), .R_j3_i3(R_j3_i3),
        .R_j4_i0(R_j4_i0), .R_j4_i1(R_j4_i1), .R_j4_i2(R_j4_i2), .R_j4_i3(R_j4_i3),
        .R_j5_i0(R_j5_i0), .R_j5_i1(R_j5_i1), .R_j5_i2(R_j5_i2), .R_j5_i3(R_j5_i3),
        .S_j2_i0(S_j2_i0), .S_j2_i1(S_j2_i1), .S_j2_i2(S_j2_i2), .S_j2_i3(S_j2_i3),
        .S_j3_i0(S_j3_i0), .S_j3_i1(S_j3_i1), .S_j3_i2(S_j3_i2), .S_j3_i3(S_j3_i3),
        .S_j4_i0(S_j4_i0), .S_j4_i1(S_j4_i1), .S_j4_i2(S_j4_i2), .S_j4_i3(S_j4_i3),
        .S_j5_i0(S_j5_i0), .S_j5_i1(S_j5_i1), .S_j5_i2(S_j5_i2), .S_j5_i3(S_j5_i3),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .Shat0_j2(Shat0_j2), .Shat1_j2(Shat1_j2),
        .Shat0_j3(Shat0_j3), .Shat1_j3(Shat1_j3),
        .Shat0_j4(Shat0_j4), .Shat1_j4(Shat1_j4),
        .Shat0_j5(Shat0_j5), .Shat1_j5(Shat1_j5),
        .valid(valid)
    );

    //-----------------------------------------------------------------
    // Clock generation
    //-----------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    //-----------------------------------------------------------------
    // Check task
    //-----------------------------------------------------------------
    task check_output;
        input [127:0] name;
        input [5:0]   actual;
        input [5:0]   expected;
        begin
            if (actual !== expected) begin
                $display("FAIL: %s: actual=%b (%d), expected=%b (%d)",
                         name, actual, actual, expected, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: %s: %b (%d)", name, actual, actual);
            end
        end
    endtask

    //-----------------------------------------------------------------
    // Main test sequence
    //-----------------------------------------------------------------
    initial begin
        // Init
        errors = 0;
        rst = 1;
        enable = 0;
        // zero all inputs
        {R_j2_i0, R_j2_i1, R_j2_i2, R_j2_i3} = 24'b0;
        {R_j3_i0, R_j3_i1, R_j3_i2, R_j3_i3} = 24'b0;
        {R_j4_i0, R_j4_i1, R_j4_i2, R_j4_i3} = 24'b0;
        {R_j5_i0, R_j5_i1, R_j5_i2, R_j5_i3} = 24'b0;
        {S_j2_i0, S_j2_i1, S_j2_i2, S_j2_i3} = 24'b0;
        {S_j3_i0, S_j3_i1, S_j3_i2, S_j3_i3} = 24'b0;
        {S_j4_i0, S_j4_i1, S_j4_i2, S_j4_i3} = 24'b0;
        {S_j5_i0, S_j5_i1, S_j5_i2, S_j5_i3} = 24'b0;
        {f0, f1, f2, f3} = 4'b0;

        // Reset
        #20 rst = 0;

        //=============================================================
        // Test 1: b=1, only c_1 undecoded
        // (Test vectors from Python golden model)
        //=============================================================
        $display("\n========================================");
        $display("Test 1: b=1, only c_1 undecoded");
        $display("========================================");

        // Flags: c_1 undecoded
        f0 = 1; f1 = 0; f2 = 1; f3 = 1;

        // ---- j=2 (L=5) ----
        R_j2_i0 = 6'b001011; R_j2_i1 = 6'b010001; R_j2_i2 = 6'b000000; R_j2_i3 = 6'b010111;
        S_j2_i0 = 6'b001011; S_j2_i1 = 6'b110100; S_j2_i2 = 6'b000000; S_j2_i3 = 6'b010111;
        exp_Shat0_j2 = 6'b010001;
        exp_Shat1_j2 = 6'b111000;

        // ---- j=3 (L=7) ----
        R_j3_i0 = 6'b011001; R_j3_i1 = 6'b001100; R_j3_i2 = 6'b000000; R_j3_i3 = 6'b011010;
        S_j3_i0 = 6'b011001; S_j3_i1 = 6'b100010; S_j3_i2 = 6'b000000; S_j3_i3 = 6'b011010;
        exp_Shat0_j3 = 6'b001100;
        exp_Shat1_j3 = 6'b101000;

        // ---- j=4 (L=9) ----
        R_j4_i0 = 6'b101110; R_j4_i1 = 6'b110100; R_j4_i2 = 6'b000000; R_j4_i3 = 6'b101100;
        S_j4_i0 = 6'b101110; S_j4_i1 = 6'b001001; S_j4_i2 = 6'b000000; S_j4_i3 = 6'b101100;
        exp_Shat0_j4 = 6'b110100;
        exp_Shat1_j4 = 6'b111101;

        // ---- j=5 (L=11) ----
        R_j5_i0 = 6'b000100; R_j5_i1 = 6'b011011; R_j5_i2 = 6'b000000; R_j5_i3 = 6'b101110;
        S_j5_i0 = 6'b000100; S_j5_i1 = 6'b101101; S_j5_i2 = 6'b000000; S_j5_i3 = 6'b101110;
        exp_Shat0_j5 = 6'b011011;
        exp_Shat1_j5 = 6'b011010;

        // Pulse enable for 1 cycle
        @(posedge clk); #1;
        enable = 1;
        @(posedge clk); #1;
        // After this posedge, the output register has latched the result
        // and valid is high.
        if (valid !== 1'b1) begin
            $display("FAIL: valid not asserted after enable!");
            errors = errors + 1;
        end else begin
            $display("PASS: valid asserted correctly");
        end
        enable = 0;

        check_output("Shat0_j2", Shat0_j2, exp_Shat0_j2);
        check_output("Shat1_j2", Shat1_j2, exp_Shat1_j2);
        check_output("Shat0_j3", Shat0_j3, exp_Shat0_j3);
        check_output("Shat1_j3", Shat1_j3, exp_Shat1_j3);
        check_output("Shat0_j4", Shat0_j4, exp_Shat0_j4);
        check_output("Shat1_j4", Shat1_j4, exp_Shat1_j4);
        check_output("Shat0_j5", Shat0_j5, exp_Shat0_j5);
        check_output("Shat1_j5", Shat1_j5, exp_Shat1_j5);

        //=============================================================
        // Sanity test: all decoded -> all output should be 0
        //=============================================================
        $display("\n========================================");
        $display("Test 2: all decoded (sanity)");
        $display("========================================");

        f0 = 1; f1 = 1; f2 = 1; f3 = 1;
        // R = S (in this artificial case where S = true high-order syndrome
        // matches r_i(alpha^L) for zero codeword)
        // Result should be 0 because:
        //   Shat = sum R - sum decoded S = 0 (when all decoded and R=S)

        R_j2_i0 = 6'b001011; R_j2_i1 = 6'b010001; R_j2_i2 = 6'b000000; R_j2_i3 = 6'b010111;
        S_j2_i0 = 6'b001011; S_j2_i1 = 6'b010001; S_j2_i2 = 6'b000000; S_j2_i3 = 6'b010111;
        // Other j: same situation
        R_j3_i0 = 6'b011001; R_j3_i1 = 6'b001100; R_j3_i2 = 6'b000000; R_j3_i3 = 6'b011010;
        S_j3_i0 = 6'b011001; S_j3_i1 = 6'b001100; S_j3_i2 = 6'b000000; S_j3_i3 = 6'b011010;
        R_j4_i0 = 6'b101110; R_j4_i1 = 6'b110100; R_j4_i2 = 6'b000000; R_j4_i3 = 6'b101100;
        S_j4_i0 = 6'b101110; S_j4_i1 = 6'b110100; S_j4_i2 = 6'b000000; S_j4_i3 = 6'b101100;
        R_j5_i0 = 6'b000100; R_j5_i1 = 6'b011011; R_j5_i2 = 6'b000000; R_j5_i3 = 6'b101110;
        S_j5_i0 = 6'b000100; S_j5_i1 = 6'b011011; S_j5_i2 = 6'b000000; S_j5_i3 = 6'b101110;

        @(posedge clk); #1;
        enable = 1;
        @(posedge clk); #1;
        if (valid !== 1'b1) begin
            $display("FAIL: valid not asserted after enable in Test 2!");
            errors = errors + 1;
        end else begin
            $display("PASS: valid asserted correctly");
        end
        enable = 0;

        check_output("Shat0_j2 (all dec)", Shat0_j2, 6'b0);
        check_output("Shat1_j2 (all dec)", Shat1_j2, 6'b0);
        check_output("Shat0_j3 (all dec)", Shat0_j3, 6'b0);
        check_output("Shat1_j3 (all dec)", Shat1_j3, 6'b0);
        check_output("Shat0_j4 (all dec)", Shat0_j4, 6'b0);
        check_output("Shat1_j4 (all dec)", Shat1_j4, 6'b0);
        check_output("Shat0_j5 (all dec)", Shat0_j5, 6'b0);
        check_output("Shat1_j5 (all dec)", Shat1_j5, 6'b0);

        //=============================================================
        // Summary
        //=============================================================
        $display("\n========================================");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED: %d errors", errors);
        $display("========================================");

        $finish;
    end

    //-----------------------------------------------------------------
    // Optional: dump waveforms
    //-----------------------------------------------------------------
    initial begin
        $dumpfile("nsu_tb.vcd");
        $dumpvars(0, nsu_tb);
    end

endmodule
