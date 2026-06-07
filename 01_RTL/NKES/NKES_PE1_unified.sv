module NKES_PE1_unified(
    input       clk,
    input       rst,
    input       start,
    input       hold,
    input       mode,
    
    input [5:0] gamma,
    input [5:0] discrepancy,
    input       branch,

    input [5:0] delta_init,
    input [5:0] theta_init,
    input [5:0] delta_poly_in,
    input [5:0] nested_delta_poly_in,

    input [5:0] sigma_even, sigma_odd,
    input [5:0] b_even, b_odd,

    output [5:0] delta_poly_pre_out,
    output [5:0] delta_poly_out,
    output [5:0] theta_poly_out,
    output [5:0] delta_delay_out,
    output [5:0] theta_delay_out
);

reg [5:0] delta_poly, delta_poly_next, theta_poly, theta_poly_next;
reg [5:0] delta_delay, delta_delay_next, theta_delay, theta_delay_next;
wire [5:0] gfmul0_out, gfmul1_out;

gf_mul u_gfmul0(.in1(gamma), .in2(mode ? delta_delay : delta_poly_in), .prod(gfmul0_out));
gf_mul u_gfmul1(.in1(discrepancy), .in2(mode ? theta_delay : theta_poly), .prod(gfmul1_out));

assign delta_poly_pre_out = delta_poly_next;
assign delta_poly_out = delta_poly;
assign theta_poly_out = theta_poly;
assign delta_delay_out = delta_delay;
assign theta_delay_out = theta_delay;

always @(*) begin
    if (start) begin
        delta_delay_next = delta_init;
        theta_delay_next = theta_init;
    end
    else if (hold) begin
        delta_delay_next = delta_delay;
        theta_delay_next = theta_delay;  
    end
    else begin
        delta_delay_next = nested_delta_poly_in ^ sigma_even ^ sigma_odd; 
        theta_delay_next = theta_poly ^ b_even ^ b_odd;
    end

    if (start & ~mode) begin
        delta_poly_next = delta_init;
        theta_poly_next = theta_init;
    end 
    else if (hold) begin
        delta_poly_next = delta_poly;
        theta_poly_next = theta_poly;  
    end
    else begin
        delta_poly_next = gfmul0_out ^ gfmul1_out;
        theta_poly_next = (branch)? (mode ? delta_delay : delta_poly_in) : (mode ? theta_delay : theta_poly);  
    end        
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        delta_poly  <= 0;
        theta_poly  <= 0;
        delta_delay <= 0;
        theta_delay <= 0;
    end

    else begin
        delta_poly  <= delta_poly_next;
        theta_poly  <= theta_poly_next;
        delta_delay <= delta_delay_next;
        theta_delay <= theta_delay_next;
    end
end  
endmodule