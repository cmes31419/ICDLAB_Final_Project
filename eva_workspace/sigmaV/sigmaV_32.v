module sigmaV(
    input  [5:0]        sigma[6:0],
    output reg [5:0]    y[31:0]
);

    wire [5:0]  sigmaE[3:0][31:0];

    sigmaE se0(
        .sigma(sigma),
        .y(sigmaE)
    );

    sigmaEB seb0(
        .sigmaE(sigmaE),
        .sigma0(sigma[0]),
        .y(y)
    );

endmodule

module sigmaE(
    input  [5:0]      sigma[6:0],
    output reg [5:0]  y[3:0][31:0]
);

    always @* begin
        y[0][0][0] = sigma[1][0] ^ sigma[2][0] ^ sigma[4][0];
        y[0][0][1] = sigma[1][1] ^ sigma[2][1] ^ sigma[4][1];
        y[0][0][2] = sigma[1][2] ^ sigma[2][2] ^ sigma[4][2];
        y[0][0][3] = sigma[1][3] ^ sigma[2][3] ^ sigma[4][3];
        y[0][0][4] = sigma[1][4] ^ sigma[2][4] ^ sigma[4][4];
        y[0][0][5] = sigma[1][5] ^ sigma[2][5] ^ sigma[4][5];

        y[0][1][0] = sigma[1][5] ^ sigma[2][4] ^ sigma[4][2];
        y[0][1][1] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[4][2] ^ sigma[4][3];
        y[0][1][2] = sigma[1][1] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[4][3] ^ sigma[4][4];
        y[0][1][3] = sigma[1][2] ^ sigma[2][1] ^ sigma[4][4] ^ sigma[4][5];
        y[0][1][4] = sigma[1][3] ^ sigma[2][2] ^ sigma[4][0] ^ sigma[4][5];
        y[0][1][5] = sigma[1][4] ^ sigma[2][3] ^ sigma[4][1];

        y[0][2][0] = sigma[1][4] ^ sigma[2][2] ^ sigma[4][3] ^ sigma[4][4];
        y[0][2][1] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[4][3] ^ sigma[4][5];
        y[0][2][2] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[4][0] ^ sigma[4][4];
        y[0][2][3] = sigma[1][1] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][5];
        y[0][2][4] = sigma[1][2] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[4][1] ^ sigma[4][2];
        y[0][2][5] = sigma[1][3] ^ sigma[2][1] ^ sigma[4][2] ^ sigma[4][3];

        y[0][3][0] = sigma[1][3] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[4][0] ^ sigma[4][4];
        y[0][3][1] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[4][1] ^ sigma[4][4] ^ sigma[4][5];
        y[0][3][2] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[4][0] ^ sigma[4][2] ^ sigma[4][5];
        y[0][3][3] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[4][1] ^ sigma[4][3];
        y[0][3][4] = sigma[1][1] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[4][2] ^ sigma[4][4];
        y[0][3][5] = sigma[1][2] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[4][3] ^ sigma[4][5];

        y[0][4][0] = sigma[1][2] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[4][0] ^ sigma[4][2] ^ sigma[4][5];
        y[0][4][1] = sigma[1][2] ^ sigma[1][3] ^ sigma[2][3] ^ sigma[2][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][5];
        y[0][4][2] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][4] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4];
        y[0][4][3] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[4][5];
        y[0][4][4] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[4][0] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[4][5];
        y[0][4][5] = sigma[1][1] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[4][1] ^ sigma[4][4] ^ sigma[4][5];

        y[0][5][0] = sigma[1][1] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4];
        y[0][5][1] = sigma[1][1] ^ sigma[1][2] ^ sigma[2][1] ^ sigma[2][3] ^ sigma[4][1] ^ sigma[4][5];
        y[0][5][2] = sigma[1][2] ^ sigma[1][3] ^ sigma[2][2] ^ sigma[2][4] ^ sigma[4][0] ^ sigma[4][2];
        y[0][5][3] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][3] ^ sigma[2][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][3];
        y[0][5][4] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][4] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][4];
        y[0][5][5] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][5];

        y[1][0][0] = sigma[3][0] ^ sigma[6][0];
        y[1][0][1] = sigma[3][1] ^ sigma[6][1];
        y[1][0][2] = sigma[3][2] ^ sigma[6][2];
        y[1][0][3] = sigma[3][3] ^ sigma[6][3];
        y[1][0][4] = sigma[3][4] ^ sigma[6][4];
        y[1][0][5] = sigma[3][5] ^ sigma[6][5];

        y[1][1][0] = sigma[3][3] ^ sigma[6][0] ^ sigma[6][5];
        y[1][1][1] = sigma[3][3] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][5];
        y[1][1][2] = sigma[3][4] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][2];
        y[1][1][3] = sigma[3][0] ^ sigma[3][5] ^ sigma[6][2] ^ sigma[6][3];
        y[1][1][4] = sigma[3][1] ^ sigma[6][3] ^ sigma[6][4];
        y[1][1][5] = sigma[3][2] ^ sigma[6][4] ^ sigma[6][5];

        y[1][2][0] = sigma[3][0] ^ sigma[3][5] ^ sigma[6][0] ^ sigma[6][4];
        y[1][2][1] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][4] ^ sigma[6][5];
        y[1][2][2] = sigma[3][1] ^ sigma[3][2] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][5];
        y[1][2][3] = sigma[3][2] ^ sigma[3][3] ^ sigma[6][1] ^ sigma[6][3];
        y[1][2][4] = sigma[3][3] ^ sigma[3][4] ^ sigma[6][2] ^ sigma[6][4];
        y[1][2][5] = sigma[3][4] ^ sigma[3][5] ^ sigma[6][3] ^ sigma[6][5];

        y[1][3][0] = sigma[3][2] ^ sigma[3][3] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[1][3][1] = sigma[3][2] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3];
        y[1][3][2] = sigma[3][3] ^ sigma[3][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4];
        y[1][3][3] = sigma[3][0] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[1][3][4] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[1][3][5] = sigma[3][1] ^ sigma[3][2] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[1][4][0] = sigma[3][0] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][2];
        y[1][4][1] = sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[1][4][2] = sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[1][4][3] = sigma[3][1] ^ sigma[3][3] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[1][4][4] = sigma[3][2] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][4] ^ sigma[6][5];
        y[1][4][5] = sigma[3][3] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][5];

        y[1][5][0] = sigma[3][1] ^ sigma[3][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[1][5][1] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];
        y[1][5][2] = sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[6][1] ^ sigma[6][4];
        y[1][5][3] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[6][2] ^ sigma[6][5];
        y[1][5][4] = sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[6][0] ^ sigma[6][3];
        y[1][5][5] = sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];

        y[2][0][0] = sigma[5][0];
        y[2][0][1] = sigma[5][1];
        y[2][0][2] = sigma[5][2];
        y[2][0][3] = sigma[5][3];
        y[2][0][4] = sigma[5][4];
        y[2][0][5] = sigma[5][5];

        y[2][1][0] = sigma[5][1];
        y[2][1][1] = sigma[5][1] ^ sigma[5][2];
        y[2][1][2] = sigma[5][2] ^ sigma[5][3];
        y[2][1][3] = sigma[5][3] ^ sigma[5][4];
        y[2][1][4] = sigma[5][4] ^ sigma[5][5];
        y[2][1][5] = sigma[5][0] ^ sigma[5][5];

        y[2][2][0] = sigma[5][1] ^ sigma[5][2];
        y[2][2][1] = sigma[5][1] ^ sigma[5][3];
        y[2][2][2] = sigma[5][2] ^ sigma[5][4];
        y[2][2][3] = sigma[5][3] ^ sigma[5][5];
        y[2][2][4] = sigma[5][0] ^ sigma[5][4];
        y[2][2][5] = sigma[5][0] ^ sigma[5][1] ^ sigma[5][5];

        y[2][3][0] = sigma[5][1] ^ sigma[5][3];
        y[2][3][1] = sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4];
        y[2][3][2] = sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5];
        y[2][3][3] = sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5];
        y[2][3][4] = sigma[5][1] ^ sigma[5][4] ^ sigma[5][5];
        y[2][3][5] = sigma[5][0] ^ sigma[5][2] ^ sigma[5][5];

        y[2][4][0] = sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4];
        y[2][4][1] = sigma[5][1] ^ sigma[5][5];
        y[2][4][2] = sigma[5][0] ^ sigma[5][2];
        y[2][4][3] = sigma[5][0] ^ sigma[5][1] ^ sigma[5][3];
        y[2][4][4] = sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4];
        y[2][4][5] = sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5];

        y[2][5][0] = sigma[5][1] ^ sigma[5][5];
        y[2][5][1] = sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5];
        y[2][5][2] = sigma[5][1] ^ sigma[5][2] ^ sigma[5][3];
        y[2][5][3] = sigma[5][2] ^ sigma[5][3] ^ sigma[5][4];
        y[2][5][4] = sigma[5][3] ^ sigma[5][4] ^ sigma[5][5];
        y[2][5][5] = sigma[5][0] ^ sigma[5][4] ^ sigma[5][5];

    end

endmodule

module sigmaEB(
    input  [5:0]      sigmaE[3:0][31:0],
    input  [5:0]      sigma0,
    output reg [5:0]  y[31:0]
);

    reg [5:0]    tmp[3:0][31:0];

    always @* begin
        tmp[0][0] = sigmaE[0][0];
        tmp[0][1] = sigmaE[0][1];
        tmp[0][2] = sigmaE[0][2];
        tmp[0][3] = sigmaE[0][3];
        tmp[0][4] = sigmaE[0][4];
        tmp[0][5] = sigmaE[0][5];
        tmp[0][6] = sigmaE[0][0] ^ sigmaE[0][1];
        tmp[0][7] = sigmaE[0][1] ^ sigmaE[0][2];
        tmp[0][8] = sigmaE[0][2] ^ sigmaE[0][3];
        tmp[0][9] = sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][10] = sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][11] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][5];
        tmp[0][12] = sigmaE[0][0] ^ sigmaE[0][2];
        tmp[0][13] = sigmaE[0][1] ^ sigmaE[0][3];
        tmp[0][14] = sigmaE[0][2] ^ sigmaE[0][4];
        tmp[0][15] = sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][16] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][4];
        tmp[0][17] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][5];
        tmp[0][18] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3];
        tmp[0][19] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][20] = sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][21] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][22] = sigmaE[0][0] ^ sigmaE[0][2] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][23] = sigmaE[0][0] ^ sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][24] = sigmaE[0][0] ^ sigmaE[0][4];
        tmp[0][25] = sigmaE[0][1] ^ sigmaE[0][5];
        tmp[0][26] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][2];
        tmp[0][27] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3];
        tmp[0][28] = sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][29] = sigmaE[0][3] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][30] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][31] = sigmaE[0][0] ^ sigmaE[0][2] ^ sigmaE[0][5];

        tmp[1][0] = sigmaE[1][0];
        tmp[1][1] = sigmaE[1][1];
        tmp[1][2] = sigmaE[1][2];
        tmp[1][3] = sigmaE[1][3];
        tmp[1][4] = sigmaE[1][4];
        tmp[1][5] = sigmaE[1][5];
        tmp[1][6] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][4];
        tmp[1][7] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][5];
        tmp[1][8] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][3];
        tmp[1][9] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][4];
        tmp[1][10] = sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][5];
        tmp[1][11] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3];
        tmp[1][12] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][4];
        tmp[1][13] = sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][4] ^ sigmaE[1][5];
        tmp[1][14] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][5];
        tmp[1][15] = sigmaE[1][0] ^ sigmaE[1][3];
        tmp[1][16] = sigmaE[1][1] ^ sigmaE[1][4];
        tmp[1][17] = sigmaE[1][2] ^ sigmaE[1][5];
        tmp[1][18] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][4];
        tmp[1][19] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][4] ^ sigmaE[1][5];
        tmp[1][20] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][3] ^ sigmaE[1][5];
        tmp[1][21] = sigmaE[1][0];
        tmp[1][22] = sigmaE[1][1];
        tmp[1][23] = sigmaE[1][2];
        tmp[1][24] = sigmaE[1][3];
        tmp[1][25] = sigmaE[1][4];
        tmp[1][26] = sigmaE[1][5];
        tmp[1][27] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][4];
        tmp[1][28] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][5];
        tmp[1][29] = sigmaE[1][0] ^ sigmaE[1][1] ^ sigmaE[1][3];
        tmp[1][30] = sigmaE[1][1] ^ sigmaE[1][2] ^ sigmaE[1][4];
        tmp[1][31] = sigmaE[1][2] ^ sigmaE[1][3] ^ sigmaE[1][5];

        tmp[2][0] = sigmaE[2][0];
        tmp[2][1] = sigmaE[2][1];
        tmp[2][2] = sigmaE[2][2];
        tmp[2][3] = sigmaE[2][3];
        tmp[2][4] = sigmaE[2][4];
        tmp[2][5] = sigmaE[2][5];
        tmp[2][6] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][5];
        tmp[2][7] = sigmaE[2][0] ^ sigmaE[2][3] ^ sigmaE[2][5];
        tmp[2][8] = sigmaE[2][0] ^ sigmaE[2][2] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][9] = sigmaE[2][0] ^ sigmaE[2][2] ^ sigmaE[2][3];
        tmp[2][10] = sigmaE[2][1] ^ sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][11] = sigmaE[2][2] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][12] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3];
        tmp[2][13] = sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][14] = sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][15] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][16] = sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][17] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][18] = sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][19] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][3];
        tmp[2][20] = sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][4];
        tmp[2][21] = sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][5];
        tmp[2][22] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][23] = sigmaE[2][0] ^ sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][24] = sigmaE[2][1] ^ sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][25] = sigmaE[2][0] ^ sigmaE[2][1];
        tmp[2][26] = sigmaE[2][1] ^ sigmaE[2][2];
        tmp[2][27] = sigmaE[2][2] ^ sigmaE[2][3];
        tmp[2][28] = sigmaE[2][3] ^ sigmaE[2][4];
        tmp[2][29] = sigmaE[2][4] ^ sigmaE[2][5];
        tmp[2][30] = sigmaE[2][0] ^ sigmaE[2][1] ^ sigmaE[2][2];
        tmp[2][31] = sigmaE[2][1] ^ sigmaE[2][2] ^ sigmaE[2][3];

        y[0] = sigma0 ^ tmp[0][0] ^ tmp[1][0] ^ tmp[2][0];
        y[1] = sigma0 ^ tmp[0][1] ^ tmp[1][1] ^ tmp[2][1];
        y[2] = sigma0 ^ tmp[0][2] ^ tmp[1][2] ^ tmp[2][2];
        y[3] = sigma0 ^ tmp[0][3] ^ tmp[1][3] ^ tmp[2][3];
        y[4] = sigma0 ^ tmp[0][4] ^ tmp[1][4] ^ tmp[2][4];
        y[5] = sigma0 ^ tmp[0][5] ^ tmp[1][5] ^ tmp[2][5];
        y[6] = sigma0 ^ tmp[0][6] ^ tmp[1][6] ^ tmp[2][6];
        y[7] = sigma0 ^ tmp[0][7] ^ tmp[1][7] ^ tmp[2][7];
        y[8] = sigma0 ^ tmp[0][8] ^ tmp[1][8] ^ tmp[2][8];
        y[9] = sigma0 ^ tmp[0][9] ^ tmp[1][9] ^ tmp[2][9];
        y[10] = sigma0 ^ tmp[0][10] ^ tmp[1][10] ^ tmp[2][10];
        y[11] = sigma0 ^ tmp[0][11] ^ tmp[1][11] ^ tmp[2][11];
        y[12] = sigma0 ^ tmp[0][12] ^ tmp[1][12] ^ tmp[2][12];
        y[13] = sigma0 ^ tmp[0][13] ^ tmp[1][13] ^ tmp[2][13];
        y[14] = sigma0 ^ tmp[0][14] ^ tmp[1][14] ^ tmp[2][14];
        y[15] = sigma0 ^ tmp[0][15] ^ tmp[1][15] ^ tmp[2][15];
        y[16] = sigma0 ^ tmp[0][16] ^ tmp[1][16] ^ tmp[2][16];
        y[17] = sigma0 ^ tmp[0][17] ^ tmp[1][17] ^ tmp[2][17];
        y[18] = sigma0 ^ tmp[0][18] ^ tmp[1][18] ^ tmp[2][18];
        y[19] = sigma0 ^ tmp[0][19] ^ tmp[1][19] ^ tmp[2][19];
        y[20] = sigma0 ^ tmp[0][20] ^ tmp[1][20] ^ tmp[2][20];
        y[21] = sigma0 ^ tmp[0][21] ^ tmp[1][21] ^ tmp[2][21];
        y[22] = sigma0 ^ tmp[0][22] ^ tmp[1][22] ^ tmp[2][22];
        y[23] = sigma0 ^ tmp[0][23] ^ tmp[1][23] ^ tmp[2][23];
        y[24] = sigma0 ^ tmp[0][24] ^ tmp[1][24] ^ tmp[2][24];
        y[25] = sigma0 ^ tmp[0][25] ^ tmp[1][25] ^ tmp[2][25];
        y[26] = sigma0 ^ tmp[0][26] ^ tmp[1][26] ^ tmp[2][26];
        y[27] = sigma0 ^ tmp[0][27] ^ tmp[1][27] ^ tmp[2][27];
        y[28] = sigma0 ^ tmp[0][28] ^ tmp[1][28] ^ tmp[2][28];
        y[29] = sigma0 ^ tmp[0][29] ^ tmp[1][29] ^ tmp[2][29];
        y[30] = sigma0 ^ tmp[0][30] ^ tmp[1][30] ^ tmp[2][30];
        y[31] = sigma0 ^ tmp[0][31] ^ tmp[1][31] ^ tmp[2][31];
    end

endmodule
