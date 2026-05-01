`timescale 1ns/1ps

module test;

// --------------------------
// parameters
parameter CYCLE = 10;
parameter NTEST = 4;
parameter SYN_COUNT = 4;
// --------------------------
// signals
reg clk;

// --------------------------
// test data
reg [23:0]	testdata[0:NTEST-1]; // syndromes
reg [17:0]  testdata_ans[0:NTEST-1]; // ELP coeff

reg         rst;
reg syndrome_rdy;

reg [5:0] LO_syndrome[0: SYN_COUNT-1];
wire sigma_done;
wire [5:0] sigma[0:2];
reg ready;
wire [17:0] sigma_con;

integer i;
integer i1, i2, i3;
integer errcnt, correctcnt;
assign sigma_con = {sigma[0], sigma[1], sigma[2]};


// --------------------------
// read files and dump files
initial begin
	$readmemh("testdata.txt", testdata);
    $readmemh("testdata_ans.txt", testdata_ans);
end

initial begin
	$fsdbDumpfile("waveform.fsdb");
	$fsdbDumpvars("+mda");
end

// --------------------------
// modules
BM dut(
    .clk(clk),
    .rst(rst),
    .syndrome_rdy(syndrome_rdy),
    .LO_syndrome(LO_syndrome),

    .sigma_done(sigma_done),
    .sigma(sigma)
);

// --------------------------
// clock
initial clk = 1;
always #(CYCLE/2.0) clk = ~clk;

// --------------------------
// test
initial begin
	rst = 0;
    syndrome_rdy = 0;
    ready = 0;
    for (i=0; i < SYN_COUNT ; i=i+1) begin
        LO_syndrome[i] = 0;
    end
    i1 = 0;
    i2 = 0;
    // iw = 1;
    errcnt = 0;
    correctcnt = 0;
    #(CYCLE*2) rst = 1;
    #(CYCLE*3) rst = 0;
    #(CYCLE) ready = 1;
end

// feed input
always @(posedge clk) begin
    if (ready) begin
        for (i=0;i<=6;i=i+1) begin
            LO_syndrome[i] = testdata[i1][(23-6*i)-:6];
        end
        syndrome_rdy = 1;
        ready = 0;
        #(CYCLE*1.2) syndrome_rdy = 0;
        i1 = i1 + 1;
    end
end

always @(posedge sigma_done) begin
    #(CYCLE*2.5) ready = 1;
end

// check output
always @(posedge clk) begin
    @(posedge sigma_done) begin
        if (sigma_con !== testdata_ans[i2]) begin
            $write("[ERROR] Test %0d\n", i2);
            $write("        sigma = %018h\n", sigma_con);
            $write("        expect= %018h\n", testdata_ans[i2]);
            errcnt = errcnt + 1;
        end
        else begin
            $write("[CORRECT]Test %0d\n", i2);
            $write("         sigma = %018h\n", sigma_con);
            $write("         expect= %018h\n", testdata_ans[i2]);
            correctcnt = correctcnt + 1;
        end

        i2 = i2 + 1;
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
	$write("Simulation Timeout!!!\n");
	$finish;
end

endmodule