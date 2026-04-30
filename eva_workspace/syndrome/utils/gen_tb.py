import sys

ntest = int(sys.argv[1])
q = int(sys.argv[2])
n = int(sys.argv[3])
t_min = int(sys.argv[4])

input_cycles = (n + 1) // 8

S_concat = "{" + ", ".join([f"S[{i}]" for i in range(2*t_min-1, -1, -1)]) + "}"

tb = f"""`timescale 1ns/1ps

module test;

// --------------------------
// parameters
parameter CYCLE = 10;
parameter NTEST = {ntest};

// --------------------------
// signals
reg clk;

// --------------------------
// test data
reg [{n}:0]	testdata[0:NTEST-1];
reg [{2*t_min*q-1}:0]  testdata_ans[0:NTEST-1];

reg         rst;
reg [{q-4}:0]   cnt;
reg [7:0]   idata;
reg         ivalid;
reg [{n}:0]  codeword;
reg [{2*t_min*q-1}:0]  syndromes_ans;

wire [{q-1}:0]  S[{2*t_min-1}:0];
wire        sdone;

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
    .cnt(cnt),
    .idata(idata),
    .ivalid(ivalid),
    .S(S),
    .sdone(sdone)
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

    for (i2=0;i2<{input_cycles};i2=i2+1) begin
        #(CYCLE) begin
            idata = codeword[{n}-8*i2 -: 8];
            ivalid = 1;
            cnt = i2;
        end
        #(CYCLE) ivalid = 0;
    end

    #(CYCLE*2) i1 = i1 + 1;
end

// check output
always @(posedge sdone) begin
    # (CYCLE*0.5);
    if ({S_concat} !== syndromes_ans) begin
        $write("Test %0d: syndromes = %6b, expected = %6b. Error\\n", i1, {S_concat}, syndromes_ans);
        errcnt = errcnt + 1;
    end
    else begin
        // $write("Test %0d: syndromes = %6b, expected = %6b. Correct\\n", i1, {S_concat}, syndromes_ans);
        correctcnt = correctcnt + 1;
    end
end

initial begin
	wait(i1 == NTEST);
	$write("Correct count = %0d\\n", correctcnt);
	$write("Error count = %0d\\n", errcnt);
	$write("Time = %0d\\n", $time - CYCLE * 5);
	#(CYCLE*5);
	$finish;
end

initial begin
	#(CYCLE*1000000);
	$write("Simulation Timeout!!!\\n");
	$finish;
end

endmodule"""

f = open("tb.v", "w")
f.write(tb)
f.close()

print("Generated tb.v")