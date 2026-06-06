module NKES_core_new(
    input           clk,
    input           rst,
    input           mode,
    input           start,

    input [5:0]     gamma_time,
    input [5:0]     dis_time,
    input           branch_time,

    input [5:0]     gamma_out,
    input [5:0]     dis_out,
    input           branch_out,

    input [5:0]     Lsigma_out[3:0],
    input [5:0]     Lb_out[3:0],
    input [5:0]     Ldelta_even_out[1:0],
    input [5:0]     Ltheta_even_out[1:0], 

    input [5:0]     HO_syn[1:0],

    output          pe_cnt,
    output [5:0]    discrepancy,
    output          sigma_done_pre,
    output          sigma_done,
    output [5:0]    sigma[6:0],

    output [5:0]    Nsigma[3:0],
    output [5:0]    Nb[3:0],
    output [5:0]    Ndelta_even[1:0],
    output [5:0]    Ntheta_even[1:0]
);

localparam S_IDLE   = 1'd0;
localparam S_PROC   = 1'd1;

reg         state, state_next;
reg [2:0]   cnt, cnt_next;
reg         valid_pre, valid_pre_next;
reg         valid, valid_next;

reg [5:0]   delta_poly_0_rec;
reg [5:0]   sigma_poly_out_rec[3:0];

wire [5:0]  delta_even_in[1:0], theta_even_in[1:0], sigma_even_in[1:0], b_even_in[1:0];
wire [5:0]  delta_init[1:0], theta_init[1:0], sigma_init[3:0], b_init[3:0];
wire [5:0]  delta_delay_out[1:0], theta_delay_out[1:0], sigma_delay_out[3:0], b_delay_out[3:0];
wire [5:0]  delta_poly[1:0], theta_poly[1:0], sigma_poly_out[3:0], b_poly_out[3:0];
wire [5:0]  delta_init_out[1:0], theta_init_out[1:0];

integer i;

genvar gi;

assign pe_cnt = cnt[0];
assign discrepancy = pe_cnt ? delta_poly_0_rec : delta_poly[0];
assign sigma_done_pre = valid_pre;
assign sigma_done = valid;

generate
    for (gi = 0; gi < 4; gi = gi + 1) begin
        assign sigma[gi] = sigma_poly_out_rec[gi];
    end
    for (gi = 4; gi < 7; gi = gi + 1) begin
        assign sigma[gi] = sigma_poly_out[gi-4];
    end

    for (gi = 0; gi < 4; gi = gi + 1) begin
        assign Nsigma[gi] = sigma_poly_out[gi];
        assign Nb[gi] = b_poly_out[gi];
    end
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign Ndelta_even[gi] = delta_poly[gi];
        assign Ntheta_even[gi] = theta_poly[gi];
    end
    
    // to precompute unit
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign delta_even_in[gi] = Ldelta_even_out[gi];
        assign theta_even_in[gi] = Ltheta_even_out[gi];
        assign sigma_even_in[gi] = Lsigma_out[gi*2];
        assign b_even_in[gi] = Lb_out[gi*2]; 
    end

    // sigma, b init
    for (gi=0; gi < 4; gi = gi + 1) begin
        assign sigma_init[gi] = Lsigma_out[gi];
        assign b_init[gi] = Lb_out[gi];
    end

    // delta, theta init
    for (gi=0 ; gi<2 ; gi = gi + 1) begin
        assign delta_init[gi] = delta_init_out[gi];
        assign theta_init[gi] = theta_init_out[gi];
    end
endgenerate

precompute_unit_new u_PU_n(
    .delta_even_in(delta_even_in),
    .theta_even_in(theta_even_in),
    .sigma_even_in(sigma_even_in),
    .b_even_in(b_even_in),
    .Su(HO_syn[1]),

    .delta_init_out(delta_init_out),
    .theta_init_out(theta_init_out)
);

NKES_PE_array_new u_pe_arr_n(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .pe_cnt(pe_cnt),
    .start(start),

    .gamma_time(gamma_time),
    .dis_time(dis_time),
    .branch_time(branch_time),

    .gamma_out(gamma_out),
    .dis_out(dis_out),
    .branch_out(branch_out),

    .Hsyn_even(HO_syn[1]),
    .Hsyn_odd(HO_syn[0]), 

    .delta_init(delta_init),
    .theta_init(theta_init),
    .sigma_init(sigma_init),
    .b_init(b_init),

    .sigma_poly_out(sigma_poly_out),
    .sigma_delay_out(sigma_delay_out),
    .b_poly_out(b_poly_out),
    .b_delay_out(b_delay_out),

    .delta_poly(delta_poly),
    .theta_poly(theta_poly),
    .delta_delay_out(delta_delay_out),
    .theta_delay_out(theta_delay_out)
);

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
        state               <= S_IDLE;
        cnt                 <= 0;
        valid_pre           <= 0;
        valid               <= 0;
        delta_poly_0_rec    <= 0;
        for (i=0;i<4;i=i+1) begin
            sigma_poly_out_rec[i]   <= 0;
        end
    end
    else begin
        state               <= state_next;
        cnt                 <= cnt_next;
        valid_pre           <= valid_pre_next;
        valid               <= valid_next;
        delta_poly_0_rec    <= delta_poly[0];
        for (i=0;i<4;i=i+1) begin
            sigma_poly_out_rec[i]   <= sigma_poly_out[i];
        end
    end
end

endmodule