import sys

ntest = int(sys.argv[1])
q = int(sys.argv[2])
n = int(sys.argv[3])
t_max = int(sys.argv[4])
parallel_num = int(sys.argv[5])

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
reg [{n-1}:0]  cdata_ans;

wire [{n-1}:0]  cdata;
wire done;

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
    .cdata(cdata),
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
        cdata_ans = testdata_ans[i1];
    end

    fork
        ready = 1;
        #(CYCLE) ready = 0;

        @(posedge done) begin
            #(CYCLE*0.5);

            if (cdata !== cdata_ans) begin
                $write("Test %0d: cdata = %6b, expected = %6b. Error\\n", i1, cdata, cdata_ans);
                errcnt = errcnt + 1;
            end
            else begin
                // $write("Test %0d: cdata = %6b, expected = %6b. Correct\\n", i1, cdata, cdata_ans);
                correctcnt = correctcnt + 1;
            end

            #(CYCLE*0.5) i1 = i1 + 1;
        end
    join
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