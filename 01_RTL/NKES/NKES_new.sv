module NKES_new(
    input clk,
    input rst,

    input syn_rdy,  // high order syndrome ready
    input [5:0] HO_syn[1:0],

    input forward,

    // from low order riBM
    input Lwaddr,
    input Lwen,
    input [5:0] Lsigma[3:0],
    input [5:0] Lb[3:0],
    input [5:0] Ldelta_even[1:0], // delta_even[0] = d0, delta_even[1] = d2
    input [5:0] Ltheta_even[1:0], // theta_even[0] = t0, theta_even[1] = t2
    input [5:0] Lgamma,
    input [1:0] Lk,

    output sigma_done,
    output [5:0] sigma[6:0]
);

wire [5:0]  Lsigma_out[3:0], Lb_out[3:0], Ldelta_even_out[1:0], Ltheta_even_out[1:0], Lgamma_out;
wire [3:0]  Lk_out;

wire        start;

wire [5:0]  discrepancy_in;

wire        pe_cnt;

wire [5:0]  gamma_out, discrepancy_out;
wire        branch_out;

wire [5:0]  gamma_init;
wire [3:0]  k_init;

reg [5:0]   gamma_time, gamma_time_next;
reg [5:0]   dis_time, dis_time_next;
reg         branch_time, branch_time_next;

assign gamma_init = Lgamma_out;
assign k_init = Lk_out;

// =========== retime registers =============
always @(posedge clk or posedge rst) begin
    if (rst) begin
        gamma_time  <= 6'b0;
        dis_time    <= 6'b0;
        branch_time <= 0;
    end
    else begin
        gamma_time  <= gamma_time_next;
        dis_time    <= dis_time_next;
        branch_time <= branch_time_next;
    end
end

always @(*) begin 
    if (start) begin
        gamma_time_next = 6'b1;
        dis_time_next = 6'b0;
        branch_time_next = 1'b0;
    end
    else if (pe_cnt) begin
        gamma_time_next = gamma_out;
        dis_time_next = discrepancy_out;
        branch_time_next = branch_out;        
    end
    else begin
        gamma_time_next = gamma_time;
        dis_time_next = dis_time;
        branch_time_next = branch_time; 
    end
end
// ==========================================

NKES_ctrl_new u_ctrl_n(
    .clk(clk),
    .rst(rst),
    .syn_rdy(syn_rdy),
    .sigma_done(sigma_done),

    .pe_cnt(pe_cnt),

    .discrepancy_in(discrepancy_in),
    .gamma_init(gamma_init),
    .k_init(k_init),

    .start(start),

    .gamma_out(gamma_out),
    .discrepancy_out(discrepancy_out),
    .branch_out(branch_out)
);

state_buff_new u_state_buff_n(
    .clk(clk),
    .rst(rst),

    .forward(forward),
    .pe_cnt(pe_cnt),

    .raddr(1'b0),

    .Lwaddr(Lwaddr),
    .Lwen(Lwen),
    .Lsigma_in(Lsigma),
    .Lb_in(Lb),
    .Ldelta_even_in(Ldelta_even),
    .Ltheta_even_in(Ltheta_even),
    .Lgamma_in(Lgamma),
    .Lk_in(Lk),

    .Nwen(1'b0),
    .Nsigma_in(),
    .Nb_in(),
    .Ndelta_even_in(),
    .Ntheta_even_in(),
    .Ngamma_in(),
    .Nk_in(),

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
    .mode(1'b1),
    .start(start),

    .gamma_time(gamma_time),
    .dis_time(dis_time),
    .branch_time(branch_time),

    .gamma_out(gamma_out),
    .dis_out(discrepancy_out),
    .branch_out(branch_out),

    .Lsigma_out(Lsigma_out),
    .Lb_out(Lb_out),
    .Ldelta_even_out(Ldelta_even_out),
    .Ltheta_even_out(Ltheta_even_out),

    .HO_syn(HO_syn),

    .pe_cnt(pe_cnt),
    .discrepancy(discrepancy_in),
    .sigma_done(),
    .sigma()
);

endmodule