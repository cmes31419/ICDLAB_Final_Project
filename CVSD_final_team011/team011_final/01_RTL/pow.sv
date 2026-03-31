module pow_a_2(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow2
);

    always @(*) begin
        pow2 = 0;
        case(code)
            2'd1: begin
                pow2[5:0] = {
                    pow1[5],
                    pow1[2] ^ pow1[5],
                    pow1[4],
                    pow1[1] ^ pow1[4],
                    pow1[3],
                    pow1[0] ^ pow1[3]
                };
            end
            2'd2: begin
                pow2[7:0] = {
                    pow1[6],
                    pow1[3] ^ pow1[5] ^ pow1[6],
                    pow1[5],
                    pow1[2] ^ pow1[4] ^ pow1[5] ^ pow1[7],
                    pow1[4] ^ pow1[6],
                    pow1[1] ^ pow1[4] ^ pow1[5] ^ pow1[6],
                    pow1[7],
                    pow1[0] ^ pow1[4] ^ pow1[6] ^ pow1[7]
                };
            end
            2'd3: begin
                pow2 = {
                    pow1[8],
                    pow1[4] ^ pow1[9],
                    pow1[7],
                    pow1[3] ^ pow1[8],
                    pow1[6],
                    pow1[2] ^ pow1[7] ^ pow1[9],
                    pow1[5],
                    pow1[1] ^ pow1[6],
                    pow1[9],
                    pow1[0] ^ pow1[5]
                };
            end
        endcase
    end

endmodule

module pow_a_3(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow3
);

    always @(*) begin
        pow3 = 0;
        case(code)
            2'd1: begin
                pow3[5:0] = {
                    pow1[5],
                    pow1[3],
                    pow1[1] ^ pow1[3] ^ pow1[5],
                    pow1[4],
                    pow1[2],
                    pow1[0] ^ pow1[2] ^ pow1[4]
                };
            end
            2'd2: begin
                pow3[7:0] = {
                    pow1[4],
                    pow1[2] ^ pow1[4] ^ pow1[7],
                    pow1[3] ^ pow1[5] ^ pow1[6] ^ pow1[7],
                    pow1[3] ^ pow1[7],
                    pow1[1] ^ pow1[3] ^ pow1[4] ^ pow1[6],
                    pow1[4] ^ pow1[5] ^ pow1[6] ^ pow1[7],
                    pow1[3] ^ pow1[5],
                    pow1[0] ^ pow1[4] ^ pow1[6] ^ pow1[7]
                };
            end
            2'd3: begin
                pow3 = {
                    pow1[3],
                    pow1[5] ^ pow1[6],
                    pow1[7] ^ pow1[9],
                    pow1[2] ^ pow1[9],
                    pow1[4] ^ pow1[5],
                    pow1[6] ^ pow1[8],
                    pow1[1] ^ pow1[8] ^ pow1[9],
                    pow1[4],
                    pow1[6] ^ pow1[7],
                    pow1[0] ^ pow1[8]
                };
            end
        endcase
    end

endmodule

module pow_a_4(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow4
);

    always @(*) begin
        pow4 = 0;
        case(code)
            2'd1: begin
                pow4[5:0] = {
                    pow1[5],
                    pow1[1] ^ pow1[4] ^ pow1[5],
                    pow1[2] ^ pow1[5],
                    pow1[2] ^ pow1[3] ^ pow1[5],
                    pow1[4],
                    pow1[0] ^ pow1[3] ^ pow1[4]
                };
            end
            2'd2: begin
                pow4[7:0] = {
                    pow1[3] ^ pow1[5] ^ pow1[6],
                    pow1[3] ^ pow1[4],
                    pow1[5],
                    pow1[1] ^ pow1[2] ^ pow1[5] ^ pow1[7],
                    pow1[2] ^ pow1[3] ^ pow1[4] ^ pow1[6] ^ pow1[7],
                    pow1[2] ^ pow1[3] ^ pow1[4] ^ pow1[5] ^ pow1[6],
                    pow1[6],
                    pow1[0] ^ pow1[2] ^ pow1[3] ^ pow1[6]
                };
            end
            2'd3: begin
                pow4 = {
                    pow1[4] ^ pow1[9],
                    pow1[2] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                    pow1[7],
                    pow1[4] ^ pow1[5] ^ pow1[9],
                    pow1[3] ^ pow1[8],
                    pow1[1] ^ pow1[6] ^ pow1[7] ^ pow1[8],
                    pow1[6],
                    pow1[3] ^ pow1[8] ^ pow1[9],
                    pow1[8],
                    pow1[0] ^ pow1[5] ^ pow1[6]
                };
            end
        endcase
    end

endmodule

module pow_a_5(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow5
);

    always @(*) begin
        pow5 = 0;
        if (code == 2'd3) begin
            pow5 = {
                pow1[6],
                pow1[3] ^ pow1[7],
                pow1[7] ^ pow1[9],
                pow1[4] ^ pow1[6],
                pow1[1] ^ pow1[3] ^ pow1[5] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[5],
                pow1[2] ^ pow1[6] ^ pow1[9],
                pow1[8],
                pow1[5] ^ pow1[7],
                pow1[0] ^ pow1[2] ^ pow1[4] ^ pow1[6] ^ pow1[8] ^ pow1[9]
            };
        end
    end

endmodule

module pow_a_6(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow6
);

    always @(*) begin
        pow6 = 0;
        if (code == 2'd3) begin
            pow6 = {
                pow1[5] ^ pow1[6],
                pow1[3] ^ pow1[6] ^ pow1[8],
                pow1[7] ^ pow1[9],
                pow1[1] ^ pow1[5] ^ pow1[6] ^ pow1[8] ^ pow1[9],
                pow1[2] ^ pow1[9],
                pow1[3] ^ pow1[4] ^ pow1[7] ^ pow1[9],
                pow1[4] ^ pow1[5],
                pow1[2] ^ pow1[6] ^ pow1[7] ^ pow1[9],
                pow1[3],
                pow1[0] ^ pow1[4] ^ pow1[5] ^ pow1[8]
            };
        end
    end

endmodule

module pow_a_7(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow7
);

    always @(*) begin
        pow7 = 0;
        if (code == 2'd3) begin
            pow7 = {
                pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[4] ^ pow1[5] ^ pow1[8] ^ pow1[9],
                pow1[1] ^ pow1[2] ^ pow1[3] ^ pow1[4] ^ pow1[5] ^ pow1[6] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[8],
                pow1[5] ^ pow1[9],
                pow1[2] ^ pow1[4] ^ pow1[6] ^ pow1[8],
                pow1[9],
                pow1[6],
                pow1[3] ^ pow1[5] ^ pow1[7] ^ pow1[9],
                pow1[0]
            };
        end
    end

endmodule

module pow_a_8(
    input [1:0]         code,
    input [9:0]         pow1,
    output reg [9:0]    pow8
);

    always @(*) begin
        pow8 = 0;
        if (code == 2'd3) begin
            pow8 = {
                pow1[2] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[1] ^ pow1[4] ^ pow1[6] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[7],
                pow1[2] ^ pow1[6] ^ pow1[7] ^ pow1[8] ^ pow1[9],
                pow1[4] ^ pow1[5] ^ pow1[9],
                pow1[3] ^ pow1[4] ^ pow1[7] ^ pow1[8],
                pow1[3] ^ pow1[8],
                pow1[4] ^ pow1[5] ^ pow1[8] ^ pow1[9],
                pow1[4] ^ pow1[9],
                pow1[0] ^ pow1[3] ^ pow1[5] ^ pow1[6] ^ pow1[8]
            };
        end
    end

endmodule
