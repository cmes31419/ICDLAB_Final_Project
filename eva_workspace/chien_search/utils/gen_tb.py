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

reg         rst;
reg         sigma_valid;
reg [{q-1}:0]	sigma[{t_max}:0];
reg [{n-1}:0]  cdata_ans;
reg         cfail_ans;

wire [{n-1}:0]  cdata;
wire        cfail;
wire        cdone;

integer i1, i2, i3;
integer iw;
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
    .sigma(sigma),
    .sigma_valid(sigma_valid),
    .ready(ready),
    .cdata(cdata),
    .cdone(cdone),
    .cfail(cfail)
);


// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	rst = 0;
    sigma_valid = 0;
    i1 = 0;
    i2 = 0;
    iw = 1;
    errcnt = 0;
    correctcnt = 0;
    #(CYCLE*0.5) rst = 1;
    #(CYCLE) rst = 0;
    iw = 0;
end

// feed input
always @(negedge clk) begin
    if (iw == 0 && ready) begin
        for (i3=0;i3<={t_max};i3=i3+1) begin
            sigma[i3] = testdata[i1][{q}*i3+:{q}];
        end

        sigma_valid = 1;
        #(CYCLE) sigma_valid = 0;

        i1 = i1 + 1;
    end
end

// check output
always @(negedge clk) begin
    if (cdone) begin
        {{cfail_ans, cdata_ans}} = testdata_ans[i2];

        if (cfail !== cfail_ans || cdata !== cdata_ans) begin
            $write("[ERROR] Test %0d\\n", i2);
            $write("        cfail = %1b, expected = %1b\\n", cfail, cfail_ans);
            $write("        cdata = %063b\\n", cdata);
            $write("        expect= %063b\\n", cdata_ans);
            errcnt = errcnt + 1;
        end
        else begin
            // $write("[PASS ] Test %0d\\n", i2);
            // $write("        cfail = %1b\\n", cfail);
            // $write("        cdata = %063b\\n", cdata);
            correctcnt = correctcnt + 1;
        end

        i2 = i2 + 1;
    end
end

initial begin
	wait(i2 == NTEST);
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