module NKES(
    input clk,
    input rst,

    input syn_rdy,  // high order syndrome ready
    input [5:0] HO_syn[1:0],

    // from low order riBM
    input Lstate_rdy,
    input cdone, cfail,
    input [5:0] Lsigma [2:0],
    input [5:0] Lb [2:0],
    input [5:0] Ldelta_even [1:0], // delta_even[0] = d0, delta_even[1] = d2
    input [5:0] Ltheta_even [1:0], // theta_even[0] = t0, theta_even[1] = t2
    input [5:0] Lgamma,
    input [1:0] Lk,

    output sigma_done,
    output [5:0] sigma[6:0]
);
wire write_en, write_idx, read_idx;
wire write_syn_en, write_syn_idx, read_syn_idx;
wire [5:0] syn_buff_out;

wire [5:0] Lsigma_out [2:0], Lb_out [2:0], Ldelta_even_out [1:0], Ltheta_even_out [1:0], Lgamma_out;
wire [1:0] Lk_out;

wire [5:0] delta_even_in[2:0], theta_even_in[2:0], sigma_even_in[2:0], b_even_in[2:0];
wire [5:0] delta_init_out[2:0], theta_init_out[2:0];
// ignore second round nested decoding for now 
genvar gi;
generate
    for (gi = 0; gi < 2; gi = gi + 1) begin
        assign delta_even_in[gi] = Ldelta_even_out[gi];
        assign theta_even_in[gi] = Ltheta_even_out[gi];
        assign sigma_even_in[gi] = Lsigma_out[gi*2];
        assign b_even_in[gi] = Lb_out[gi*2]; 
    end
        assign delta_even_in[2] = 6'd0;
        assign theta_even_in[2] = 6'd0;
        assign sigma_even_in[2] = 6'd0;
        assign b_even_in[2] = 6'd0;
endgenerate

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
    .Lstate_rdy(Lstate_rdy),
    .cdone(cdone),
    .cfail(cfail),

    .write_en(write_en),
    .write_idx(write_idx),
    .read_idx(read_idx),

    .write_syn_en(write_syn_en),
    .write_syn_idx(write_syn_idx),
    .read_syn_idx(read_syn_idx)
);

state_buff u_state_buff(
    .clk(clk),
    .rst(rst),

    .read_idx(read_idx),
    .write_idx(write_idx),
    .write_en(write_en),

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

// NKES_PE1 u_PE10(.clk(clk), .rst(rst), .start(), .hold(), .gamma(), .discrepancy(), .branch(),
//     .delta_init(),
//     .theta_init(),
//     .delta_poly_in(),

//     .sigma_even() .sigma_odd(),
//     .b_even() .b_odd(),

//     .delta_poly_out()
// );

endmodule

module NKES_ctrl(
    input clk,
    input rst, 
    input syn_rdy,  // high order syndrome ready

    input Lstate_rdy,
    input cdone, cfail,

    output read_idx, 
    output write_en,
    output write_idx,

    output write_syn_en,
    output write_syn_idx,
    output read_syn_idx
);

    parameter S_STORE0  = 4'd0;
    parameter S_STORE1  = 4'd1;
    parameter S_CHECK0  = 4'd2;
    parameter S_CHECK1  = 4'd3;
    parameter S_FULL    = 4'd4;

    parameter S_INIT1   = 4'd5; 
    parameter S_CYC00   = 4'd6;
    parameter S_CYC01   = 4'd7;
    parameter S_CYC10   = 4'd8;
    parameter S_CYC11   = 4'd9;
    parameter S_DONE    = 4'd10;

    reg [3:0] state, state_next;

    assign write_en = (state == S_STORE0 || state == S_STORE1) && Lstate_rdy;
    assign write_idx = (state== S_STORE0)? 1'b0 : 1'b1;
    assign read_idx = (state == S_INIT1);

    assign write_syn_en = ((state==S_STORE1 || state==S_FULL) && syn_rdy) || (state == S_INIT1 || state == S_CYC00 || state == S_CYC01);
    assign write_syn_idx = (state == S_INIT1 || state == S_CYC01);
    assign read_syn_idx = (state == S_INIT1 || state == S_CYC01);

    always @(*) begin
        case(state) 
        S_STORE0: begin 
            state_next = (Lstate_rdy)? S_CHECK0 : state; 
        end
        S_CHECK0: begin 
            if (cdone) state_next = (cfail)? S_STORE1 : S_STORE0;
            else state_next = state;
        end
        S_STORE1: begin 
            if (syn_rdy) state_next = S_INIT1;
            else state_next = (Lstate_rdy)? S_CHECK1 : state;
        end
        S_CHECK1: begin
            if (cdone) state_next = (cfail)? S_FULL : S_STORE1;
            else state_next = state;
        end
        S_FULL: begin
            state_next = (syn_rdy)? S_INIT1 : state; 
        end
        S_INIT1: state_next = S_CYC00;
        S_CYC00: state_next = S_CYC01;
        S_CYC01: state_next = S_CYC10;
        S_CYC10: state_next = S_CYC11;
        S_CYC11: state_next = S_DONE;
        default: state_next = state;
        endcase 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_STORE0;
        end
        else begin
            state <= state_next;
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