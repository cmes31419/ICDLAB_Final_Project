module BM(
    input clk,
    input rstn,
    input syndrome_rdy,
    input reset,

    input [5:0] S1,
    input [5:0] S2,
    input [5:0] S3,

    output [5:0] sigma0,
    output [5:0] sigma1,
    output [5:0] sigma2,

    output decode_fail,
    output chien_rdy
);

    wire [5:0] discrepancy, gamma;
    wire start, hold, c0;
    wire [7:0] c1;
    wire deg_lt_4;

    wire [5:0] sigma3, sigma4, sigma5, sigma6, sigma7;

    wire [9:0] b_in[0:3];
    wire [5:0] delta_in[1:7];

    assign sigma0 = discrepancy;
    assign sigma1 = delta_in[1];
    assign sigma2 = delta_in[2];
    assign sigma3 = delta_in[3];
    assign sigma4 = delta_in[4];
    assign sigma5 = delta_in[5];
    assign sigma6 = delta_in[6];
    assign sigma7 = delta_in[7];

    assign deg_lt_4 = |sigma5 || |sigma6 || |sigma7;
    assign decode_fail = (deg_lt_4 || |sigma3 || |sigma4) & chien_rdy;

    bm_control u_bm_ctrl(
        .clk(clk),
        .rstn(rstn),
        .discrepancy(discrepancy),
        .syndrome_rdy(syndrome_rdy),
        .reset(reset),

        .c0(c0),
        .c1(c1),
        .start(start),
        .hold(hold),

        .gamma(gamma),
        .chien_rdy(chien_rdy)
    );

    // PE_array ========
    // even row =================
    PE u_PE0(
        .clk(clk),
        .rstn(rstn),
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
        .delta_init(S3),
        .theta_init(6'b0),

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
        .delta_init(6'b1),
        .theta_init(6'b0),

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
        .delta_init(6'b0),
        .theta_init(6'b0),

        .c0(c0),
        .c1(c1[6]),
        .start(start),
        .hold(hold),

        .delta_in(6'b0),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[6])
    ); 
    // ====================
    // odd row ============
    PE u_PE1(
        .clk(clk),
        .rstn(rstn),
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
        .delta_init(6'b0),
        .theta_init(6'b1),   
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
        .delta_init(6'b0),
        .theta_init(6'b0),

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
        .delta_init(6'b0),
        .theta_init(6'b0),

        .c0(c0),
        .c1(c1[7]),
        .start(start),
        .hold(hold),

        .delta_in(6'b0),
        .gamma(gamma),
        .discrepancy(discrepancy),

        .delta(delta_in[7])
    ); 
    // ==========================

endmodule


module bm_control(
    input clk,
    input rstn,
    input [5:0] discrepancy,
    input syndrome_rdy,
    input reset,

    output c0,
    output reg [7:0] c1,
    output start,
    output hold,

    output reg [5:0] gamma,

    output chien_rdy
); 
    reg [1:0] state, state_next;
    reg k, k_next;
    reg [5:0] gamma_next;
    reg [7:0] c1_next;

    wire [1:0] increment;

    reg rdy_hold, rdy_hold_next;

    assign increment = state + 1;

    assign c0 = |discrepancy & (k==0);
    assign start = (state == 0 && syndrome_rdy);
    assign hold = (state == 0 && !syndrome_rdy);

    assign chien_rdy = rdy_hold;

    always @(*) begin
        if (syndrome_rdy | reset) rdy_hold_next = 0;
        else if (state == 2) rdy_hold_next = 1;
        else rdy_hold_next = rdy_hold;
    end

    always @(*) begin
        case(state) // synopsys parallel_case
        0: state_next = (syndrome_rdy)? increment : state;
        2: state_next = 3'b0;
        default: state_next = increment;
        endcase
    end

    always @(*) begin
        if (start) begin
            gamma_next = 6'b1;
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
        if (start) c1_next = 8'b011;
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