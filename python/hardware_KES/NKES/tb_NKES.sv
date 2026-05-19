`timescale 1ns/1ps

module test;

// --------------------------
// parameters
parameter CYCLE = 10;
parameter NTEST = 100;

// --------------------------
// signals
reg clk;

// --------------------------
// test data
reg [41:0]	testdata[0:NTEST-1];
reg [63:0]  testdata_ans[0:NTEST-1];

reg         rst;


reg [5:0] HO_syn[1:0];
reg syn_rdy;

reg cdone, cfail;
reg Lstate_rdy;
reg [5:0] Lsigma[2:0], Lb[2:0], Ldelta_even[1:0], Ltheta_even[1:0], Lgamma;
reg [1:0] Lk;

integer i1, i2, i3;
integer iw;
integer errcnt, correctcnt;

// --------------------------
// read files and dump files
// initial begin
// 	$readmemb("testdata.txt", testdata);
//     $readmemb("testdata_ans.txt", testdata_ans);
// end

initial begin
	$fsdbDumpfile("waveform.fsdb");
	$fsdbDumpvars("+mda");
end

// --------------------------
// modules

NKES u_nkes(
    .clk(clk),
    .rst(rst),
    .syn_rdy(syn_rdy),
    .HO_syn(HO_syn),

    .Lstate_rdy(Lstate_rdy),
    .cdone(cdone), .cfail(cfail),
    .Lsigma(Lsigma),
    .Lb(Lb),
    .Ldelta_even(Ldelta_even),
    .Ltheta_even(Ltheta_even),
    .Lgamma(Lgamma),
    .Lk(Lk),

    .sigma_done(),
    .sigma()
);

// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	rst = 0;
    i1 = 0;
    i2 = 0;
    iw = 1;
    errcnt = 0;
    correctcnt = 0;
    #(CYCLE*0.5) rst = 1;
    #(CYCLE) rst = 0;
    iw = 0;
end

initial begin
    cdone = 0; cfail = 0; Lstate_rdy = 0;
    syn_rdy = 0; HO_syn[0] = 6'h00; HO_syn[1] = 6'h00;
    #(CYCLE*20);
    @(posedge clk);
    Lstate_rdy = 1;
    Lsigma[0] = 6'h01; Lsigma[1] = 6'h02; Lsigma[2] = 6'h03;
    Lb[0] = 6'h04; Lb[1] = 6'h05; Lb[2] = 6'h06;
    Ldelta_even[0] = 6'h07; Ldelta_even[1] = 6'h08;
    Ltheta_even[0] = 6'h09; Ltheta_even[1] = 6'h0a;
    Lgamma = 6'h0b;
    Lk = 2'b11;
    @(posedge clk);
    Lstate_rdy = 0;
    #(CYCLE*2);@(posedge clk);
    cdone = 1; cfail = 1;
    @(posedge clk);
    cdone = 0; cfail = 0;
    #(CYCLE*8);
    @(posedge clk);
    syn_rdy = 1; HO_syn[0] = 6'h3f; HO_syn[1] = 6'h0a;
    @(posedge clk);
    HO_syn[0] = 6'h15; HO_syn[1] = 6'h0b;
    @(posedge clk);
    syn_rdy = 0;
    HO_syn[0] = 6'h19; HO_syn[1] = 6'h0c;
    @(posedge clk);
    HO_syn[0] = 6'h2a; HO_syn[1] = 6'h0d;
end

// feed input
// always @(negedge clk) begin
//     if (iw == 0 && ready) begin
//         for (i3=0;i3<=6;i3=i3+1) begin
//             sigma[i3] = testdata[i1][6*i3+:6];
//         end

//         sigma_valid = 1;
//         #(CYCLE) sigma_valid = 0;

//         i1 = i1 + 1;
//     end
// end

// check output
// always @(negedge clk) begin
//     if (cdone) begin
//         {cfail_ans, cdata_ans} = testdata_ans[i2];

//         if (cfail !== cfail_ans || cdata !== cdata_ans) begin
//             $write("[ERROR] Test %0d\n", i2);
//             $write("        cfail = %1b, expected = %1b\n", cfail, cfail_ans);
//             $write("        cdata = %063b\n", cdata);
//             $write("        expect= %063b\n", cdata_ans);
//             errcnt = errcnt + 1;
//         end
//         else begin
//             // $write("[PASS ] Test %0d\n", i2);
//             // $write("        cfail = %1b\n", cfail);
//             // $write("        cdata = %063b\n", cdata);
//             correctcnt = correctcnt + 1;
//         end

//         i2 = i2 + 1;
//     end
// end

// initial begin
// 	wait(i2 == NTEST);
// 	$write("Correct count = %0d\n", correctcnt);
// 	$write("Error count = %0d\n", errcnt);
// 	$write("Time = %0d\n", $time - CYCLE * 5);
// 	#(CYCLE*5);
// 	$finish;
// end

initial begin
	#(CYCLE*10000);
	$write("Simulation Timeout!!!\n");
	$finish;
end

endmodule