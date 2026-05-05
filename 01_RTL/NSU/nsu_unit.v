//=====================================================================
// nsu_unit.v
//
// Nested Syndrome Unit for one specific j value in GII-BCH decoder
// 
// Spec: m=4 interleaves, v=2 nested codes, GF(2^6), psi(x)=x^6+x+1
//
// Computes (combinational + output register):
//
//   Shat0 = sum_{i=0..3} R[i]                       (k=0, all coeffs = 1)
//           ^ sum_{i: f[i]=1} S[i]
//
//   Shat1 = sum_{i=0..3} alpha^((2j+1)*i) * R[i]    (k=1, varying coeffs)
//           ^ sum_{i: f[i]=1} alpha^((2j+1)*i) * S[i]
//
// The actual constants used depend on j and are wired at instance level
// in the parent module. This module is parameterized to take 3 constant
// multipliers (for i=1,2,3; i=0 has coefficient 1 = pass-through).
//
// Latency: 1 cycle (output register only)
// Throughput: 1 enable/cycle
//=====================================================================

module nsu_unit (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,        // 1-cycle pulse to latch result

    // Received-word evaluations: r_i(alpha^(2j+1)) for i = 0..3
    input  wire [5:0]  R0,
    input  wire [5:0]  R1,
    input  wire [5:0]  R2,
    input  wire [5:0]  R3,

    // High-order syndromes from HOSU: S_(2j)^(i) for i = 0..3
    input  wire [5:0]  S0,
    input  wire [5:0]  S1,
    input  wire [5:0]  S2,
    input  wire [5:0]  S3,

    // Decoded flags: f[i] = 1 if interleave i decoded, else 0
    input  wire        f0,
    input  wire        f1,
    input  wire        f2,
    input  wire        f3,

    // Pre-multiplied versions of R1, R2, R3 (k=1 path)
    // The parent module wires these through GF constant multipliers
    // appropriate for this j value.
    input  wire [5:0]  R1_mul,    // = alpha^((2j+1)*1) * R1
    input  wire [5:0]  R2_mul,    // = alpha^((2j+1)*2) * R2
    input  wire [5:0]  R3_mul,    // = alpha^((2j+1)*3) * R3

    // Pre-multiplied versions of S1, S2, S3 (after flag gating)
    input  wire [5:0]  S1_mul,    // = alpha^((2j+1)*1) * S1 (gated)
    input  wire [5:0]  S2_mul,    // = alpha^((2j+1)*2) * S2 (gated)
    input  wire [5:0]  S3_mul,    // = alpha^((2j+1)*3) * S3 (gated)

    // Outputs (registered)
    output reg  [5:0]  Shat0,
    output reg  [5:0]  Shat1,
    output reg         valid
);

    //-----------------------------------------------------------------
    // Flag gating for S0 (other S already gated externally before mul)
    //-----------------------------------------------------------------
    wire [5:0] S0_gated;
    assign S0_gated = f0 ? S0 : 6'b0;

    //-----------------------------------------------------------------
    // Note: S1_mul, S2_mul, S3_mul are pre-gated and pre-multiplied
    // by the parent (gate first, then multiply). This is equivalent
    // to multiplying then gating because gating with 0 stays 0.
    //-----------------------------------------------------------------

    //-----------------------------------------------------------------
    // k=0 path: coefficients all = 1, pure XOR tree
    //-----------------------------------------------------------------
    // S1, S2, S3 also need flag gating for the k=0 path
    // (we use the gated versions before multiplication)
    wire [5:0] S1_gated_k0, S2_gated_k0, S3_gated_k0;
    assign S1_gated_k0 = f1 ? S1 : 6'b0;
    assign S2_gated_k0 = f2 ? S2 : 6'b0;
    assign S3_gated_k0 = f3 ? S3 : 6'b0;

    wire [5:0] Shat0_raw;
    wire [5:0] Shat0_dec;
    wire [5:0] Shat0_comb;

    assign Shat0_raw = R0 ^ R1 ^ R2 ^ R3;
    assign Shat0_dec = S0_gated ^ S1_gated_k0 ^ S2_gated_k0 ^ S3_gated_k0;
    assign Shat0_comb = Shat0_raw ^ Shat0_dec;

    //-----------------------------------------------------------------
    // k=1 path: uses pre-multiplied inputs from parent
    //-----------------------------------------------------------------
    wire [5:0] Shat1_raw;
    wire [5:0] Shat1_dec;
    wire [5:0] Shat1_comb;

    assign Shat1_raw = R0 ^ R1_mul ^ R2_mul ^ R3_mul;
    assign Shat1_dec = S0_gated ^ S1_mul ^ S2_mul ^ S3_mul;
    assign Shat1_comb = Shat1_raw ^ Shat1_dec;

    //-----------------------------------------------------------------
    // Output register
    //-----------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Shat0 <= 6'b0;
            Shat1 <= 6'b0;
            valid <= 1'b0;
        end else if (enable) begin
            Shat0 <= Shat0_comb;
            Shat1 <= Shat1_comb;
            valid <= 1'b1;
        end else begin
            valid <= 1'b0;
        end
    end

endmodule
