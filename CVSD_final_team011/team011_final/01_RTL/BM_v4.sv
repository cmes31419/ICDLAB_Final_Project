module BM(
    input clk,
    input rstn,
    input syndrome_rdy,
    input reset,
    input [1:0] code,

    input [9:0] S1,
    input [9:0] S2,
    input [9:0] S3,
    input [9:0] S4,
    input [9:0] S5,
    input [9:0] S6,
    input [9:0] S7,
    input [9:0] S8,

    output [9:0] sigma0,
    output [9:0] sigma1,
    output [9:0] sigma2,
    output [9:0] sigma3,
    output [9:0] sigma4,

    output decode_fail,
    output chien_rdy
);

    wire [9:0] discrepancy, gamma;
    wire start, hold, c0;
    wire [7:0] c1;
    wire t, first_iter;
    wire deg_lt_4;

    wire [9:0] sigma5, sigma6, sigma7;

    wire [9:0] b_in[0:3];
    wire [9:0] delta_in[1:7];

    assign t = (&code)? 1'b1 : 1'b0;

    assign sigma0 = discrepancy;
    assign sigma1 = delta_in[1];
    assign sigma2 = delta_in[2];
    assign sigma3 = delta_in[3];
    assign sigma4 = delta_in[4];
    assign sigma5 = delta_in[5];
    assign sigma6 = delta_in[6];
    assign sigma7 = delta_in[7];

    assign deg_lt_4 = |sigma5 || |sigma6 || |sigma7;
    assign decode_fail = ((t)? deg_lt_4 : (deg_lt_4 || |sigma3 || |sigma4)) & chien_rdy;

    bm_control u_bm_ctrl(
        .clk(clk),
        .rstn(rstn),
        .t(t),
        .discrepancy(discrepancy),
        .syndrome_rdy(syndrome_rdy),
        .reset(reset),

        .c0(c0),
        .c1(c1),
        .start(start),
        .hold(hold),

        .gamma(gamma),
        .first_iter(first_iter),
        .chien_rdy(chien_rdy)
    );

    // PE_array ========
    // even row =================
    PE u_PE0(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init(S1),
        .theta_init(S2),

        .c0(c0),
        .c1(c1[0]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[2]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(discrepancy)
    ); 
    PE u_PE2(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init(S3),
        .theta_init((t)? S4 : 10'b0),

        .c0(c0),
        .c1(c1[2]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[4]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[2])
    ); 
    PE u_PE4(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init((t)? S5 : 10'b1),
        .theta_init((t)? S6 : 10'b0),

        .c0(c0),
        .c1(c1[4]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[6]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[4])
    ); 
    PE u_PE6(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init((t)? S7 : 10'b0),
        .theta_init(10'b0),

        .c0(c0),
        .c1(c1[6]),
        .start(start),
        .hold(hold),

        .delta_in((t && first_iter)? 10'b1 : 10'b0),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[6])
    ); 
    // ====================
    // odd row ============
    PE u_PE1(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init(S2),
        .theta_init(S3),

        .c0(c0),
        .c1(c1[1]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[3]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[1])
    ); 

    PE u_PE3(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init((t)? S4 : 10'b0),
        .theta_init((t)? S5 : 10'b1),   
        .c0(c0),
        .c1(c1[3]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[5]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[3])
    ); 

    PE u_PE5(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init((t)? S6 : 10'b0),
        .theta_init((t)? S7 : 10'b0),

        .c0(c0),
        .c1(c1[5]),
        .start(start),
        .hold(hold),

        .delta_in(delta_in[7]),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[5])
    ); 

    PE u_PE7(
        .clk(clk),
        .rstn(rstn),
        .code(code),
        .delta_init(10'b0),
        .theta_init((t)? 10'b1 : 10'b0),

        .c0(c0),
        .c1(c1[7]),
        .start(start),
        .hold(hold),

        .delta_in(10'b0),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[7])
    ); 
    // ==========================

endmodule


module bm_control(
    input clk,
    input rstn,
    input t, // 0: t=2, 1: t=4
    input [9:0] discrepancy,
    input syndrome_rdy,
    input reset,

    output c0,
    output reg [7:0] c1,
    output start,
    output hold,

    output reg [9:0] gamma,

    output first_iter,
    output chien_rdy
); 
    reg [2:0] state, state_next;
    reg k, k_next;
    reg [9:0] gamma_next;
    reg [7:0] c1_next;

    wire [2:0] increment;

    reg rdy_hold, rdy_hold_next;

    assign increment = state + 1;
    assign first_iter = (state == 1);

    assign c0 = |discrepancy & (k==0);
    assign start = (state == 0 && syndrome_rdy);
    assign hold = (state == 0 && !syndrome_rdy);

    assign chien_rdy = rdy_hold;

    always @(*) begin
        if (syndrome_rdy | reset) rdy_hold_next = 0;
        else if (state == 4 || (state == 2 && t==0)) rdy_hold_next = 1;
        else rdy_hold_next = rdy_hold;
    end

    always @(*) begin
        case(state) // synopsys parallel_case
        0: state_next = (syndrome_rdy)? increment : state;
        2: state_next = (t == 0)? 3'b0 : increment;
        4: state_next = 3'b0;
        default: state_next = increment;
        endcase
    end

    always @(*) begin
        if (start) begin
            gamma_next = 10'b1;
            k_next = 1'b0;
        end
        else if (hold) begin
            gamma_next = gamma;
            k_next = k;
        end
        else begin
            gamma_next = (c0)? discrepancy : gamma;
            k_next = (c0)? 1'b1 : 1'b0;
        end
    end

    always @(*) begin
        if (start) c1_next = (t)? 8'b0011_0000 : 8'b011;
        else if (hold) c1_next = c1;
        else c1_next = c1 >> 2;
    end

    always @(posedge clk) begin
        if (!rstn) begin
            state       <= 0;
            k           <= 0;
            gamma       <= 1;     
            c1          <= 0;
            rdy_hold    <= 0;
        end
        else begin
            state       <= state_next;
            k           <= k_next;
            gamma       <= gamma_next;
            c1          <= c1_next;
            rdy_hold    <= rdy_hold_next;
        end
    end
     
endmodule