//=========================================================================
// horner_a5.v - Parallel Horner unit: r(alpha^5) over GF(2^6)
//   n=63, P=32, cycles=2, fb_const=alpha^34
//   enable=0 freezes the unit (saves power)
//   On start: state is effectively cleared before update
//=========================================================================

module horner_a5 (
    input  wire              clk,
    input  wire              rst,
    input  wire              enable,
    input  wire              start,
    input  wire [31:0]       data,
    input  wire [5:0]        state,
    output wire [5:0]        next_state
);

    wire [5:0] eff_state;
    assign eff_state = enable ? (start ? 6'b0 : state) : 6'b0;

    wire [31:0] eff_data;
    assign eff_data = enable ? data : 32'b0;

    assign next_state[0] = eff_state[1] ^ eff_state[4] ^ eff_data[0] ^ eff_data[6] ^ eff_data[7] ^ eff_data[8] ^ eff_data[9] ^ eff_data[12] ^ eff_data[15] ^ eff_data[17] ^ eff_data[19] ^ eff_data[22] ^ eff_data[23] ^ eff_data[25] ^ eff_data[30];
    assign next_state[1] = eff_state[1] ^ eff_state[2] ^ eff_state[4] ^ eff_state[5] ^ eff_data[5] ^ eff_data[6] ^ eff_data[7] ^ eff_data[8] ^ eff_data[11] ^ eff_data[14] ^ eff_data[16] ^ eff_data[18] ^ eff_data[21] ^ eff_data[22] ^ eff_data[24] ^ eff_data[29];
    assign next_state[2] = eff_state[0] ^ eff_state[2] ^ eff_state[3] ^ eff_state[5] ^ eff_data[4] ^ eff_data[8] ^ eff_data[10] ^ eff_data[11] ^ eff_data[13] ^ eff_data[14] ^ eff_data[15] ^ eff_data[16] ^ eff_data[17] ^ eff_data[18] ^ eff_data[20] ^ eff_data[22] ^ eff_data[23] ^ eff_data[24] ^ eff_data[28] ^ eff_data[29];
    assign next_state[3] = eff_state[1] ^ eff_state[3] ^ eff_state[4] ^ eff_data[3] ^ eff_data[4] ^ eff_data[7] ^ eff_data[8] ^ eff_data[9] ^ eff_data[11] ^ eff_data[12] ^ eff_data[18] ^ eff_data[19] ^ eff_data[20] ^ eff_data[21] ^ eff_data[24] ^ eff_data[27] ^ eff_data[29] ^ eff_data[31];
    assign next_state[4] = eff_state[2] ^ eff_state[4] ^ eff_state[5] ^ eff_data[2] ^ eff_data[4] ^ eff_data[6] ^ eff_data[9] ^ eff_data[10] ^ eff_data[12] ^ eff_data[17] ^ eff_data[21] ^ eff_data[23] ^ eff_data[24] ^ eff_data[26] ^ eff_data[27] ^ eff_data[28] ^ eff_data[29] ^ eff_data[30] ^ eff_data[31];
    assign next_state[5] = eff_state[0] ^ eff_state[3] ^ eff_state[5] ^ eff_data[1] ^ eff_data[2] ^ eff_data[3] ^ eff_data[4] ^ eff_data[5] ^ eff_data[6] ^ eff_data[8] ^ eff_data[10] ^ eff_data[11] ^ eff_data[12] ^ eff_data[16] ^ eff_data[17] ^ eff_data[20] ^ eff_data[21] ^ eff_data[22] ^ eff_data[24] ^ eff_data[25] ^ eff_data[31];

    // Total XOR gates (combinational): 103
endmodule