module NKES(
    input clk,
    input rst,

    input syn_rdy,  // high order syndrome ready
    input [5:0] HO_syn[1:0],

    // from low order riBM
    input Lstate_rdy, LKES_fail,
    input cdone, cfail,
    input [5:0] Lsigma [3:0],
    input [5:0] Lb [3:0],
    input [5:0] Ldelta_even [1:0], // delta_even[0] = d0, delta_even[1] = d2
    input [5:0] Ltheta_even [1:0], // theta_even[0] = t0, theta_even[1] = t2
    input [5:0] Lgamma,
    input [1:0] Lk,

    // high order control
    input ncget, ncdone, ncfail,
    input fail_num,
    input nsu_stage_flag,

    output sigma_done,
    output [5:0] sigma[6:0]
);
wire write_en, write_idx, read_idx;
wire write_syn_en, write_syn_idx, read_syn_idx;
wire [5:0] syn_buff_out;

wire [5:0] Lsigma_out [3:0], Lb_out [3:0], Ldelta_even_out [1:0], Ltheta_even_out [1:0], Lgamma_out;
wire [1:0] Lk_out;

wire start, hold;
wire [5:0] delta_even_in[2:0], theta_even_in[2:0], sigma_even_in[2:0], b_even_in[2:0];
wire [5:0] delta_init[2:0], theta_init[2:0], delta_init_out[2:0], theta_init_out[2:0];

wire [5:0] sigma_init[7:0], b_init[7:0];
wire [5:0] delta_poly[3:0], theta_poly[3:0];
wire [5:0] delta_delay_out[3:0], theta_delay_out[3:0];
wire [5:0] sigma_even[3:0], sigma_odd[3:0], b_even[2:0], b_odd[2:0];
wire [5:0] b_poly_out[7:0];
wire [5:0] sigma_delay_out[7:0], b_delay_out[7:0];
wire [5:0] Hsyn_odd, Hsyn_even;
wire last_iter, store_from_PE, fail_init;
wire re_init;

wire [5:0] gamma_out, discrepancy_out;
wire branch_out;

// retime registers for PE1 array
wire [5:0] gamma_init;
wire [1:0] k_init;
reg [5:0] gamma_time, gamma_time_next, dis_time, dis_time_next;
reg branch_time, branch_time_next;

assign Hsyn_even = (last_iter)? 6'b0: HO_syn[0]; 
assign Hsyn_odd = syn_buff_out;

// =========== retime registers =============
always @(posedge clk or posedge rst) begin
    if (rst) begin
        gamma_time <= 6'b0;
        dis_time <= 6'b0;
        branch_time <= 0;
    end
    else begin
        gamma_time <= gamma_time_next;
        dis_time <= dis_time_next;
        branch_time <= branch_time_next;
    end
end

always @(*) begin 
    if (start) begin
        gamma_time_next = 6'b1;
        dis_time_next = 6'b0;
        branch_time_next = 1'b0;
    end
    else if (hold) begin
        gamma_time_next = gamma_time;
        dis_time_next = dis_time;
        branch_time_next = branch_time; 
    end
    else begin
        gamma_time_next = gamma_out;
        dis_time_next = discrepancy_out;
        branch_time_next = branch_out;        
    end
end

// ==========================================

// todo: ignore second round nested decoding for now 
genvar gi;
generate
    // to precompute unit
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign delta_even_in[gi] = (fail_init)? delta_delay_out[gi] : Ldelta_even_out[gi];
        assign theta_even_in[gi] = (fail_init)? theta_delay_out[gi] : Ltheta_even_out[gi];
        assign sigma_even_in[gi] = (fail_init)? sigma_delay_out[gi*2] : Lsigma_out[gi*2];
        assign b_even_in[gi]     = (fail_init)? b_delay_out[gi*2] : Lb_out[gi*2]; 
    end
        assign delta_even_in[2] = (fail_init)? delta_delay_out[2] : 6'd0;
        assign theta_even_in[2] = (fail_init)? theta_delay_out[2] : 6'd0;
        assign sigma_even_in[2] = (fail_init)? sigma_delay_out[4] : 6'd0;
        assign b_even_in[2]     = (fail_init)? b_delay_out[4] : 6'd0;

    // sigma, b init
    for (gi=0; gi < 4; gi = gi + 1) begin
        assign sigma_init[gi] = (store_from_PE)? sigma[gi] : Lsigma_out[gi];
        assign b_init[gi] = (store_from_PE)? b_poly_out[gi] : Lb_out[gi];
    end
    for (gi=4; gi < 6; gi = gi + 1) begin
        assign sigma_init[gi] = (store_from_PE)? sigma[gi] : 6'd0;
        assign b_init[gi] = (store_from_PE)? b_poly_out[gi] : 6'd0;
    end
    for (gi=6; gi < 8; gi = gi + 1) begin
        assign sigma_init[gi] = 6'd0;
        assign b_init[gi] = 6'd0;
    end

    // delta, theta init
    for (gi=0 ; gi<3 ; gi = gi + 1) begin
        assign delta_init[gi] = (store_from_PE)? delta_poly[gi] : delta_init_out[gi];
        assign theta_init[gi] = (store_from_PE)? theta_poly[gi] : theta_init_out[gi];
    end
endgenerate


assign gamma_init = Lgamma_out;
assign k_init = Lk_out;

precompute_unit u_PU(
    .delta_even_in(delta_even_in),
    .theta_even_in(theta_even_in),
    .sigma_even_in(sigma_even_in),
    .b_even_in(b_even_in),
    .Su(HO_syn[0]),

    .delta_init_out(delta_init_out),
    .theta_init_out(theta_init_out)
);

NKES_ctrl u_ctrl(
    .clk(clk),
    .rst(rst),
    .syn_rdy(syn_rdy),

    .read_idx(read_idx),

    .write_syn_en(write_syn_en),
    .write_syn_idx(write_syn_idx),
    .read_syn_idx(read_syn_idx),

    .ncget(ncget), .ncdone(ncdone), .ncfail(ncfail),
    .fail_num(fail_num),
    .nsu_stage_flag(nsu_stage_flag),

    .discrepancy_in(delta_poly[0]),
    .Lgamma_init(gamma_init),
    .Lk_init(k_init),
    .gamma_out(gamma_out),
    .discrepancy_out(discrepancy_out),
    .branch_out(branch_out),
    .store_from_PE(store_from_PE),
    .fail_init(fail_init),

    .last_iter(last_iter),
    .start(start),
    .hold(hold),

    .sigma_done(sigma_done)
);

state_buff u_state_buff(
    .clk(clk),
    .rst(rst),

    .Lstate_rdy(Lstate_rdy),
    .LKES_fail(LKES_fail),
    .cdone(cdone), .cfail(cfail),
    .read_idx(read_idx),

    .Lsigma_in(Lsigma),
    .Lb_in(Lb),
    .Ldelta_even_in(Ldelta_even),
    .Ltheta_even_in(Ltheta_even),
    .Lgamma_in(Lgamma),
    .Lk_in(Lk),

    .Lsigma_out(Lsigma_out),
    .Lb_out(Lb_out),
    .Ldelta_even_out(Ldelta_even_out),
    .Ltheta_even_out(Ltheta_even_out),
    .Lgamma_out(Lgamma_out),
    .Lk_out(Lk_out)
);

syndrome_buff u_syn_buff(
    .clk(clk),
    .rst(rst),
    .write_en(write_syn_en),
    .write_idx(write_syn_idx),
    .syn_in(HO_syn[1]),

    .read_idx(read_syn_idx),
    .syn_out(syn_buff_out)
);

// ============ PE1 array ====================
NKES_PE1 u_PE10(.clk(clk), .rst(rst), .start(start || fail_init), .hold(hold), .gamma(gamma_time), .discrepancy(dis_time), .branch(branch_time),
    .delta_init(delta_init[0]),
    .theta_init(theta_init[0]),
    .delta_poly_in(delta_poly[1]),

    .sigma_even(sigma_even[0]), .sigma_odd(sigma_odd[0]),
    .b_even(6'b0), .b_odd(6'b0),

    .delta_poly_out(delta_poly[0]),
    .theta_poly_out(theta_poly[0]),
    .delta_delay_out(delta_delay_out[0]),
    .theta_delay_out(theta_delay_out[0])
);

NKES_PE1 u_PE11(.clk(clk), .rst(rst), .start(start || fail_init) , .hold(hold), .gamma(gamma_time), .discrepancy(dis_time), .branch(branch_time),
    .delta_init(delta_init[1]),
    .theta_init(theta_init[1]),
    .delta_poly_in(delta_poly[2]),

    .sigma_even(sigma_even[1]), .sigma_odd(sigma_odd[1]),
    .b_even(b_even[0]), .b_odd(b_odd[0]),

    .delta_poly_out(delta_poly[1]),
    .theta_poly_out(theta_poly[1]),
    .delta_delay_out(delta_delay_out[1]),
    .theta_delay_out(theta_delay_out[1])
);

NKES_PE1 u_PE12(.clk(clk), .rst(rst), .start(start || fail_init), .hold(hold), .gamma(gamma_time), .discrepancy(dis_time), .branch(branch_time),
    .delta_init(delta_init[2]),
    .theta_init(theta_init[2]),
    .delta_poly_in(delta_poly[3]),

    .sigma_even(sigma_even[2]), .sigma_odd(sigma_odd[2]),
    .b_even(b_even[1]), .b_odd(b_odd[1]),

    .delta_poly_out(delta_poly[2]),
    .theta_poly_out(theta_poly[2]),
    .delta_delay_out(delta_delay_out[2]),
    .theta_delay_out(theta_delay_out[2])
);

NKES_PE1 u_PE13(.clk(clk), .rst(rst), .start(start || fail_init), .hold(hold), .gamma(gamma_time), .discrepancy(dis_time), .branch(branch_time),
    .delta_init(6'b0),
    .theta_init(6'b0),
    .delta_poly_in(6'b0),

    .sigma_even(sigma_even[3]), .sigma_odd(sigma_odd[3]),
    .b_even(b_even[2]), .b_odd(b_odd[2]),

    .delta_poly_out(delta_poly[3]),
    .theta_poly_out(theta_poly[3]),
    .delta_delay_out(delta_delay_out[3]),
    .theta_delay_out(theta_delay_out[3])
);
// =========================================

// ============ PE0 array ====================
NKES_PE0 u_PE00(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_even),
    .b_poly_in(6'b0),
    .sigma_init(sigma_init[0]),
    .b_init(b_init[0]),

    .sigma_syn(sigma_even[0]),
    .b_syn(b_even[0]),
    .b_poly_out(b_poly_out[0]),
    .sigma_poly_out(sigma[0]),
    .sigma_delay_out(sigma_delay_out[0]),
    .b_delay_out(b_delay_out[0])
);
NKES_PE0 u_PE02(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[0]),
    .sigma_init(sigma_init[2]),
    .b_init(b_init[2]),

    .sigma_syn(sigma_even[1]),
    .b_syn(b_even[1]),
    .b_poly_out(b_poly_out[2]),
    .sigma_poly_out(sigma[2]),
    .sigma_delay_out(sigma_delay_out[2]),
    .b_delay_out(b_delay_out[2])
);
NKES_PE0 u_PE04(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[2]),
    .sigma_init(sigma_init[4]),
    .b_init(b_init[4]),

    .sigma_syn(sigma_even[2]),
    .b_syn(b_even[2]),
    .b_poly_out(b_poly_out[4]),
    .sigma_poly_out(sigma[4]),
    .sigma_delay_out(sigma_delay_out[4]),
    .b_delay_out(b_delay_out[4])
);
NKES_PE0 u_PE06(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_even),
    .b_poly_in(b_poly_out[4]),
    .sigma_init(sigma_init[6]),
    .b_init(b_init[6]),

    .sigma_syn(sigma_even[3]),
    .b_syn(),
    .b_poly_out(),
    .sigma_poly_out(sigma[6]),
    .sigma_delay_out(sigma_delay_out[6]),
    .b_delay_out(b_delay_out[6])
);

NKES_PE0 u_PE01(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_odd),
    .b_poly_in(6'b0),
    .sigma_init(sigma_init[1]),
    .b_init(b_init[1]),

    .sigma_syn(sigma_odd[0]),
    .b_syn(b_odd[0]),
    .b_poly_out(b_poly_out[1]),
    .sigma_poly_out(sigma[1]),
    .sigma_delay_out(sigma_delay_out[1]),
    .b_delay_out(b_delay_out[1])
);
NKES_PE0 u_PE03(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[1]),
    .sigma_init(sigma_init[3]),
    .b_init(b_init[3]),

    .sigma_syn(sigma_odd[1]),
    .b_syn(b_odd[1]),
    .b_poly_out(b_poly_out[3]),
    .sigma_poly_out(sigma[3]),
    .sigma_delay_out(sigma_delay_out[3]),
    .b_delay_out(b_delay_out[3])
);
NKES_PE0 u_PE05(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[3]),
    .sigma_init(sigma_init[5]),
    .b_init(b_init[5]),

    .sigma_syn(sigma_odd[2]),
    .b_syn(b_odd[2]),
    .b_poly_out(b_poly_out[5]),
    .sigma_poly_out(sigma[5]),
    .sigma_delay_out(sigma_delay_out[5]),
    .b_delay_out(b_delay_out[5])
);
NKES_PE0 u_PE07(.clk(clk), .rst(rst), .start(start), .hold(hold), .gamma(gamma_out), .discrepancy(discrepancy_out), .branch(branch_out),
    .H_syn(Hsyn_odd),
    .b_poly_in(b_poly_out[5]),
    .sigma_init(sigma_init[7]),
    .b_init(b_init[7]),

    .sigma_syn(sigma_odd[3]),
    .b_syn(),
    .b_poly_out(),
    .sigma_poly_out(),
    .sigma_delay_out(sigma_delay_out[7]),
    .b_delay_out(b_delay_out[7])
);
endmodule




module NKES_ctrl(
    input clk,
    input rst, 
    input syn_rdy,  // high order syndrome ready

    output read_idx, 

    output write_syn_en,
    output write_syn_idx,
    output read_syn_idx,

    input ncget, ncdone, ncfail,
    input fail_num,
    input nsu_stage_flag,

    input [5:0] discrepancy_in,
    input [5:0] Lgamma_init,
    input [1:0] Lk_init,
    output [5:0] gamma_out,
    output [5:0] discrepancy_out,
    output branch_out,
    output store_from_PE,
    output fail_init,

    output last_iter,
    output start,
    output hold,

    // output re_init, // for second round delta and theta init
    output sigma_done
);

    // parameter S_STORE0  = 4'd0;
    // parameter S_STORE1  = 4'd1;
    // parameter S_CHECK0  = 4'd2;
    // parameter S_CHECK1  = 4'd3;
    // parameter S_FULL    = 4'd4;

    parameter S_INIT0   = 4'd0;
    parameter S_INIT1   = 4'd1; 
    parameter S_CYC00   = 4'd2;
    parameter S_CYC01   = 4'd3;
    parameter S_CYC10   = 4'd4;
    parameter S_CYC11   = 4'd5;
    parameter S_WAIT1   = 4'd6;
    parameter S_CHECK1  = 4'd7;
    parameter S_FAIL1   = 4'd8;
    parameter S_WAIT2   = 4'd9;
    parameter S_CHECK2  = 4'd10;
    parameter S_CHECK3  = 4'd11;
    parameter S_FINIT   = 4'd12;


    reg [3:0] state, state_next;
    reg [5:0] gamma, gamma_next, gamma_delay, gamma_delay_next;
    reg signed [3:0] k, k_next, k_delay, k_delay_next; 
    wire [3:0] k_init;
    wire [5:0] gamma_init;
    wire init;

    assign read_idx = (state == S_INIT1);

    // assign re_init = (state == S_FINIT) && syn_rdy;
    assign init = ((state == S_INIT0) && syn_rdy) || (state == S_INIT1) 
    || ((state == S_WAIT1 || state == S_WAIT2) && ncget);
    assign write_syn_en = (((state == S_INIT0 || state == S_FINIT) && syn_rdy) || state == S_INIT1|| state == S_CYC00 || state == S_CYC01);
    assign write_syn_idx = (state == S_INIT1 || state == S_CYC01);
    assign read_syn_idx = (state == S_CYC11 || state == S_CYC01);
    assign last_iter = (state == S_CYC10 || state == S_CYC11);

    assign store_from_PE = (state == S_WAIT1) || (state == S_WAIT2);
    assign fail_init = (state == S_FINIT) && syn_rdy;

    assign start = init;
    assign hold = ((state == S_WAIT1 || state == S_WAIT2) && !ncget) 
    || (state == S_CHECK1 || state == S_CHECK2 || state == S_CHECK3 || state == S_FAIL1 || state == S_FINIT); 
    assign gamma_out = gamma;
    assign discrepancy_out = discrepancy_in;
    assign branch_out = |discrepancy_in && ($signed(k) <= $signed(2'd0));
    assign sigma_done = (state == S_WAIT1) || (state >= 4'd8 && state <= 4'd9 && fail_num == 1'b1); 

    assign k_init = (store_from_PE)? k : {{2{Lk_init[1]}}, Lk_init};
    assign gamma_init = (store_from_PE)? gamma : Lgamma_init;

    // k reg
    always @(*) begin
        if (start) begin
            k_delay_next = k_init; // sign extend 
       end
        else if (hold) begin
            k_delay_next = k_delay;
        end
        else begin
            k_delay_next = (branch_out)? -k : k - 1'b1; 
        end

        if (hold) k_next = k;
        else k_next = k_delay;
    end

    // gamma
    always @(*) begin        
        if (start) begin
            gamma_delay_next = gamma_init;
        end
        else if (hold) begin
            gamma_delay_next = gamma_delay;
        end
        else begin
            gamma_delay_next = (branch_out)? discrepancy_in : gamma; 
        end

        if (hold) gamma_next = gamma;
        else gamma_next = gamma_delay;
    end

    // FSM
    always @(*) begin
        case(state) 
        S_INIT0: state_next = (syn_rdy)? S_INIT1 : state;
        S_INIT1: state_next = S_CYC00;
        S_CYC00: state_next = S_CYC01;
        S_CYC01: state_next = S_CYC10;
        S_CYC10: state_next = S_CYC11;
        S_CYC11: state_next = S_WAIT1;
        S_WAIT1: state_next = (ncget)? S_CHECK1 : S_WAIT1;
        S_CHECK1: begin
            state_next = state;
            if (ncdone) begin
                case({fail_num, ncfail}) // synopsys parallel_case full_case
                2'b00: state_next = S_INIT0;
                2'b01: state_next = (nsu_stage_flag)? S_INIT0 : S_FINIT;
                2'b10: state_next = S_WAIT2;
                2'b11: state_next = S_FAIL1;
                endcase 
            end
        end
        S_FAIL1: state_next = (ncget)? S_CHECK3 : state;
        S_WAIT2: state_next = (ncget)? S_CHECK2 : state;
        S_CHECK2: state_next = (ncdone)? ((ncfail)? S_FINIT : S_INIT0) : state;
        S_CHECK3: state_next = (ncdone)? ((ncfail)? S_INIT0 : S_FINIT): state;
        S_FINIT: state_next = (syn_rdy)? S_INIT1 : state;
        default: state_next = state;
        endcase 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_INIT0;
            gamma       <= 6'b0;
            gamma_delay <= 6'b0;
            k           <= 4'b0;
            k_delay     <= 4'b0;
        end
        else begin
            state       <= state_next;
            gamma       <= gamma_next;
            gamma_delay <= gamma_delay_next;
            k           <= k_next;
            k_delay     <= k_delay_next;
        end
    end
endmodule

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

module syndrome_buff(
    input clk,
    input rst,

    input write_en,
    input write_idx,
    input [5:0] syn_in,

    input read_idx,
    output [5:0] syn_out
);

    reg [5:0] syn_buff[1:0], syn_buff_next[1:0];

    assign syn_out = syn_buff[read_idx];

    always @(*) begin
        if (write_en) begin
            syn_buff_next[0] = (write_idx == 1'b0)? syn_in : syn_buff[0];
            syn_buff_next[1] = (write_idx == 1'b1)? syn_in : syn_buff[1];
        end
        else begin
            syn_buff_next[0] = syn_buff[0];
            syn_buff_next[1] = syn_buff[1];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            syn_buff[0] <= 6'b0;
            syn_buff[1] <= 6'b0;
        end
        else begin
            syn_buff[0] <= syn_buff_next[0];
            syn_buff[1] <= syn_buff_next[1];
        end
    end

endmodule