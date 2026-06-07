module BM(
    input clk,
    input rst,
    input syndrome_rdy,

    input [5:0] LO_syndrome[3:0],
    input cget,

    output sigma_done,
    output sigma_fail,
    output [5:0] sigma_out[3:0],
    output [5:0] b_out[3:0],
    output [5:0] delta_even_out[1:0],
    output [5:0] theta_even_out[1:0],
    output [5:0] gamma_out,
    output [1:0] k_out
);

wire [5:0] gamma, discrepancy;
wire       branch, first_iter;
wire       start, hold;

wire [5:0] sigma_init[3:0], b_init[3:0];
wire [5:0] delta_init[1:0], theta_init[1:0];

genvar gi;

generate
    assign sigma_init[0] = 6'b1;
    assign b_init[0] = 6'b0;
    for (gi = 1; gi < 4; gi = gi + 1) begin
        assign sigma_init[gi] = 6'b0;
        assign b_init[gi] = 6'b0;
    end
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign delta_init[gi] = LO_syndrome[gi * 2];
        assign theta_init[gi] = LO_syndrome[gi * 2 + 1];
    end
endgenerate

assign discrepancy = delta_even_out[0];
assign gamma_out = gamma;
assign sigma_fail = sigma_done && (|sigma_out[3]);

// ============ Control ===============
BM_control bm_ctrl( .clk(clk), .rst(rst), .syndrome_rdy(syndrome_rdy), .discrepancy(discrepancy),
    .start(start), .hold(hold),
    .gamma(gamma), .k_out(k_out),
    .cget(cget), .sigma_fail(sigma_fail),
    .first_iter(first_iter), .branch(branch), .sigma_done(sigma_done)
);

NKES_PE_array_new u_pe_arr_n(
    .clk(clk),
    .rst(rst),
    .start(start),
    .hold(hold),
    .first_iter(first_iter),
    .mode(1'b0),
    .pe_cnt(1'b0),

    .gamma_time(gamma),
    .dis_time(discrepancy),
    .branch_time(branch),
    .gamma_out(gamma),
    .dis_out(discrepancy),
    .branch_out(branch),

    .Hsyn_even(6'b0),
    .Hsyn_odd(6'b0), 

    .sigma_init(sigma_init),
    .b_init(b_init),
    .delta_init(delta_init),
    .theta_init(theta_init),

    .sigma_poly_out(sigma_out),
    .b_poly_out(b_out),
    .delta_poly_out(delta_even_out),
    .theta_poly_out(theta_even_out),
    
    .sigma_delay_out(),
    .b_delay_out(),
    .delta_delay_out(),
    .theta_delay_out()
);

endmodule

module BM_control(
    input clk,
    input rst,
    input syndrome_rdy,
    input [5:0] discrepancy,
    input cget,
    input sigma_fail,

    output start,
    output hold,
    output reg [5:0] gamma,
    output first_iter,
    output branch,
    output sigma_done,

    output [1:0] k_out
);

localparam S_IDLE = 2'd0;
localparam S_ITER0 = 2'd1;
localparam S_ITER1 = 2'd2;
localparam S_DONE = 2'd3;

reg [1:0] state, state_next;
reg [1:0] k, k_next;
reg [5:0] gamma_next;

assign branch = |discrepancy && ($signed(k) <= $signed(2'd0));
assign first_iter = (state == S_ITER0);
assign sigma_done = (state == S_DONE);
assign start = syndrome_rdy;
assign hold = (state == S_DONE || state == S_IDLE)&& !syndrome_rdy;
assign k_out = k;

always @(*) begin
    if (syndrome_rdy) begin
        k_next = 2'd0;
    end
    else if (hold) begin
        k_next = k;
    end
    else begin
        k_next = (branch)? -k : k - 1'b1; 
    end

    if (syndrome_rdy) begin
        gamma_next = 6'b1;
    end
    else if (hold) begin
        gamma_next = gamma;
    end
    else begin
        gamma_next = (branch)? discrepancy : gamma;
    end
end

always @(*) begin
    case(state) // synopsys parallel_case
    S_IDLE: state_next = (syndrome_rdy)? S_ITER0 : state;
    S_ITER0: state_next = S_ITER1;
    S_ITER1: state_next = S_DONE;
    S_DONE: state_next = (cget || sigma_fail)? S_IDLE : state;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= S_IDLE;
        k       <= 2'd0;
        gamma   <= 6'b0;
    end
    else begin
        state   <= state_next;
        k       <= k_next;
        gamma   <= gamma_next;
    end
end

endmodule
