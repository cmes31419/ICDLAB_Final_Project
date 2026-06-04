module precompute_unit(
    input [5:0] delta_even_in [2:0],
    input [5:0] theta_even_in [2:0],
    input [5:0] sigma_even_in [2:0],
    input [5:0] b_even_in [2:0],
    input [5:0] Su,

    output [5:0] delta_init_out[2:0],
    output [5:0] theta_init_out[2:0]
);

    wire [5:0] syn_sigma_prod[2:0];
    wire [5:0] syn_b_prod[2:0];
    genvar gi;
    generate
        for (gi = 0; gi < 3; gi = gi + 1) begin
            gf_mul u_gf_mul_sigma(.in1(Su), .in2(sigma_even_in[gi]), .prod(syn_sigma_prod[gi]));
            gf_mul u_gf_mul_b(.in1(Su), .in2(b_even_in[gi]), .prod(syn_b_prod[gi]));

            assign delta_init_out[gi] = syn_sigma_prod[gi] ^ delta_even_in[gi];
            assign theta_init_out[gi] = syn_b_prod[gi] ^ theta_even_in[gi];
        end 
    endgenerate

endmodule


module precompute_unit_new(
    input [5:0] delta_even_in [1:0],
    input [5:0] theta_even_in [1:0],
    input [5:0] sigma_even_in [1:0],
    input [5:0] b_even_in [1:0],
    input [5:0] Su,

    output [5:0] delta_init_out[1:0],
    output [5:0] theta_init_out[1:0]
);

    wire [5:0] syn_sigma_prod[1:0];
    wire [5:0] syn_b_prod[1:0];

    genvar gi;

    generate
        for (gi = 0; gi < 2; gi = gi + 1) begin
            gf_mul u_gf_mul_sigma(.in1(Su), .in2(sigma_even_in[gi]), .prod(syn_sigma_prod[gi]));
            gf_mul u_gf_mul_b(.in1(Su), .in2(b_even_in[gi]), .prod(syn_b_prod[gi]));

            assign delta_init_out[gi] = syn_sigma_prod[gi] ^ delta_even_in[gi];
            assign theta_init_out[gi] = syn_b_prod[gi] ^ theta_even_in[gi];
        end 
    endgenerate

endmodule