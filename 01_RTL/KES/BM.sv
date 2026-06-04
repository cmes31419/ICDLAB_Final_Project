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


wire [5:0] b_poly0;
wire [5:0] gamma, discrepancy;
wire branch, first_iter;
wire start, hold;
wire [5:0] delta_poly2, delta_poly3;

assign delta_even_out[0] = discrepancy;
assign delta_even_out[1] = delta_poly2;
assign gamma_out = gamma;
assign sigma_fail = sigma_done && (|sigma_out[3]);

// ============ Control ===============
BM_control bm_ctrl( .clk(clk), .rst(rst), .syndrome_rdy(syndrome_rdy), .discrepancy(discrepancy),
    .start(start), .hold(hold),
    .gamma(gamma), .k_out(k_out),
    .cget(cget),
    .first_iter(first_iter), .branch(branch), .sigma_done(sigma_done)
);


// ============ PE0 array ==============
BM_PE0 u_PE00(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b1),
    .b_poly_in(6'b0),

    .b_poly_out(b_out[0]),
    .sigma_poly_out(sigma_out[0])
);

BM_PE0 u_PE01(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b0),
    .b_poly_in(first_iter? 6'b1 : 6'b0),

    .b_poly_out(b_out[1]),
    .sigma_poly_out(sigma_out[1])
);

BM_PE0 u_PE02(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b0),
    .b_poly_in(b_out[0]),

    .b_poly_out(b_out[2]),
    .sigma_poly_out(sigma_out[2])
);

BM_PE0 u_PE03(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b0),
    .b_poly_in(b_out[1]),

    .b_poly_out(b_out[3]),
    .sigma_poly_out(sigma_out[3])
);


// ============ PE1 array ==============
BM_PE1 u_PE10(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[0]),
    .theta_init(LO_syndrome[1]),
    .delta_poly_in(delta_poly2),

    .delta_poly_out(discrepancy),
    .theta_poly_out(theta_even_out[0])
);

// BM_PE1 u_PE11(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
//     .start(start), .hold(hold),
//     .delta_init(LO_syndrome[1]),
//     .theta_init(LO_syndrome[2]),
//     .delta_poly_in(delta_poly3),

//     .delta_poly_out()
// );

BM_PE1 u_PE12(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[2]),
    .theta_init(LO_syndrome[3]),
    .delta_poly_in(6'b0),

    .delta_poly_out(delta_poly2),
    .theta_poly_out(theta_even_out[1])

);

// BM_PE1 u_PE13(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
//     .start(start), .hold(hold),
//     .delta_init(LO_syndrome[3]),
//     .theta_init(6'b0),
//     .delta_poly_in(6'b0),

//     .delta_poly_out(delta_poly3)
// );

endmodule

module BM_control(
    input clk,
    input rst,
    input syndrome_rdy,
    input [5:0] discrepancy,
    input cget,

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
reg signed [1:0] k, k_next;
reg [5:0] gamma_next;

assign branch = |discrepancy && (k <= 2'd0);
assign first_iter = (state == S_ITER0);
assign sigma_done = (state == S_DONE);
assign start = syndrome_rdy;
assign hold = (state == S_DONE || state == S_IDLE)&& !syndrome_rdy;
assign k_out = k;

always @(*) begin
    if (syndrome_rdy) begin
        k_next = 2'd0;
    end
    else begin
        k_next = (branch)? -k : k - 1'b1; 
    end

    if (syndrome_rdy) begin
        gamma_next = 6'b1;
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
    S_DONE: state_next = (cget)? S_IDLE : state;
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
