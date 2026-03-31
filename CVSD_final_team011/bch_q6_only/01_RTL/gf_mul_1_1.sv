module gf_mul_1_1(
    input [5:0]     in1,
    input [5:0]     in2,
    output [5:0]    out1
);

    wire [10:0]  tmp1;

    bin_mul_1_1 bm0(
        .in1(in1),
        .in2(in2),
        .out1(tmp1)
    );

    rotate_table_1_1 rt0(
        .in1(tmp1),
        .out1(out1)
    );

endmodule

module bin_mul_1_1(
    input [5:0]         in1,
    input [5:0]         in2,
    output reg [10:0]   out1
);

    always @(*) begin
        out1[10] =  in1[5] & in2[5];
        out1[9]  = (in1[5] & in2[4]) ^ (in1[4] & in2[5]);
        out1[8]  = (in1[5] & in2[3]) ^ (in1[4] & in2[4]) ^ (in1[3] & in2[5]);
        out1[7]  = (in1[5] & in2[2]) ^ (in1[4] & in2[3]) ^ (in1[3] & in2[4]) ^ (in1[2] & in2[5]);
        out1[6]  = (in1[5] & in2[1]) ^ (in1[4] & in2[2]) ^ (in1[3] & in2[3]) ^ (in1[2] & in2[4]) ^ (in1[1] & in2[5]);
        out1[5]  = (in1[5] & in2[0]) ^ (in1[4] & in2[1]) ^ (in1[3] & in2[2]) ^ (in1[2] & in2[3]) ^ (in1[1] & in2[4]) ^ (in1[0] & in2[5]);
        out1[4]  = (in1[4] & in2[0]) ^ (in1[3] & in2[1]) ^ (in1[2] & in2[2]) ^ (in1[1] & in2[3]) ^ (in1[0] & in2[4]);
        out1[3]  = (in1[3] & in2[0]) ^ (in1[2] & in2[1]) ^ (in1[1] & in2[2]) ^ (in1[0] & in2[3]);
        out1[2]  = (in1[2] & in2[0]) ^ (in1[1] & in2[1]) ^ (in1[0] & in2[2]);
        out1[1]  = (in1[1] & in2[0]) ^ (in1[0] & in2[1]);
        out1[0]  =  in1[0] & in2[0];
    end

endmodule

module rotate_table_1_1(
    input [10:0]        in1,
    output reg [5:0]    out1
);

    always @(*) begin
        out1[0] = in1[0] ^ in1[6];
        out1[1] = in1[1] ^ in1[6] ^ in1[7];
        out1[2] = in1[2] ^ in1[7] ^ in1[8];
        out1[3] = in1[3] ^ in1[8] ^ in1[9];
        out1[4] = in1[4] ^ in1[9] ^ in1[10];
        out1[5] = in1[5] ^ in1[10];
    end

endmodule
