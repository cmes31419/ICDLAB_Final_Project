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
wire write_en, write_idx;

NKES_ctrl u_ctrl(
    .clk(clk),
    .rst(rst),
    .syn_rdy(syn_rdy),
    .Lstate_rdy(Lstate_rdy),
    .cdone(cdone),
    .cfail(cfail),

    .write_en(write_en),
    .write_idx(write_idx)
);

state_buff u_state_buff(
    .clk(clk),
    .rst(rst),

    .read_idx(),
    .write_idx(write_idx),
    .write_en(write_en),

    .Lsigma_in(Lsigma),
    .Lb_in(Lb),
    .Ldelta_even_in(Ldelta_even),
    .Ltheta_even_in(Ltheta_even),
    .Lgamma_in(Lgamma),
    .Lk_in(Lk),

    .Lsigma_out(),
    .Lb_out(),
    .Ldelta_even_out(),
    .Ltheta_even_out(),
    .Lgamma_out(),
    .Lk_out()
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
    
    output write_en,
    output write_idx
);

    parameter S_STORE0  = 4'd0;
    parameter S_STORE1  = 4'd1;
    parameter S_CHECK0  = 4'd2;
    parameter S_CHECK1  = 4'd3;
    parameter S_FULL    = 4'd4;
    parameter S_INIT1   = 4'd5;

    reg [3:0] state, state_next;

    assign write_en = (state == S_STORE0 || state == S_STORE1) && Lstate_rdy;
    assign write_idx = (state== S_STORE0)? 1'b0 : 1'b1;

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
            state_next = (Lstate_rdy)? S_CHECK1 : state;
        end
        S_CHECK1: begin
            if (cdone) state_next = (cfail)? S_FULL : S_STORE1;
            else state_next = state;
        end
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