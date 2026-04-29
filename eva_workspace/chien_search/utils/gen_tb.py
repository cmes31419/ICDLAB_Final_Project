import sys

ntest = int(sys.argv[1])
parallel_num = int(sys.argv[2])
q = int(sys.argv[3])
n = int(sys.argv[4])
t_max = int(sys.argv[5]) 

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
reg [{q*t_max+q-1}:0]	testdata[0:NTEST-1];
reg [{n}:0]  testdata_ans[0:NTEST-1];

reg         rst, ready;
reg [{q-1}:0]	sigma[{t_max}:0];
reg [{n}:0]  zeros_ans;

wire [{parallel_num-1}:0]	zeros;

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

    for (i2=0;i2<={t_max};i2=i2+1) begin
        sigma[i2] = testdata[i1][{q}*i2+:{q}];
        zeros_ans = testdata_ans[i1];
    end
    ready = 1;
    #(CYCLE) ready = 0;"""

for i in range((n + 1) // parallel_num):
    print(f"Generating testbench code for checking test {i}...")
    tb += f"""
    
    #(CYCLE);
    if (zeros !== zeros_ans[{i*parallel_num}+:{parallel_num}]) begin
        $write("Test %0d: zeros = %6b, expected = %6b. Error\\n", i1, zeros, zeros_ans[{i*parallel_num}+:{parallel_num}]);
        errcnt = errcnt + 1;
    end
    else begin
        // $write("Test %0d: zeros = %6b, expected = %6b. Correct\\n", i1, zeros, zeros_ans[{i*parallel_num}+:{parallel_num}]);
        correctcnt = correctcnt + 1;
    end"""

tb += f"""

    #(CYCLE*5) i1 = i1 + 1;
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

f = open("./tb.v", "w")
f.write(tb)
f.close()

print("Generated tb.v for testbench with the given parameters!")