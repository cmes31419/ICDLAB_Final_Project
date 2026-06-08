module HSU_top_new (
    input  wire        clk,
    input  wire        rst,
    input  wire        start0,
    input  wire        start1,
    input  wire        nsget,

    input  wire [62:0] r0,
    input  wire [62:0] r1,
    input  wire [62:0] r2,
    input  wire [62:0] r3,

    input  wire        b,
    input  wire        flag0, flag1, flag2, flag3,      // flags for whether each interleave is undecoded (1 = undecoded, 0 = decoded)
    input  wire        stage_flag,

    input  wire [1:0]  undecoded_idx_1, undecoded_idx_2,
    input  wire        stage2_match_idx,
    input  wire        sel_idx,

    // Used to calculate S6 (S3^2) and S8 (S4^2), which are needed for the final output S_out_0..3
    input  wire [5:0]  Syndrome_3_i0, Syndrome_4_i0, Syndrome_3_i1, Syndrome_4_i1,

    output reg         syn_rdy,                            // Signal to indicate that the syndrome outputs are ready
    output reg  [5:0]  S_out_ch1, S_out_ch2,

    output [6:0]       Ndata,
    output             Nsel,
    output             Nwen
);

    // State controller for HSU_top
    reg [2:0]  counter, counter_next;
    reg        syn_rdy_next;

    always @(*) begin
        if (start1) counter_next = 3'd1;
        else if (counter == 3'd3) counter_next = nsget ? counter + 3'd1 : counter;
        else if (counter != 3'd0) counter_next = counter + 3'd1;
        else counter_next = 3'd0;
        if (counter == 3'd2) syn_rdy_next = 1'b1;
        else if (counter == 3'd4) syn_rdy_next = 1'b0;
        else syn_rdy_next = syn_rdy;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            syn_rdy <= 0;
        end
        else begin
            counter <= counter_next;
            syn_rdy <= syn_rdy_next;
        end
    end

    wire [5:0] Syndrome_3_sel, Syndrome_4_sel;
    assign Syndrome_3_sel = sel_idx ? Syndrome_3_i1 : Syndrome_3_i0;
    assign Syndrome_4_sel = sel_idx ? Syndrome_4_i1 : Syndrome_4_i0;

    wire [5:0]  square_in, square_out;
    assign square_in = (counter == 4'd2) ? Syndrome_3_sel : ((counter == 4'd4) ? Syndrome_4_sel : 6'd0);

    gf_mul square_inst (
        .in1(square_in),
        .in2(square_in),
        .prod(square_out)
    );

    wire [5:0] S_out_0, S_out_1, S_out_2, S_out_3; // Final syndrome outputs from HSU

    wire [5:0] mul0, mul1;
    wire i_4or6; // 0: S_4; 1: S_6
    assign mul0 = b ? ((counter == 3'd2) ? S_out_0 : ((counter == 3'd4) ? S_out_2 : 6'd0)) : 6'd0;
    assign mul1 = b ? ((counter == 3'd2) ? S_out_1 : ((counter == 3'd4) ? S_out_3 : 6'd0)) : 6'd0;
    assign i_4or6 = (b && counter == 3'd4) ? 1'b1 : 1'b0;

    wire [5:0] o_HS;

    nsu_top nsu_inst (
        .clk(clk),
        .rst(rst),
        .start(start0),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .b(b),
        .stage_flag(stage_flag),
        .S_out_0(S_out_0),  // S5_0 or S9_0
        .S_out_1(S_out_1),  // S5_1 or S9_1
        .S_out_2(S_out_2),  // S7_0 or S11_0
        .S_out_3(S_out_3)   // S7_1 or S11_1
    );

    A_inv_new inv_inst (
        .i_clk(clk),
        .i_rst(rst),
        .i_sel(sel_idx),                   // 0: i0, 1: i1
        .i_4or6(i_4or6),                   // 0: S_4; 1: S_6
        .i_gf_mul0_in1(mul0),              // S_4_0 or S_6_0
        .i_gf_mul1_in1(mul1),              // S_4_1 or S_6_1
        .i_undecoded_idx_1(undecoded_idx_1),  // Index of the first undecoded interleave (0 to 3)      
        .i_undecoded_idx_2(undecoded_idx_2),  // Index of the second undecoded interleave (0 to 3, or 0 if only 1 undecoded interleave)
        .o_HS(o_HS)
    );

    reg [5:0]   S_out_ch1_delay, S_out_ch1_delay_next;
    reg [5:0]   S_out_ch1_next;
    reg [5:0]   S_out_ch2_next;

    always @(*) begin
        case (counter)
        3'd2: begin
            S_out_ch1_delay_next = square_out;
            S_out_ch1_next = 6'd0;
            S_out_ch2_next = stage_flag ? S_out_0 : (b ? o_HS : S_out_0);
        end
        3'd4: begin
            S_out_ch1_delay_next = square_out;
            S_out_ch1_next = S_out_ch1_delay;
            S_out_ch2_next = stage_flag ? S_out_2 : (b ? o_HS : S_out_2);
        end
        3'd6: begin
            S_out_ch1_delay_next = 6'd0;
            S_out_ch1_next = S_out_ch1_delay;
            S_out_ch2_next = 6'd0;
        end
        3'd3, 3'd5, 3'd7: begin
            S_out_ch1_delay_next = S_out_ch1_delay;
            S_out_ch1_next = S_out_ch1;
            S_out_ch2_next = S_out_ch2;
        end
        default: begin
            S_out_ch1_delay_next = 6'd0;
            S_out_ch1_next = 6'd0;
            S_out_ch2_next = 6'd0;
        end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S_out_ch1_delay <= 6'd0;
            S_out_ch1       <= 6'd0;
            S_out_ch2       <= 6'd0;
        end
        else begin
            S_out_ch1_delay <= S_out_ch1_delay_next;
            S_out_ch1       <= S_out_ch1_next;
            S_out_ch2       <= S_out_ch2_next;
        end
    end

    assign Nwen = (counter == 3'd4 || counter == 3'd6) ? 1 : 0;
    assign Nsel = (counter == 3'd6) ? 1 : 0;
    assign Ndata = Nsel ? S_out_ch1 : S_out_ch2;

endmodule