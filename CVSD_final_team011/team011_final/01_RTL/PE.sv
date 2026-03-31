module PE(
    input clk,
    input rstn,
    input [1:0] code,
    input [9:0] delta_init,
    input [9:0] theta_init,

    input c0, c1,
    input start,
    input hold,

    input [9:0] delta_in,
    input [9:0] gamma,
    input [9:0] discrepancy,
 
    output reg [9:0] delta
);
    reg [9:0] delta_next, theta, theta_next;
    wire [9:0] mul0_out, mul1_out;

    gf_mul_1_1 u_gfmul0(.code(code), .in1(delta_in), .in2(gamma), .out1(mul0_out));
    gf_mul_1_1 u_gfmul1(.code(code), .in1(discrepancy), .in2(theta), .out1(mul1_out));

    always @(*) begin
        if (start) begin
            delta_next = delta_init;
            theta_next = theta_init;
        end
        else if (hold) begin
            delta_next = delta;
            theta_next = theta;
        end
        else begin
            delta_next = mul0_out ^ mul1_out;
            theta_next = (c1)? 0 : ((c0)? delta_in : theta);
        end
    end
    
    always @(posedge clk) begin
        if (!rstn) begin
            delta   <= 0;
            theta   <= 0;
        end
        else begin
            delta   <= delta_next;
            theta   <= theta_next;
        end
    end
endmodule