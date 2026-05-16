//=========================================================================
// nsu_tb.v
// Self-checking testbench for nsu_top.
// Compares against Python golden model expected values.
//=========================================================================

`timescale 1ns/1ps

module nsu_tb;
    reg         clk;
    reg         rst_n;
    reg         start;
    reg  [62:0] r0, r1, r2, r3;
    reg         b;
    reg         stage_flag;
    
    wire [5:0]  S_out_0, S_out_1, S_out_2, S_out_3;
    wire        b_out;
    wire        valid;
    
    integer     pass_count = 0;
    integer     fail_count = 0;
    
    nsu_top dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3),
        .b(b), .stage_flag(stage_flag),
        .S_out_0(S_out_0), .S_out_1(S_out_1),
        .S_out_2(S_out_2), .S_out_3(S_out_3),
        .b_out(b_out), .valid(valid)
    );
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Task to run one test case
    task run_test;
        input [255:0] name;
        input [62:0]  ir0, ir1, ir2, ir3;
        input         ib;
        input         istage;
        input [5:0]   eS0, eS1, eS2, eS3;
        input         eb;
        begin
            // Idle: ensure previous valid has cleared
            @(posedge clk); #1;
            start = 1'b0;
            @(posedge clk); #1;
            
            // Apply inputs and assert start
            r0 = ir0; r1 = ir1; r2 = ir2; r3 = ir3;
            b = ib; stage_flag = istage;
            start = 1'b1;
            @(posedge clk); #1;
            start = 1'b0;
            
            // Wait for valid (next ~2 cycles)
            while (!valid) begin
                @(posedge clk); #1;
            end
            
            // valid is high now; sample outputs
            $write("%s: ", name);
            if (S_out_0 === eS0 && S_out_1 === eS1 &&
                S_out_2 === eS2 && S_out_3 === eS3 &&
                b_out === eb) begin
                $display("PASS  S=(%02h, %02h, %02h, %02h) b_out=%b",
                         S_out_0, S_out_1, S_out_2, S_out_3, b_out);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL");
                $display("  Got      S=(%02h, %02h, %02h, %02h) b_out=%b",
                         S_out_0, S_out_1, S_out_2, S_out_3, b_out);
                $display("  Expected S=(%02h, %02h, %02h, %02h) b_out=%b",
                         eS0, eS1, eS2, eS3, eb);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    initial begin
        rst_n = 0; start = 0;
        r0 = 0; r1 = 0; r2 = 0; r3 = 0; b = 0; stage_flag = 0;
        #20 rst_n = 1;
        @(posedge clk); #1;
        
        // T1: stage 0, b=0
        run_test("T1 stage0 b=0",
                 63'h0000000000000000,
                 63'h0000000000100020,
                 63'h0000000000000000,
                 63'h0000000000000000,
                 1'b0, 1'b0,
                 6'h0e, 6'h1f, 6'h00, 6'h00, 1'b0);
        
        // T2: stage 0, b=1
        run_test("T2 stage0 b=1",
                 63'h0000000000000000,
                 63'h0000000000100020,
                 63'h0000000000000000,
                 63'h0000000000000000,
                 1'b1, 1'b0,
                 6'h0e, 6'h1f, 6'h09, 6'h01, 1'b1);
        
        // T3: stage 1, b=0
        run_test("T3 stage1 b=0",
                 63'h0000000000000000,
                 63'h0000000000100020,
                 63'h0000000000000000,
                 63'h0000000000000000,
                 1'b0, 1'b1,
                 6'h0e, 6'h0b, 6'h00, 6'h00, 1'b0);
        
        // T4: stage 1, b=1
        run_test("T4 stage1 b=1",
                 63'h0000000000000000,
                 63'h0000000000100020,
                 63'h0000000000000000,
                 63'h0000000000000000,
                 1'b1, 1'b1,
                 6'h0e, 6'h0b, 6'h16, 6'h32, 1'b1);
        
        // T5: stage 0, b=1, mixed
        run_test("T5 stage0 b=1 mixed",
                 63'h0000000000000400,
                 63'h0000000000000020,
                 63'h0000000002000000,
                 63'h0000010000000000,
                 1'b1, 1'b0,
                 6'h14, 6'h0b, 6'h18, 6'h27, 1'b1);
        
        // Summary
        @(posedge clk); #1;
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        $finish;
    end
endmodule