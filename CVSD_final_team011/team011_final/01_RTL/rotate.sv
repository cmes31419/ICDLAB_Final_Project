module rotate_4_8(
    input [1:0]         code,
    input [9:0]         syn1,
    input [9:0]         syn3,
    input [9:0]         syn5,
    input [9:0]         syn7,
    output reg [9:0]    syn1_rot,
    output reg [9:0]    syn3_rot,
    output reg [9:0]    syn5_rot,
    output reg [9:0]    syn7_rot
);

    always @(*) begin
        syn1_rot = 0;
        syn3_rot = 0;
        syn5_rot = 0;
        syn7_rot = 0;
        case(code)
            2'd1: begin
                // x^6 + x + 1
                syn1_rot[0] =                               syn1[3] ^ syn1[4]          ;
                syn1_rot[1] =                               syn1[3]           ^ syn1[5];
                syn1_rot[2] = syn1[0]                               ^ syn1[4]          ;
                syn1_rot[3] = syn1[0] ^ syn1[1]                               ^ syn1[5];
                syn1_rot[4] =           syn1[1] ^ syn1[2]                              ;
                syn1_rot[5] =                     syn1[2] ^ syn1[3]                    ;
                // x^6 + x^4 + x^2 + x + 1
                syn3_rot[0] = syn3[0]                     ^ syn3[3]                    ;
                syn3_rot[1] = syn3[0] ^ syn3[1]           ^ syn3[3] ^ syn3[4]          ;
                syn3_rot[2] =           syn3[1] ^ syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5];
                syn3_rot[3] = syn3[0]           ^ syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5];
                syn3_rot[4] =           syn3[1]                     ^ syn3[4] ^ syn3[5];
                syn3_rot[5] =                     syn3[2]                     ^ syn3[5];
            end
            2'd2: begin
                // x^8 + x^4 + x^3 + x^2 + 1
                syn1_rot[0] = syn1[0]                               ^ syn1[4] ^ syn1[5] ^ syn1[6]          ;
                syn1_rot[1] =           syn1[1]                               ^ syn1[5] ^ syn1[6] ^ syn1[7];
                syn1_rot[2] = syn1[0]           ^ syn1[2]           ^ syn1[4] ^ syn1[5]           ^ syn1[7];
                syn1_rot[3] = syn1[0] ^ syn1[1]           ^ syn1[3] ^ syn1[4]                              ;
                syn1_rot[4] = syn1[0] ^ syn1[1] ^ syn1[2]                               ^ syn1[6]          ;
                syn1_rot[5] =           syn1[1] ^ syn1[2] ^ syn1[3]                               ^ syn1[7];
                syn1_rot[6] =                     syn1[2] ^ syn1[3] ^ syn1[4]                              ;
                syn1_rot[7] =                               syn1[3] ^ syn1[4] ^ syn1[5]                    ;
                // x^8 + x^6 + x^5 + x^4 + x^2 + x + 1
                syn3_rot[0] = syn3[0]           ^ syn3[2] ^ syn3[3]                     ^ syn3[6]          ;
                syn3_rot[1] = syn3[0] ^ syn3[1] ^ syn3[2]           ^ syn3[4]           ^ syn3[6] ^ syn3[7];
                syn3_rot[2] = syn3[0] ^ syn3[1]                               ^ syn3[5] ^ syn3[6] ^ syn3[7];
                syn3_rot[3] =           syn3[1] ^ syn3[2]                               ^ syn3[6] ^ syn3[7];
                syn3_rot[4] = syn3[0]                                                   ^ syn3[6] ^ syn3[7];
                syn3_rot[5] = syn3[0] ^ syn3[1] ^ syn3[2] ^ syn3[3]                     ^ syn3[6] ^ syn3[7];
                syn3_rot[6] = syn3[0] ^ syn3[1]                     ^ syn3[4]           ^ syn3[6] ^ syn3[7];
                syn3_rot[7] =           syn3[1] ^ syn3[2]                     ^ syn3[5]           ^ syn3[7];
            end
            2'd3: begin
                // x^10 + x^3 + 1
                syn1_rot[0] =           syn1[2]                                                             ^ syn1[9];
                syn1_rot[1] =                     syn1[3]                                                            ;
                syn1_rot[2] =                               syn1[4]                                                  ;
                syn1_rot[3] =           syn1[2]                     ^ syn1[5]                               ^ syn1[9];
                syn1_rot[4] =                     syn1[3]                     ^ syn1[6]                              ;
                syn1_rot[5] =                               syn1[4]                     ^ syn1[7]                    ;
                syn1_rot[6] =                                         syn1[5]                     ^ syn1[8]          ;
                syn1_rot[7] =                                                   syn1[6]                     ^ syn1[9];
                syn1_rot[8] = syn1[0]                                                   ^ syn1[7]                    ;
                syn1_rot[9] = syn1[1]                                                             ^ syn1[8]          ;
                // x^10 + x^3 + x^2 + x + 1
                syn3_rot[0] =           syn3[2]                                                             ^ syn3[9];
                syn3_rot[1] =           syn3[2] ^ syn3[3]                                                   ^ syn3[9];
                syn3_rot[2] =           syn3[2] ^ syn3[3] ^ syn3[4]                                         ^ syn3[9];
                syn3_rot[3] =           syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5]                               ^ syn3[9];
                syn3_rot[4] =                     syn3[3] ^ syn3[4] ^ syn3[5] ^ syn3[6]                              ;
                syn3_rot[5] =                               syn3[4] ^ syn3[5] ^ syn3[6] ^ syn3[7]                    ;
                syn3_rot[6] =                                         syn3[5] ^ syn3[6] ^ syn3[7] ^ syn3[8]          ;
                syn3_rot[7] =                                                   syn3[6] ^ syn3[7] ^ syn3[8] ^ syn3[9];
                syn3_rot[8] = syn3[0]                                                   ^ syn3[7] ^ syn3[8] ^ syn3[9];
                syn3_rot[9] = syn3[1]                                                             ^ syn3[8] ^ syn3[9];
                // x^10 + x^8 + x^3 + x^2 + 1
                syn5_rot[0] =           syn5[2]           ^ syn5[4]           ^ syn5[6]           ^ syn5[8] ^ syn5[9];
                syn5_rot[1] =                     syn5[3]           ^ syn5[5]           ^ syn5[7]           ^ syn5[9];
                syn5_rot[2] =           syn5[2]                                                             ^ syn5[9];
                syn5_rot[3] =           syn5[2] ^ syn5[3] ^ syn5[4]           ^ syn5[6]           ^ syn5[8] ^ syn5[9];
                syn5_rot[4] =                     syn5[3] ^ syn5[4] ^ syn5[5]           ^ syn5[7]           ^ syn5[9];
                syn5_rot[5] =                               syn5[4] ^ syn5[5] ^ syn5[6]           ^ syn5[8]          ;
                syn5_rot[6] =                                         syn5[5] ^ syn5[6] ^ syn5[7]           ^ syn5[9];
                syn5_rot[7] =                                                   syn5[6] ^ syn5[7] ^ syn5[8]          ;
                syn5_rot[8] = syn5[0] ^ syn5[2]           ^ syn5[4]           ^ syn5[6] ^ syn5[7]                    ;
                syn5_rot[9] = syn5[1]           ^ syn5[3]           ^ syn5[5]           ^ syn5[7] ^ syn5[8]          ;
                // x^10 + x^9 + x^8 + x^7 + x^6 + x^5 + x^4 + x^3 + 1
                syn7_rot[0] =           syn7[2] ^ syn7[3]                                                            ;
                syn7_rot[1] =                     syn7[3] ^ syn7[4]                                                  ;
                syn7_rot[2] =                               syn7[4] ^ syn7[5]                                        ;
                syn7_rot[3] =           syn7[2] ^ syn7[3]           ^ syn7[5] ^ syn7[6]                              ;
                syn7_rot[4] =           syn7[2]           ^ syn7[4]           ^ syn7[6] ^ syn7[7]                    ;
                syn7_rot[5] =           syn7[2]                     ^ syn7[5]           ^ syn7[7] ^ syn7[8]          ;
                syn7_rot[6] =           syn7[2]                               ^ syn7[6]           ^ syn7[8] ^ syn7[9];
                syn7_rot[7] =           syn7[2]                                         ^ syn7[7]           ^ syn7[9];
                syn7_rot[8] = syn7[0] ^ syn7[2]                                                   ^ syn7[8]          ;
                syn7_rot[9] = syn7[1] ^ syn7[2]                                                             ^ syn7[9];
            end
        endcase
    end

endmodule

module rotate_4_8_add(
    input [1:0]         code,
    input [9:0]         syn1,
    input [9:0]         syn3,
    input [9:0]         syn5,
    input [9:0]         syn7,
    input [7:0]         data,
    output reg [9:0]    syn1_rot,
    output reg [9:0]    syn3_rot,
    output reg [9:0]    syn5_rot,
    output reg [9:0]    syn7_rot
);

    always @(*) begin
        syn1_rot = 0;
        syn3_rot = 0;
        syn5_rot = 0;
        syn7_rot = 0;
        case(code)
            2'd1: begin
                // x^6 + x + 1
                syn1_rot[0] = data[0] ^ data[6]                                         ^ syn1[3] ^ syn1[4]          ;
                syn1_rot[1] = data[1] ^ data[6] ^ data[7]                               ^ syn1[3]           ^ syn1[5];
                syn1_rot[2] = data[2]           ^ data[7] ^ syn1[0]                               ^ syn1[4]          ;
                syn1_rot[3] = data[3]                     ^ syn1[0] ^ syn1[1]                               ^ syn1[5];
                syn1_rot[4] = data[4]                               ^ syn1[1] ^ syn1[2]                              ;
                syn1_rot[5] = data[5]                                         ^ syn1[2] ^ syn1[3]                    ;
                // x^6 + x^4 + x^2 + x + 1
                syn3_rot[0] = data[0] ^ data[6]           ^ syn3[0]                     ^ syn3[3]                    ;
                syn3_rot[1] = data[1] ^ data[6] ^ data[7] ^ syn3[0] ^ syn3[1]           ^ syn3[3] ^ syn3[4]          ;
                syn3_rot[2] = data[2] ^ data[6] ^ data[7]           ^ syn3[1] ^ syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5];
                syn3_rot[3] = data[3]           ^ data[7] ^ syn3[0]           ^ syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5];
                syn3_rot[4] = data[4] ^ data[6]                     ^ syn3[1]                     ^ syn3[4] ^ syn3[5];
                syn3_rot[5] = data[5]           ^ data[7]                     ^ syn3[2]                     ^ syn3[5];
            end
            2'd2: begin
                // x^8 + x^4 + x^3 + x^2 + 1
                syn1_rot[0] = data[0] ^ syn1[0]                               ^ syn1[4] ^ syn1[5] ^ syn1[6]          ;
                syn1_rot[1] = data[1]           ^ syn1[1]                               ^ syn1[5] ^ syn1[6] ^ syn1[7];
                syn1_rot[2] = data[2] ^ syn1[0]           ^ syn1[2]           ^ syn1[4] ^ syn1[5]           ^ syn1[7];
                syn1_rot[3] = data[3] ^ syn1[0] ^ syn1[1]           ^ syn1[3] ^ syn1[4]                              ;
                syn1_rot[4] = data[4] ^ syn1[0] ^ syn1[1] ^ syn1[2]                               ^ syn1[6]          ;
                syn1_rot[5] = data[5]           ^ syn1[1] ^ syn1[2] ^ syn1[3]                               ^ syn1[7];
                syn1_rot[6] = data[6]                     ^ syn1[2] ^ syn1[3] ^ syn1[4]                              ;
                syn1_rot[7] = data[7]                               ^ syn1[3] ^ syn1[4] ^ syn1[5]                    ;
                // x^8 + x^6 + x^5 + x^4 + x^2 + x + 1
                syn3_rot[0] = data[0] ^ syn3[0]           ^ syn3[2] ^ syn3[3]                     ^ syn3[6]          ;
                syn3_rot[1] = data[1] ^ syn3[0] ^ syn3[1] ^ syn3[2]           ^ syn3[4]           ^ syn3[6] ^ syn3[7];
                syn3_rot[2] = data[2] ^ syn3[0] ^ syn3[1]                               ^ syn3[5] ^ syn3[6] ^ syn3[7];
                syn3_rot[3] = data[3]           ^ syn3[1] ^ syn3[2]                               ^ syn3[6] ^ syn3[7];
                syn3_rot[4] = data[4] ^ syn3[0]                                                   ^ syn3[6] ^ syn3[7];
                syn3_rot[5] = data[5] ^ syn3[0] ^ syn3[1] ^ syn3[2] ^ syn3[3]                     ^ syn3[6] ^ syn3[7];
                syn3_rot[6] = data[6] ^ syn3[0] ^ syn3[1]                     ^ syn3[4]           ^ syn3[6] ^ syn3[7];
                syn3_rot[7] = data[7]           ^ syn3[1] ^ syn3[2]                     ^ syn3[5]           ^ syn3[7];
            end
            2'd3: begin
                // x^10 + x^3 + 1
                syn1_rot[0] = data[0] ^ syn1[2]                                                             ^ syn1[9];
                syn1_rot[1] = data[1]           ^ syn1[3]                                                            ;
                syn1_rot[2] = data[2]                     ^ syn1[4]                                                  ;
                syn1_rot[3] = data[3] ^ syn1[2]                     ^ syn1[5]                               ^ syn1[9];
                syn1_rot[4] = data[4]           ^ syn1[3]                     ^ syn1[6]                              ;
                syn1_rot[5] = data[5]                     ^ syn1[4]                     ^ syn1[7]                    ;
                syn1_rot[6] = data[6]                               ^ syn1[5]                     ^ syn1[8]          ;
                syn1_rot[7] = data[7]                                         ^ syn1[6]                     ^ syn1[9];
                syn1_rot[8] = syn1[0]                                                   ^ syn1[7]                    ;
                syn1_rot[9] = syn1[1]                                                             ^ syn1[8]          ;
                // x^10 + x^3 + x^2 + x + 1
                syn3_rot[0] = data[0] ^ syn3[2]                                                             ^ syn3[9];
                syn3_rot[1] = data[1] ^ syn3[2] ^ syn3[3]                                                   ^ syn3[9];
                syn3_rot[2] = data[2] ^ syn3[2] ^ syn3[3] ^ syn3[4]                                         ^ syn3[9];
                syn3_rot[3] = data[3] ^ syn3[2] ^ syn3[3] ^ syn3[4] ^ syn3[5]                               ^ syn3[9];
                syn3_rot[4] = data[4]           ^ syn3[3] ^ syn3[4] ^ syn3[5] ^ syn3[6]                              ;
                syn3_rot[5] = data[5]                     ^ syn3[4] ^ syn3[5] ^ syn3[6] ^ syn3[7]                    ;
                syn3_rot[6] = data[6]                               ^ syn3[5] ^ syn3[6] ^ syn3[7] ^ syn3[8]          ;
                syn3_rot[7] = data[7]                                         ^ syn3[6] ^ syn3[7] ^ syn3[8] ^ syn3[9];
                syn3_rot[8] = syn3[0]                                                   ^ syn3[7] ^ syn3[8] ^ syn3[9];
                syn3_rot[9] = syn3[1]                                                             ^ syn3[8] ^ syn3[9];
                // x^10 + x^8 + x^3 + x^2 + 1
                syn5_rot[0] = data[0] ^ syn5[2]           ^ syn5[4]           ^ syn5[6]           ^ syn5[8] ^ syn5[9];
                syn5_rot[1] = data[1]           ^ syn5[3]           ^ syn5[5]           ^ syn5[7]           ^ syn5[9];
                syn5_rot[2] = data[2] ^ syn5[2]                                                             ^ syn5[9];
                syn5_rot[3] = data[3] ^ syn5[2] ^ syn5[3] ^ syn5[4]           ^ syn5[6]           ^ syn5[8] ^ syn5[9];
                syn5_rot[4] = data[4]           ^ syn5[3] ^ syn5[4] ^ syn5[5]           ^ syn5[7]           ^ syn5[9];
                syn5_rot[5] = data[5]                     ^ syn5[4] ^ syn5[5] ^ syn5[6]           ^ syn5[8]          ;
                syn5_rot[6] = data[6]                               ^ syn5[5] ^ syn5[6] ^ syn5[7]           ^ syn5[9];
                syn5_rot[7] = data[7]                                         ^ syn5[6] ^ syn5[7] ^ syn5[8]          ;
                syn5_rot[8] = syn5[0] ^ syn5[2]           ^ syn5[4]           ^ syn5[6] ^ syn5[7]                    ;
                syn5_rot[9] = syn5[1]           ^ syn5[3]           ^ syn5[5]           ^ syn5[7] ^ syn5[8]          ;
                // x^10 + x^9 + x^8 + x^7 + x^6 + x^5 + x^4 + x^3 + 1
                syn7_rot[0] = data[0] ^ syn7[2] ^ syn7[3]                                                            ;
                syn7_rot[1] = data[1]           ^ syn7[3] ^ syn7[4]                                                  ;
                syn7_rot[2] = data[2]                     ^ syn7[4] ^ syn7[5]                                        ;
                syn7_rot[3] = data[3] ^ syn7[2] ^ syn7[3]           ^ syn7[5] ^ syn7[6]                              ;
                syn7_rot[4] = data[4] ^ syn7[2]           ^ syn7[4]           ^ syn7[6] ^ syn7[7]                    ;
                syn7_rot[5] = data[5] ^ syn7[2]                     ^ syn7[5]           ^ syn7[7] ^ syn7[8]          ;
                syn7_rot[6] = data[6] ^ syn7[2]                               ^ syn7[6]           ^ syn7[8] ^ syn7[9];
                syn7_rot[7] = data[7] ^ syn7[2]                                         ^ syn7[7]           ^ syn7[9];
                syn7_rot[8] = syn7[0] ^ syn7[2]                                                   ^ syn7[8]          ;
                syn7_rot[9] = syn7[1] ^ syn7[2]                                                             ^ syn7[9];
            end
        endcase
    end

endmodule

module rotate_8(
    input  [1:0]        code,
    input  [9:0]        sigma,
    output reg [9:0]    sigma_rot
);

    always @(*) begin
        sigma_rot = 10'b0;
        case (code)
            2'd1: begin  // m = 6, const = alpha^8 = 0xc
                sigma_rot[0] = sigma[3] ^ sigma[4];
                sigma_rot[1] = sigma[3] ^ sigma[5];
                sigma_rot[2] = sigma[0] ^ sigma[4];
                sigma_rot[3] = sigma[0] ^ sigma[1] ^ sigma[5];
                sigma_rot[4] = sigma[1] ^ sigma[2];
                sigma_rot[5] = sigma[2] ^ sigma[3];
            end
            2'd2: begin  // m = 8, const = alpha^8 = 0x1d
                sigma_rot[0] = sigma[0] ^ sigma[4] ^ sigma[5] ^ sigma[6];
                sigma_rot[1] = sigma[1] ^ sigma[5] ^ sigma[6] ^ sigma[7];
                sigma_rot[2] = sigma[0] ^ sigma[2] ^ sigma[4] ^ sigma[5] ^ sigma[7];
                sigma_rot[3] = sigma[0] ^ sigma[1] ^ sigma[3] ^ sigma[4];
                sigma_rot[4] = sigma[0] ^ sigma[1] ^ sigma[2] ^ sigma[6];
                sigma_rot[5] = sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[7];
                sigma_rot[6] = sigma[2] ^ sigma[3] ^ sigma[4];
                sigma_rot[7] = sigma[3] ^ sigma[4] ^ sigma[5];
            end
            2'd3: begin  // m = 10, const = alpha^8 = 0x100
                sigma_rot[0] = sigma[2] ^ sigma[9];
                sigma_rot[1] = sigma[3];
                sigma_rot[2] = sigma[4];
                sigma_rot[3] = sigma[2] ^ sigma[5] ^ sigma[9];
                sigma_rot[4] = sigma[3] ^ sigma[6];
                sigma_rot[5] = sigma[4] ^ sigma[7];
                sigma_rot[6] = sigma[5] ^ sigma[8];
                sigma_rot[7] = sigma[6] ^ sigma[9];
                sigma_rot[8] = sigma[0] ^ sigma[7];
                sigma_rot[9] = sigma[1] ^ sigma[8];
            end
        endcase
    end

endmodule

module rotate_16(
    input  [1:0]        code,
    input  [9:0]        sigma,
    output reg [9:0]    sigma_rot
);

    always @(*) begin
        sigma_rot = 10'b0;
        case (code)
            2'd1: begin  // m = 6, const = alpha^16 = 0x13
                sigma_rot[0] = sigma[0] ^ sigma[2] ^ sigma[5];
                sigma_rot[1] = sigma[0] ^ sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[5];
                sigma_rot[2] = sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[4];
                sigma_rot[3] = sigma[2] ^ sigma[3] ^ sigma[4] ^ sigma[5];
                sigma_rot[4] = sigma[0] ^ sigma[3] ^ sigma[4] ^ sigma[5];
                sigma_rot[5] = sigma[1] ^ sigma[4] ^ sigma[5];
            end
            2'd2: begin  // m = 8, const = alpha^16 = 0x4c
                sigma_rot[0] = sigma[2] ^ sigma[5] ^ sigma[7];
                sigma_rot[1] = sigma[3] ^ sigma[6];
                sigma_rot[2] = sigma[0] ^ sigma[2] ^ sigma[4] ^ sigma[5];
                sigma_rot[3] = sigma[0] ^ sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[6] ^ sigma[7];
                sigma_rot[4] = sigma[1] ^ sigma[3] ^ sigma[4] ^ sigma[5];
                sigma_rot[5] = sigma[2] ^ sigma[4] ^ sigma[5] ^ sigma[6];
                sigma_rot[6] = sigma[0] ^ sigma[3] ^ sigma[5] ^ sigma[6] ^ sigma[7];
                sigma_rot[7] = sigma[1] ^ sigma[4] ^ sigma[6] ^ sigma[7];
            end
            2'd3: begin  // m = 10, const = alpha^16 = 0x240
                sigma_rot[0] = sigma[1] ^ sigma[4] ^ sigma[8];
                sigma_rot[1] = sigma[2] ^ sigma[5] ^ sigma[9];
                sigma_rot[2] = sigma[3] ^ sigma[6];
                sigma_rot[3] = sigma[1] ^ sigma[7] ^ sigma[8];
                sigma_rot[4] = sigma[2] ^ sigma[8] ^ sigma[9];
                sigma_rot[5] = sigma[3] ^ sigma[9];
                sigma_rot[6] = sigma[0] ^ sigma[4];
                sigma_rot[7] = sigma[1] ^ sigma[5];
                sigma_rot[8] = sigma[2] ^ sigma[6];
                sigma_rot[9] = sigma[0] ^ sigma[3] ^ sigma[7];
            end
        endcase
    end

endmodule

module rotate_24(
    input  [1:0]        code,
    input  [9:0]        sigma,
    output reg [9:0]    sigma_rot
);

    always @(*) begin
        sigma_rot = 10'b0;
        case (code)
            2'd1: begin  // m = 6, const = alpha^24 = 0x11
                sigma_rot[0] = sigma[0] ^ sigma[2];
                sigma_rot[1] = sigma[1] ^ sigma[2] ^ sigma[3];
                sigma_rot[2] = sigma[2] ^ sigma[3] ^ sigma[4];
                sigma_rot[3] = sigma[3] ^ sigma[4] ^ sigma[5];
                sigma_rot[4] = sigma[0] ^ sigma[4] ^ sigma[5];
                sigma_rot[5] = sigma[1] ^ sigma[5];
            end
            2'd2: begin  // m = 8, const = alpha^24 = 0x8f
                sigma_rot[0] = sigma[0] ^ sigma[1];
                sigma_rot[1] = sigma[0] ^ sigma[1] ^ sigma[2];
                sigma_rot[2] = sigma[0] ^ sigma[2] ^ sigma[3];
                sigma_rot[3] = sigma[0] ^ sigma[3] ^ sigma[4];
                sigma_rot[4] = sigma[4] ^ sigma[5];
                sigma_rot[5] = sigma[5] ^ sigma[6];
                sigma_rot[6] = sigma[6] ^ sigma[7];
                sigma_rot[7] = sigma[0] ^ sigma[7];
            end
            2'd3: begin  // m = 10, const = alpha^24 = 0x19
                sigma_rot[0] = sigma[0] ^ sigma[6] ^ sigma[7];
                sigma_rot[1] = sigma[1] ^ sigma[7] ^ sigma[8];
                sigma_rot[2] = sigma[2] ^ sigma[8] ^ sigma[9];
                sigma_rot[3] = sigma[0] ^ sigma[3] ^ sigma[6] ^ sigma[7] ^ sigma[9];
                sigma_rot[4] = sigma[0] ^ sigma[1] ^ sigma[4] ^ sigma[7] ^ sigma[8];
                sigma_rot[5] = sigma[1] ^ sigma[2] ^ sigma[5] ^ sigma[8] ^ sigma[9];
                sigma_rot[6] = sigma[2] ^ sigma[3] ^ sigma[6] ^ sigma[9];
                sigma_rot[7] = sigma[3] ^ sigma[4] ^ sigma[7];
                sigma_rot[8] = sigma[4] ^ sigma[5] ^ sigma[8];
                sigma_rot[9] = sigma[5] ^ sigma[6] ^ sigma[9];
            end
        endcase
    end

endmodule

module rotate_32(
    input  [1:0]        code,
    input  [9:0]        sigma,
    output reg [9:0]    sigma_rot
);

    always @(*) begin
        sigma_rot = 10'b0;
        case (code)
            2'd1: begin  // m = 6, const = alpha^32 = 0x9
                sigma_rot[0] = sigma[0] ^ sigma[3];
                sigma_rot[1] = sigma[1] ^ sigma[3] ^ sigma[4];
                sigma_rot[2] = sigma[2] ^ sigma[4] ^ sigma[5];
                sigma_rot[3] = sigma[0] ^ sigma[3] ^ sigma[5];
                sigma_rot[4] = sigma[1] ^ sigma[4];
                sigma_rot[5] = sigma[2] ^ sigma[5];
            end
            2'd2: begin  // m = 8, const = alpha^32 = 0x9d
                sigma_rot[0] = sigma[0] ^ sigma[1] ^ sigma[4] ^ sigma[7];
                sigma_rot[1] = sigma[1] ^ sigma[2] ^ sigma[5];
                sigma_rot[2] = sigma[0] ^ sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[4] ^ sigma[6] ^ sigma[7];
                sigma_rot[3] = sigma[0] ^ sigma[2] ^ sigma[3] ^ sigma[5];
                sigma_rot[4] = sigma[0] ^ sigma[3] ^ sigma[6] ^ sigma[7];
                sigma_rot[5] = sigma[1] ^ sigma[4] ^ sigma[7];
                sigma_rot[6] = sigma[2] ^ sigma[5];
                sigma_rot[7] = sigma[0] ^ sigma[3] ^ sigma[6];
            end
            2'd3: begin  // m = 10, const = alpha^32 = 0x136
                sigma_rot[0] = sigma[2] ^ sigma[5] ^ sigma[6] ^ sigma[8];
                sigma_rot[1] = sigma[0] ^ sigma[3] ^ sigma[6] ^ sigma[7] ^ sigma[9];
                sigma_rot[2] = sigma[0] ^ sigma[1] ^ sigma[4] ^ sigma[7] ^ sigma[8];
                sigma_rot[3] = sigma[1] ^ sigma[6] ^ sigma[9];
                sigma_rot[4] = sigma[0] ^ sigma[2] ^ sigma[7];
                sigma_rot[5] = sigma[0] ^ sigma[1] ^ sigma[3] ^ sigma[8];
                sigma_rot[6] = sigma[1] ^ sigma[2] ^ sigma[4] ^ sigma[9];
                sigma_rot[7] = sigma[2] ^ sigma[3] ^ sigma[5];
                sigma_rot[8] = sigma[0] ^ sigma[3] ^ sigma[4] ^ sigma[6];
                sigma_rot[9] = sigma[1] ^ sigma[4] ^ sigma[5] ^ sigma[7];
            end
        endcase
    end

endmodule
