module NKES_PE_array_new(
    input           clk,
    input           rst,
    input           mode,
    input           pe_cnt,
    input           start,

    input [5:0]     gamma_time,
    input [5:0]     dis_time,
    input           branch_time,

    input [5:0]     gamma_out,
    input [5:0]     dis_out,
    input           branch_out,

    input [5:0]     Hsyn_even,
    input [5:0]     Hsyn_odd, 

    input [5:0]     delta_init[1:0],
    input [5:0]     theta_init[1:0],
    input [5:0]     sigma_init[3:0],
    input [5:0]     b_init[3:0],

    output [5:0]    sigma_poly_out[3:0],
    output [5:0]    sigma_delay_out[3:0],
    output [5:0]    b_poly_out[3:0],
    output [5:0]    b_delay_out[3:0],

    output [5:0]    delta_poly[1:0],
    output [5:0]    theta_poly[1:0],
    output [5:0]    delta_delay_out[1:0],
    output [5:0]    theta_delay_out[1:0]
);

reg [5:0]   b_poly_2_rec;
reg [5:0]   b_poly_3_rec;
reg [5:0]   b_even_1_rec;
reg [5:0]   b_odd_1_rec;

wire [5:0]  sigma_even[1:0], sigma_odd[1:0];
wire [5:0]  b_even[1:0], b_odd[1:0];
wire [5:0]  delta_poly_pre_out_0;

// ============ PE1 array ====================
NKES_PE1_unified u_PE10(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(1'b0),
    .mode(mode), 
    
    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(delta_init[0]),
    .theta_init(theta_init[0]),
    .delta_poly_in(delta_poly[1]),
    .nested_delta_poly_in(delta_poly[1]),

    .sigma_even(sigma_even[0]), .sigma_odd(sigma_odd[0]),
    .b_even(pe_cnt ? b_even_1_rec : 6'b0), .b_odd(pe_cnt ? b_odd_1_rec : 6'b0),

    .delta_poly_pre_out(delta_poly_pre_out_0),

    .delta_poly_out(delta_poly[0]),
    .theta_poly_out(theta_poly[0]),
    .delta_delay_out(delta_delay_out[0]),
    .theta_delay_out(theta_delay_out[0])
);

NKES_PE1_unified u_PE11(
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .hold(1'b0),
    .mode(mode), 
    
    .gamma(gamma_time), 
    .discrepancy(dis_time), 
    .branch(branch_time),

    .delta_init(delta_init[1]),
    .theta_init(theta_init[1]),
    .delta_poly_in(6'b0),
    .nested_delta_poly_in(pe_cnt ? 6'b0 : delta_poly_pre_out_0),

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
    .hold(1'b0),
    .mode(mode), 
    
    .gamma(gamma_out), 
    .discrepancy(dis_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(pe_cnt ? b_poly_2_rec : 6'b0),
    .sigma_init(sigma_init[0]),
    .b_init(b_init[0]),

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
    .hold(1'b0),
    .mode(mode), 
    
    .gamma(gamma_out), 
    .discrepancy(dis_out), 
    .branch(branch_out),

    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[0]),
    .sigma_init(sigma_init[2]),
    .b_init(b_init[2]),

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
    .hold(1'b0),
    .mode(mode), 
    
    .gamma(gamma_out), 
    .discrepancy(dis_out), 
    .branch(branch_out),

    .H_syn(Hsyn_odd),
    .b_poly_in(pe_cnt ? b_poly_3_rec : 6'b0),
    .sigma_init(sigma_init[1]),
    .b_init(b_init[1]),

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
    .hold(1'b0),
    
    .gamma(gamma_out), 
    .discrepancy(dis_out), 
    .branch(branch_out),

    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[1]),
    .sigma_init(sigma_init[3]),
    .b_init(b_init[3]),

    .sigma_syn(sigma_odd[1]),
    .b_syn(b_odd[1]),

    .b_poly_out(b_poly_out[3]),
    .sigma_poly_out(sigma_poly_out[3]),
    .sigma_delay_out(sigma_delay_out[3]),
    .b_delay_out(b_delay_out[3])
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        b_poly_2_rec    <= 0;
        b_poly_3_rec    <= 0;
        b_even_1_rec    <= 0;
        b_odd_1_rec     <= 0;
    end
    else begin
        b_poly_2_rec    <= b_poly_out[2];
        b_poly_3_rec    <= b_poly_out[3];
        b_even_1_rec    <= b_even[1];
        b_odd_1_rec     <= b_odd[1];
    end
end

endmodule