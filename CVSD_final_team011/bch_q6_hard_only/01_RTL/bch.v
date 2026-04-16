module bch(
	input clk,
	input rstn,
	input mode,
	input [1:0] code,
	input set,
	input [63:0] idata,
	output ready,
	output finish,
	output [9:0] odata
);

	localparam S_IDLE	= 2'd0;
	localparam S_INPUT	= 2'd1;
	localparam S_CALC	= 2'd2;
	localparam S_OUTPUT	= 2'd3;

	reg [1:0]		state, state_next;
	reg [6:0]		cnt, cnt_next;

	reg 			mode_set, mode_set_next;
	reg [1:0]		code_set, code_set_next;

	// Memory
	wire [9:0]		mem_cnt;
	wire [5:0]		factor8;
	wire [5:0]		factor16;

	// Syndrome
	wire			syn_rdy;
	wire [5:0]		taggle_loc0;
	wire [5:0]		taggle_loc1;
	wire [6:0]		taggle_corr0;
	wire [6:0]		taggle_corr1;
	wire [5:0]		Sa[2:0];
	wire [5:0]		Sb[2:0];
	wire [5:0]		Sc[2:0];
	wire [5:0]		Sd[2:0];

	// Core
	wire [6:0]		chien_data[`PARALLEL_NUM-1:0];
	wire			chien_proc, proc_done, out_stop;
	wire [9:0]		out_loc;
	wire out_done;

	integer i;
	
	assign ready = (state == S_INPUT) ? 1 : 0;

	assign out_done = (finish & out_stop) ? 1 : 0;

	assign finish = (state == S_OUTPUT) ? 1 : 0;
	assign odata = (out_loc == 10'd0) ? 10'd1023 : (code_set[1] ? (code_set[0] ? ~out_loc : {2'b0, ~out_loc[7:0]}) : (code_set[0] ? {4'b0, ~out_loc[5:0]} : 10'd1023));

	memory mem0(
		.clk(clk),
		.rstn(rstn),
		.idata(idata),
		.ready(ready),
		.chien(chien_proc),
		.reset(out_done),
		.cnt(mem_cnt),
		.factor8(factor8),
		.factor16(factor16),
		.chien_data(chien_data)
	);

	syndrome syn0(
		.clk(clk),
		.rstn(rstn),
		.ready(ready),
		.reset(out_done),
		.data(idata),
		.valid(syn_rdy),
		.taggle_loc0(taggle_loc0),
		.taggle_loc1(taggle_loc1),
		.taggle_corr0(taggle_corr0),
		.taggle_corr1(taggle_corr1),
		.Sa(Sa),
		.Sb(Sb),
		.Sc(Sc),
		.Sd(Sd)
	);

	core core0(
		.clk(clk),
		.rstn(rstn),
		.mode(mode_set),
		.code(code_set),
		.reset(out_done),
		.syn_rdy(syn_rdy),
		.taggle_loc0(taggle_loc0),
		.taggle_loc1(taggle_loc1),
		.taggle_corr0(taggle_corr0),
		.taggle_corr1(taggle_corr1),
		.Sa(Sa),
		.Sb(Sb),
		.Sc(Sc),
		.Sd(Sd),
		.mem_cnt(mem_cnt),
		.factor8(factor8),
		.factor16(factor16),
		.chien_data(chien_data),
		.chien_proc(chien_proc),
		.proc_done(proc_done),
		.out_stop(out_stop),
		.out_loc(out_loc)
	);

	always @(*) begin
		if (set) begin
			mode_set_next = mode;
			code_set_next = code;
		end
		else begin
			mode_set_next = mode_set;
			code_set_next = code_set;
		end
	end

	always @(*) begin
		cnt_next = 0;
		if (state == S_INPUT) begin
			case (code_set)
				2'd1:	cnt_next[2:0] = cnt[2:0] + 1;
				2'd2:	cnt_next[4:0] = cnt[4:0] + 1;
				2'd3:	cnt_next = cnt + 1;
			endcase
		end
		else if (state == S_OUTPUT) begin
			cnt_next[2:0] = out_done ? 0 : cnt[2:0] + 1;
		end
	end

	always @(*) begin
		case (state)
			S_IDLE:		state_next = set ? S_INPUT : S_IDLE;
			S_INPUT: begin
				case (code_set)
					2'd0:	state_next = S_IDLE;
					2'd1:	state_next = (cnt[2:0] == 3'd7) ? S_CALC : S_INPUT;
					2'd2:	state_next = (cnt[4:0] == 5'd31) ? S_CALC : S_INPUT;
					2'd3:	state_next = (cnt == 7'd127) ? S_CALC : S_INPUT;
				endcase
			end
			S_CALC: 	state_next = proc_done ? S_OUTPUT : S_CALC;
			S_OUTPUT:	state_next = out_done ? S_IDLE : S_OUTPUT;
		endcase
	end

	always @(posedge clk) begin
		if (~rstn) begin
			state		<= S_IDLE;
			cnt			<= 0;
			mode_set	<= 0;
			code_set	<= 0;
		end
		else begin
			state		<= state_next;
			cnt			<= cnt_next;
			mode_set	<= mode_set_next;
			code_set	<= code_set_next;
		end
	end

endmodule

