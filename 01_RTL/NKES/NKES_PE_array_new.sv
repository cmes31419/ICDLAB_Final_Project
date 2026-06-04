module NKES_PE_array_new(
    input       clk,
    input       rst,
    input       start,
    input       hold,
    input       fail_init,
    input       mode,

    input [5:0] gamma_time,
    input [5:0] dis_time,
    input       branch_time,

    input [5:0] gamma_out,
    input [5:0] dis_out,
    input       branch_out,

    input [5:0] Hsyn_odd, 
    input [5:0] Hsyn_even,

    input [5:0] delta_init[2:0],
    input [5:0] theta_init[2:0],
    input [5:0] sigma_init[7:0],
    input [5:0] b_init[7:0],

    output [5:0] delta_poly[3:0],
    output [5:0] theta_poly[3:0],
    output [5:0] delta_delay_out[3:0],
    output [5:0] theta_delay_out[3:0],

    output       sigma_done,
    output [5:0] sigma[6:0],
    output [5:0] sigma_delay_out[7:0],
    output [5:0] b_poly_out[5:0],
    output [5:0] b_delay_out[7:0]
);

localparam S_IDLE   = 1'd0;
localparam S_PROC   = 1'd1;

reg         state, state_next;
reg [2:0]   cnt, cnt_next;
reg         valid_pre, valid_pre_next;
reg         valid, valid_next;

reg [5:0]   b_poly_2_rec, b_poly_2_rec_next;
reg [5:0]   b_poly_3_rec, b_poly_3_rec_next;
reg [5:0]   b_even_1_rec, b_even_1_rec_next;
reg [5:0]   b_odd_1_rec, b_odd_1_rec_next;
reg [5:0]   sigma_poly_out_rec[3:0], sigma_poly_out_rec_next[3:0];

wire [5:0]  sigma_even[1:0], sigma_odd[1:0];
wire [5:0]  b_even[1:0], b_odd[1:0];
wire [5:0]  delta_poly_pre_out_0;
wire [5:0]  sigma_poly_out[3:0];

integer i;

genvar gi;

// TODO: fix --------------------------------
reg [5:0] gamma_time_rec;
reg [5:0] dis_time_rec;
reg       branch_time_rec;
reg [5:0] gamma_out_rec;
reg [5:0] dis_out_rec;
reg       branch_out_rec;
reg [5:0] Hsyn_odd_rec;
reg [5:0] Hsyn_even_rec;

reg [5:0] delta_init_2_rec;
reg [5:0] theta_init_2_rec;
reg [5:0] sigma_init_4_rec;
reg [5:0] sigma_init_5_rec;
reg [5:0] sigma_init_6_rec;
reg [5:0] sigma_init_7_rec;
reg [5:0] b_init_4_rec;
reg [5:0] b_init_5_rec;
reg [5:0] b_init_6_rec;
reg [5:0] b_init_7_rec;
// ------------------------------------------

assign sigma_done = valid;

generate
    for (gi=0;gi<4;gi=gi+1) begin
        assign sigma[gi] = sigma_poly_out_rec[gi];
    end
    for (gi=4;gi<7;gi=gi+1) begin
        assign sigma[gi] = sigma_poly_out[gi-4];
    end
endgenerate


// ============ PE1 array ====================
NKES_PE1_unified u_PE10(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 
    .mode(mode), 
    
    .gamma(cnt[0] ? gamma_time_rec : gamma_time), 
    .discrepancy(cnt[0] ? dis_time_rec : dis_time), 
    .branch(cnt[0] ? branch_time_rec : branch_time),

    .delta_init(cnt[0] ? delta_init_2_rec : delta_init[0]),
    .theta_init(cnt[0] ? theta_init_2_rec : theta_init[0]),
    .delta_poly_in(delta_poly[1]),
    .nested_delta_poly_in(delta_poly[1]),

    .sigma_even(sigma_even[0]), .sigma_odd(sigma_odd[0]),
    .b_even(cnt[0] ? b_even_1_rec : 6'b0), .b_odd(cnt[0] ? b_odd_1_rec : 6'b0),

    .delta_poly_pre_out(delta_poly_pre_out_0),

    .delta_poly_out(delta_poly[0]),
    .theta_poly_out(theta_poly[0]),
    .delta_delay_out(delta_delay_out[0]),
    .theta_delay_out(theta_delay_out[0])
);

NKES_PE1_unified u_PE11(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 
    .mode(mode), 
    
    .gamma(cnt[0] ? gamma_time_rec : gamma_time), 
    .discrepancy(cnt[0] ? dis_time_rec : dis_time), 
    .branch(cnt[0] ? branch_time_rec : branch_time),

    .delta_init(cnt[0] ? 6'b0 : delta_init[1]),
    .theta_init(cnt[0] ? 6'b0 : theta_init[1]),
    .delta_poly_in(6'b0),
    .nested_delta_poly_in(cnt[0] ? 6'b0 : delta_poly_pre_out_0),

    .sigma_even(sigma_even[1]), .sigma_odd(sigma_odd[1]),
    .b_even(b_even[0]), .b_odd(b_odd[0]),
    
    .delta_poly_pre_out(),

    .delta_poly_out(delta_poly[1]),
    .theta_poly_out(theta_poly[1]),
    .delta_delay_out(delta_delay_out[1]),
    .theta_delay_out(theta_delay_out[1])
);
// =========================================

// ============ PE0 array ====================
NKES_PE0_unified u_PE00(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    .mode(mode), 
    
    .gamma(cnt[0] ? gamma_out_rec : gamma_out), 
    .discrepancy(cnt[0] ? dis_out_rec : dis_out), 
    .branch(cnt[0] ? branch_out_rec : branch_out),

    .H_syn(cnt[0] ? Hsyn_even_rec : Hsyn_even),
    .b_poly_in(cnt[0] ? b_poly_2_rec : 6'b0),
    .sigma_init(cnt[0] ? sigma_init_4_rec : sigma_init[0]),
    .b_init(cnt[0] ? b_init_4_rec : b_init[0]),

    .sigma_syn(sigma_even[0]),
    .b_syn(b_even[0]),

    .b_poly_out(b_poly_out[0]),
    .sigma_poly_out(sigma_poly_out[0]),
    .sigma_delay_out(sigma_delay_out[0]),
    .b_delay_out(b_delay_out[0])
);

NKES_PE0_unified u_PE02(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    .mode(mode), 
    
    .gamma(cnt[0] ? gamma_out_rec : gamma_out), 
    .discrepancy(cnt[0] ? dis_out_rec : dis_out), 
    .branch(cnt[0] ? branch_out_rec : branch_out),

    .H_syn(cnt[0] ? Hsyn_even_rec : Hsyn_even),
    .b_poly_in(b_poly_out[0]),
    .sigma_init(cnt[0] ? sigma_init_6_rec : sigma_init[2]),
    .b_init(cnt[0] ? b_init_6_rec : b_init[2]),

    .sigma_syn(sigma_even[1]),
    .b_syn(b_even[1]),

    .b_poly_out(b_poly_out[2]),
    .sigma_poly_out(sigma_poly_out[2]),
    .sigma_delay_out(sigma_delay_out[2]),
    .b_delay_out(b_delay_out[2])
);

NKES_PE0_unified u_PE01(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    .mode(mode), 
    
    .gamma(cnt[0] ? gamma_out_rec : gamma_out), 
    .discrepancy(cnt[0] ? dis_out_rec : dis_out), 
    .branch(cnt[0] ? branch_out_rec : branch_out),

    .H_syn(cnt[0] ? Hsyn_odd_rec : Hsyn_odd),
    .b_poly_in(cnt[0] ? b_poly_3_rec : 6'b0),
    .sigma_init(cnt[0] ? sigma_init_5_rec : sigma_init[1]),
    .b_init(cnt[0] ? b_init_5_rec : b_init[1]),

    .sigma_syn(sigma_odd[0]),
    .b_syn(b_odd[0]),

    .b_poly_out(b_poly_out[1]),
    .sigma_poly_out(sigma_poly_out[1]),
    .sigma_delay_out(sigma_delay_out[1]),
    .b_delay_out(b_delay_out[1])
);

NKES_PE0 u_PE03(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(cnt[0] ? gamma_out_rec : gamma_out), 
    .discrepancy(cnt[0] ? dis_out_rec : dis_out), 
    .branch(cnt[0] ? branch_out_rec : branch_out),

    .H_syn(cnt[0] ? Hsyn_odd_rec : Hsyn_odd),
    .b_poly_in(b_poly_out[1]),
    .sigma_init(cnt[0] ? sigma_init_7_rec : sigma_init[3]),
    .b_init(cnt[0] ? b_init_7_rec : b_init[3]),

    .sigma_syn(sigma_odd[1]),
    .b_syn(b_odd[1]),

    .b_poly_out(b_poly_out[3]),
    .sigma_poly_out(sigma_poly_out[3]),
    .sigma_delay_out(sigma_delay_out[3]),
    .b_delay_out(b_delay_out[3])
);

always @(*) begin
    b_poly_2_rec_next = b_poly_out[2];
    b_poly_3_rec_next = b_poly_out[3];
    b_even_1_rec_next = b_even[1];
    b_odd_1_rec_next = b_odd[1];
    for (i=0;i<4;i=i+1) begin
        sigma_poly_out_rec_next[i] = sigma_poly_out[i];
    end
end

always @(*) begin
    if (state == S_IDLE) cnt_next = start ? cnt + 1 : 0;
    else cnt_next = (cnt == 3'd5) ? 0 : cnt + 1;
    valid_pre_next = (cnt == 3'd5) ? 1 : 0;
    valid_next = valid_pre;
end

always @(*) begin
    case (state)
    S_IDLE:     state_next = start ? S_PROC : S_IDLE;
    S_PROC:     state_next = (cnt == 3'd5) ? S_IDLE : S_PROC;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state           <= S_IDLE;
        cnt             <= 0;
        valid_pre       <= 0;
        valid           <= 0;
        b_poly_2_rec    <= 0;
        b_poly_3_rec    <= 0;
        b_even_1_rec    <= 0;
        b_odd_1_rec     <= 0;
        for (i=0;i<4;i=i+1) begin
            sigma_poly_out_rec[i]   <= 0;
        end

        gamma_time_rec      <= 0;
        dis_time_rec        <= 0;
        branch_time_rec     <= 0;
        gamma_out_rec       <= 0;
        dis_out_rec         <= 0;
        branch_out_rec      <= 0;
        Hsyn_odd_rec        <= 0;
        Hsyn_even_rec       <= 0;
        delta_init_2_rec    <= 0;
        theta_init_2_rec    <= 0;
        sigma_init_4_rec    <= 0;
        sigma_init_5_rec    <= 0;
        sigma_init_6_rec    <= 0;
        sigma_init_7_rec    <= 0;
        b_init_4_rec    <= 0;
        b_init_5_rec    <= 0;
        b_init_6_rec    <= 0;
        b_init_7_rec    <= 0;
    end
    else begin
        state           <= state_next;
        cnt             <= cnt_next;
        valid_pre       <= valid_pre_next;
        valid           <= valid_next;
        b_poly_2_rec    <= b_poly_2_rec_next;
        b_poly_3_rec    <= b_poly_3_rec_next;
        b_even_1_rec    <= b_even_1_rec_next;
        b_odd_1_rec     <= b_odd_1_rec_next;
        for (i=0;i<4;i=i+1) begin
            sigma_poly_out_rec[i]   <= sigma_poly_out_rec_next[i];
        end

        gamma_time_rec      <= gamma_time;
        dis_time_rec        <= dis_time;
        branch_time_rec     <= branch_time;
        gamma_out_rec       <= gamma_out;
        dis_out_rec         <= dis_out;
        branch_out_rec      <= branch_out;
        Hsyn_odd_rec        <= Hsyn_odd;
        Hsyn_even_rec       <= Hsyn_even;
        delta_init_2_rec    <= delta_init[2];
        theta_init_2_rec    <= theta_init[2];
        sigma_init_4_rec    <= sigma_init[4];
        sigma_init_5_rec    <= sigma_init[5];
        sigma_init_6_rec    <= sigma_init[6];
        sigma_init_7_rec    <= sigma_init[7];
        b_init_4_rec    <= b_init[4];
        b_init_5_rec    <= b_init[5];
        b_init_6_rec    <= b_init[6];
        b_init_7_rec    <= b_init[7];
    end
end

endmodule