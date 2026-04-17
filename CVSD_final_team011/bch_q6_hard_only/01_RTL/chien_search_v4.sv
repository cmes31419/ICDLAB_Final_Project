module chien_search(
    input               clk,
    input               rstn,
    input               decode_fail,
    input               ready,
    input [5:0]         sigma0,
    input [5:0]         sigma1,
    input [5:0]         sigma2,
	input [9:0]		    mem_cnt,
	input [5:0]		    factor8,
	input [5:0]		    factor16,
    output              chien_wait,
    output              chien_proc,
    output              chien_done,
    output              chien_success,
    output reg [9:0]    error_loc[1:0]
);

	localparam MAX_CYCLES_M6 = 64 / `PARALLEL_NUM;
    localparam MAX_CYCLES_M8 = 256 / `PARALLEL_NUM;
    localparam MAX_CYCLES_M10 = 1024 / `PARALLEL_NUM;
    localparam PAR_BITS = $clog2(`PARALLEL_NUM);
    localparam CNT_BITS = $clog2(MAX_CYCLES_M10);

    localparam S_IDLE = 3'd0;
    localparam S_PROC = 3'd1;
    localparam S_DONE = 3'd2;
    localparam S_FAIL = 3'd3;
    localparam S_WAIT = 3'd4;
    localparam S_LATE = 3'd5;

    reg [2:0]                   state, state_next;
    reg [CNT_BITS:0]            cnt, cnt_next;
    reg [9:0]                   error_loc_next[1:0];

    reg                         zero_sum_valid, zero_sum_valid_next;

    reg [5:0]	                sigma0_rec, sigma0_rec_next;
	reg [5:0]	                sigma1_rec, sigma1_rec_next;
    reg [5:0]	                sigma2_rec, sigma2_rec_next;

    reg [5:0]                   sigma0_prod, sigma0_prod_next;
    reg [5:0]                   sigma1_prod, sigma1_prod_next;
    reg [5:0]                   sigma2_prod, sigma2_prod_next;

    wire [5:0]                  sigma0_rot;
    wire [5:0]                  sigma1_rot;
    wire [5:0]                  sigma2_rot;

    wire [5:0]                  sigma0_now;
    wire [5:0]                  sigma1_now;
    wire [5:0]                  sigma2_now;

    reg                         proc_finish, proc_success;

    wire [`PARALLEL_NUM-1:0]    zero_sum;

    wire [`PARALLEL_NUM-1:0]    col_zero_sum;
    wire                        col_valid, col_stall;
    wire [PAR_BITS-1:0]         col_loc;

    reg [9:0]                   loc;
    reg [12:0]                  loc_tmp;
    reg [10:0]                  loc_tmp2;

    integer i, j;

    assign chien_wait = (state == S_WAIT) ? 1 : 0;
    assign chien_proc = ((state == S_IDLE && ready) || ((state == S_WAIT || state == S_PROC || state == S_LATE) && ~col_stall)) ? 1 : 0;
    assign chien_done = (state == S_DONE || state == S_FAIL) ? 1 : 0;
    assign chien_success = (state == S_DONE) ? 1 : 0;

    assign col_zero_sum = zero_sum_valid ? {zero_sum[`PARALLEL_NUM-1:1], zero_sum[0] & (|cnt)} : {`PARALLEL_NUM{1'b0}};

    assign sigma0_now = (state == S_IDLE && ready) ? sigma0 : sigma0_rec;
    assign sigma1_now = (state == S_IDLE && ready) ? sigma1 : sigma1_rec;
    assign sigma2_now = (state == S_IDLE && ready) ? sigma2 : sigma2_rec;

    assign sigma0_rot = sigma0_now;

    gf_mul_1_1 gfmul0(
        .in1(sigma1_now), 
        .in2(factor8), 
        .out1(sigma1_rot)
    );

    gf_mul_1_1 gfmul1( 
        .in1(sigma2_now), 
        .in2(factor16), 
        .out1(sigma2_rot)
    );

    chien_mul cmul0(
        .clk(clk),
        .rstn(rstn),
        .ready((state == S_WAIT || state == S_PROC) ? 1'b1 : 1'b0),
        .stall(col_stall),
		.sigma0(sigma0_prod),
		.sigma1(sigma1_prod),
		.sigma2(sigma2_prod),
        .zero_sum(zero_sum)
    );

    collect_loc cloc0(
        .clk(clk),
        .rstn(rstn),
        .reset((state == S_WAIT) ? 1'b1 : 1'b0),
        .zero_sum(col_zero_sum),
        .valid(col_valid),
        .stall(col_stall),
        .loc(col_loc)
    );

    always @(*) begin
        loc_tmp = 0;
        loc_tmp2 = 0;
        loc = 0;
        if (state == S_PROC || state == S_LATE) begin
            loc_tmp = (col_loc[PAR_BITS-1:3] << CNT_BITS-1) + ((mem_cnt-2) << 3) + col_loc[2:0];
            loc_tmp2[7:0] = loc_tmp[12:6] + loc_tmp[5:0];
            loc[5:0] = loc_tmp2[10:6] + loc_tmp2[5:0];
        end
                
        if (state == S_PROC || state == S_LATE) begin
            if (col_valid) begin
                error_loc_next[0] = loc;
                for (i=1;i<2;i=i+1) begin
                    error_loc_next[i] = error_loc[i-1];
                end
            end
            else begin
                for (i=0;i<2;i=i+1) begin
                    error_loc_next[i] = error_loc[i];
                end
            end
        end
        else if (state == S_DONE) begin
            for (i=0;i<2;i=i+1) begin
                error_loc_next[i] = error_loc[i];
            end
        end
        else begin
            for (i=0;i<2;i=i+1) begin
                error_loc_next[i] = 0;
            end
        end
    end

    always @(*) begin
        if (state == S_PROC || state == S_LATE) cnt_next = col_stall ? cnt : cnt + 1;
        else cnt_next = 0;
    end

    always @(*) begin
		sigma0_rec_next = (state == S_IDLE && ready) ? sigma0 : sigma0_rec;
		sigma1_rec_next = (state == S_IDLE && ready) ? sigma1 : sigma1_rec;
		sigma2_rec_next = (state == S_IDLE && ready) ? sigma2 : sigma2_rec;
        sigma0_prod_next = col_stall ? sigma0_prod : sigma0_rot;
        sigma1_prod_next = col_stall ? sigma1_prod : sigma1_rot;
        sigma2_prod_next = col_stall ? sigma2_prod : sigma2_rot;
	end

    always @(*) begin
        if (sigma2_now != 10'd0) begin
            proc_success = (error_loc[1] != 10'd0) ? 1 : 0;
        end
        else if (sigma1_now != 10'd0) begin
            proc_success = (error_loc[0] != 10'd0) ? 1 : 0;
        end
        else proc_success = 1;
    end

    always @(*) begin
        proc_finish = (cnt[CNT_BITS-4:0] == MAX_CYCLES_M6-1) ? 1 : 0;
    end

    always @(*) begin
        if (state == S_WAIT || (state == S_PROC && ~proc_finish && ~col_stall)) zero_sum_valid_next = 1;
        else zero_sum_valid_next = 0;
    end

    always @(*) begin
        case (state)
            S_IDLE:     state_next = ready ? S_WAIT : S_IDLE;
            S_WAIT:     state_next = decode_fail ? S_FAIL : S_PROC;
            S_PROC:     state_next = proc_success ? S_DONE : (proc_finish ? (col_valid ? S_LATE : S_FAIL) : S_PROC);
            S_LATE:     state_next = proc_success ? S_DONE : (col_valid ? S_LATE : S_FAIL);
            S_DONE:     state_next = S_IDLE;
            S_FAIL:     state_next = S_IDLE;
            default:    state_next = S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (~rstn) begin
            state           <= S_IDLE;
            cnt             <= 0;
            for (i=0;i<2;i=i+1) begin
                error_loc[i]    <= 0;
            end
            zero_sum_valid  <= 0;
            sigma0_rec	    <= 0;
            sigma1_rec	    <= 0;
            sigma2_rec	    <= 0;
            sigma0_prod     <= 0;
            sigma1_prod     <= 0;
            sigma2_prod     <= 0;
        end
        else begin
            state           <= state_next;
            cnt             <= cnt_next;
            for (i=0;i<2;i=i+1) begin
                error_loc[i]    <= error_loc_next[i];
            end
            zero_sum_valid  <= zero_sum_valid_next;
			sigma0_rec	    <= sigma0_rec_next;
			sigma1_rec	    <= sigma1_rec_next;
			sigma2_rec	    <= sigma2_rec_next;
            sigma0_prod     <= sigma0_prod_next;
            sigma1_prod     <= sigma1_prod_next;
            sigma2_prod     <= sigma2_prod_next;
        end
    end

endmodule