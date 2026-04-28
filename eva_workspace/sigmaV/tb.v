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

reg [5:0]	sigma[6:0];

wire [5:0]	y_conv[31:0];
wire [5:0]	y_base[31:0];
wire [5:0]	y[31:0];

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
    for (i2=0;i2<=6;i2=i2+1) begin
        sigma[i2] = testdata[i1][6*i2+:6];
    end
	i1 = i1 + 1;
end

// check output
always @(posedge clk) begin
	for (i2=0;i2<32;i2=i2+1) begin
		if (y_conv[i2] !== y[i2]) begin
			$write("y_conv[%0d] = %6b, y[%0d] = %6b. Error\n", i2, y_conv[i2], i2, y[i2]);
			errcnt = errcnt + 1;
		end
		else begin
			// $write("y_conv[%0d] = %6b, y[%0d] = %6b. Correct\n", i2, y_conv[i2], i2, y[i2]);
			correctcnt = correctcnt + 1;
		end
        if (y_base[i2] !== y[i2]) begin
			$write("y_base[%0d] = %6b, y[%0d] = %6b. Error\n", i2, y_base[i2], i2, y[i2]);
			errcnt = errcnt + 1;
        end
        else begin
			// $write("y_base[%0d] = %6b, y[%0d] = %6b. Correct\n", i2, y_base[i2], i2, y[i2]);
			correctcnt = correctcnt + 1;
		end
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