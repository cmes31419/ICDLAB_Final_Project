module HSU_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    input  wire [62:0] r0,
    input  wire [62:0] r1,
    input  wire [62:0] r2,
    input  wire [62:0] r3,

    input  wire        b,
    input  wire        flag0, flag1, flag2, flag3,      // flags for whether each interleave is undecoded (1 = undecoded, 0 = decoded)
    input  wire        stage_flag,

    input  wire [1:0]  undecoded_idx_1, undecoded_idx_2,
    input  wire        stage2_match_idx,

    // Used to calculate S6 (S3^2) and S8 (S4^2), which are needed for the final output S_out_0..3
    input  wire [5:0]  Syndrome_3_i0, Syndrome_4_i0, Syndrome_3_i1, Syndrome_4_i1,   
    input  wire        valid_S3_S4,                     // Signal to enable input of S3 and S4

    output reg         syn_rdy,                            // Signal to indicate that the syndrome outputs are ready
    output reg  [5:0]  S_out_ch1, S_out_ch2
);

    // Calculate S6 and S8 using the provided S3 and S4 values
    wire [5:0] Syndrome_6_i0, Syndrome_8_i0, Syndrome_6_i1, Syndrome_8_i1;
    reg [5:0] Syndrome_6_i0_reg, Syndrome_8_i0_reg, Syndrome_6_i1_reg, Syndrome_8_i1_reg;

    reg [5:0] square_S3_S5, square_S3_S6;
    reg [5:0] Syndrome_5_i0_reg, Syndrome_5_i1_reg;

    always @(*) begin
        if (valid_S3_S4 && ~stage_flag) begin
            square_S3_S5 = Syndrome_3_i0; // S3_i0 for S6 calculation
            square_S3_S6 = Syndrome_3_i1; // S3_i1 for S6 calculation
        end else begin
            if (stage2_match_idx) begin
                square_S3_S5 = Syndrome_5_i1_reg; // S4_i0 for S8 calculation
                square_S3_S6 = Syndrome_6_i1_reg; // S4_i1 for S8 calculation
            end
            else begin
                square_S3_S5 = Syndrome_5_i0_reg;
                square_S3_S6 = Syndrome_6_i0_reg;
            end 
        end
    end

    gf_mul square_inst0 (
        .in1(square_S3_S5),
        .in2(square_S3_S5),
        .prod(Syndrome_6_i0)
    );

    gf_mul square_inst1 (
        .in1(Syndrome_4_i0), // S4_i0 for S8 calculation
        .in2(Syndrome_4_i0),
        .prod(Syndrome_8_i0)
    );

    gf_mul square_inst2 (
        .in1(square_S3_S6), // S3_i1 for S6 calculation
        .in2(square_S3_S6),
        .prod(Syndrome_6_i1)
    );

    gf_mul square_inst3 (
        .in1(Syndrome_4_i1), // S4_i1 for S8 calculation
        .in2(Syndrome_4_i1),
        .prod(Syndrome_8_i1)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Syndrome_6_i0_reg <= 6'd0;
            Syndrome_8_i0_reg <= 6'd0;
            Syndrome_6_i1_reg <= 6'd0;
            Syndrome_8_i1_reg <= 6'd0;
        end else if (valid_S3_S4 && ~stage_flag) begin 
            Syndrome_6_i0_reg <= Syndrome_6_i0; // S6 = S3^2 = S3_i0 ** 2
            Syndrome_8_i0_reg <= Syndrome_8_i0; // S8 = S4^2 = S4_i0 ** 2
            Syndrome_6_i1_reg <= Syndrome_6_i1; // S6 = S3^2 = S3_i1 ** 2
            Syndrome_8_i1_reg <= Syndrome_8_i1; // S8 = S4^2 = S4_i1 ** 2
        end
    end

    reg [5:0] Syndrome_12_i0_reg, Syndrome_12_i1_reg;

    wire [5:0] S_out_0, S_out_1, S_out_2, S_out_3; // Final syndrome outputs from HSU

    // state controller for HSU_top
    reg [2:0] counter;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 3'd0;
        end else if (start) begin
            counter <= 3'd1;
        end
        else if (counter < 3'd5 && counter != 0) begin
            counter <= counter + 3'd1;
        end
    end

    wire [5:0] o_HS_1, o_HS_2;
    reg [5:0] o_HS_2_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_HS_2_reg <= 6'd0;
        end else if (counter == 3'd2 && b) begin
            o_HS_2_reg <= o_HS_2;   // second S5
        end else if (counter == 3'd4 && b) begin
            o_HS_2_reg <= o_HS_2;   // second S7
        end
    end


    // Output Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            syn_rdy <= 1'b0;
        end else if (counter == 3'd2) begin
            syn_rdy <= 1'b1;
        end else if (counter == 3'd4) begin
            syn_rdy <= 1'b0;
        end
    end

    reg [5:0]   S_out_ch1_next;
    reg [5:0]   S_out_ch2_next;

    always @(*) begin
        case (counter)
        3'd2: begin
            S_out_ch1_next = stage_flag ? S_out_0 : (b ? o_HS_1 : S_out_0);
            S_out_ch2_next = stage_flag ? Syndrome_6_i0 : Syndrome_6_i0_reg;
        end
        3'd3: begin
            S_out_ch1_next = stage_flag ? 6'd0 : (b ? o_HS_2_reg : 6'd0);
            S_out_ch2_next = stage_flag ? 6'd0 : (b ? Syndrome_6_i1_reg : 6'd0);
        end
        3'd4: begin
            S_out_ch1_next = stage_flag ? S_out_1 : (b ? o_HS_1 : S_out_1);
            S_out_ch2_next = stage_flag ? Syndrome_6_i1 : Syndrome_8_i0_reg;
        end
        3'd5: begin
            S_out_ch1_next = stage_flag ? 6'd0 : (b ? o_HS_2_reg : 6'd0);
            S_out_ch2_next = stage_flag ? 6'd0 : (b ? Syndrome_8_i1_reg : 6'd0);
        end
        default: begin
            S_out_ch1_next = 6'd0;
            S_out_ch2_next = 6'd0;
        end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S_out_ch1   <= 6'd0;
            S_out_ch2   <= 6'd0;
        end
        else begin
            S_out_ch1   <= S_out_ch1_next;
            S_out_ch2   <= S_out_ch2_next;
        end
    end

    reg [5:0] mul0, mul1;
    reg i_4or6; // 0: S_4; 1: S_6
    always @(*) begin
        if (counter == 3'd2 && b) begin // S5
            mul0 = S_out_0;
            mul1 = S_out_2;
            i_4or6 = 1'b0;
        end else if (counter == 3'd4 && b) begin // S7
            mul0 = S_out_1;
            mul1 = S_out_3;
            i_4or6 = 1'b1;
        end else begin
            mul0 = 6'd0;
            mul1 = 6'd0;
            i_4or6 = 1'b0;
        end
    end

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Syndrome_5_i0_reg <= 6'd0;
            Syndrome_5_i1_reg <= 6'd0;
        end else if (counter == 3'd2 && ~stage_flag) begin
            if (b) begin
                Syndrome_5_i0_reg <= o_HS_1; // First S5
                Syndrome_5_i1_reg <= o_HS_2; // Second S5 (if exists)
            end else begin
                Syndrome_5_i0_reg <= S_out_0; // The only S5
                Syndrome_5_i1_reg <= 6'd0;
            end
        end
    end

    nsu_top nsu_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .b(b),
        .stage_flag(stage_flag),
        .S_out_0(S_out_0),
        .S_out_1(S_out_2),
        .S_out_2(S_out_1),
        .S_out_3(S_out_3)
    );

    A_inv inv_inst (
        .i_clk(clk),
        .i_rst(rst),
        .i_4or6(i_4or6),                   // 0: S_4; 1: S_6
        .i_gf_mul0_in1(mul0),              // S_4_0 or S_6_0
        .i_gf_mul1_in1(mul1),              // S_4_1 or S_6_1
        .i_gf_mul2_in1(mul0),              // S_4_0 or S_6_0
        .i_gf_mul3_in1(mul1),              // S_4_1 or S_6_1
        .i_undecoded_idx_1(undecoded_idx_1),  // Index of the first undecoded interleave (0 to 3)      
        .i_undecoded_idx_2(undecoded_idx_2),  // Index of the second undecoded interleave (0 to 3, or 0 if only 1 undecoded interleave)
        .o_HS_1(o_HS_1),
        .o_HS_2(o_HS_2)
    );

endmodule