module NKES_PE_array(
    input       clk,
    input       rst,
    input       start,
    input       hold,
    input       fail_init,

    input [5:0] gamma_time,
    input [5:0] dis_time,
    input       branch_time,

    input [5:0] gamma_out,
    input [5:0] discrepancy_out,
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

    output [5:0] sigma[6:0],
    output [5:0] sigma_delay_out[7:0],
    output [5:0] b_poly_out[5:0],
    output [5:0] b_delay_out[7:0]
);

wire [5:0] sigma_even[3:0], sigma_odd[3:0];
wire [5:0] b_even[2:0], b_odd[2:0];

// ============ PE1 array ====================
NKES_PE1 u_PE10(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 
    
    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(delta_init[0]),
    .theta_init(theta_init[0]),
    .delta_poly_in(delta_poly[1]),

    .sigma_even(sigma_even[0]), .sigma_odd(sigma_odd[0]),
    .b_even(6'b0), .b_odd(6'b0),

    .delta_poly_out(delta_poly[0]),
    .theta_poly_out(theta_poly[0]),
    .delta_delay_out(delta_delay_out[0]),
    .theta_delay_out(theta_delay_out[0])
);

NKES_PE1 u_PE11(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 
    
    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(delta_init[1]),
    .theta_init(theta_init[1]),
    .delta_poly_in(delta_poly[2]),

    .sigma_even(sigma_even[1]), .sigma_odd(sigma_odd[1]),
    .b_even(b_even[0]), .b_odd(b_odd[0]),
    
    .delta_poly_out(delta_poly[1]),
    .theta_poly_out(theta_poly[1]),
    .delta_delay_out(delta_delay_out[1]),
    .theta_delay_out(theta_delay_out[1])
);

NKES_PE1 u_PE12(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 

    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(delta_init[2]),
    .theta_init(theta_init[2]),
    .delta_poly_in(delta_poly[3]),

    .sigma_even(sigma_even[2]), .sigma_odd(sigma_odd[2]),
    .b_even(b_even[1]), .b_odd(b_odd[1]),

    .delta_poly_out(delta_poly[2]),
    .theta_poly_out(theta_poly[2]),
    .delta_delay_out(delta_delay_out[2]),
    .theta_delay_out(theta_delay_out[2])
);

NKES_PE1 u_PE13(
    .clk(clk), 
    .rst(rst), 
    .start(start || fail_init), 
    .hold(hold), 
    
    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(6'b0),
    .theta_init(6'b0),
    .delta_poly_in(6'b0),

    .sigma_even(sigma_even[3]), .sigma_odd(sigma_odd[3]),
    .b_even(b_even[2]), .b_odd(b_odd[2]),

    .delta_poly_out(delta_poly[3]),
    .theta_poly_out(theta_poly[3]),
    .delta_delay_out(delta_delay_out[3]),
    .theta_delay_out(theta_delay_out[3])
);
// =========================================

// ============ PE0 array ====================
NKES_PE0 u_PE00(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(6'b0),
    .sigma_init(sigma_init[0]),
    .b_init(b_init[0]),

    .sigma_syn(sigma_even[0]),
    .b_syn(b_even[0]),
    .b_poly_out(b_poly_out[0]),
    .sigma_poly_out(sigma[0]),
    .sigma_delay_out(sigma_delay_out[0]),
    .b_delay_out(b_delay_out[0])
);

NKES_PE0 u_PE02(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[0]),
    .sigma_init(sigma_init[2]),
    .b_init(b_init[2]),

    .sigma_syn(sigma_even[1]),
    .b_syn(b_even[1]),
    .b_poly_out(b_poly_out[2]),
    .sigma_poly_out(sigma[2]),
    .sigma_delay_out(sigma_delay_out[2]),
    .b_delay_out(b_delay_out[2])
);

NKES_PE0 u_PE04(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[2]),
    .sigma_init(sigma_init[4]),
    .b_init(b_init[4]),

    .sigma_syn(sigma_even[2]),
    .b_syn(b_even[2]),
    .b_poly_out(b_poly_out[4]),
    .sigma_poly_out(sigma[4]),
    .sigma_delay_out(sigma_delay_out[4]),
    .b_delay_out(b_delay_out[4])
);

NKES_PE0 u_PE06(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[4]),
    .sigma_init(sigma_init[6]),
    .b_init(b_init[6]),

    .sigma_syn(sigma_even[3]),
    .b_syn(),
    .b_poly_out(),
    .sigma_poly_out(sigma[6]),
    .sigma_delay_out(sigma_delay_out[6]),
    .b_delay_out(b_delay_out[6])
);

NKES_PE0 u_PE01(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_odd),
    .b_poly_in(6'b0),
    .sigma_init(sigma_init[1]),
    .b_init(b_init[1]),

    .sigma_syn(sigma_odd[0]),
    .b_syn(b_odd[0]),
    .b_poly_out(b_poly_out[1]),
    .sigma_poly_out(sigma[1]),
    .sigma_delay_out(sigma_delay_out[1]),
    .b_delay_out(b_delay_out[1])
);

NKES_PE0 u_PE03(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[1]),
    .sigma_init(sigma_init[3]),
    .b_init(b_init[3]),

    .sigma_syn(sigma_odd[1]),
    .b_syn(b_odd[1]),
    .b_poly_out(b_poly_out[3]),
    .sigma_poly_out(sigma[3]),
    .sigma_delay_out(sigma_delay_out[3]),
    .b_delay_out(b_delay_out[3])
);

NKES_PE0 u_PE05(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 
    
    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),
    
    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[3]),
    .sigma_init(sigma_init[5]),
    .b_init(b_init[5]),

    .sigma_syn(sigma_odd[2]),
    .b_syn(b_odd[2]),
    .b_poly_out(b_poly_out[5]),
    .sigma_poly_out(sigma[5]),
    .sigma_delay_out(sigma_delay_out[5]),
    .b_delay_out(b_delay_out[5])
);

NKES_PE0 u_PE07(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(hold), 

    .gamma(gamma_out), 
    .discrepancy(discrepancy_out), 
    .branch(branch_out),

    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[5]),
    .sigma_init(sigma_init[7]),
    .b_init(b_init[7]),

    .sigma_syn(sigma_odd[3]),
    .b_syn(),
    .b_poly_out(),
    .sigma_poly_out(),
    .sigma_delay_out(sigma_delay_out[7]),
    .b_delay_out(b_delay_out[7])
);

endmodule