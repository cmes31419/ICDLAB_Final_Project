module BM(
    input clk,
    input rst,
    input syndrome_rdy,

    input [5:0] LO_syndrome[3:0],

    output sigma_done,
    output [5:0] sigma[2:0]
);


wire [5:0] b_poly0;
wire [5:0] gamma, discrepancy;
wire branch, first_iter;
wire start, hold;

// ============ Control ===============
BM_control bm_ctrl( .clk(clk), .rst(rst), .syndrome_rdy(syndrome_rdy), .discrepancy(discrepancy),
    .start(start), .hold(hold),
    .gamma(gamma),
    .first_iter(first_iter), .branch(branch), .sigma_done(sigma_done)
);


// ============ PE0 array ==============
BM_PE0 u_PE00(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b1),
    .b_poly_in(6'b0),

    .b_poly_out(b_poly0),
    .sigma_poly_out(sigma[0])
);

BM_PE0 u_PE01(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b0),
    .b_poly_in(first_iter? 6'b1 : 6'b0),

    .b_poly_out(),
    .sigma_poly_out(sigma[1])
);

BM_PE0 u_PE02(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .sigma_init(6'b0),
    .b_poly_in(b_poly0),

    .b_poly_out(),
    .sigma_poly_out(sigma[2])
);

wire [5:0] delta_poly2, delta_poly3;

// ============ PE1 array ==============
BM_PE1 u_PE10(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[0]),
    .theta_init(LO_syndrome[1]),
    .delta_poly_in(delta_poly2),

    .delta_poly_out(discrepancy)
);

BM_PE1 u_PE11(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[1]),
    .theta_init(LO_syndrome[2]),
    .delta_poly_in(delta_poly3),

    .delta_poly_out()
);

BM_PE1 u_PE12(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[2]),
    .theta_init(LO_syndrome[3]),
    .delta_poly_in(6'b0),

    .delta_poly_out(delta_poly2)
);

BM_PE1 u_PE13(.clk(clk), .rst(rst), .gamma(gamma), .discrepancy(discrepancy), .branch(branch),
    .start(start), .hold(hold),
    .delta_init(LO_syndrome[3]),
    .theta_init(6'b0),
    .delta_poly_in(6'b0),

    .delta_poly_out(delta_poly3)
);

endmodule

module BM_control(
    input clk,
    input rst,
    input syndrome_rdy,
    input [5:0] discrepancy,

    output start,
    output hold,
    output reg [5:0] gamma,
    output first_iter,
    output branch,
    output sigma_done
);

localparam S_IDLE = 2'd0;
localparam S_ITER0 = 2'd1;
localparam S_ITER1 = 2'd2;
localparam S_DONE = 2'd3;

reg [1:0] state, state_next;
reg [1:0] k, k_next;
reg [5:0] gamma_next;

assign branch = |discrepancy && (k != 2'd0);
assign first_iter = (state == S_ITER0);
assign sigma_done = (state == S_DONE);
assign start = syndrome_rdy;
assign hold = (state == S_DONE || state == S_IDLE)&& !syndrome_rdy;

always @(*) begin
    if (syndrome_rdy) begin
        k_next = 2'd1;
    end
    else begin
        case(k) // synopsys parallel_case
        2'd1: k_next = (branch)? k : 2'd2;
        2'd2: k_next = (branch)? 2'd0 : 2'd3;
        default: k_next = k;
        endcase
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
    S_DONE: state_next = S_IDLE;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= S_IDLE;
        k       <= 2'd1;
        gamma   <= 6'b0;
    end
    else begin
        state   <= state_next;
        k       <= k_next;
        gamma   <= gamma_next;
    end
end

endmodule
