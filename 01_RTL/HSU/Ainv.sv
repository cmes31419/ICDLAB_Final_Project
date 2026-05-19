module A_inv (
    input i_clk,
    input i_rst,

    input i_mode, // 0: square; 1: A inverse
    input i_4or6, // 0: S_4; 1: S_6

    input [5:0] i_gf_mul0_in1,
    input [5:0] i_gf_mul1_in1,
    input [5:0] i_gf_mul2_in1,
    input [5:0] i_gf_mul3_in1,

    input [1:0] i_undecoded_idx_1,
    input [1:0] i_undecoded_idx_2,

    output [5:0] o_HS_1,
    output [5:0] o_HS_2,
    output [5:0] o_HS_3,
    output [5:0] o_HS_4
);
    integer i, j;

    // Register for gf_mul
    logic [5:0] gf_mul0_in2;
    logic [5:0] gf_mul1_in2;
    logic [5:0] gf_mul2_in2;
    logic [5:0] gf_mul3_in2;

    logic [5:0] gf_mul0_prod;
    logic [5:0] gf_mul1_prod;
    logic [5:0] gf_mul2_prod;
    logic [5:0] gf_mul3_prod;

    gf_mul u0_gf_mul (
        .in1(i_gf_mul0_in1),
        .in2((i_mode == 1'b0) ? i_gf_mul0_in1 : gf_mul0_in2),
        .prod(gf_mul0_prod)
    );

    gf_mul u1_gf_mul (
        .in1(i_gf_mul1_in1),
        .in2((i_mode == 1'b0) ? i_gf_mul1_in1 : gf_mul1_in2),
        .prod(gf_mul1_prod)
    );

    gf_mul u2_gf_mul (
        .in1(i_gf_mul2_in1),
        .in2((i_mode == 1'b0) ? i_gf_mul2_in1 : gf_mul2_in2),
        .prod(gf_mul2_prod)
    );

    gf_mul u3_gf_mul (
        .in1(i_gf_mul3_in1),
        .in2((i_mode == 1'b0) ? i_gf_mul3_in1 : gf_mul3_in2),
        .prod(gf_mul3_prod)
    );

    logic [5:0] o_HS_1_w;
    logic [5:0] o_HS_2_w;
    logic [5:0] o_HS_3_w;
    logic [5:0] o_HS_4_w;

    assign o_HS_1 = o_HS_1_w;
    assign o_HS_2 = o_HS_2_w;
    assign o_HS_3 = o_HS_3_w;
    assign o_HS_4 = o_HS_4_w;

    always_comb begin
        gf_mul0_in2 = 6'd0;
        gf_mul1_in2 = 6'd0;
        gf_mul2_in2 = 6'd0;
        gf_mul3_in2 = 6'd0;
        if (i_mode == 1'b0) begin // square
            o_HS_1_w = gf_mul0_prod;
            o_HS_2_w = gf_mul1_prod;
            o_HS_3_w = gf_mul2_prod;
            o_HS_4_w = gf_mul3_prod;
        end
        else begin
            case (i_4or6)
                1'b0: begin
                    // S_4^b1
                    case ({i_undecoded_idx_1, i_undecoded_idx_2})
                        {2'd0, 2'd1}: begin
                            gf_mul0_in2 = 6'b000011; // a+1
                            gf_mul1_in2 = 6'b000010; // a
                        end
                        {2'd0, 2'd2}: begin 
                            gf_mul0_in2 = 6'b000101; // a^2+1
                            gf_mul1_in2 = 6'b000100; // a^2
                        end
                        {2'd0, 2'd3}: begin 
                            gf_mul0_in2 = 6'b101110; // a^5+a^3+a^2+a
                            gf_mul1_in2 = 6'b101111; // a^5+a^3+a^2+a+1
                        end
                        {2'd1, 2'd2}: begin 
                            gf_mul0_in2 = 6'b000011; // a+1
                            gf_mul1_in2 = 6'b111101; // a^5+a^4+a^3+a^2+1
                        end
                        {2'd1, 2'd3}: begin 
                            gf_mul0_in2 = 6'b000101; // a^2+1
                            gf_mul1_in2 = 6'b111001; // a^5+a^4+a^3+1
                        end
                        {2'd2, 2'd3}: begin 
                            gf_mul0_in2 = 6'b000011; // a+1
                            gf_mul1_in2 = 6'b010111; // a^4+a^2+a+1
                        end
                    endcase
                    // S_4^b2
                    case ({i_undecoded_idx_1, i_undecoded_idx_2})
                        {2'd0, 2'd1}: begin
                            gf_mul2_in2 = 6'b000010; // a
                            gf_mul3_in2 = 6'b000010;// a
                        end 
                        {2'd0, 2'd2}: begin 
                            gf_mul2_in2 = 6'b000100; // a^2
                            gf_mul3_in2 = 6'b000100; // a^2
                        end
                        {2'd0, 2'd3}: begin 
                            gf_mul2_in2 = 6'b101111; // a^5+a^3+a^2+a+1
                            gf_mul3_in2 = 6'b101111; // a^5+a^3+a^2+a+1
                        end
                        {2'd1, 2'd2}: begin 
                            gf_mul2_in2 = 6'b000010; // a
                            gf_mul3_in2 = 6'b111101; // a^5+a^4+a^3+a^2+1
                        end
                        {2'd1, 2'd3}: begin 
                            gf_mul2_in2 = 6'b000100; // a^2
                            gf_mul3_in2 = 6'b111001; // a^5+a^4+a^3+1
                        end
                        {2'd2, 2'd3}: begin 
                            gf_mul2_in2 = 6'b000010; // a
                            gf_mul3_in2 = 6'b010111; // a^4+a^2+a+1
                        end
                    endcase
                end
                1'b1: begin
                    // S_6^b1
                    case ({i_undecoded_idx_1, i_undecoded_idx_2})
                        {2'd0, 2'd1}: begin
                            gf_mul0_in2 = 6'b101101; // a^5+a^3+a^2+1
                            gf_mul1_in2 = 6'b101100;// a^5+a^3+a^2
                        end 
                        {2'd0, 2'd2}: begin 
                            gf_mul0_in2 = 6'b100010; // a^5+a
                            gf_mul1_in2 = 6'b100011; // a^5+a+1
                        end
                        {2'd0, 2'd3}: begin 
                            gf_mul0_in2 = 6'b111010; // a^5+a^4+a^3+a
                            gf_mul1_in2 = 6'b111011; // a^5+a^4+a^3+a+1
                        end
                        {2'd1, 2'd2}: begin 
                            gf_mul0_in2 = 6'b101101; // a^5+a^3+a^2+1
                            gf_mul1_in2 = 6'b110011; // a^5+a^4+a+1
                        end
                        {2'd1, 2'd3}: begin 
                            gf_mul0_in2 = 6'b100010; // a^5+a
                            gf_mul1_in2 = 6'b010000; // a^4
                        end
                        {2'd2, 2'd3}: begin 
                            gf_mul0_in2 = 6'b101101; // a^5+a^3+a^2+1
                            gf_mul1_in2 = 6'b101001; // a^5+a^3+1
                        end
                    endcase
                    // S_6^b2
                    case ({i_undecoded_idx_1, i_undecoded_idx_2})
                        {2'd0, 2'd1}: begin
                            gf_mul2_in2 = 6'b101100; // a^5+a^3+a^2
                            gf_mul3_in2 = 6'b101100;// a^5+a^3+a^2
                        end 
                        {2'd0, 2'd2}: begin 
                            gf_mul2_in2 = 6'b100011; // a^5+a+1
                            gf_mul3_in2 = 6'b100011; // a^5+a+1
                        end
                        {2'd0, 2'd3}: begin 
                            gf_mul2_in2 = 6'b111011; // a^5+a^4+a^3+a+1
                            gf_mul3_in2 = 6'b111011; // a^5+a^4+a^3+a+1
                        end
                        {2'd1, 2'd2}: begin 
                            gf_mul2_in2 = 6'b101100; // a^5+a^3+a^2
                            gf_mul3_in2 = 6'b110011; // a^5+a^4+a+1
                        end
                        {2'd1, 2'd3}: begin 
                            gf_mul2_in2 = 6'b100011; // a^5+a+1
                            gf_mul3_in2 = 6'b010000; // a^4
                        end
                        {2'd2, 2'd3}: begin 
                            gf_mul2_in2 = 6'b101100; // a^5+a^3+a^2
                            gf_mul3_in2 = 6'b101001; // a^5+a^3+1
                        end
                    endcase
                end
            endcase
            o_HS_1_w = gf_mul0_prod ^ gf_mul1_prod;
            o_HS_2_w = gf_mul2_prod ^ gf_mul3_prod;
            o_HS_3_w = 6'd0;
            o_HS_4_w = 6'd0;
        end
    end
endmodule