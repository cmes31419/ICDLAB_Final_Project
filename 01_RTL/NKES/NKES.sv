module NKES(
    input       clk,
    input       rst,

    input       LO_syn_rdy,  // low order syndrome ready
    input [5:0] LO_syn[3:0],

    input       HO_syn_rdy,  // high order syndrome ready
    input [5:0] HO_syn[1:0],

    input       forward,
    input       sel_idx,

    input       Lwaddr,

    input       Lwen_ctrl,
    input       Nwen_ctrl,

    output       LO_syn_get,
    output       HO_syn_get,
    output       Lsigma_done,
    output       Lsigma_fail,
    output       Nsigma_done,
    output [5:0] sigma[6:0]
);

wire [5:0]  Lsigma_out[3:0], Lb_out[3:0], Ldelta_even_out[1:0], Ltheta_even_out[1:0], Lgamma_out;
wire [3:0]  Lk_out;

wire [5:0]  sigma_poly_out[3:0], b_poly_out[3:0], delta_poly_out[1:0], theta_poly_out[1:0];

wire        start, mode, mode_init, pe_cnt, first_iter;
wire        Lwen, Nwen0, Nwen1;

wire [5:0]  sigma_poly_out_rec[3:0];

wire [5:0]  gamma_time;
wire [5:0]  dis_time;
wire        branch_time;
wire [5:0]  gamma_out;
wire [5:0]  dis_out;
wire        branch_out;
wire [2:0]  k_out;

wire [5:0]  discrepancy;
wire [5:0]  gamma_init;
wire [3:0]  k_init;

genvar gi;

generate
    for (gi = 0; gi < 4; gi = gi + 1) begin
        assign sigma[gi] = Lwen ? sigma_poly_out[gi] : sigma_poly_out_rec[gi];
    end
    for (gi = 4; gi < 7; gi = gi + 1) begin
        assign sigma[gi] = Lwen ? 6'b0 : sigma_poly_out[gi-4];
    end
endgenerate

assign Lsigma_done = Lwen;
assign Lsigma_fail = Lwen & (|sigma_poly_out[3]);
assign Nsigma_done = Nwen1;

assign gamma_init = Lgamma_out;
assign k_init = Lk_out;

NKES_ctrl u_ctrl(
    .clk(clk),
    .rst(rst),
    .LO_syn_rdy(LO_syn_rdy),
    .HO_syn_rdy(HO_syn_rdy),

    .dis_in(discrepancy),
    .gamma_init(gamma_init),
    .k_init(k_init),

    .start(start),
    .mode(mode),
    .mode_init(mode_init),
    .pe_cnt(pe_cnt),
    .first_iter(first_iter),
    .LO_syn_get(LO_syn_get),
    .HO_syn_get(HO_syn_get),
    .Lwen(Lwen),
    .Nwen0(Nwen0),
    .Nwen1(Nwen1),

    .gamma_time(gamma_time),
    .dis_time(dis_time),
    .branch_time(branch_time),
    .gamma_out(gamma_out),
    .dis_out(dis_out),
    .branch_out(branch_out),
    .k_out(k_out)
);

state_buff u_state_buff(
    .clk(clk),
    .rst(rst),

    .forward(forward),
    .pe_cnt(pe_cnt),

    .raddr(sel_idx),

    .Lwaddr(Lwaddr),
    .Lwen(Lwen & Lwen_ctrl),
    .Lsigma_in(sigma_poly_out),
    .Lb_in(b_poly_out),
    .Ldelta_even_in(delta_poly_out),
    .Ltheta_even_in(theta_poly_out),
    .Lgamma_in(gamma_out),
    .Lk_in(k_out[1:0]),

    .Nwen0(Nwen0 & Nwen_ctrl),
    .Nwen1(Nwen1 & Nwen_ctrl),
    .Nsigma_in(sigma_poly_out),
    .Nb_in(b_poly_out),
    .Ndelta_even_in(delta_poly_out),
    .Ntheta_even_in(theta_poly_out),
    .Ngamma_in(gamma_out),
    .Nk_in(k_out),

    .sigma_out(Lsigma_out),
    .b_out(Lb_out),
    .delta_even_out(Ldelta_even_out),
    .theta_even_out(Ltheta_even_out),
    .gamma_out(Lgamma_out),
    .k_out(Lk_out)
);

NKES_core u_core(
    .clk(clk),
    .rst(rst),
    .start(start),
    .first_iter(first_iter),
    .mode(mode),
    .mode_init(mode_init),
    .pe_cnt(pe_cnt),

    .gamma_time(mode ? gamma_time : gamma_out),
    .dis_time(mode ? dis_time : dis_out),
    .branch_time(mode ? branch_time : branch_out),
    .gamma_out(gamma_out),
    .dis_out(dis_out),
    .branch_out(branch_out),

    .Lsigma_out(Lsigma_out),
    .Lb_out(Lb_out),
    .Ldelta_even_out(Ldelta_even_out),
    .Ltheta_even_out(Ltheta_even_out),

    .LO_syn(LO_syn),
    .HO_syn(HO_syn),

    .discrepancy(discrepancy),
    .sigma_poly_out_rec(sigma_poly_out_rec),
    .sigma_poly_out(sigma_poly_out),
    .b_poly_out(b_poly_out),
    .delta_poly_out(delta_poly_out),
    .theta_poly_out(theta_poly_out)
);

endmodule