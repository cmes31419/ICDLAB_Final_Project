module syndrome(
	input           clk,
	input           rstn,
    input           ready,
    input           reset,
	input [63:0]    data,
    output          valid,
    output [5:0]    taggle_loc0,
    output [5:0]    taggle_loc1,
    output [6:0]    taggle_corr0,
    output [6:0]    taggle_corr1,
    output [5:0]    Sa[2:0],
    output [5:0]    Sb[2:0],
    output [5:0]    Sc[2:0],
    output [5:0]    Sd[2:0]
);

    localparam S_IDLE = 2'd0;
    localparam S_PROC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]   state, state_next;
    reg [2:0]   cnt, cnt_next;

	reg [7:0]	syn_data, syn_data_next;

    reg [5:0]   syn1, syn1_next;
    reg [5:0]   syn3, syn3_next;

    reg [6:0]   min0_abs, min0_abs_next;
    reg [5:0]   min0_loc, min0_loc_next;
    reg [5:0]   min0_syn1, min0_syn1_next;
    reg [5:0]   min0_syn3, min0_syn3_next;

    reg [6:0]   min1_abs, min1_abs_next;
    reg [5:0]   min1_loc, min1_loc_next;
    reg [5:0]   min1_syn1, min1_syn1_next;
    reg [5:0]   min1_syn3, min1_syn3_next;

    wire [5:0]  syn1_rot, syn3_rot;
    wire [5:0]  min0_syn1_rot, min0_syn3_rot;
    wire [5:0]  min1_syn1_rot, min1_syn3_rot;

    wire [7:0]  r;
    wire [55:0] exmin;
    wire [6:0]  exm_min0_abs, exm_min1_abs;
    wire [2:0]  exm_min0_loc, exm_min1_loc;

    integer i;

    assign r = {(|cnt) ? syn_data[7] : 1'b0, syn_data[6:0]};

    assign exmin[6:0]   = data[7]  ? ~data[6:0]   + 1 : data[6:0]  ;
    assign exmin[13:7]  = data[15] ? ~data[14:8]  + 1 : data[14:8] ;
    assign exmin[20:14] = data[23] ? ~data[22:16] + 1 : data[22:16];
    assign exmin[27:21] = data[31] ? ~data[30:24] + 1 : data[30:24];
    assign exmin[34:28] = data[39] ? ~data[38:32] + 1 : data[38:32];
    assign exmin[41:35] = data[47] ? ~data[46:40] + 1 : data[46:40];
    assign exmin[48:42] = data[55] ? ~data[54:48] + 1 : data[54:48];
    assign exmin[55:49] = (state == S_PROC) ? (data[63] ? ~data[62:56] + 1 : data[62:56]) : 7'b1111111;

    assign valid = (state == S_DONE) ? 1 : 0;

    assign taggle_loc0 = min0_loc;
    assign taggle_loc1 = min1_loc;
    assign taggle_corr0 = min0_abs;
    assign taggle_corr1 = min1_abs;

    assign Sa[0] = syn1;
    assign Sb[0] = syn1 ^ min0_syn1;
    assign Sc[0] = syn1 ^ min1_syn1;
    assign Sd[0] = syn1 ^ min0_syn1 ^ min1_syn1;

    extract_min_2 exm0(
		.clk(clk),
		.rstn(rstn),
        .data(exmin),
        .exm_min0_abs(exm_min0_abs),
        .exm_min0_loc(exm_min0_loc),
        .exm_min1_abs(exm_min1_abs),
        .exm_min1_loc(exm_min1_loc)
    );

    pow_a_2 pa20(
        .pow1(syn1),
        .pow2(Sa[1])
    );
    
    pow_a_3 pa30(
        .pow1(syn3),
        .pow3(Sa[2])
    );

    pow_a_2 pa21(
        .pow1(syn1 ^ min0_syn1),
        .pow2(Sb[1])
    );
    
    pow_a_3 pa31(
        .pow1(syn3 ^ min0_syn3),
        .pow3(Sb[2])
    );

    pow_a_2 pa22(
        .pow1(syn1 ^ min1_syn1),
        .pow2(Sc[1])
    );

    pow_a_3 pa32(
        .pow1(syn3 ^ min1_syn3),
        .pow3(Sc[2])
    );

    pow_a_2 pa23(
        .pow1(syn1 ^ min0_syn1 ^ min1_syn1),
        .pow2(Sd[1])
    );

    pow_a_3 pa33(
        .pow1(syn3 ^ min0_syn3 ^ min1_syn3),
        .pow3(Sd[2])
    );

    rotate_4_8_add rot48add0(
        .syn1(syn1),
        .syn3(syn3),
        .data(r),
        .syn1_rot(syn1_rot),
        .syn3_rot(syn3_rot)
    );

    rotate_4_8 rot480(
        .syn1(min0_syn1),
        .syn3(min0_syn3),
        .syn1_rot(min0_syn1_rot),
        .syn3_rot(min0_syn3_rot)
    );

    rotate_4_8 rot481(
        .syn1(min1_syn1),
        .syn3(min1_syn3),
        .syn1_rot(min1_syn1_rot),
        .syn3_rot(min1_syn3_rot)
    );

    always @(*) begin
        if (state == S_PROC) begin
            syn1_next = syn1_rot;
            syn3_next = syn3_rot;
        end
        else if (reset) begin
            syn1_next = 0;
            syn3_next = 0;
        end
        else begin
            syn1_next = syn1;
            syn3_next = syn3;
        end
    end

    always @(*) begin
        if (reset) begin
            min0_abs_next = 7'b1111111;
            min0_loc_next = 0;
            min0_syn1_next = 0;
            min0_syn3_next = 0;
            min1_abs_next = 7'b1111111;
            min1_loc_next = 0;
            min1_syn1_next = 0;
            min1_syn3_next = 0;
        end
        else if (state == S_PROC) begin
            min0_abs_next = min0_abs;
            min0_loc_next = min0_loc;
            min0_syn1_next = min0_syn1_rot;
            min0_syn3_next = min0_syn3_rot;
            min1_abs_next = min1_abs;
            min1_loc_next = min1_loc;
            min1_syn1_next = min1_syn1_rot;
            min1_syn3_next = min1_syn3_rot;

            if (exm_min0_abs < min0_abs) begin
                min0_abs_next = exm_min0_abs;
                min0_loc_next = {cnt, exm_min0_loc};

                if (exm_min0_loc == 3'd1) begin
                    min0_syn1_next = 6'b11;
                    min0_syn3_next = 6'b10111;
                end
                else if (exm_min0_loc == 3'd0) begin
                    min0_syn1_next = 6'b110;
                    min0_syn3_next = 6'b101110;
                end
                else begin
                    min0_syn1_next = 6'b100000 >> (exm_min0_loc - 2);
                    min0_syn3_next = min0_syn1_next;
                end
                
                if (exm_min1_abs < min0_abs) begin
                    min1_abs_next = exm_min1_abs;
                    min1_loc_next = {cnt, exm_min1_loc};

                    if (exm_min1_loc == 3'd1) begin
                        min1_syn1_next = 6'b11;
                        min1_syn3_next = 6'b10111;
                    end
                    else if (exm_min1_loc == 3'd0) begin
                        min1_syn1_next = 6'b110;
                        min1_syn3_next = 6'b101110;
                    end
                    else begin
                        min1_syn1_next = 6'b100000 >> (exm_min1_loc - 2);
                        min1_syn3_next = min1_syn1_next;
                    end

                end
                else begin
                    min1_abs_next = min0_abs;
                    min1_loc_next = min0_loc;
                    min1_syn1_next = min0_syn1_rot;
                    min1_syn3_next = min0_syn3_rot;
                end
            end
            else if (exm_min0_abs < min1_abs) begin
                min1_abs_next = exm_min0_abs;
                min1_loc_next = {cnt, exm_min0_loc};

                if (exm_min0_loc == 3'd1) begin
                    min1_syn1_next = 6'b11;
                    min1_syn3_next = 6'b10111;
                end
                else if (exm_min0_loc == 3'd0) begin
                    min1_syn1_next = 6'b110;
                    min1_syn3_next = 6'b101110;
                end
                else begin
                    min1_syn1_next = 6'b100000 >> (exm_min0_loc - 2);
                    min1_syn3_next = min1_syn1_next;
                end
            end
        end
        else begin
            min0_abs_next = min0_abs;
            min0_loc_next = min0_loc;
            min0_syn1_next = min0_syn1;
            min0_syn3_next = min0_syn3;
            min1_abs_next = min1_abs;
            min1_loc_next = min1_loc;
            min1_syn1_next = min1_syn1;
            min1_syn3_next = min1_syn3;
        end
    end

    always @(*) begin
		syn_data_next = {data[63], data[55], data[47], data[39], data[31], data[23], data[15], data[7]};
	end

    always @(*) begin
        if (state == S_DONE) cnt_next = 0;
        else if (state == S_PROC) cnt_next = cnt + 1;
        else cnt_next = cnt;
    end

    always @(*) begin
        case(state)
            S_IDLE:     state_next = ready ? S_PROC : S_IDLE;
            S_PROC:     state_next = (cnt == 3'd7) ? S_DONE : S_PROC;
            S_DONE:     state_next = S_IDLE;
            default:    state_next = S_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (~rstn) begin
            state       <= S_IDLE;
            cnt         <= 0;
			syn_data	<= 0;
            syn1        <= 0;
            syn3        <= 0;
            min0_abs    <= 7'b1111111;
            min0_loc    <= 0;
            min0_syn1   <= 0;
            min0_syn3   <= 0;
            min1_abs    <= 7'b1111111;
            min1_loc    <= 0;
            min1_syn1   <= 0;
            min1_syn3   <= 0;
        end
        else begin
            state       <= state_next;
            cnt         <= cnt_next;
			syn_data	<= syn_data_next;
            syn1        <= syn1_next;
            syn3        <= syn3_next;
            min0_abs    <= min0_abs_next;
            min0_loc    <= min0_loc_next;
            min0_syn1   <= min0_syn1_next;
            min0_syn3   <= min0_syn3_next;
            min1_abs    <= min1_abs_next;
            min1_loc    <= min1_loc_next;
            min1_syn1   <= min1_syn1_next;
            min1_syn3   <= min1_syn3_next;
        end
    end

endmodule