`timescale 1ns/1ps

module test;

// --------------------------
// parameters
parameter CYCLE = 10;
parameter PATTERN = 1;
integer NTEST = 1;

// --------------------------
// signals
reg clk, rstn;
reg mode;
reg [1:0] code;
reg set;
reg [63:0] idata;
wire ready;
wire finish;
wire [9:0] odata;

// --------------------------
// test data
reg [63:0] testdata [0:8191];
reg [9:0] testa [0:511];
integer i1, i2, i3;
integer errcnt, correctcnt;

// --------------------------
// read files and dump files
initial begin
	if (PATTERN == 100) begin
		NTEST = 2;
		$readmemb("testdata/p100.txt", testdata);
		$readmemb("testdata/p100a.txt", testa);
	end
	if (PATTERN == 200) begin
		NTEST = 2;
		$readmemb("testdata/p200.txt", testdata);
		$readmemb("testdata/p200a.txt", testa);
	end
	if (PATTERN == 300) begin
		NTEST = 2;
		$readmemb("testdata/p300.txt", testdata);
		$readmemb("testdata/p300a.txt", testa);
	end
	// Additional
	// example ===========
	if (PATTERN == 99) begin
		NTEST = 1;
		$readmemb("testdata/example_hard.txt", testdata);
		$readmemb("testdata/example_hard_ans.txt", testa);
	end
	if (PATTERN == 399) begin
		NTEST = 1;
		$readmemb("testdata/example_soft.txt", testdata);
		$readmemb("testdata/example_soft_ans.txt", testa);
	end
	// ============
	// m = 6, hard ==============
	if (PATTERN == 0) begin
		NTEST = 50;
		$readmemb("testdata/hard_pattern/hard_6_0.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_6_0.txt", testa);
	end	
	if (PATTERN == 50) begin
		NTEST = 1;
		$readmemb("testdata/hard_pattern/hard_6_50.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_6_50.txt", testa);
	end	
	// ===========================
	// m = 8, hard ==============
	if (PATTERN == 101) begin
		NTEST = 50;
		$readmemb("testdata/hard_pattern/hard_8_0.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_8_0.txt", testa);
	end	
	if (PATTERN == 150) begin
		NTEST = 1;
		$readmemb("testdata/hard_pattern/hard_8_50.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_8_50.txt", testa);
	end	
	// ===========================
	// m = 10, hard ==============
	if (PATTERN == 201) begin
		NTEST = 50;
		$readmemb("testdata/hard_pattern/hard_10_0.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_10_0.txt", testa);
	end	
	if (PATTERN == 250) begin
		NTEST = 1;
		$readmemb("testdata/hard_pattern/hard_10_50.txt", testdata);
		$readmemb("testdata/hard_pattern/hardans_10_50.txt", testa);
	end	
	// ===========================
	// m = 6, soft ==============
	if (PATTERN == 301) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_0.txt", testdata);
		$readmemb("testdata/softans_6_0.txt", testa);
	end
	if (PATTERN == 302) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_1.txt", testdata);
		$readmemb("testdata/softans_6_1.txt", testa);
	end
	if (PATTERN == 303) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_2.txt", testdata);
		$readmemb("testdata/softans_6_2.txt", testa);
	end
	if (PATTERN == 304) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_3.txt", testdata);
		$readmemb("testdata/softans_6_3.txt", testa);
	end
	if (PATTERN == 305) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_4.txt", testdata);
		$readmemb("testdata/softans_6_4.txt", testa);
	end
	if (PATTERN == 306) begin
		NTEST = 1;
		$readmemb("testdata/soft_6_5.txt", testdata);
		$readmemb("testdata/softans_6_5.txt", testa);
	end
	if (PATTERN == 310) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_0.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_0.txt", testa);
	end	
	if (PATTERN == 311) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_1.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_1.txt", testa);
	end	
	if (PATTERN == 312) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_2.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_2.txt", testa);
	end	
	if (PATTERN == 313) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_3.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_3.txt", testa);
	end	
	if (PATTERN == 314) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_4.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_4.txt", testa);
	end	
	if (PATTERN == 315) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_5.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_5.txt", testa);
	end	
	if (PATTERN == 316) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_6_6.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_6.txt", testa);
	end	
	if (PATTERN == 350) begin
		NTEST = 1;
		$readmemb("testdata/soft_pattern/soft_6_50.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_6_50.txt", testa);
	end	
	// =======
	// m = 8 , soft ==============
	if (PATTERN == 410) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_0.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_0.txt", testa);
	end	
	if (PATTERN == 411) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_1.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_1.txt", testa);
	end	
	if (PATTERN == 412) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_2.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_2.txt", testa);
	end	
	if (PATTERN == 413) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_3.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_3.txt", testa);
	end	
	if (PATTERN == 414) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_4.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_4.txt", testa);
	end	
	if (PATTERN == 415) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_5.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_5.txt", testa);
	end	
	if (PATTERN == 416) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_8_6.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_6.txt", testa);
	end	
	if (PATTERN == 450) begin
		NTEST = 1;
		$readmemb("testdata/soft_pattern/soft_8_50.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_8_50.txt", testa);
	end	
	// ===========================
	// m = 10, soft ==============
	if (PATTERN == 510) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_0.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_0.txt", testa);
	end	
	if (PATTERN == 511) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_1.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_1.txt", testa);
	end	
	if (PATTERN == 512) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_2.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_2.txt", testa);
	end	
	if (PATTERN == 513) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_3.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_3.txt", testa);
	end	
	if (PATTERN == 514) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_4.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_4.txt", testa);
	end	
	if (PATTERN == 515) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_5.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_5.txt", testa);
	end	
	if (PATTERN == 516) begin
		NTEST = 64;
		$readmemb("testdata/soft_pattern/soft_10_6.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_6.txt", testa);
	end	
	if (PATTERN == 550) begin
		NTEST = 1;
		$readmemb("testdata/soft_pattern/soft_10_50.txt", testdata);
		$readmemb("testdata/soft_pattern/softans_10_50.txt", testa);
	end	
	// ===========================

	
end

// initial begin
// 	$fsdbDumpfile("waveform.fsdb");
// 	$fsdbDumpvars("+mda");
// end

// --------------------------
// modules
bch U_bch(
	.clk(clk),
	.rstn(rstn),
	.mode(mode),
	.code(code),
	.set(set),
	.idata(idata),
	.ready(ready),
	.finish(finish),
	.odata(odata)
);
`ifdef SDF_GATE
	initial $sdf_annotate("../02_SYN/Netlist/bch_syn.sdf", U_bch);
`elsif SDF_POST
	initial $sdf_annotate("../04_APR/Netlist/bch_apr.sdf", U_bch);
`endif

// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	i1 = 0;
	i2 = 0;
	i3 = 0;
	errcnt = 0;
	correctcnt = 0;

	rstn = 0;
	mode = 0;
	code = 0;
	set = 0;
	idata = 0;
	#(CYCLE*5);
	@(negedge clk);
	rstn = 1;

	@(negedge clk);
	#(CYCLE*5);
	for (i2 = 0; i2 < NTEST; i2 = i2 + 1) begin
		if (PATTERN <= 100) begin
			code = 1;
			mode = 0;
		end else if (PATTERN <= 200) begin
			code = 2;
			mode = 0;
		end else if (PATTERN <= 300) begin
			code = 3;
			mode = 0;
		end else if (PATTERN <= 400) begin
			code = 1;
			mode = 1;
		end else if (PATTERN <= 500) begin
			code = 2;
			mode = 1;
		end else if (PATTERN <= 600) begin
			code = 3;
			mode = 1;
		end
		set = 1;
		#(CYCLE);
		set = 0;

		wait(finish === 1);
		@(negedge clk);
		#(CYCLE*10);
	end
end
always @(negedge clk) begin
	if (ready === 1) begin
		idata = testdata[i1];
		i1 = i1 + 1;
	end
end
always @(negedge clk) begin
	if (finish === 1 && $time >= CYCLE * 5) begin
		if (odata !== testa[i3]) begin
			errcnt = errcnt + 1;
			$write("design output = %4d, golden output = %4d. Error\n", odata, testa[i3]);
		end else begin
			correctcnt = correctcnt + 1;
			$write("design output = %4d, golden output = %4d\n", odata, testa[i3]);
		end
		i3 = i3 + 1;
	end
end
initial begin
	wait(i2 == NTEST);
	$write("Correct count = %0d\n", correctcnt);
	$write("Error count = %0d\n", errcnt);
	$write("Time = %0d\n", $time - CYCLE * 5);
	#(CYCLE*5);
	$finish;
end
initial begin
	#(CYCLE*1000000);
	$write("Timeout\n");
	$finish;
end

endmodule
