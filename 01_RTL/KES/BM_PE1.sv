module BM_PE1(
    input clk,
    input rst,
    input syndrome_rdy,
    
    input [5:0] gamma,
    input [5:0] discrepancy,
    input branch,

    input [5:0] delta_init,
    input [5:0] theta_init,
    input [5:0] delta_poly_in,

    output [5:0] delta_poly_out
);

reg [5:0] delta_poly, delta_poly_next, theta_poly, theta_poly_next;
wire [5:0] gfmul0_out, gfmul1_out;

assign delta_poly_out = delta_poly;

gf_mul u_gfmul0(.in1(gamma), .in2(delta_poly_in), .prod(gfmul0_out));
gf_mul u_gfmul1(.in1(theta_poly), .in2(discrepancy), .prod(gfmul1_out));


always @(*) begin
    if (syndrome_rdy) begin
        delta_poly_next = delta_init;
        theta_poly_next = theta_init;
    end
    else begin
        delta_poly_next = gfmul0_out ^ gfmul1_out;
        theta_poly_next = (branch)? delta_poly_in : theta_poly;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        delta_poly  <= 0;
        theta_poly  <= 0;
    end

    else begin
        delta_poly  <= delta_poly_next;
        theta_poly  <= theta_poly_next;
    end
end

endmodule