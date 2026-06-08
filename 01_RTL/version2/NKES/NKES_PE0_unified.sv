module NKES_PE0_unified(
    input       clk,
    input       rst,
    input       start,
    input       hold,
    input       mode,
    input       mode_init,

    input [5:0] gamma,
    input [5:0] discrepancy,
    input       branch,

    input [5:0] H_syn,
    input [5:0] b_poly_in,
    input [5:0] sigma_init,
    input [5:0] b_init,
    
    output [5:0] sigma_syn, // sigma * syndrome
    output [5:0] b_syn,     // b * syndrome
    output [5:0] sigma_poly_out,
    output [5:0] b_poly_out,
    output [5:0] sigma_delay_out,
    output [5:0] b_delay_out
);

reg [5:0] b_poly, b_poly_next, sigma_poly, sigma_poly_next;
reg [5:0] b_delay, b_delay_next, sigma_delay, sigma_delay_next;

wire [5:0] gfmul0_out, gfmul1_out;
wire [5:0] sigma_tmp, b_tmp;

assign sigma_poly_out = sigma_poly;
assign b_poly_out = b_poly;
assign sigma_delay_out = sigma_delay;
assign b_delay_out = b_delay;

assign sigma_tmp = gfmul0_out ^ gfmul1_out;
assign b_tmp = branch ? sigma_poly : b_poly_in;

gf_mul u_gfmul0(.in1(gamma), .in2(sigma_poly), .prod(gfmul0_out));
gf_mul u_gfmul1(.in1(b_poly_in), .in2(discrepancy), .prod(gfmul1_out));

gf_mul u_gfmul2(.in1(sigma_poly), .in2(H_syn), .prod(sigma_syn));
gf_mul u_gfmul3(.in1(b_poly), .in2(H_syn), .prod(b_syn));

always @(*) begin
    if (start) begin
        sigma_delay_next = sigma_init;
        b_delay_next = b_init;
    end
    else if (hold) begin
        sigma_delay_next = sigma_delay;
        b_delay_next = b_delay;
    end
    else begin
        sigma_delay_next = sigma_tmp;
        b_delay_next = b_tmp; 
    end
    
    if (start & ~mode_init) begin
        sigma_poly_next = sigma_init;
        b_poly_next = b_init;
    end
    else if (hold) begin
        sigma_poly_next = sigma_poly;
        b_poly_next = b_poly; 
    end
    else begin
        sigma_poly_next = mode ? sigma_delay : sigma_tmp;
        b_poly_next = mode ? b_delay : b_tmp;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        b_poly      <= 0;
        b_delay     <= 0;
        sigma_poly  <= 0;
        sigma_delay <= 0;
    end
    else begin
        b_poly      <= b_poly_next;
        b_delay     <= b_delay_next;
        sigma_poly  <= sigma_poly_next; 
        sigma_delay <= sigma_delay_next;
    end
end

endmodule