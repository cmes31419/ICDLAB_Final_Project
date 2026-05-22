module HSU_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,

    input  wire [62:0] r0,
    input  wire [62:0] r1,
    input  wire [62:0] r2,
    input  wire [62:0] r3,

    input  wire        flag0, flag1, flag2, flag3,      // flags for whether each interleave is undecoded (1 = undecoded, 0 = decoded)
    input  wire        stage_flag,

    // Used to calculate S6 (S3^2) and S8 (S4^2), which are needed for the final output S_out_0..3
    input  wire [5:0]  Syndrome_3_i0, Syndrome_4_i0, Syndrome_3_i1, Syndrome_4_i1,   
    input  wire        valid_S3_S4,                     // Signal to enable input of S3 and S4

    output reg         syn_rdy,                            // Signal to indicate that the syndrome outputs are ready
    output reg  [5:0]  S_out_ch1, S_out_ch2
);

    // Calculate S6 and S8 using the provided S3 and S4 values
    wire [5:0] Syndrome_6_i0, Syndrome_8_i0, Syndrome_6_i1, Syndrome_8_i1;
    reg [5:0] Syndrome_6_i0_reg, Syndrome_8_i0_reg, Syndrome_6_i1_reg, Syndrome_8_i1_reg;
    reg stage_flag_reg;

    gf_mul square_inst0 (
        .in1(Syndrome_3_i0),
        .in2(Syndrome_3_i0),
        .prod(Syndrome_6_i0)
    );

    gf_mul square_inst1 (
        .in1(Syndrome_4_i0), // S4_i0 for S8 calculation
        .in2(Syndrome_4_i0),
        .prod(Syndrome_8_i0)
    );

    gf_mul square_inst2 (
        .in1(Syndrome_3_i1), // S3_i1 for S6 calculation
        .in2(Syndrome_3_i1),
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
        end else if (valid_S3_S4) begin 
            Syndrome_6_i0_reg <= Syndrome_6_i0; // S6 = S3^2 = S3_i0 ** 2
            Syndrome_8_i0_reg <= Syndrome_8_i0; // S8 = S4^2 = S4_i0 ** 2
            Syndrome_6_i1_reg <= Syndrome_6_i1; // S6 = S3^2 = S3_i1 ** 2
            Syndrome_8_i1_reg <= Syndrome_8_i1; // S8 = S4^2 = S4_i1 ** 2
        end
    end

    reg [5:0] Syndrome_12_i0_reg, Syndrome_12_i1_reg;
    reg [1:0] idx_12_i0_reg, idx_12_i1_reg;
    reg i1_valid;

    //   - b        : 0 -> 1 interleave undecoded (only Ŝ_0 needed)
    //                1 -> 2 interleaves undecoded (need both Ŝ_0 and Ŝ_1)
    wire b = ~(flag0 ^ flag1 ^ flag2 ^ flag3); // b is 1 if an odd number of flags are 1, else 0
    reg  b_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            b_reg <= 1'b0;
        end else if (start) begin
            b_reg <= b; // Latch b at the start of processing
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            i1_valid <= 1'b0;
        end
        else if (start && ~stage_flag_reg) begin
            if (b) begin
                i1_valid <= 1'b1;
            end else begin
                i1_valid <= 1'b0;
            end
        end
    end

    reg [1:0] undecoded_idx_1_reg, undecoded_idx_2_reg; // 2-bit indices of the undecoded interleaves (0 to 3)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            undecoded_idx_1_reg <= 2'd0;
            undecoded_idx_2_reg <= 2'd0;
        end else if (start && ~stage_flag_reg) begin
            // Capture the indices of the undecoded interleaves at the start of processing
            if (flag0) begin
                undecoded_idx_1_reg <= 2'd0;
            end else if (flag1) begin
                undecoded_idx_1_reg <= 2'd1;
            end else if (flag2) begin
                undecoded_idx_1_reg <= 2'd2;
            end else if (flag3) begin
                undecoded_idx_1_reg <= 2'd3;
            end

            if (b) begin // If there are 2 undecoded interleaves, find the second one
                if (flag1 && undecoded_idx_1_reg != 2'd1) begin
                    undecoded_idx_2_reg <= 2'd1;
                end else if (flag2 && undecoded_idx_1_reg != 2'd2) begin
                    undecoded_idx_2_reg <= 2'd2;
                end else if (flag3 && undecoded_idx_1_reg != 2'd3) begin
                    undecoded_idx_2_reg <= 2'd3;
                end
            end
        end
    end

    wire [5:0] S_out_0, S_out_1, S_out_2, S_out_3; // Final syndrome outputs from HSU
    wire valid; // Signal from HSU indicating that S_out_0..3 are valid and can be registered
    reg [5:0] S_out_0_reg, S_out_1_reg, S_out_2_reg, S_out_3_reg; // Registered versions of the outputs

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S_out_0_reg <= 6'd0;
            S_out_1_reg <= 6'd0;
            S_out_2_reg <= 6'd0;
            S_out_3_reg <= 6'd0;
        end else if (valid) begin
            S_out_0_reg <= S_out_0;
            S_out_1_reg <= S_out_1;
            S_out_2_reg <= S_out_2;
            S_out_3_reg <= S_out_3;
        end
    end

    
    always @(posedge clk or posedge rst) begin  
        if (rst) begin
            stage_flag_reg <= 1'b0;
        end else if (start) begin
            stage_flag_reg <= stage_flag; // Latch stage_flag at the start of processing
        end
    end

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
        end else if (counter == 3'd2 && b_reg) begin
            o_HS_2_reg <= o_HS_2;   // second S5
        end else if (counter == 3'd4 && b_reg) begin
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

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S_out_ch1 <= 6'd0;
            S_out_ch2 <= 6'd0;
        end else if (counter == 3'd2) begin
            if (~stage_flag_reg) begin      // Stage 1
                if (b_reg) begin                // 2 undercoded interleaves
                    S_out_ch1 <= o_HS_1;            // Output first S5
                    S_out_ch2 <= Syndrome_6_i0_reg; // Output first S6
                end else begin                  // 1 undercoded interleave
                    S_out_ch1 <= S_out_0;       // Output the only S5
                    S_out_ch2 <= Syndrome_6_i0_reg; // Output the only S6
                end
            end else begin                  // Stage 2
                S_out_ch1 <= S_out_0_reg; // Output S9
                S_out_ch2 <= 6'd0; // Output S10
            end
        end else if (counter == 3'd3) begin
            if (~stage_flag_reg) begin      // Stage 1
                if (b_reg) begin                // 2 undercoded interleaves
                    S_out_ch1 <= o_HS_2_reg;        // Output second S5
                    S_out_ch2 <= Syndrome_6_i1_reg; // Output second S6
                end else begin                  // 1 undercoded interleave
                    S_out_ch1 <= 6'd0;
                    S_out_ch2 <= 6'd0;
                end
            end else begin                  // Stage 2
                S_out_ch1 <= 6'd0;
                S_out_ch2 <= 6'd0;
            end
        end else if (counter == 3'd4) begin
            if (~stage_flag_reg) begin      // Stage 1
                if (b_reg) begin                // 2 undercoded interleaves
                    S_out_ch1 <= o_HS_1;            // Output first S7
                    S_out_ch2 <= Syndrome_8_i0_reg; // Output first S8
                end else begin                  // 1 undercoded interleave
                    S_out_ch1 <= S_out_1_reg;       // Output the only S7    
                    S_out_ch2 <= Syndrome_8_i0_reg; // Output the only S8
                end
            end else begin                  // Stage 2
                S_out_ch1 <= S_out_1_reg; // Output S11
                S_out_ch2 <= 6'd0; // Output S12
            end
        end else if (counter == 3'd5) begin
            if (~stage_flag_reg) begin      // Stage 1
                if (b_reg) begin                // 2 undercoded interleaves
                    S_out_ch1 <= o_HS_2_reg;        // Output second S7
                    S_out_ch2 <= Syndrome_8_i1_reg; // Output second S8
                end else begin                  // 1 undercoded interleave
                    S_out_ch1 <= 6'd0;
                    S_out_ch2 <= 6'd0;
                end
            end else begin                  // Stage 2
                S_out_ch1 <= 6'd0;
                S_out_ch2 <= 6'd0;
            end
        end
    end

    reg [5:0] mul0, mul1;
    reg i_4or6; // 0: S_4; 1: S_6
    always @(*) begin
        if (counter == 3'd2 && b_reg) begin // S5
            mul0 = S_out_0;
            mul1 = S_out_2;
            i_4or6 = 1'b0;
        end else if (counter == 3'd4 && b_reg) begin // S7
            mul0 = S_out_1_reg;
            mul1 = S_out_3_reg;
            i_4or6 = 1'b1;
        end else begin
            mul0 = 6'd0;
            mul1 = 6'd0;
            i_4or6 = 1'b0;
        end
    end

    reg [5:0] Syndrome_5_i0_reg, Syndrome_5_i1_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Syndrome_5_i0_reg <= 6'd0;
            Syndrome_5_i1_reg <= 6'd0;
        end else if (counter == 3'd2 && ~stage_flag_reg) begin
            Syndrome_5_i0_reg <= S_out_0; // First S5
            Syndrome_5_i1_reg <= S_out_2; // Second S5 (if exists)
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
        .S_out_1(S_out_1),
        .S_out_2(S_out_2),
        .S_out_3(S_out_3),
        .b_out(),
        .valid(valid)
    );

    A_inv inv_inst (
        .i_clk(clk),
        .i_rst(rst),
        .i_mode(1'b1),
        .i_4or6(i_4or6),                   // 0: S_4; 1: S_6
        .i_gf_mul0_in1(mul0),              // S_4_0 or S_6_0
        .i_gf_mul1_in1(mul1),              // S_4_1 or S_6_1
        .i_gf_mul2_in1(mul0),              // S_4_0 or S_6_0
        .i_gf_mul3_in1(mul1),              // S_4_1 or S_6_1
        .i_undecoded_idx_1(undecoded_idx_1_reg),  // Index of the first undecoded interleave (0 to 3)      
        .i_undecoded_idx_2(undecoded_idx_2_reg),  // Index of the second undecoded interleave (0 to 3, or 0 if only 1 undecoded interleave)
        .o_HS_1(o_HS_1),
        .o_HS_2(o_HS_2)
    );

endmodule