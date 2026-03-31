module syndrome(
	input           clk,
	input           rstn,
    input           ready,
    input           reset,
	input [1:0]     code,
	input [63:0]    data,
    output          valid,
    output [9:0]    taggle_loc0,
    output [9:0]    taggle_loc1,
    output [6:0]    taggle_corr0,
    output [6:0]    taggle_corr1,
    output [9:0]    Sa[7:0],
    output [9:0]    Sb[7:0],
    output [9:0]    Sc[7:0],
    output [9:0]    Sd[7:0]
);

    localparam S_IDLE = 2'd0;
    localparam S_PROC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]   state, state_next;
    reg [6:0]   cnt, cnt_next;

	reg [7:0]	syn_data, syn_data_next;

    reg [9:0]   syn1, syn1_next;
    reg [9:0]   syn3, syn3_next;
    reg [9:0]   syn5, syn5_next;
    reg [9:0]   syn7, syn7_next;

    reg [6:0]   min0_abs, min0_abs_next;
    reg [9:0]   min0_loc, min0_loc_next;
    reg [9:0]   min0_syn1, min0_syn1_next;
    reg [9:0]   min0_syn3, min0_syn3_next;
    reg [9:0]   min0_syn5, min0_syn5_next;
    reg [9:0]   min0_syn7, min0_syn7_next;

    reg [6:0]   min1_abs, min1_abs_next;
    reg [9:0]   min1_loc, min1_loc_next;
    reg [9:0]   min1_syn1, min1_syn1_next;
    reg [9:0]   min1_syn3, min1_syn3_next;
    reg [9:0]   min1_syn5, min1_syn5_next;
    reg [9:0]   min1_syn7, min1_syn7_next;

    wire [9:0]  syn1_rot, syn3_rot, syn5_rot, syn7_rot;
    wire [9:0]  min0_syn1_rot, min0_syn3_rot, min0_syn5_rot, min0_syn7_rot;
    wire [9:0]  min1_syn1_rot, min1_syn3_rot, min1_syn5_rot, min1_syn7_rot;

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
        .code(code),
        .pow1(syn1),
        .pow2(Sa[1])
    );
    
    pow_a_3 pa30(
        .code(code),
        .pow1(syn3),
        .pow3(Sa[2])
    );

    pow_a_4 pa40(
        .code(code),
        .pow1(syn1),
        .pow4(Sa[3])
    );

    pow_a_5 pa50(
        .code(code),
        .pow1(syn5),
        .pow5(Sa[4])
    );
    
    pow_a_6 pa60(
        .code(code),
        .pow1(syn3),
        .pow6(Sa[5])
    );

    pow_a_7 pa70(
        .code(code),
        .pow1(syn7),
        .pow7(Sa[6])
    );

    pow_a_8 pa80(
        .code(code),
        .pow1(syn1),
        .pow8(Sa[7])
    );

    pow_a_2 pa21(
        .code(code),
        .pow1(syn1 ^ min0_syn1),
        .pow2(Sb[1])
    );
    
    pow_a_3 pa31(
        .code(code),
        .pow1(syn3 ^ min0_syn3),
        .pow3(Sb[2])
    );

    pow_a_4 pa41(
        .code(code),
        .pow1(syn1 ^ min0_syn1),
        .pow4(Sb[3])
    );

    pow_a_5 pa51(
        .code(code),
        .pow1(syn5 ^ min0_syn5),
        .pow5(Sb[4])
    );
    
    pow_a_6 pa61(
        .code(code),
        .pow1(syn3 ^ min0_syn3),
        .pow6(Sb[5])
    );

    pow_a_7 pa71(
        .code(code),
        .pow1(syn7 ^ min0_syn7),
        .pow7(Sb[6])
    );

    pow_a_8 pa81(
        .code(code),
        .pow1(syn1 ^ min0_syn1),
        .pow8(Sb[7])
    );

    pow_a_2 pa22(
        .code(code),
        .pow1(syn1 ^ min1_syn1),
        .pow2(Sc[1])
    );

    pow_a_3 pa32(
        .code(code),
        .pow1(syn3 ^ min1_syn3),
        .pow3(Sc[2])
    );

    pow_a_4 pa42(
        .code(code),
        .pow1(syn1 ^ min1_syn1),
        .pow4(Sc[3])
    );

    pow_a_5 pa52(
        .code(code),
        .pow1(syn5 ^ min1_syn5),
        .pow5(Sc[4])
    );

    pow_a_6 pa62(
        .code(code),
        .pow1(syn3 ^ min1_syn3),
        .pow6(Sc[5])
    );

    pow_a_7 pa72(
        .code(code),
        .pow1(syn7 ^ min1_syn7),
        .pow7(Sc[6])
    );

    pow_a_8 pa82(
        .code(code),
        .pow1(syn1 ^ min1_syn1),
        .pow8(Sc[7])
    );

    pow_a_2 pa23(
        .code(code),
        .pow1(syn1 ^ min0_syn1 ^ min1_syn1),
        .pow2(Sd[1])
    );

    pow_a_3 pa33(
        .code(code),
        .pow1(syn3 ^ min0_syn3 ^ min1_syn3),
        .pow3(Sd[2])
    );

    pow_a_4 pa43(
        .code(code),
        .pow1(syn1 ^ min0_syn1 ^ min1_syn1),
        .pow4(Sd[3])
    );

    pow_a_5 pa53(
        .code(code),
        .pow1(syn5 ^ min0_syn5 ^ min1_syn5),
        .pow5(Sd[4])
    );

    pow_a_6 pa63(
        .code(code),
        .pow1(syn3 ^ min0_syn3 ^ min1_syn3),
        .pow6(Sd[5])
    );

    pow_a_7 pa73(
        .code(code),
        .pow1(syn7 ^ min0_syn7 ^ min1_syn7),
        .pow7(Sd[6])
    );

    pow_a_8 pa83(
        .code(code),
        .pow1(syn1 ^ min0_syn1 ^ min1_syn1),
        .pow8(Sd[7])
    );

    rotate_4_8_add rot48add0(
        .code(code),
        .syn1(syn1),
        .syn3(syn3),
        .syn5(syn5),
        .syn7(syn7),
        .data(r),
        .syn1_rot(syn1_rot),
        .syn3_rot(syn3_rot),
        .syn5_rot(syn5_rot),
        .syn7_rot(syn7_rot)
    );

    rotate_4_8 rot480(
        .code(code),
        .syn1(min0_syn1),
        .syn3(min0_syn3),
        .syn5(min0_syn5),
        .syn7(min0_syn7),
        .syn1_rot(min0_syn1_rot),
        .syn3_rot(min0_syn3_rot),
        .syn5_rot(min0_syn5_rot),
        .syn7_rot(min0_syn7_rot)
    );

    rotate_4_8 rot481(
        .code(code),
        .syn1(min1_syn1),
        .syn3(min1_syn3),
        .syn5(min1_syn5),
        .syn7(min1_syn7),
        .syn1_rot(min1_syn1_rot),
        .syn3_rot(min1_syn3_rot),
        .syn5_rot(min1_syn5_rot),
        .syn7_rot(min1_syn7_rot)
    );

    always @(*) begin
        if (state == S_PROC) begin
            syn1_next = syn1_rot;
            syn3_next = syn3_rot;
            syn5_next = syn5_rot;
            syn7_next = syn7_rot;
        end
        else if (reset) begin
            syn1_next = 0;
            syn3_next = 0;
            syn5_next = 0;
            syn7_next = 0;
        end
        else begin
            syn1_next = syn1;
            syn3_next = syn3;
            syn5_next = syn5;
            syn7_next = syn7;
        end
    end

    always @(*) begin
        if (reset) begin
            min0_abs_next = 7'b1111111;
            min0_loc_next = 0;
            min0_syn1_next = 0;
            min0_syn3_next = 0;
            min0_syn5_next = 0;
            min0_syn7_next = 0;
            min1_abs_next = 7'b1111111;
            min1_loc_next = 0;
            min1_syn1_next = 0;
            min1_syn3_next = 0;
            min1_syn5_next = 0;
            min1_syn7_next = 0;
        end
        else if (state == S_PROC) begin
            min0_abs_next = min0_abs;
            min0_loc_next = min0_loc;
            min0_syn1_next = min0_syn1_rot;
            min0_syn3_next = min0_syn3_rot;
            min0_syn5_next = min0_syn5_rot;
            min0_syn7_next = min0_syn7_rot;
            min1_abs_next = min1_abs;
            min1_loc_next = min1_loc;
            min1_syn1_next = min1_syn1_rot;
            min1_syn3_next = min1_syn3_rot;
            min1_syn5_next = min1_syn5_rot;
            min1_syn7_next = min1_syn7_rot;

            if (exm_min0_abs < min0_abs) begin
                min0_abs_next = exm_min0_abs;
                min0_loc_next = {cnt, exm_min0_loc};

                if (code == 2'd1 && exm_min0_loc == 3'd1) begin
                    min0_syn1_next = 10'b11;
                    min0_syn3_next = 10'b10111;
                end
                else if (code == 2'd1 && exm_min0_loc == 3'd0) begin
                    min0_syn1_next = 10'b110;
                    min0_syn3_next = 10'b101110;
                end
                else begin
                    min0_syn1_next = 10'h80 >> exm_min0_loc;
                    min0_syn3_next = min0_syn1_next;
                end

                if (code == 2'd3) begin
                    min0_syn5_next = min0_syn1_next;
                    min0_syn7_next = min0_syn1_next;
                end
                else begin
                    min0_syn5_next = 0;
                    min0_syn7_next = 0;
                end
                
                if (exm_min1_abs < min0_abs) begin
                    min1_abs_next = exm_min1_abs;
                    min1_loc_next = {cnt, exm_min1_loc};

                    if (code == 2'd1 && exm_min1_loc == 3'd1) begin
                        min1_syn1_next = 10'b11;
                        min1_syn3_next = 10'b10111;
                    end
                    else if (code == 2'd1 && exm_min1_loc == 3'd0) begin
                        min1_syn1_next = 10'b110;
                        min1_syn3_next = 10'b101110;
                    end
                    else begin
                        min1_syn1_next = 10'h80 >> exm_min1_loc;
                        min1_syn3_next = min1_syn1_next;
                    end

                    if (code == 2'd3) begin
                        min1_syn5_next = min1_syn1_next;
                        min1_syn7_next = min1_syn1_next;
                    end
                    else begin
                        min1_syn5_next = 0;
                        min1_syn7_next = 0;
                    end
                end
                else begin
                    min1_abs_next = min0_abs;
                    min1_loc_next = min0_loc;
                    min1_syn1_next = min0_syn1_rot;
                    min1_syn3_next = min0_syn3_rot;
                    min1_syn5_next = min0_syn5_rot;
                    min1_syn7_next = min0_syn7_rot;
                end
            end
            else if (exm_min0_abs < min1_abs) begin
                min1_abs_next = exm_min0_abs;
                min1_loc_next = {cnt, exm_min0_loc};

                if (code == 2'd1 && exm_min0_loc == 3'd1) begin
                    min1_syn1_next = 10'b11;
                    min1_syn3_next = 10'b10111;
                end
                else if (code == 2'd1 && exm_min0_loc == 3'd0) begin
                    min1_syn1_next = 10'b110;
                    min1_syn3_next = 10'b101110;
                end
                else begin
                    min1_syn1_next = 10'h80 >> exm_min0_loc;
                    min1_syn3_next = min1_syn1_next;
                end

                if (code == 2'd3) begin
                    min1_syn5_next = min1_syn1_next;
                    min1_syn7_next = min1_syn1_next;
                end
                else begin
                    min1_syn5_next = 0;
                    min1_syn7_next = 0;
                end
            end
        end
        else begin
            min0_abs_next = min0_abs;
            min0_loc_next = min0_loc;
            min0_syn1_next = min0_syn1;
            min0_syn3_next = min0_syn3;
            min0_syn5_next = min0_syn5;
            min0_syn7_next = min0_syn7;
            min1_abs_next = min1_abs;
            min1_loc_next = min1_loc;
            min1_syn1_next = min1_syn1;
            min1_syn3_next = min1_syn3;
            min1_syn5_next = min1_syn5;
            min1_syn7_next = min1_syn7;
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
            S_PROC: begin
                case (code)
                    2'd1: state_next = (cnt[2:0] == 3'd7) ? S_DONE : S_PROC;
                    2'd2: state_next = (cnt[4:0] == 5'd31) ? S_DONE : S_PROC;
                    2'd3: state_next = (cnt == 7'd127) ? S_DONE : S_PROC;
                    default: state_next = S_IDLE;
                endcase
            end
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
            syn5        <= 0;
            syn7        <= 0;
            min0_abs    <= 7'b1111111;
            min0_loc    <= 0;
            min0_syn1   <= 0;
            min0_syn3   <= 0;
            min0_syn5   <= 0;
            min0_syn7   <= 0;
            min1_abs    <= 7'b1111111;
            min1_loc    <= 0;
            min1_syn1   <= 0;
            min1_syn3   <= 0;
            min1_syn5   <= 0;
            min1_syn7   <= 0;
        end
        else begin
            state       <= state_next;
            cnt         <= cnt_next;
			syn_data	<= syn_data_next;
            syn1        <= syn1_next;
            syn3        <= syn3_next;
            syn5        <= syn5_next;
            syn7        <= syn7_next;
            min0_abs    <= min0_abs_next;
            min0_loc    <= min0_loc_next;
            min0_syn1   <= min0_syn1_next;
            min0_syn3   <= min0_syn3_next;
            min0_syn5   <= min0_syn5_next;
            min0_syn7   <= min0_syn7_next;
            min1_abs    <= min1_abs_next;
            min1_loc    <= min1_loc_next;
            min1_syn1   <= min1_syn1_next;
            min1_syn3   <= min1_syn3_next;
            min1_syn5   <= min1_syn5_next;
            min1_syn7   <= min1_syn7_next;
        end
    end

endmodule