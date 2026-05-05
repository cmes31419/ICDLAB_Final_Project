//=====================================================================
// nsu_top.v
//
// Top-level Nested Syndrome Unit for GII-BCH decoder
//
// Spec:
//   m=4 interleaves, v=2 nested codes
//   GF(2^6), psi(x) = x^6 + x + 1
//   t0=2, t1=4, t2=6
//
// This module instantiates 4 nsu_unit instances (one per j value):
//   - j=2 (evaluate at alpha^5):   produces Shat for S_5
//   - j=3 (evaluate at alpha^7):   produces Shat for S_7
//   - j=4 (evaluate at alpha^9):   produces Shat for S_9
//   - j=5 (evaluate at alpha^11):  produces Shat for S_11
//
// Inputs are organized as 4 sets (one per j). The parent of this module
// (system controller) decides which j set is valid based on stage.
//   - Stage 0 finished:  use j=2 and j=3 outputs
//   - Stage 1 finished:  use j=4 and j=5 outputs
//
// The HOSU outputs S_(2j)^(i) for the requested j must be aligned with
// the corresponding R_i input.
//
// Latency: 1 cycle from enable to output valid.
//=====================================================================

module nsu_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,            // 1-cycle pulse to compute all j

    //------------------------------------------------------------------
    // R inputs: r_i(alpha^(2j+1)) for each interleave i and each j
    //   R_jX_iY = r_Y(alpha^(2X+1))
    //------------------------------------------------------------------
    input  wire [5:0]  R_j2_i0, R_j2_i1, R_j2_i2, R_j2_i3,  // for j=2 (alpha^5)
    input  wire [5:0]  R_j3_i0, R_j3_i1, R_j3_i2, R_j3_i3,  // for j=3 (alpha^7)
    input  wire [5:0]  R_j4_i0, R_j4_i1, R_j4_i2, R_j4_i3,  // for j=4 (alpha^9)
    input  wire [5:0]  R_j5_i0, R_j5_i1, R_j5_i2, R_j5_i3,  // for j=5 (alpha^11)

    //------------------------------------------------------------------
    // S inputs: S_(2j)^(i) from HOSU for each j and each i
    //------------------------------------------------------------------
    input  wire [5:0]  S_j2_i0, S_j2_i1, S_j2_i2, S_j2_i3,
    input  wire [5:0]  S_j3_i0, S_j3_i1, S_j3_i2, S_j3_i3,
    input  wire [5:0]  S_j4_i0, S_j4_i1, S_j4_i2, S_j4_i3,
    input  wire [5:0]  S_j5_i0, S_j5_i1, S_j5_i2, S_j5_i3,

    //------------------------------------------------------------------
    // Decoded flags (shared across all j)
    //------------------------------------------------------------------
    input  wire        f0, f1, f2, f3,

    //------------------------------------------------------------------
    // Outputs: 2 nested syndromes per j (4 j's = 8 outputs)
    //------------------------------------------------------------------
    output wire [5:0]  Shat0_j2, Shat1_j2,
    output wire [5:0]  Shat0_j3, Shat1_j3,
    output wire [5:0]  Shat0_j4, Shat1_j4,
    output wire [5:0]  Shat0_j5, Shat1_j5,

    output wire        valid
);

    //=================================================================
    // Constant multipliers:
    // For each j, we need to multiply by alpha^((2j+1)*i) for i=1,2,3
    //
    //   j=2 (2j+1=5):   alpha^5,  alpha^10, alpha^15
    //   j=3 (2j+1=7):   alpha^7,  alpha^14, alpha^21
    //   j=4 (2j+1=9):   alpha^9,  alpha^18, alpha^27
    //   j=5 (2j+1=11):  alpha^11, alpha^22, alpha^33
    //
    // For each (j, i) we need TWO multipliers: one for R, one for S.
    // The S inputs are flag-gated BEFORE multiplication (so that for
    // undecoded interleaves, the gated input is 0 and the mul output
    // is 0, contributing nothing to the sum).
    //=================================================================

    //--- Flag-gated S inputs (for k=1 path; the k=0 path gates inside nsu_unit)
    wire [5:0] S_j2_i1_g, S_j2_i2_g, S_j2_i3_g;
    wire [5:0] S_j3_i1_g, S_j3_i2_g, S_j3_i3_g;
    wire [5:0] S_j4_i1_g, S_j4_i2_g, S_j4_i3_g;
    wire [5:0] S_j5_i1_g, S_j5_i2_g, S_j5_i3_g;

    assign S_j2_i1_g = f1 ? S_j2_i1 : 6'b0;
    assign S_j2_i2_g = f2 ? S_j2_i2 : 6'b0;
    assign S_j2_i3_g = f3 ? S_j2_i3 : 6'b0;

    assign S_j3_i1_g = f1 ? S_j3_i1 : 6'b0;
    assign S_j3_i2_g = f2 ? S_j3_i2 : 6'b0;
    assign S_j3_i3_g = f3 ? S_j3_i3 : 6'b0;

    assign S_j4_i1_g = f1 ? S_j4_i1 : 6'b0;
    assign S_j4_i2_g = f2 ? S_j4_i2 : 6'b0;
    assign S_j4_i3_g = f3 ? S_j4_i3 : 6'b0;

    assign S_j5_i1_g = f1 ? S_j5_i1 : 6'b0;
    assign S_j5_i2_g = f2 ? S_j5_i2 : 6'b0;
    assign S_j5_i3_g = f3 ? S_j5_i3 : 6'b0;

    //=================================================================
    // GF constant multipliers for j=2 (2j+1 = 5)
    //=================================================================
    wire [5:0] R_j2_i1_mul, R_j2_i2_mul, R_j2_i3_mul;
    wire [5:0] S_j2_i1_mul, S_j2_i2_mul, S_j2_i3_mul;

    mul_a05 m_R_j2_i1 (.x(R_j2_i1),    .y(R_j2_i1_mul));
    mul_a10 m_R_j2_i2 (.x(R_j2_i2),    .y(R_j2_i2_mul));
    mul_a15 m_R_j2_i3 (.x(R_j2_i3),    .y(R_j2_i3_mul));
    mul_a05 m_S_j2_i1 (.x(S_j2_i1_g),  .y(S_j2_i1_mul));
    mul_a10 m_S_j2_i2 (.x(S_j2_i2_g),  .y(S_j2_i2_mul));
    mul_a15 m_S_j2_i3 (.x(S_j2_i3_g),  .y(S_j2_i3_mul));

    //=================================================================
    // GF constant multipliers for j=3 (2j+1 = 7)
    //=================================================================
    wire [5:0] R_j3_i1_mul, R_j3_i2_mul, R_j3_i3_mul;
    wire [5:0] S_j3_i1_mul, S_j3_i2_mul, S_j3_i3_mul;

    mul_a07 m_R_j3_i1 (.x(R_j3_i1),    .y(R_j3_i1_mul));
    mul_a14 m_R_j3_i2 (.x(R_j3_i2),    .y(R_j3_i2_mul));
    mul_a21 m_R_j3_i3 (.x(R_j3_i3),    .y(R_j3_i3_mul));
    mul_a07 m_S_j3_i1 (.x(S_j3_i1_g),  .y(S_j3_i1_mul));
    mul_a14 m_S_j3_i2 (.x(S_j3_i2_g),  .y(S_j3_i2_mul));
    mul_a21 m_S_j3_i3 (.x(S_j3_i3_g),  .y(S_j3_i3_mul));

    //=================================================================
    // GF constant multipliers for j=4 (2j+1 = 9)
    //=================================================================
    wire [5:0] R_j4_i1_mul, R_j4_i2_mul, R_j4_i3_mul;
    wire [5:0] S_j4_i1_mul, S_j4_i2_mul, S_j4_i3_mul;

    mul_a09 m_R_j4_i1 (.x(R_j4_i1),    .y(R_j4_i1_mul));
    mul_a18 m_R_j4_i2 (.x(R_j4_i2),    .y(R_j4_i2_mul));
    mul_a27 m_R_j4_i3 (.x(R_j4_i3),    .y(R_j4_i3_mul));
    mul_a09 m_S_j4_i1 (.x(S_j4_i1_g),  .y(S_j4_i1_mul));
    mul_a18 m_S_j4_i2 (.x(S_j4_i2_g),  .y(S_j4_i2_mul));
    mul_a27 m_S_j4_i3 (.x(S_j4_i3_g),  .y(S_j4_i3_mul));

    //=================================================================
    // GF constant multipliers for j=5 (2j+1 = 11)
    //=================================================================
    wire [5:0] R_j5_i1_mul, R_j5_i2_mul, R_j5_i3_mul;
    wire [5:0] S_j5_i1_mul, S_j5_i2_mul, S_j5_i3_mul;

    mul_a11 m_R_j5_i1 (.x(R_j5_i1),    .y(R_j5_i1_mul));
    mul_a22 m_R_j5_i2 (.x(R_j5_i2),    .y(R_j5_i2_mul));
    mul_a33 m_R_j5_i3 (.x(R_j5_i3),    .y(R_j5_i3_mul));
    mul_a11 m_S_j5_i1 (.x(S_j5_i1_g),  .y(S_j5_i1_mul));
    mul_a22 m_S_j5_i2 (.x(S_j5_i2_g),  .y(S_j5_i2_mul));
    mul_a33 m_S_j5_i3 (.x(S_j5_i3_g),  .y(S_j5_i3_mul));

    //=================================================================
    // 4 nsu_unit instances (one per j)
    //
    // Note: only one valid signal is exposed (they all fire together).
    //=================================================================
    wire valid_j2, valid_j3, valid_j4, valid_j5;

    nsu_unit u_nsu_j2 (
        .clk(clk), .rst(rst), .enable(enable),
        .R0(R_j2_i0),     .R1(R_j2_i1),     .R2(R_j2_i2),     .R3(R_j2_i3),
        .S0(S_j2_i0),     .S1(S_j2_i1),     .S2(S_j2_i2),     .S3(S_j2_i3),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .R1_mul(R_j2_i1_mul), .R2_mul(R_j2_i2_mul), .R3_mul(R_j2_i3_mul),
        .S1_mul(S_j2_i1_mul), .S2_mul(S_j2_i2_mul), .S3_mul(S_j2_i3_mul),
        .Shat0(Shat0_j2), .Shat1(Shat1_j2),
        .valid(valid_j2)
    );

    nsu_unit u_nsu_j3 (
        .clk(clk), .rst(rst), .enable(enable),
        .R0(R_j3_i0),     .R1(R_j3_i1),     .R2(R_j3_i2),     .R3(R_j3_i3),
        .S0(S_j3_i0),     .S1(S_j3_i1),     .S2(S_j3_i2),     .S3(S_j3_i3),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .R1_mul(R_j3_i1_mul), .R2_mul(R_j3_i2_mul), .R3_mul(R_j3_i3_mul),
        .S1_mul(S_j3_i1_mul), .S2_mul(S_j3_i2_mul), .S3_mul(S_j3_i3_mul),
        .Shat0(Shat0_j3), .Shat1(Shat1_j3),
        .valid(valid_j3)
    );

    nsu_unit u_nsu_j4 (
        .clk(clk), .rst(rst), .enable(enable),
        .R0(R_j4_i0),     .R1(R_j4_i1),     .R2(R_j4_i2),     .R3(R_j4_i3),
        .S0(S_j4_i0),     .S1(S_j4_i1),     .S2(S_j4_i2),     .S3(S_j4_i3),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .R1_mul(R_j4_i1_mul), .R2_mul(R_j4_i2_mul), .R3_mul(R_j4_i3_mul),
        .S1_mul(S_j4_i1_mul), .S2_mul(S_j4_i2_mul), .S3_mul(S_j4_i3_mul),
        .Shat0(Shat0_j4), .Shat1(Shat1_j4),
        .valid(valid_j4)
    );

    nsu_unit u_nsu_j5 (
        .clk(clk), .rst(rst), .enable(enable),
        .R0(R_j5_i0),     .R1(R_j5_i1),     .R2(R_j5_i2),     .R3(R_j5_i3),
        .S0(S_j5_i0),     .S1(S_j5_i1),     .S2(S_j5_i2),     .S3(S_j5_i3),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .R1_mul(R_j5_i1_mul), .R2_mul(R_j5_i2_mul), .R3_mul(R_j5_i3_mul),
        .S1_mul(S_j5_i1_mul), .S2_mul(S_j5_i2_mul), .S3_mul(S_j5_i3_mul),
        .Shat0(Shat0_j5), .Shat1(Shat1_j5),
        .valid(valid_j5)
    );

    assign valid = valid_j2;  // All 4 fire together; just expose one

endmodule
