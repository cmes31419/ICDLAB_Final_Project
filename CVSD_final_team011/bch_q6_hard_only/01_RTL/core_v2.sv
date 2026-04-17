module core(
	input			clk,
	input			rstn,
	input			reset,
	input			syn_rdy,
	input [5:0]		Sa[2:0],
	input [9:0]		mem_cnt,
	input [5:0]		factor8,
	input [5:0]		factor16,
	input [6:0]		chien_data[`PARALLEL_NUM-1:0],
	output			chien_proc,
	output			proc_done,
	output			out_stop,
	output [5:0]	out_loc
);

	localparam S_IDLE = 2'd0;
	localparam S_PROC = 2'd1;
	localparam S_DONE = 2'd2;

	reg [1:0]	cnt, cnt_next;
	reg [1:0]	state, state_next;

	reg [9:0]	loc_rec[1:0], loc_rec_next[1:0];

	reg [5:0]	S[2:0];
	
	wire [5:0]  sigma0;
	wire [5:0]  sigma1;
	wire [5:0]  sigma2;
	wire 		chien_rdy;
	wire		decode_fail;

	wire		chien_wait;
	wire		chien_done;
	wire		chien_success;
	wire [9:0]	chien_loc[3:0];

	wire		sort_ready;
	wire		sort_done;

	integer i;

	assign proc_done = (state == S_DONE && sort_done) ? 1 : 0;

	always @(*) begin
		for (i=0;i<3;i=i+1) begin
			S[i] = Sa[i];
		end
	end

    always @(*) begin
		if (state == S_PROC && chien_done && chien_success) begin
			loc_rec_next[0] = chien_loc[0];
			loc_rec_next[1] = chien_loc[1];
		end
		else if (state == S_PROC) begin
			for (i=0;i<2;i=i+1) begin
				loc_rec_next[i] = loc_rec[i];
			end
		end
		else begin
			for (i=0;i<2;i=i+1) begin
				loc_rec_next[i] = 0;
			end
		end
    end
	
	always @(*) begin
		if (state == S_PROC) cnt_next = chien_done ? cnt + 1 : cnt;
		else cnt_next = 0;
	end

	always @(*) begin
		case(state)
			S_IDLE:		state_next = syn_rdy ? S_PROC : S_IDLE;
			S_PROC:		state_next = chien_done ? S_DONE : S_PROC;
			S_DONE:		state_next = sort_done ? S_IDLE : S_DONE;
			default:	state_next = S_IDLE;
		endcase
	end

	BM bm0(
		.clk(clk),
		.rstn(rstn),
		.syndrome_rdy(syn_rdy),
		.reset(chien_wait),
		.S1(S[0]),
		.S2(S[1]),
		.S3(S[2]),
		.sigma0(sigma0),
		.sigma1(sigma1),
		.sigma2(sigma2),
		.decode_fail(decode_fail),
		.chien_rdy(chien_rdy)
	);

	chien_search chien0(
		.clk(clk),
		.rstn(rstn),
		.decode_fail(decode_fail),
		.ready(chien_rdy),
		.sigma0(sigma0),
		.sigma1(sigma1),
		.sigma2(sigma2),
		.mem_cnt(mem_cnt),
		.factor8(factor8),
		.factor16(factor16),
		.chien_wait(chien_wait),
		.chien_proc(chien_proc),
		.chien_done(chien_done),
    	.chien_success(chien_success),
		.error_loc(chien_loc)
	);

	sort_desc sort0(
		.clk(clk),
		.rstn(rstn),
		.ready(chien_done),
		.loc(loc_rec_next),
		.sort_done(sort_done),
		.out_stop(out_stop),
		.out_loc(out_loc)
	);

	always @(posedge clk) begin
		if (~rstn) begin
			state		<= S_IDLE;
			cnt			<= 0;
			for (i=0;i<2;i=i+1) begin
				loc_rec[i]	<= 0;
			end
		end
		else begin
			state		<= state_next;
			cnt			<= cnt_next;
			for (i=0;i<2;i=i+1) begin
				loc_rec[i]	<= loc_rec_next[i];
			end
		end
	end

endmodule