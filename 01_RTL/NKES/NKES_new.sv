module NKES_new(
    input       clk,
    input       rst,

    input       LO_syn_rdy,  // low order syndrome ready
    input [5:0] LO_syn[3:0],

    input       HO_syn_rdy,  // high order syndrome ready
    input [5:0] HO_syn[1:0],

    input       forward,
    input       sel_idx,

    // from low order riBM
    input       Lwaddr,
    input       Lwen,
    input [5:0] Lsigma[3:0],
    input [5:0] Lb[3:0],
    input [5:0] Ldelta_even[1:0], // delta_even[0] = d0, delta_even[1] = d2
    input [5:0] Ltheta_even[1:0], // theta_even[0] = t0, theta_even[1] = t2
    input [5:0] Lgamma,
    input [1:0] Lk,

    input       Nwen_ctrl,

    output       LO_syn_get,
    output       HO_syn_get,
    output       sigma_done,
    output [5:0] sigma[6:0]
);

parameter S_IDLE    = 2'd0;
parameter S_PROC0   = 2'd1;
parameter S_PROC1   = 2'd2;

reg [3:0]   state, state_next;

wire [5:0]  Lsigma_out[3:0], Lb_out[3:0], Ldelta_even_out[1:0], Ltheta_even_out[1:0], Lgamma_out;
wire [3:0]  Lk_out;

wire [5:0]  Nsigma[3:0], Nb[3:0], Ndelta_even[1:0], Ntheta_even[1:0];

wire        start, mode, mode_init, pe_cnt, first_iter;
wire        Nwen0, Nwen1;

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

assign gamma_init = Lgamma_out;
assign k_init = Lk_out;

NKES_ctrl_new u_ctrl_n(
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
    .Nwen0(Nwen0),
    .Nwen1(Nwen1),
    .sigma_done(sigma_done),

    .gamma_time(gamma_time),
    .dis_time(dis_time),
    .branch_time(branch_time),
    .gamma_out(gamma_out),
    .dis_out(dis_out),
    .branch_out(branch_out),
    .k_out(k_out)
);

state_buff_new u_state_buff_n(
    .clk(clk),
    .rst(rst),

    .forward(forward),
    .pe_cnt(pe_cnt),

    .raddr(sel_idx),

    .Lwaddr(Lwaddr),
    .Lwen(Lwen),
    .Lsigma_in(Lsigma),
    .Lb_in(Lb),
    .Ldelta_even_in(Ldelta_even),
    .Ltheta_even_in(Ltheta_even),
    .Lgamma_in(Lgamma),
    .Lk_in(Lk),

    .Nwen0(Nwen0 & Nwen_ctrl),
    .Nwen1(Nwen1 & Nwen_ctrl),
    .Nsigma_in(Nsigma),
    .Nb_in(Nb),
    .Ndelta_even_in(Ndelta_even),
    .Ntheta_even_in(Ntheta_even),
    .Ngamma_in(gamma_out),
    .Nk_in(k_out),

    .sigma_out(Lsigma_out),
    .b_out(Lb_out),
    .delta_even_out(Ldelta_even_out),
    .theta_even_out(Ltheta_even_out),
    .gamma_out(Lgamma_out),
    .k_out(Lk_out)
);

NKES_core_new u_core_n(
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

    // .pe_cnt(pe_cnt),
    .discrepancy(discrepancy),
    // .sigma_done_pre(),
    // .sigma_done(),
    .sigma(sigma),
    
    .Nsigma(Nsigma),
    .Nb(Nb),
    .Ndelta_even(Ndelta_even),
    .Ntheta_even(Ntheta_even)
);

endmodule