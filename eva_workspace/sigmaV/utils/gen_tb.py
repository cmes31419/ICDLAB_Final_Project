import sys

ntest = int(sys.argv[1])
parallel_num = int(sys.argv[2])
q = int(sys.argv[3])
t_max = int(sys.argv[4])

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
reg [{q*(t_max+1)-1}:0]	testdata[0:NTEST-1];

reg [{q-1}:0]	sigma[{t_max}:0];

wire [{q-1}:0]	y_conv[{parallel_num-1}:0];
wire [{q-1}:0]	y_base[{parallel_num-1}:0];
wire [{q-1}:0]	y[{parallel_num-1}:0];

integer i1, i2;
integer errcnt, correctcnt;

// --------------------------
// read files and dump files
initial begin
	$readmemb("testdata.txt", testdata);
end

initial begin
	$fsdbDumpfile("waveform.fsdb");
	$fsdbDumpvars("+mda");
end

// --------------------------
// modules
sigmaV_conventional U0(
    .sigma(sigma),
    .y(y_conv)
);

sigmaV_baseline U1(
    .sigma(sigma),
    .y(y_base)
);

sigmaV U2(
    .sigma(sigma),
    .y(y)
);

// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	i1 = 0;
	errcnt = 0;
    correctcnt = 0;
end

// feed input 
always @(negedge clk) begin
    for (i2=0;i2<={t_max};i2=i2+1) begin
        sigma[i2] = testdata[i1][{q}*i2+:{q}];
    end
	i1 = i1 + 1;
end

// check output
always @(posedge clk) begin
	for (i2=0;i2<{parallel_num};i2=i2+1) begin
		if (y_conv[i2] !== y[i2]) begin
			$write("y_conv[%0d] = %6b, y[%0d] = %6b. Error\\n", i2, y_conv[i2], i2, y[i2]);
			errcnt = errcnt + 1;
		end
		else begin
			// $write("y_conv[%0d] = %6b, y[%0d] = %6b. Correct\\n", i2, y_conv[i2], i2, y[i2]);
			correctcnt = correctcnt + 1;
		end
        if (y_base[i2] !== y[i2]) begin
			$write("y_base[%0d] = %6b, y[%0d] = %6b. Error\\n", i2, y_base[i2], i2, y[i2]);
			errcnt = errcnt + 1;
        end
        else begin
			// $write("y_base[%0d] = %6b, y[%0d] = %6b. Correct\\n", i2, y_base[i2], i2, y[i2]);
			correctcnt = correctcnt + 1;
		end
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