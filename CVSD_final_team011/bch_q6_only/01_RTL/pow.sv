module pow_a_2(
    input [5:0]         pow1,
    output reg [5:0]    pow2
);

    always @(*) begin
        pow2[5:0] = {
            pow1[5],
            pow1[2] ^ pow1[5],
            pow1[4],
            pow1[1] ^ pow1[4],
            pow1[3],
            pow1[0] ^ pow1[3]
        };
    end

endmodule

module pow_a_3(
    input [5:0]         pow1,
    output reg [5:0]    pow3
);

    always @(*) begin
        pow3 = {
            pow1[5],
            pow1[3],
            pow1[1] ^ pow1[3] ^ pow1[5],
            pow1[4],
            pow1[2],
            pow1[0] ^ pow1[2] ^ pow1[4]
        };
    end

endmodule
