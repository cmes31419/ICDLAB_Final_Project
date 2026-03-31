module gf_mul_1_1(
    input [1:0]     code,
    input [9:0]     in1,
    input [9:0]     in2,
    output [9:0]    out1
);

    wire [18:0]  tmp1;

    bin_mul_1_1 bm0(
        .in1(in1),
        .in2(in2),
        .out1(tmp1)
    );

    rotate_table_1_1 rt0(
        .code(code),
        .in1(tmp1),
        .out1(out1)
    );

endmodule

module bin_mul_1_1(
    input [9:0]         in1,
    input [9:0]         in2,
    output reg [18:0]   out1
);

    always @(*) begin
        out1[18] = in1[9] & in2[9];
        out1[17] = (in1[9] & in2[8]) ^ (in1[8] & in2[9]);
        out1[16] = (in1[9] & in2[7]) ^ (in1[8] & in2[8]) ^ (in1[7] & in2[9]);
        out1[15] = (in1[9] & in2[6]) ^ (in1[8] & in2[7]) ^ (in1[7] & in2[8]) ^ (in1[6] & in2[9]);
        out1[14] = (in1[9] & in2[5]) ^ (in1[8] & in2[6]) ^ (in1[7] & in2[7]) ^ (in1[6] & in2[8]) ^ (in1[5] & in2[9]);
        out1[13] = (in1[9] & in2[4]) ^ (in1[8] & in2[5]) ^ (in1[7] & in2[6]) ^ (in1[6] & in2[7]) ^ (in1[5] & in2[8]) ^ (in1[4] & in2[9]);
        out1[12] = (in1[9] & in2[3]) ^ (in1[8] & in2[4]) ^ (in1[7] & in2[5]) ^ (in1[6] & in2[6]) ^ (in1[5] & in2[7]) ^ (in1[4] & in2[8]) ^ (in1[3] & in2[9]);
        out1[11] = (in1[9] & in2[2]) ^ (in1[8] & in2[3]) ^ (in1[7] & in2[4]) ^ (in1[6] & in2[5]) ^ (in1[5] & in2[6]) ^ (in1[4] & in2[7]) ^ (in1[3] & in2[8]) ^ (in1[2] & in2[9]);
        out1[10] = (in1[9] & in2[1]) ^ (in1[8] & in2[2]) ^ (in1[7] & in2[3]) ^ (in1[6] & in2[4]) ^ (in1[5] & in2[5]) ^ (in1[4] & in2[6]) ^ (in1[3] & in2[7]) ^ (in1[2] & in2[8]) ^ (in1[1] & in2[9]);
        out1[9]  = (in1[9] & in2[0]) ^ (in1[8] & in2[1]) ^ (in1[7] & in2[2]) ^ (in1[6] & in2[3]) ^ (in1[5] & in2[4]) ^ (in1[4] & in2[5]) ^ (in1[3] & in2[6]) ^ (in1[2] & in2[7]) ^ (in1[1] & in2[8]) ^ (in1[0] & in2[9]);
        out1[8]  = (in1[8] & in2[0]) ^ (in1[7] & in2[1]) ^ (in1[6] & in2[2]) ^ (in1[5] & in2[3]) ^ (in1[4] & in2[4]) ^ (in1[3] & in2[5]) ^ (in1[2] & in2[6]) ^ (in1[1] & in2[7]) ^ (in1[0] & in2[8]);
        out1[7]  = (in1[7] & in2[0]) ^ (in1[6] & in2[1]) ^ (in1[5] & in2[2]) ^ (in1[4] & in2[3]) ^ (in1[3] & in2[4]) ^ (in1[2] & in2[5]) ^ (in1[1] & in2[6]) ^ (in1[0] & in2[7]);
        out1[6]  = (in1[6] & in2[0]) ^ (in1[5] & in2[1]) ^ (in1[4] & in2[2]) ^ (in1[3] & in2[3]) ^ (in1[2] & in2[4]) ^ (in1[1] & in2[5]) ^ (in1[0] & in2[6]);
        out1[5]  = (in1[5] & in2[0]) ^ (in1[4] & in2[1]) ^ (in1[3] & in2[2]) ^ (in1[2] & in2[3]) ^ (in1[1] & in2[4]) ^ (in1[0] & in2[5]);
        out1[4]  = (in1[4] & in2[0]) ^ (in1[3] & in2[1]) ^ (in1[2] & in2[2]) ^ (in1[1] & in2[3]) ^ (in1[0] & in2[4]);
        out1[3]  = (in1[3] & in2[0]) ^ (in1[2] & in2[1]) ^ (in1[1] & in2[2]) ^ (in1[0] & in2[3]);
        out1[2]  = (in1[2] & in2[0]) ^ (in1[1] & in2[1]) ^ (in1[0] & in2[2]);
        out1[1]  = (in1[1] & in2[0]) ^ (in1[0] & in2[1]);
        out1[0]  =  in1[0] & in2[0];
    end

endmodule

module rotate_table_1_1(
    input [1:0]         code,
    input [18:0]        in1,
    output reg [9:0]    out1
);

    always @(*) begin
        out1 = 0;
        case (code)
            2'd1: begin
                out1[0] = in1[0] ^ in1[6];
                out1[1] = in1[1] ^ in1[6] ^ in1[7];
                out1[2] = in1[2] ^ in1[7] ^ in1[8];
                out1[3] = in1[3] ^ in1[8] ^ in1[9];
                out1[4] = in1[4] ^ in1[9] ^ in1[10];
                out1[5] = in1[5] ^ in1[10];
            end
            2'd2: begin
                out1[0] = in1[0] ^ in1[8] ^ in1[12] ^ in1[13] ^ in1[14];
                out1[1] = in1[1] ^ in1[9] ^ in1[13] ^ in1[14];
                out1[2] = in1[2] ^ in1[8] ^ in1[10] ^ in1[12] ^ in1[13];
                out1[3] = in1[3] ^ in1[8] ^ in1[9] ^ in1[11] ^ in1[12];
                out1[4] = in1[4] ^ in1[8] ^ in1[9] ^ in1[10] ^ in1[14];
                out1[5] = in1[5] ^ in1[9] ^ in1[10] ^ in1[11];
                out1[6] = in1[6] ^ in1[10] ^ in1[11] ^ in1[12];
                out1[7] = in1[7] ^ in1[11] ^ in1[12] ^ in1[13];
            end
            2'd3: begin
                out1[0] = in1[0] ^ in1[10] ^ in1[17];
                out1[1] = in1[1] ^ in1[11] ^ in1[18];
                out1[2] = in1[2] ^ in1[12];
                out1[3] = in1[3] ^ in1[10] ^ in1[13] ^ in1[17];
                out1[4] = in1[4] ^ in1[11] ^ in1[14] ^ in1[18];
                out1[5] = in1[5] ^ in1[12] ^ in1[15];
                out1[6] = in1[6] ^ in1[13] ^ in1[16];
                out1[7] = in1[7] ^ in1[14] ^ in1[17];
                out1[8] = in1[8] ^ in1[15] ^ in1[18];
                out1[9] = in1[9] ^ in1[16];
            end
        endcase
    end

endmodule
