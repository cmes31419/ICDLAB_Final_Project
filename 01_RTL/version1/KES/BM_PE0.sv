module BM_PE0(
    input clk,
    input rst,
    input start,
    input hold,
    
    input [5:0] gamma,
    input [5:0] discrepancy,
    input branch,

    input [5:0] sigma_init,
    input [5:0] b_poly_in,

    output [5:0] b_poly_out,
    output [5:0] sigma_poly_out
);


reg [5:0] b_poly, b_poly_next, sigma_poly, sigma_poly_next;
wire [5:0] gfmul0_out, gfmul1_out;


assign sigma_poly_out = sigma_poly;
assign b_poly_out = b_poly;

gf_mul u_gfmul0(.in1(gamma), .in2(sigma_poly), .prod(gfmul0_out));
gf_mul u_gfmul1(.in1(b_poly_in), .in2(discrepancy), .prod(gfmul1_out));


always @(*) begin
    if (start) begin
        sigma_poly_next = sigma_init;
        b_poly_next = 0;
    end
    else if (hold) begin
        sigma_poly_next = sigma_poly;
        b_poly_next = b_poly;
    end
    else begin
        sigma_poly_next = gfmul0_out ^ gfmul1_out;
        b_poly_next = (branch)? sigma_poly : b_poly_in;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        b_poly      <= 0;
        sigma_poly  <= 0;
    end

    else begin
        b_poly      <= b_poly_next;
        sigma_poly  <= sigma_poly_next;
    end
end

endmodule