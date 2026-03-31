module core(
	input			clk,
	input			rstn,
	input			mode,
	input [1:0]		code,
	input			reset,
	input			syn_rdy,
	input [9:0]		taggle_loc0,
	input [9:0]		taggle_loc1,
	input [6:0]		taggle_corr0,
	input [6:0]		taggle_corr1,
	input [9:0]		Sa[7:0],
	input [9:0]		Sb[7:0],
	input [9:0]		Sc[7:0],
	input [9:0]		Sd[7:0],
	input [9:0]		mem_cnt,
	input [9:0]		factor8,
	input [9:0]		factor16,
	input [9:0]		factor24,
	input [9:0]		factor32,
	input [6:0]		chien_data[`PARALLEL_NUM-1:0],
	output			chien_proc,
	output			proc_done,
	output			out_stop,
	output [9:0]	out_loc
);

	localparam S_IDLE = 2'd0;
	localparam S_PROC = 2'd1;
	localparam S_DONE = 2'd2;

	reg [1:0]	cnt, cnt_next;
	reg [1:0]	state, state_next;

	reg [9:0]	corr_rec, corr_rec_next;
	reg [9:0]	loc_rec[5:0], loc_rec_next[5:0];

	reg [9:0]	S[7:0];

	// reg [9:0]	sigma0_rec, sigma0_rec_next;
	// reg [9:0]	sigma1_rec, sigma1_rec_next;
    // reg [9:0]	sigma2_rec, sigma2_rec_next;
    // reg [9:0]	sigma3_rec, sigma3_rec_next;
    // reg [9:0]	sigma4_rec, sigma4_rec_next;
	
	wire [9:0]  sigma0;
	wire [9:0]  sigma1;
	wire [9:0]  sigma2;
	wire [9:0]  sigma3;
	wire [9:0]  sigma4;
	wire 		chien_rdy;
	wire		decode_fail;

	wire		chien_wait;
	wire		chien_done;
	wire		chien_success;
	wire [9:0]	chien_loc[3:0];
	wire [8:0]	chien_corr;

	wire [9:0]	corr_now;
	wire		sort_ready;
	wire		sort_done;

	integer i;

	assign corr_now = chien_corr + (cnt[0] ? taggle_corr0 : 0) + (cnt[1] ? taggle_corr1 : 0);

	assign proc_done = (state == S_DONE && sort_done) ? 1 : 0;

	// always @(*) begin
	// 	sigma0_rec_next = chien_rdy ? sigma0 : sigma0_rec;
	// 	sigma1_rec_next = chien_rdy ? sigma1 : sigma1_rec;
	// 	sigma2_rec_next = chien_rdy ? sigma2 : sigma2_rec;
	// 	sigma3_rec_next = chien_rdy ? sigma3 : sigma3_rec;
	// 	sigma4_rec_next = chien_rdy ? sigma4 : sigma4_rec;
	// end

	always @(*) begin
		for (i=0;i<8;i=i+1) begin
			if (state == S_PROC) begin
				case(cnt)
					2'd0: S[i] = Sb[i];
					2'd1: S[i] = Sc[i];
					2'd2: S[i] = Sd[i];
					2'd3: S[i] = Sa[i];
				endcase
			end
			else S[i] = Sa[i];
		end
	end

    always @(*) begin
		if (state == S_PROC && chien_done && chien_success && corr_now < corr_rec) begin
			corr_rec_next = corr_now;
			case(code)
				2'd0: begin
					for (i=0;i<6;i=i+1) begin
						loc_rec_next[i] = 0;
					end
				end
				2'd1, 2'd2: begin
					loc_rec_next[0] = chien_loc[0];
					loc_rec_next[1] = chien_loc[1];
					loc_rec_next[2] = cnt[0] ? taggle_loc0 : 0;
					loc_rec_next[3] = cnt[1] ? taggle_loc1 : 0;
					loc_rec_next[4] = 0;
					loc_rec_next[5] = 0;
				end
				2'd3: begin
					loc_rec_next[0] = chien_loc[0];
					loc_rec_next[1] = chien_loc[1];
					loc_rec_next[2] = cnt[0] ? taggle_loc0 : 0;
					loc_rec_next[3] = cnt[1] ? taggle_loc1 : 0;
					loc_rec_next[4] = chien_loc[2];
					loc_rec_next[5] = chien_loc[3];
				end
			endcase
		end
		else if (state == S_PROC) begin
			corr_rec_next = corr_rec;
			for (i=0;i<6;i=i+1) begin
				loc_rec_next[i] = loc_rec[i];
			end
		end
		else begin
			corr_rec_next = 10'd1023;
			for (i=0;i<6;i=i+1) begin
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
			S_PROC:		state_next = chien_done ? ((mode && cnt != 2'd3) ? S_PROC : S_DONE): S_PROC;
			S_DONE:		state_next = sort_done ? S_IDLE : S_DONE;
			default:	state_next = S_IDLE;
		endcase
	end

	BM bm0(
		.clk(clk),
		.rstn(rstn),
		.syndrome_rdy(syn_rdy | (chien_wait && mode && cnt != 2'd3)),
		.reset(chien_wait && ~(mode && cnt != 2'd3)),
		.code(code),
		.S1(S[0]),
		.S2(S[1]),
		.S3(S[2]),
		.S4(S[3]),
		.S5(S[4]),
		.S6(S[5]),
		.S7(S[6]),
		.S8(S[7]),
		.sigma0(sigma0),
		.sigma1(sigma1),
		.sigma2(sigma2),
		.sigma3(sigma3),
		.sigma4(sigma4),
		.decode_fail(decode_fail),
		.chien_rdy(chien_rdy)
	);

	chien_search chien0(
		.clk(clk),
		.rstn(rstn),
		.decode_fail(decode_fail),
		.ready(chien_rdy),
		.code(code),
		// .sigma0(chien_rdy ? sigma0 : sigma0_rec),
		// .sigma1(chien_rdy ? sigma1 : sigma1_rec),
		// .sigma2(chien_rdy ? sigma2 : sigma2_rec),
		// .sigma3(chien_rdy ? sigma3 : sigma3_rec),
		// .sigma4(chien_rdy ? sigma4 : sigma4_rec),
		.sigma0(sigma0),
		.sigma1(sigma1),
		.sigma2(sigma2),
		.sigma3(sigma3),
		.sigma4(sigma4),
		.mem_cnt(mem_cnt),
		.factor8(factor8),
		.factor16(factor16),
		.factor24(factor24),
		.factor32(factor32),
		.data(chien_data),
		.chien_wait(chien_wait),
		.chien_proc(chien_proc),
		.chien_done(chien_done),
    	.chien_success(chien_success),
		.error_loc(chien_loc),
		.corr_val(chien_corr)
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
			corr_rec	<= 10'd1023;
			for (i=0;i<6;i=i+1) begin
				loc_rec[i]	<= 0;
			end
			// sigma0_rec	<= 0;
			// sigma1_rec	<= 0;
			// sigma2_rec	<= 0;
			// sigma3_rec	<= 0;
			// sigma4_rec	<= 0;
		end
		else begin
			state		<= state_next;
			cnt			<= cnt_next;
			corr_rec	<= corr_rec_next;
			for (i=0;i<6;i=i+1) begin
				loc_rec[i]	<= loc_rec_next[i];
			end
			// sigma0_rec	<= sigma0_rec_next;
			// sigma1_rec	<= sigma1_rec_next;
			// sigma2_rec	<= sigma2_rec_next;
			// sigma3_rec	<= sigma3_rec_next;
			// sigma4_rec	<= sigma4_rec_next;
		end
	end

endmodule