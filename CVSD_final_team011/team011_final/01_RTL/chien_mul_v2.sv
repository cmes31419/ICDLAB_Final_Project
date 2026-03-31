module chien_mul(
    input                           clk,
    input                           rstn,
	input [1:0]                     code,
    input                           ready,
    input                           stall,
    input [9:0]                     sigma0,
    input [9:0]                     sigma1,
    input [9:0]                     sigma2,
    input [9:0]                     sigma3,
    input [9:0]                     sigma4,
    output reg [`PARALLEL_NUM-1:0]  zero_sum
);

    // wire [9:0]                  sigma_E[`PARALLEL_NUM-1:0];
    wire [9:0]                  sigma_E[`PARALLEL_NUM+1:0];
    wire [9:0]                  sigma_EB[`PARALLEL_NUM-1:0];

    reg [`PARALLEL_NUM-1:0]     zero_sum_next;

    integer i;

    always @(*) begin
        for (i=0;i<`PARALLEL_NUM;i=i+1) begin
            if (stall) zero_sum_next[i] = zero_sum[i];
            else if (ready) zero_sum_next[i] = ~(|sigma_EB[i]);
            else zero_sum_next[i] = 0;
        end
    end

    sigmaE se0(
        .code(code),
        .sigma0(sigma0),
        .sigma1(sigma1),
        .sigma2(sigma2),
        .sigma3(sigma3),
        .sigma4(sigma4),
        .y(sigma_E)
    );

    sigmaEB seb0(
        .code(code),
        .sigmaE(sigma_E),
        .y(sigma_EB)
    );

    always @(posedge clk) begin
        if (~rstn) begin
            zero_sum    <= 0;
        end
        else begin
            zero_sum    <= zero_sum_next;
        end
    end

endmodule