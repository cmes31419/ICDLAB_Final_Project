module gf_square(
    input  [5:0] in1,
    output [5:0] prod
);

    wire [10:0] raw_prod;

    binary_mul u_binary_mul (
        .in1(in1),
        .raw_prod(raw_prod)
    );

    reduction_table u_reduction_table (
        .in1(raw_prod),
        .prod(prod)
    );

endmodule

module binary_mul(
    input  [5:0] in1,
    output reg [10:0] raw_prod
);

    always @(*) begin
        raw_prod[10] = (in1[5] & in1[5]);
        raw_prod[9]  = (in1[4] & in1[5]) ^ (in1[5] & in1[4]);
        raw_prod[8]  = (in1[3] & in1[5]) ^ (in1[4] & in1[4]) ^ (in1[5] & in1[3]);
        raw_prod[7]  = (in1[2] & in1[5]) ^ (in1[3] & in1[4]) ^ (in1[4] & in1[3]) ^ (in1[5] & in1[2]);
        raw_prod[6]  = (in1[1] & in1[5]) ^ (in1[2] & in1[4]) ^ (in1[3] & in1[3]) ^ (in1[4] & in1[2]) ^ (in1[5] & in1[1]);
        raw_prod[5]  = (in1[0] & in1[5]) ^ (in1[1] & in1[4]) ^ (in1[2] & in1[3]) ^ (in1[3] & in1[2]) ^ (in1[4] & in1[1]) ^ (in1[5] & in1[0]);
        raw_prod[4]  = (in1[0] & in1[4]) ^ (in1[1] & in1[3]) ^ (in1[2] & in1[2]) ^ (in1[3] & in1[1]) ^ (in1[4] & in1[0]);
        raw_prod[3]  = (in1[0] & in1[3]) ^ (in1[1] & in1[2]) ^ (in1[2] & in1[1]) ^ (in1[3] & in1[0]);
        raw_prod[2]  = (in1[0] & in1[2]) ^ (in1[1] & in1[1]) ^ (in1[2] & in1[0]);
        raw_prod[1]  = (in1[0] & in1[1]) ^ (in1[1] & in1[0]);
        raw_prod[0]  = (in1[0] & in1[0]);
    end

endmodule

module reduction_table(
    input  [10:0] in1,
    output reg [5:0] prod
);

    always @(*) begin
        prod[0]  = in1[0] ^ in1[6];
        prod[1]  = in1[1] ^ in1[6] ^ in1[7];
        prod[2]  = in1[2] ^ in1[7] ^ in1[8];
        prod[3]  = in1[3] ^ in1[8] ^ in1[9];
        prod[4]  = in1[4] ^ in1[9] ^ in1[10];
        prod[5]  = in1[5] ^ in1[10];
    end

endmodule

