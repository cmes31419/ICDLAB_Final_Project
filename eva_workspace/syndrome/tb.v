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
reg [63:0]	testdata[0:NTEST-1];
reg [23:0]  testdata_ans[0:NTEST-1];

reg         rst;
reg [7:0]   idata;
reg         ivalid;
reg [2:0]   cnt;
reg [63:0]  codeword;
reg [23:0]  syndromes_ans;

wire [5:0]  S[3:0];
wire        done;

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
syndrome U0(
    .clk(clk),
    .rst(rst),
    .idata(idata),
    .ivalid(ivalid),
    .cnt(cnt),
    .S(S),
    .done(done)
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
    ivalid = 0;
    errcnt = 0;
    correctcnt = 0;
    #(CYCLE*0.5) rst = 1;
    #(CYCLE) rst = 0;
end

// feed input
always @(negedge clk) begin
    #(CYCLE*2);

    codeword = testdata[i1];
    syndromes_ans = testdata_ans[i1];

    for (i2=0;i2<8;i2=i2+1) begin
        #(CYCLE) begin
            idata = codeword[63-8*i2 -: 8];
            ivalid = 1;
            cnt = i2;
        end
        #(CYCLE) ivalid = 0;
    end

    #(CYCLE*2) i1 = i1 + 1;
end

// check output
always @(posedge done) begin
    # (CYCLE*0.5);
    if ({S[3], S[2], S[1], S[0]} !== syndromes_ans) begin
        $write("Test %0d: syndromes = %6b, expected = %6b. Error\n", i1, {S[3], S[2], S[1], S[0]}, syndromes_ans);
        errcnt = errcnt + 1;
    end
    else begin
        // $write("Test %0d: syndromes = %6b, expected = %6b. Correct\n", i1, {S[3], S[2], S[1], S[0]}, syndromes_ans);
        correctcnt = correctcnt + 1;
    end
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