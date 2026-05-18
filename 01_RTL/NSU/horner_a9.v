//=========================================================================
// horner_a9.v - Parallel Horner unit: r(alpha^9) over GF(2^6)
//   n=63, P=32, cycles=2, fb_const=alpha^36
//   enable=0 freezes the unit (saves power)
//   On start: state is effectively cleared before update
//=========================================================================

module horner_a9 (
    input  wire              clk,
    input  wire              rst,
    input  wire              enable,
    input  wire              start,
    input  wire [31:0]         data,
    output reg  [5:0]          state,
    output reg               done
);

    wire [5:0] eff_state;
    assign eff_state = start ? 6'b0 : state;

    wire [5:0] next_state;
    assign next_state[0] = eff_state[2] ^ eff_state[4] ^ eff_state[5] ^ data[0] ^ data[2] ^ data[5] ^ data[6] ^ data[7] ^ data[9] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[19] ^ data[20] ^ data[21] ^ data[23] ^ data[26] ^ data[27] ^ data[28] ^ data[30];
    assign next_state[1] = eff_state[0] ^ eff_state[2] ^ eff_state[3] ^ eff_state[4] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[9] ^ data[10] ^ data[11] ^ data[13] ^ data[16] ^ data[17] ^ data[18] ^ data[20] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[30] ^ data[31];
    assign next_state[2] = eff_state[0] ^ eff_state[1] ^ eff_state[3] ^ eff_state[4] ^ eff_state[5] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[9] ^ data[10] ^ data[11] ^ data[13] ^ data[16] ^ data[17] ^ data[18] ^ data[20] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[30] ^ data[31];
    assign next_state[3] = eff_state[1] ^ eff_state[2] ^ eff_state[4] ^ eff_state[5] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[8] ^ data[9] ^ data[10] ^ data[12] ^ data[15] ^ data[16] ^ data[17] ^ data[19] ^ data[22] ^ data[23] ^ data[24] ^ data[26] ^ data[29] ^ data[30] ^ data[31];
    assign next_state[4] = eff_state[0] ^ eff_state[2] ^ eff_state[3] ^ eff_state[5] ^ data[1] ^ data[4] ^ data[5] ^ data[6] ^ data[8] ^ data[11] ^ data[12] ^ data[13] ^ data[15] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[25] ^ data[26] ^ data[27] ^ data[29];
    assign next_state[5] = eff_state[1] ^ eff_state[3] ^ eff_state[4];

    reg [0:0] cyc_cnt;
    reg              running;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= 6'b0;
            cyc_cnt  <= 1'b0;
            running  <= 1'b0;
            done     <= 1'b0;
        end else if (!enable) begin
            done <= 1'b0;
        end else if (start) begin
            state    <= next_state;
            cyc_cnt  <= 1'd1;
            running  <= 1'b1;
            done     <= 1'b0;
        end else if (running) begin
            state   <= next_state;
            if (cyc_cnt == 1'd1) begin
                running <= 1'b0;
                done    <= 1'b1;
                cyc_cnt <= 1'b0;
            end else begin
                cyc_cnt <= cyc_cnt + 1'd1;
                done    <= 1'b0;
            end
        end else begin
            done <= 1'b0;
        end
    end

    // Total XOR gates (combinational): 107
endmodule