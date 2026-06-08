module NKES_core_new(
    input               clk,
    input               rst,
    input               start,
    input               first_iter,
    input               mode,
    input               mode_init,
    input               pe_cnt,

    input [5:0]         gamma_time,
    input [5:0]         dis_time,
    input               branch_time,
    input [5:0]         gamma_out,
    input [5:0]         dis_out,
    input               branch_out,

    input [5:0]         Lsigma_out[3:0],
    input [5:0]         Lb_out[3:0],
    input [5:0]         Ldelta_even_out[1:0],
    input [5:0]         Ltheta_even_out[1:0],

    input [5:0]         LO_syn[3:0],    
    input [5:0]         HO_syn[1:0],

    output [5:0]        discrepancy,
    output reg [5:0]    sigma_poly_out_rec[3:0],
    output [5:0]        sigma_poly_out[3:0],
    output [5:0]        b_poly_out[3:0],
    output [5:0]        delta_poly_out[1:0],
    output [5:0]        theta_poly_out[1:0]
);

// localparam S_IDLE   = 1'd0;
// localparam S_PROC   = 1'd1;

// reg         state, state_next;
// reg [2:0]   cnt, cnt_next;
// reg         valid_pre, valid_pre_next;
// reg         valid, valid_next;

reg [5:0]   delta_poly_0_rec;

wire [5:0]  delta_even_in[1:0], theta_even_in[1:0], sigma_even_in[1:0], b_even_in[1:0];
wire [5:0]  delta_init[1:0], theta_init[1:0], sigma_init[3:0], b_init[3:0];
wire [5:0]  delta_init_out[1:0], theta_init_out[1:0];

integer i;

genvar gi;

assign discrepancy = pe_cnt ? delta_poly_0_rec : delta_poly_out[0];

generate
    // to precompute unit
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign delta_even_in[gi] = Ldelta_even_out[gi];
        assign theta_even_in[gi] = Ltheta_even_out[gi];
        assign sigma_even_in[gi] = Lsigma_out[gi*2];
        assign b_even_in[gi] = Lb_out[gi*2]; 
    end

    // sigma, b init
        assign sigma_init[0] = mode_init ? Lsigma_out[0] : 6'b1;
        assign b_init[0] = mode_init ? Lb_out[0] : 6'b0;
    for (gi=1; gi < 4; gi = gi + 1) begin
        assign sigma_init[gi] = mode_init ? Lsigma_out[gi] : 6'b0;
        assign b_init[gi] = mode_init ? Lb_out[gi] : 6'b0;
    end

    // delta, theta init
    for (gi=0; gi < 2 ; gi = gi + 1) begin
        assign delta_init[gi] = mode_init ? delta_init_out[gi] : LO_syn[gi * 2];
        assign theta_init[gi] = mode_init ? theta_init_out[gi] : LO_syn[gi * 2 + 1];
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
    .start(start),
    .hold(1'b0),
    .first_iter(first_iter),
    .mode(mode),
    .mode_init(mode_init),
    .pe_cnt(pe_cnt),

    .gamma_time(gamma_time),
    .dis_time(dis_time),
    .branch_time(branch_time),
    .gamma_out(gamma_out),
    .dis_out(dis_out),
    .branch_out(branch_out),

    .Hsyn_even(HO_syn[1]),
    .Hsyn_odd(HO_syn[0]), 

    .sigma_init(sigma_init),
    .b_init(b_init),
    .delta_init(delta_init),
    .theta_init(theta_init),

    .sigma_poly_out(sigma_poly_out),
    .b_poly_out(b_poly_out),
    .delta_poly_out(delta_poly_out),
    .theta_poly_out(theta_poly_out)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        delta_poly_0_rec    <= 0;
        for (i = 0; i < 4; i = i + 1) begin
            sigma_poly_out_rec[i]   <= 0;
        end
    end
    else begin
        delta_poly_0_rec    <= delta_poly_out[0];
        for (i = 0; i < 4; i = i + 1) begin
            sigma_poly_out_rec[i]   <= sigma_poly_out[i];
        end
    end
end

endmodule