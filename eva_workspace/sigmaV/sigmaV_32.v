module sigmaV(
    input  [5:0]        sigma[2:0],
    output reg [5:0]    y[31:0]
);

    wire [5:0]  sigmaE[1][31:0];

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
    input  [5:0]      sigma[2:0],
    output reg [5:0]  y[1][31:0]
);

    always @* begin
        y[0][0][0] = sigma[1][0] ^ sigma[2][0];
        y[0][0][1] = sigma[1][1] ^ sigma[2][1];
        y[0][0][2] = sigma[1][2] ^ sigma[2][2];
        y[0][0][3] = sigma[1][3] ^ sigma[2][3];
        y[0][0][4] = sigma[1][4] ^ sigma[2][4];
        y[0][0][5] = sigma[1][5] ^ sigma[2][5];

        y[0][1][0] = sigma[1][5] ^ sigma[2][4];
        y[0][1][1] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][4] ^ sigma[2][5];
        y[0][1][2] = sigma[1][1] ^ sigma[2][0] ^ sigma[2][5];
        y[0][1][3] = sigma[1][2] ^ sigma[2][1];
        y[0][1][4] = sigma[1][3] ^ sigma[2][2];
        y[0][1][5] = sigma[1][4] ^ sigma[2][3];

        y[0][2][0] = sigma[1][4] ^ sigma[2][2];
        y[0][2][1] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3];
        y[0][2][2] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][3] ^ sigma[2][4];
        y[0][2][3] = sigma[1][1] ^ sigma[2][4] ^ sigma[2][5];
        y[0][2][4] = sigma[1][2] ^ sigma[2][0] ^ sigma[2][5];
        y[0][2][5] = sigma[1][3] ^ sigma[2][1];

        y[0][3][0] = sigma[1][3] ^ sigma[2][0] ^ sigma[2][5];
        y[0][3][1] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5];
        y[0][3][2] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2];
        y[0][3][3] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3];
        y[0][3][4] = sigma[1][1] ^ sigma[2][3] ^ sigma[2][4];
        y[0][3][5] = sigma[1][2] ^ sigma[2][4] ^ sigma[2][5];

        y[0][4][0] = sigma[1][2] ^ sigma[2][3] ^ sigma[2][4];
        y[0][4][1] = sigma[1][2] ^ sigma[1][3] ^ sigma[2][3] ^ sigma[2][5];
        y[0][4][2] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][4];
        y[0][4][3] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5];
        y[0][4][4] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2];
        y[0][4][5] = sigma[1][1] ^ sigma[2][2] ^ sigma[2][3];

        y[0][5][0] = sigma[1][1] ^ sigma[2][1] ^ sigma[2][2];
        y[0][5][1] = sigma[1][1] ^ sigma[1][2] ^ sigma[2][1] ^ sigma[2][3];
        y[0][5][2] = sigma[1][2] ^ sigma[1][3] ^ sigma[2][2] ^ sigma[2][4];
        y[0][5][3] = sigma[1][3] ^ sigma[1][4] ^ sigma[2][3] ^ sigma[2][5];
        y[0][5][4] = sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][4];
        y[0][5][5] = sigma[1][0] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5];

    end

endmodule

module sigmaEB(
    input  [5:0]      sigmaE[1][31:0],
    input  [5:0]      sigma0,
    output reg [5:0]  y[31:0]
);

    reg [5:0]    tmp[1][31:0];

    always @* begin
        tmp[0][0] = sigmaE[0][0];
        tmp[0][1] = sigmaE[0][1];
        tmp[0][2] = sigmaE[0][2];
        tmp[0][3] = sigmaE[0][3];
        tmp[0][4] = sigmaE[0][4];
        tmp[0][5] = sigmaE[0][5];
        tmp[0][6] = sigmaE[0][0] ^ sigmaE[0][1];
        tmp[0][7] = sigmaE[0][1] ^ sigmaE[0][2];
        tmp[0][8] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][4];
        tmp[0][9] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][5];
        tmp[0][10] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3];
        tmp[0][11] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][12] = sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][13] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][14] = sigmaE[0][0] ^ sigmaE[0][2] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][15] = sigmaE[0][0] ^ sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][16] = sigmaE[0][0] ^ sigmaE[0][3];
        tmp[0][17] = sigmaE[0][1] ^ sigmaE[0][4];
        tmp[0][18] = sigmaE[0][2] ^ sigmaE[0][5];
        tmp[0][19] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][3];
        tmp[0][20] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][4];
        tmp[0][21] = sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][22] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][23] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][24] = sigmaE[0][0] ^ sigmaE[0][2] ^ sigmaE[0][3];
        tmp[0][25] = sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][4];
        tmp[0][26] = sigmaE[0][2] ^ sigmaE[0][4] ^ sigmaE[0][5];
        tmp[0][27] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][28] = sigmaE[0][0] ^ sigmaE[0][2] ^ sigmaE[0][4];
        tmp[0][29] = sigmaE[0][1] ^ sigmaE[0][3] ^ sigmaE[0][5];
        tmp[0][30] = sigmaE[0][0] ^ sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][4];
        tmp[0][31] = sigmaE[0][1] ^ sigmaE[0][2] ^ sigmaE[0][3] ^ sigmaE[0][5];

        y[0] = sigma0 ^ tmp[0][0];
        y[1] = sigma0 ^ tmp[0][1];
        y[2] = sigma0 ^ tmp[0][2];
        y[3] = sigma0 ^ tmp[0][3];
        y[4] = sigma0 ^ tmp[0][4];
        y[5] = sigma0 ^ tmp[0][5];
        y[6] = sigma0 ^ tmp[0][6];
        y[7] = sigma0 ^ tmp[0][7];
        y[8] = sigma0 ^ tmp[0][8];
        y[9] = sigma0 ^ tmp[0][9];
        y[10] = sigma0 ^ tmp[0][10];
        y[11] = sigma0 ^ tmp[0][11];
        y[12] = sigma0 ^ tmp[0][12];
        y[13] = sigma0 ^ tmp[0][13];
        y[14] = sigma0 ^ tmp[0][14];
        y[15] = sigma0 ^ tmp[0][15];
        y[16] = sigma0 ^ tmp[0][16];
        y[17] = sigma0 ^ tmp[0][17];
        y[18] = sigma0 ^ tmp[0][18];
        y[19] = sigma0 ^ tmp[0][19];
        y[20] = sigma0 ^ tmp[0][20];
        y[21] = sigma0 ^ tmp[0][21];
        y[22] = sigma0 ^ tmp[0][22];
        y[23] = sigma0 ^ tmp[0][23];
        y[24] = sigma0 ^ tmp[0][24];
        y[25] = sigma0 ^ tmp[0][25];
        y[26] = sigma0 ^ tmp[0][26];
        y[27] = sigma0 ^ tmp[0][27];
        y[28] = sigma0 ^ tmp[0][28];
        y[29] = sigma0 ^ tmp[0][29];
        y[30] = sigma0 ^ tmp[0][30];
        y[31] = sigma0 ^ tmp[0][31];
    end

endmodule
