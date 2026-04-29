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

reg         rst, ready;
reg [5:0]	sigma[6:0];
reg [63:0]  zeros_ans;

wire [31:0]	zeros;

integer i1, i2;
integer errcnt, correctcnt;

// --------------------------
// read files and dump files
initial begin
	$readmemb("testdata.txt", testdata);
    $readmemb("testdata_ans.txt", testdata_ans);
end

initial begin
	$fsdbDumpfile("waveform.fsdb");
	$fsdbDumpvars("+mda");
end

// --------------------------
// modules
chien_search U0(
    .clk(clk),
    .rst(rst),
    .ready(ready),
    .sigma(sigma),
    .zeros(zeros)
);

// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	rst = 0;
    ready = 0;
    i1 = 0;
    errcnt = 0;
    correctcnt = 0;
    #(CYCLE*0.5) rst = 1;
    #(CYCLE) rst = 0;
end

// feed input & check output
always @(negedge clk) begin
    #(CYCLE*2);

    for (i2=0;i2<=6;i2=i2+1) begin
        sigma[i2] = testdata[i1][6*i2+:6];
        zeros_ans = testdata_ans[i1];
    end
    ready = 1;
    #(CYCLE) ready = 0;
    
    #(CYCLE);
    if (zeros !== zeros_ans[0+:32]) begin
        $write("Test %0d: zeros = %6b, expected = %6b. Error\n", i1, zeros, zeros_ans[0+:32]);
        errcnt = errcnt + 1;
    end
    else begin
        // $write("Test %0d: zeros = %6b, expected = %6b. Correct\n", i1, zeros, zeros_ans[0+:32]);
        correctcnt = correctcnt + 1;
    end
    
    #(CYCLE);
    if (zeros !== zeros_ans[32+:32]) begin
        $write("Test %0d: zeros = %6b, expected = %6b. Error\n", i1, zeros, zeros_ans[32+:32]);
        errcnt = errcnt + 1;
    end
    else begin
        // $write("Test %0d: zeros = %6b, expected = %6b. Correct\n", i1, zeros, zeros_ans[32+:32]);
        correctcnt = correctcnt + 1;
    end

    #(CYCLE*5) i1 = i1 + 1;
end

initial begin
	wait(i1 == NTEST);
	$write("Correct count = %0d\n", correctcnt);
	$write("Error count = %0d\n", errcnt);
	$write("Time = %0d\n", $time - CYCLE * 5);
	#(CYCLE*5);
	$finish;
end

initial begin
	#(CYCLE*1000000);
	$write("Simulation Timeout!!!\n");
	$finish;
end

endmodule