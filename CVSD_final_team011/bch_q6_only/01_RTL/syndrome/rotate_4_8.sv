module rotate_4_8(
    input [5:0]         syn1,
    input [5:0]         syn3,
    output reg [5:0]    syn1_rot,
    output reg [5:0]    syn3_rot
);

    always @(*) begin
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

endmodule

module rotate_4_8_add(
    input [5:0]         syn1,
    input [5:0]         syn3,
    input [7:0]         data,
    output reg [5:0]    syn1_rot,
    output reg [5:0]    syn3_rot
);

    always @(*) begin
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

endmodule
