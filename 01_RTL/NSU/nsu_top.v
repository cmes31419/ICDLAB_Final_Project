//=========================================================================
// nsu_top.v
//
// Nested Syndrome Unit (NSU) for GII-BCH decoder.
//
// Spec:
//   - GF(2^6), psi(x) = x^6 + x + 1
//   - m=4 interleaves, v=2 nested codes
//   - Evaluates at alpha^5, alpha^7 (stage 0 done) or alpha^9, alpha^11 (stage 1 done)
//
// Inputs:
//   - r0..r3   : 4 corrected binary BCH codewords (63 bit each, parallel)
//   - b        : 0 -> 1 interleave undecoded (only Ŝ_0 needed)
//                1 -> 2 interleaves undecoded (need both Ŝ_0 and Ŝ_1)
//   - stage_flag: 0 -> stage 0 done (use L=5,7)
//                 1 -> stage 1 done (use L=9,11)
//   - start    : 1-cycle pulse to begin
//
// Outputs:
//   - S_out_0..3: 4 nested syndromes (6 bit each)
//        stage_flag=0: S_out_{0..3} = Ŝ_0@L=5, Ŝ_0@L=7, Ŝ_1@L=5, Ŝ_1@L=7
//        stage_flag=1: S_out_{0..3} = Ŝ_0@L=9, Ŝ_0@L=11, Ŝ_1@L=9, Ŝ_1@L=11
//        S_out_2, S_out_3 are forced to 0 if b==0.
//   - b_out    : latched copy of b
//   - valid    : pulses high when outputs are ready
//
// Combinational pre-processing layer:
//   r_xor   = r0 ^ r1 ^ r2 ^ r3                          (for Ŝ_0 path)
//   r_shift = r0 ^ rot(r1,1) ^ rot(r2,2) ^ rot(r3,3)     (for Ŝ_1 path)
//     - rot(r, k): cyclic left rotate by k bits
//     - cyclic is exactly equivalent to logical shift here because alpha^63 = 1
//
// 8 Horner instances; only the needed ones are enabled (others frozen).
//=========================================================================

module nsu_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,

    input  wire [62:0] r0,
    input  wire [62:0] r1,
    input  wire [62:0] r2,
    input  wire [62:0] r3,

    input  wire        b,
    input  wire        stage_flag,

    output wire [5:0]  S_out_0,
    output wire [5:0]  S_out_1,
    output wire [5:0]  S_out_2,
    output wire [5:0]  S_out_3,
    output reg         b_out,
    output wire        valid
);

    //----------------------------------------------------------------
    // Combinational pre-processing (pure wiring)
    //----------------------------------------------------------------
    wire [62:0] r_xor;
    assign r_xor = r0 ^ r1 ^ r2 ^ r3;

    // Cyclic left rotate:
    //   rot(r, k)[i] = r[(i - k) mod 63]
    //   So rotated[k..62] = r[0..62-k], rotated[0..k-1] = r[63-k..62]
    //   In Verilog concat: {r[62-k:0], r[62:63-k]}
    wire [62:0] r1_rot, r2_rot, r3_rot;
    assign r1_rot = {r1[61:0], r1[62]};      // rotate left by 1
    assign r2_rot = {r2[60:0], r2[62:61]};   // rotate left by 2
    assign r3_rot = {r3[59:0], r3[62:60]};   // rotate left by 3

    wire [62:0] r_shift;
    assign r_shift = r0 ^ r1_rot ^ r2_rot ^ r3_rot;

    //----------------------------------------------------------------
    // Cycle counter + state latching
    //----------------------------------------------------------------
    reg       running;
    reg [1:0] cyc_cnt;        // 0 = idle, 1 = mid-evaluation
    reg       latched_stage;
    reg       latched_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running       <= 1'b0;
            cyc_cnt       <= 2'd0;
            latched_stage <= 1'b0;
            latched_b     <= 1'b0;
            b_out         <= 1'b0;
        end else if (start) begin
            running       <= 1'b1;
            cyc_cnt       <= 2'd1;
            latched_stage <= stage_flag;
            latched_b     <= b;
            b_out         <= b;
        end else if (running) begin
            if (cyc_cnt == 2'd1) begin
                cyc_cnt <= 2'd2;
            end else begin
                running <= 1'b0;
                cyc_cnt <= 2'd0;
            end
        end
    end

    //----------------------------------------------------------------
    // Data feed to each Horner: 63 bits split into 2 chunks of 32 bits.
    // Horner expects MSB-first; pad 1 bit zero in MSB of cycle 1.
    //
    //   Cycle 1 (during start): data = { 1'b0, r[62:32] }    (1 pad + 31 high)
    //   Cycle 2 (next cycle)  : data = r[31:0]               (32 low)
    //----------------------------------------------------------------
    wire [31:0] data_xor;
    wire [31:0] data_shift;

    // At 'start' cycle, send high chunk; otherwise (running, cyc_cnt=1), send low.
    assign data_xor   = start ? {1'b0, r_xor[62:32]}   : r_xor[31:0];
    assign data_shift = start ? {1'b0, r_shift[62:32]} : r_shift[31:0];

    //----------------------------------------------------------------
    // Enable signals: only enable Horners we need
    //----------------------------------------------------------------
    // During 'start' cycle, gate by the incoming stage_flag/b.
    // While running, gate by latched_stage/latched_b.
    wire stage_now = start ? stage_flag : latched_stage;
    wire b_now     = start ? b          : latched_b;

    wire run_active = start | running;

    wire en_a5_k0  = run_active & (stage_now == 1'b0);
    wire en_a7_k0  = run_active & (stage_now == 1'b0);
    wire en_a9_k0  = run_active & (stage_now == 1'b1);
    wire en_a11_k0 = run_active & (stage_now == 1'b1);

    wire en_a5_k1  = run_active & (stage_now == 1'b0) & b_now;
    wire en_a7_k1  = run_active & (stage_now == 1'b0) & b_now;
    wire en_a9_k1  = run_active & (stage_now == 1'b1) & b_now;
    wire en_a11_k1 = run_active & (stage_now == 1'b1) & b_now;

    // Start pulse to each Horner (only the ones being used this run)
    wire start_a5_k0  = start & (stage_flag == 1'b0);
    wire start_a7_k0  = start & (stage_flag == 1'b0);
    wire start_a9_k0  = start & (stage_flag == 1'b1);
    wire start_a11_k0 = start & (stage_flag == 1'b1);

    wire start_a5_k1  = start & (stage_flag == 1'b0) & b;
    wire start_a7_k1  = start & (stage_flag == 1'b0) & b;
    wire start_a9_k1  = start & (stage_flag == 1'b1) & b;
    wire start_a11_k1 = start & (stage_flag == 1'b1) & b;

    //----------------------------------------------------------------
    // 8 Horner instances
    //----------------------------------------------------------------
    wire [5:0] S_5_k0,  S_7_k0,  S_9_k0,  S_11_k0;
    wire [5:0] S_5_k1,  S_7_k1,  S_9_k1,  S_11_k1;
    wire       d_5_k0,  d_7_k0,  d_9_k0,  d_11_k0;
    wire       d_5_k1,  d_7_k1,  d_9_k1,  d_11_k1;

    // Stage 0 done: alpha^5
    horner_a5 u_a5_k0 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a5_k0), .start(start_a5_k0),
        .data(data_xor),   .state(S_5_k0),  .done(d_5_k0)
    );
    horner_a5 u_a5_k1 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a5_k1), .start(start_a5_k1),
        .data(data_shift), .state(S_5_k1),  .done(d_5_k1)
    );

    // Stage 0 done: alpha^7
    horner_a7 u_a7_k0 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a7_k0), .start(start_a7_k0),
        .data(data_xor),   .state(S_7_k0),  .done(d_7_k0)
    );
    horner_a7 u_a7_k1 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a7_k1), .start(start_a7_k1),
        .data(data_shift), .state(S_7_k1),  .done(d_7_k1)
    );

    // Stage 1 done: alpha^9
    horner_a9 u_a9_k0 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a9_k0), .start(start_a9_k0),
        .data(data_xor),   .state(S_9_k0),  .done(d_9_k0)
    );
    horner_a9 u_a9_k1 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a9_k1), .start(start_a9_k1),
        .data(data_shift), .state(S_9_k1),  .done(d_9_k1)
    );

    // Stage 1 done: alpha^11
    horner_a11 u_a11_k0 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a11_k0), .start(start_a11_k0),
        .data(data_xor),    .state(S_11_k0), .done(d_11_k0)
    );
    horner_a11 u_a11_k1 (
        .clk(clk), .rst_n(rst_n),
        .enable(en_a11_k1), .start(start_a11_k1),
        .data(data_shift),  .state(S_11_k1), .done(d_11_k1)
    );

    //----------------------------------------------------------------
    // Output mux (based on latched_stage / latched_b)
    //----------------------------------------------------------------
    assign S_out_0 = (latched_stage == 1'b0) ? S_5_k0 : S_9_k0;
    assign S_out_1 = (latched_stage == 1'b0) ? S_7_k0 : S_11_k0;
    assign S_out_2 = (latched_b == 1'b0) ? 6'b0 :
                     ((latched_stage == 1'b0) ? S_5_k1 : S_9_k1);
    assign S_out_3 = (latched_b == 1'b0) ? 6'b0 :
                     ((latched_stage == 1'b0) ? S_7_k1 : S_11_k1);

    // valid: pulse when the k=0 path's done goes high
    assign valid = (latched_stage == 1'b0) ? d_5_k0 : d_9_k0;

endmodule