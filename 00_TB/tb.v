`timescale 1ns/1ps

module test;

// --------------------------
// parameters
parameter CYCLE = 10;
parameter PATTERN = 1;
integer CODEWORD_CNT = 1;
integer NTEST; //= CODEWORD_CNT*4;
integer TESTBYTE; //= NTEST * 8;
// --------------------------
// signals
reg clk, rst;
reg [7:0] idata;
reg ivalid;
wire iready;
wire [7:0] odata;
wire ovalid;

// --------------------------
// test data
reg [63:0] testdata [0:8191];
reg [63:0] testa [0:8191];
integer i1, i2;
integer ibyte_cnt, obyte_cnt;
integer errcnt, correctcnt;

// --------------------------
// read files and dump files
initial begin
	if (PATTERN == 0) begin
		CODEWORD_CNT = 1;
		$readmemb("../00_TB/testdata/pattern/p0.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p0a.txt", testa);
	end
	if (PATTERN == 1) begin
		CODEWORD_CNT = 1;
		$readmemb("../00_TB/testdata/pattern/p1.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p1a.txt", testa);
	end
	if (PATTERN == 2) begin
		CODEWORD_CNT = 1;
		$readmemb("../00_TB/testdata/pattern/p2.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p2a.txt", testa);
	end
	if (PATTERN == 3) begin
		CODEWORD_CNT = 1;
		$readmemb("../00_TB/testdata/pattern/p3.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p3a.txt", testa);
	end
	if (PATTERN == 4) begin
		CODEWORD_CNT = 4;
		$readmemb("../00_TB/testdata/pattern/p4.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p4a.txt", testa);
	end
	if (PATTERN == 5) begin
		CODEWORD_CNT = 10;
		$readmemb("../00_TB/testdata/pattern/p5.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p5a.txt", testa);
	end
	if (PATTERN == 6) begin
		CODEWORD_CNT = 8;
		$readmemb("../00_TB/testdata/pattern/p6.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p6a.txt", testa);
	end
	if (PATTERN == 7) begin
		CODEWORD_CNT = 100;
		$readmemb("../00_TB/testdata/pattern/p7.txt", testdata);
		$readmemb("../00_TB/testdata/codeword/p7a.txt", testa);
	end
	// Recalculate dependent parameters
	NTEST = CODEWORD_CNT * 4;
	TESTBYTE = NTEST * 8;
	// ===========================	
end

initial begin
	$fsdbDumpfile("waveform.fsdb");
	$fsdbDumpvars("+mda");
end

// --------------------------
// modules
CHIP dut(
	.clk(clk),
	.rst(rst),
	.idata(idata),
    .ivalid(ivalid),
    .iready(iready),
	.odata(odata),
    .ovalid(ovalid)
);
`ifdef SDF_GATE
	initial $sdf_annotate("../02_SYN/Netlist/CHIP_syn.sdf", dut);
`elsif SDF_POST
	initial $sdf_annotate("../04_APR/Netlist/CHIP_apr.sdf", dut);
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
    ibyte_cnt = 0;
    obyte_cnt = 0;

    errcnt = 0;
    correctcnt = 0;

	rst = 0;
	idata = 0;
    ivalid = 0;

    // reset ======
	#(CYCLE*5);
	@(negedge clk);
	rst = 1;
    #(CYCLE*2)
	@(negedge clk);
    rst = 0;
    // ==============
	#(CYCLE*5);
	// for (i2 = 0; i2 < NTEST; i2 = i2 + 1) begin
	// 	if (PATTERN <= 100) begin
	// 		code = 1;
	// 		mode = 0;
	// 	end else if (PATTERN <= 200) begin
	// 		code = 2;
	// 		mode = 0;
	// 	end else if (PATTERN <= 300) begin
	// 		code = 3;
	// 		mode = 0;
	// 	end else if (PATTERN <= 400) begin
	// 		code = 1;
	// 		mode = 1;
	// 	end else if (PATTERN <= 500) begin
	// 		code = 2;
	// 		mode = 1;
	// 	end else if (PATTERN <= 600) begin
	// 		code = 3;
	// 		mode = 1;
	// 	end
	// 	#(CYCLE);
	// 	set = 0;

	// 	wait(finish === 1);
	// 	@(negedge clk);
	// 	#(CYCLE*10);
	// end
end
// feed input
initial begin
	@(negedge rst);
	@(posedge clk);
	while (i1 < NTEST) begin
		@(negedge clk);
		if (iready === 1) begin
	        ivalid = 1;
			idata = testdata[i1][(63-ibyte_cnt*8)-:8];
	        ibyte_cnt = ibyte_cnt + 1;
	        if (ibyte_cnt >= 8) begin
	            i1 = i1 + 1;
	            ibyte_cnt = 0;
	        end
		end
	    else begin
	        ivalid = 0;
	    end

	end
	@(negedge clk);
	ivalid = 0;
end

// check output
initial begin
	while(i2 < NTEST) begin
		@(negedge clk);
		if (ovalid === 1) begin
			if (odata !== testa[i2][(63-obyte_cnt*8)-:8]) begin          
				errcnt = errcnt + 1;
				$write("design output = %8b, golden output = %8b. Byte Error, code_idx = %d\n", odata, testa[i2][(63-obyte_cnt*8)-:8], i2);
			end
			else begin
				correctcnt = correctcnt + 1;
				$write("design output = %8b, golden output = %8b. Byte Correct, code_idx = %d\n", odata, testa[i2][(63-obyte_cnt*8)-:8], i2);
			end
			obyte_cnt = obyte_cnt + 1; 
        	if (obyte_cnt >= 8) begin
        	    i2 = i2 + 1;
        	    obyte_cnt = 0;
        	end
		end
	end

	$write("Correct count = %0d\n", correctcnt);
	$write("Error count = %0d\n", errcnt);
	$write("Time = %0d\n", $time - CYCLE * 5);
	#(CYCLE*5);
	$finish;
end

initial begin
	#(CYCLE*100000);
	$write("Simulation Timeout!!!\n");
	$finish;
end

endmodule