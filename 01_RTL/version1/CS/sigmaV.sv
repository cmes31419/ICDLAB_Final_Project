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
        tmp[0][0][0] = sigmaE[0][0][0];
        tmp[0][0][1] = sigmaE[0][0][1];
        tmp[0][0][2] = sigmaE[0][0][2];
        tmp[0][0][3] = sigmaE[0][0][3];
        tmp[0][0][4] = sigmaE[0][0][4];
        tmp[0][0][5] = sigmaE[0][0][5];

        tmp[0][1][0] = sigmaE[0][1][0];
        tmp[0][1][1] = sigmaE[0][1][1];
        tmp[0][1][2] = sigmaE[0][1][2];
        tmp[0][1][3] = sigmaE[0][1][3];
        tmp[0][1][4] = sigmaE[0][1][4];
        tmp[0][1][5] = sigmaE[0][1][5];

        tmp[0][2][0] = sigmaE[0][2][0];
        tmp[0][2][1] = sigmaE[0][2][1];
        tmp[0][2][2] = sigmaE[0][2][2];
        tmp[0][2][3] = sigmaE[0][2][3];
        tmp[0][2][4] = sigmaE[0][2][4];
        tmp[0][2][5] = sigmaE[0][2][5];

        tmp[0][3][0] = sigmaE[0][3][0];
        tmp[0][3][1] = sigmaE[0][3][1];
        tmp[0][3][2] = sigmaE[0][3][2];
        tmp[0][3][3] = sigmaE[0][3][3];
        tmp[0][3][4] = sigmaE[0][3][4];
        tmp[0][3][5] = sigmaE[0][3][5];

        tmp[0][4][0] = sigmaE[0][4][0];
        tmp[0][4][1] = sigmaE[0][4][1];
        tmp[0][4][2] = sigmaE[0][4][2];
        tmp[0][4][3] = sigmaE[0][4][3];
        tmp[0][4][4] = sigmaE[0][4][4];
        tmp[0][4][5] = sigmaE[0][4][5];

        tmp[0][5][0] = sigmaE[0][5][0];
        tmp[0][5][1] = sigmaE[0][5][1];
        tmp[0][5][2] = sigmaE[0][5][2];
        tmp[0][5][3] = sigmaE[0][5][3];
        tmp[0][5][4] = sigmaE[0][5][4];
        tmp[0][5][5] = sigmaE[0][5][5];

        tmp[0][6][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0];
        tmp[0][6][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1];
        tmp[0][6][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2];
        tmp[0][6][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3];
        tmp[0][6][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4];
        tmp[0][6][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5];

        tmp[0][7][0] = sigmaE[0][1][0] ^ sigmaE[0][2][0];
        tmp[0][7][1] = sigmaE[0][1][1] ^ sigmaE[0][2][1];
        tmp[0][7][2] = sigmaE[0][1][2] ^ sigmaE[0][2][2];
        tmp[0][7][3] = sigmaE[0][1][3] ^ sigmaE[0][2][3];
        tmp[0][7][4] = sigmaE[0][1][4] ^ sigmaE[0][2][4];
        tmp[0][7][5] = sigmaE[0][1][5] ^ sigmaE[0][2][5];

        tmp[0][8][0] = sigmaE[0][2][0] ^ sigmaE[0][3][0];
        tmp[0][8][1] = sigmaE[0][2][1] ^ sigmaE[0][3][1];
        tmp[0][8][2] = sigmaE[0][2][2] ^ sigmaE[0][3][2];
        tmp[0][8][3] = sigmaE[0][2][3] ^ sigmaE[0][3][3];
        tmp[0][8][4] = sigmaE[0][2][4] ^ sigmaE[0][3][4];
        tmp[0][8][5] = sigmaE[0][2][5] ^ sigmaE[0][3][5];

        tmp[0][9][0] = sigmaE[0][3][0] ^ sigmaE[0][4][0];
        tmp[0][9][1] = sigmaE[0][3][1] ^ sigmaE[0][4][1];
        tmp[0][9][2] = sigmaE[0][3][2] ^ sigmaE[0][4][2];
        tmp[0][9][3] = sigmaE[0][3][3] ^ sigmaE[0][4][3];
        tmp[0][9][4] = sigmaE[0][3][4] ^ sigmaE[0][4][4];
        tmp[0][9][5] = sigmaE[0][3][5] ^ sigmaE[0][4][5];

        tmp[0][10][0] = sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][10][1] = sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][10][2] = sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][10][3] = sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][10][4] = sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][10][5] = sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][11][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][5][0];
        tmp[0][11][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][5][1];
        tmp[0][11][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][5][2];
        tmp[0][11][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][5][3];
        tmp[0][11][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][5][4];
        tmp[0][11][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][5][5];

        tmp[0][12][0] = sigmaE[0][0][0] ^ sigmaE[0][2][0];
        tmp[0][12][1] = sigmaE[0][0][1] ^ sigmaE[0][2][1];
        tmp[0][12][2] = sigmaE[0][0][2] ^ sigmaE[0][2][2];
        tmp[0][12][3] = sigmaE[0][0][3] ^ sigmaE[0][2][3];
        tmp[0][12][4] = sigmaE[0][0][4] ^ sigmaE[0][2][4];
        tmp[0][12][5] = sigmaE[0][0][5] ^ sigmaE[0][2][5];

        tmp[0][13][0] = sigmaE[0][1][0] ^ sigmaE[0][3][0];
        tmp[0][13][1] = sigmaE[0][1][1] ^ sigmaE[0][3][1];
        tmp[0][13][2] = sigmaE[0][1][2] ^ sigmaE[0][3][2];
        tmp[0][13][3] = sigmaE[0][1][3] ^ sigmaE[0][3][3];
        tmp[0][13][4] = sigmaE[0][1][4] ^ sigmaE[0][3][4];
        tmp[0][13][5] = sigmaE[0][1][5] ^ sigmaE[0][3][5];

        tmp[0][14][0] = sigmaE[0][2][0] ^ sigmaE[0][4][0];
        tmp[0][14][1] = sigmaE[0][2][1] ^ sigmaE[0][4][1];
        tmp[0][14][2] = sigmaE[0][2][2] ^ sigmaE[0][4][2];
        tmp[0][14][3] = sigmaE[0][2][3] ^ sigmaE[0][4][3];
        tmp[0][14][4] = sigmaE[0][2][4] ^ sigmaE[0][4][4];
        tmp[0][14][5] = sigmaE[0][2][5] ^ sigmaE[0][4][5];

        tmp[0][15][0] = sigmaE[0][3][0] ^ sigmaE[0][5][0];
        tmp[0][15][1] = sigmaE[0][3][1] ^ sigmaE[0][5][1];
        tmp[0][15][2] = sigmaE[0][3][2] ^ sigmaE[0][5][2];
        tmp[0][15][3] = sigmaE[0][3][3] ^ sigmaE[0][5][3];
        tmp[0][15][4] = sigmaE[0][3][4] ^ sigmaE[0][5][4];
        tmp[0][15][5] = sigmaE[0][3][5] ^ sigmaE[0][5][5];

        tmp[0][16][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][4][0];
        tmp[0][16][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][4][1];
        tmp[0][16][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][4][2];
        tmp[0][16][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][4][3];
        tmp[0][16][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][4][4];
        tmp[0][16][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][4][5];

        tmp[0][17][0] = sigmaE[0][1][0] ^ sigmaE[0][2][0] ^ sigmaE[0][5][0];
        tmp[0][17][1] = sigmaE[0][1][1] ^ sigmaE[0][2][1] ^ sigmaE[0][5][1];
        tmp[0][17][2] = sigmaE[0][1][2] ^ sigmaE[0][2][2] ^ sigmaE[0][5][2];
        tmp[0][17][3] = sigmaE[0][1][3] ^ sigmaE[0][2][3] ^ sigmaE[0][5][3];
        tmp[0][17][4] = sigmaE[0][1][4] ^ sigmaE[0][2][4] ^ sigmaE[0][5][4];
        tmp[0][17][5] = sigmaE[0][1][5] ^ sigmaE[0][2][5] ^ sigmaE[0][5][5];

        tmp[0][18][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][2][0] ^ sigmaE[0][3][0];
        tmp[0][18][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][2][1] ^ sigmaE[0][3][1];
        tmp[0][18][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][2][2] ^ sigmaE[0][3][2];
        tmp[0][18][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][2][3] ^ sigmaE[0][3][3];
        tmp[0][18][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][2][4] ^ sigmaE[0][3][4];
        tmp[0][18][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][2][5] ^ sigmaE[0][3][5];

        tmp[0][19][0] = sigmaE[0][1][0] ^ sigmaE[0][2][0] ^ sigmaE[0][3][0] ^ sigmaE[0][4][0];
        tmp[0][19][1] = sigmaE[0][1][1] ^ sigmaE[0][2][1] ^ sigmaE[0][3][1] ^ sigmaE[0][4][1];
        tmp[0][19][2] = sigmaE[0][1][2] ^ sigmaE[0][2][2] ^ sigmaE[0][3][2] ^ sigmaE[0][4][2];
        tmp[0][19][3] = sigmaE[0][1][3] ^ sigmaE[0][2][3] ^ sigmaE[0][3][3] ^ sigmaE[0][4][3];
        tmp[0][19][4] = sigmaE[0][1][4] ^ sigmaE[0][2][4] ^ sigmaE[0][3][4] ^ sigmaE[0][4][4];
        tmp[0][19][5] = sigmaE[0][1][5] ^ sigmaE[0][2][5] ^ sigmaE[0][3][5] ^ sigmaE[0][4][5];

        tmp[0][20][0] = sigmaE[0][2][0] ^ sigmaE[0][3][0] ^ sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][20][1] = sigmaE[0][2][1] ^ sigmaE[0][3][1] ^ sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][20][2] = sigmaE[0][2][2] ^ sigmaE[0][3][2] ^ sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][20][3] = sigmaE[0][2][3] ^ sigmaE[0][3][3] ^ sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][20][4] = sigmaE[0][2][4] ^ sigmaE[0][3][4] ^ sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][20][5] = sigmaE[0][2][5] ^ sigmaE[0][3][5] ^ sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][21][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][3][0] ^ sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][21][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][3][1] ^ sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][21][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][3][2] ^ sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][21][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][3][3] ^ sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][21][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][3][4] ^ sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][21][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][3][5] ^ sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][22][0] = sigmaE[0][0][0] ^ sigmaE[0][2][0] ^ sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][22][1] = sigmaE[0][0][1] ^ sigmaE[0][2][1] ^ sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][22][2] = sigmaE[0][0][2] ^ sigmaE[0][2][2] ^ sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][22][3] = sigmaE[0][0][3] ^ sigmaE[0][2][3] ^ sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][22][4] = sigmaE[0][0][4] ^ sigmaE[0][2][4] ^ sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][22][5] = sigmaE[0][0][5] ^ sigmaE[0][2][5] ^ sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][23][0] = sigmaE[0][0][0] ^ sigmaE[0][3][0] ^ sigmaE[0][5][0];
        tmp[0][23][1] = sigmaE[0][0][1] ^ sigmaE[0][3][1] ^ sigmaE[0][5][1];
        tmp[0][23][2] = sigmaE[0][0][2] ^ sigmaE[0][3][2] ^ sigmaE[0][5][2];
        tmp[0][23][3] = sigmaE[0][0][3] ^ sigmaE[0][3][3] ^ sigmaE[0][5][3];
        tmp[0][23][4] = sigmaE[0][0][4] ^ sigmaE[0][3][4] ^ sigmaE[0][5][4];
        tmp[0][23][5] = sigmaE[0][0][5] ^ sigmaE[0][3][5] ^ sigmaE[0][5][5];

        tmp[0][24][0] = sigmaE[0][0][0] ^ sigmaE[0][4][0];
        tmp[0][24][1] = sigmaE[0][0][1] ^ sigmaE[0][4][1];
        tmp[0][24][2] = sigmaE[0][0][2] ^ sigmaE[0][4][2];
        tmp[0][24][3] = sigmaE[0][0][3] ^ sigmaE[0][4][3];
        tmp[0][24][4] = sigmaE[0][0][4] ^ sigmaE[0][4][4];
        tmp[0][24][5] = sigmaE[0][0][5] ^ sigmaE[0][4][5];

        tmp[0][25][0] = sigmaE[0][1][0] ^ sigmaE[0][5][0];
        tmp[0][25][1] = sigmaE[0][1][1] ^ sigmaE[0][5][1];
        tmp[0][25][2] = sigmaE[0][1][2] ^ sigmaE[0][5][2];
        tmp[0][25][3] = sigmaE[0][1][3] ^ sigmaE[0][5][3];
        tmp[0][25][4] = sigmaE[0][1][4] ^ sigmaE[0][5][4];
        tmp[0][25][5] = sigmaE[0][1][5] ^ sigmaE[0][5][5];

        tmp[0][26][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][2][0];
        tmp[0][26][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][2][1];
        tmp[0][26][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][2][2];
        tmp[0][26][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][2][3];
        tmp[0][26][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][2][4];
        tmp[0][26][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][2][5];

        tmp[0][27][0] = sigmaE[0][1][0] ^ sigmaE[0][2][0] ^ sigmaE[0][3][0];
        tmp[0][27][1] = sigmaE[0][1][1] ^ sigmaE[0][2][1] ^ sigmaE[0][3][1];
        tmp[0][27][2] = sigmaE[0][1][2] ^ sigmaE[0][2][2] ^ sigmaE[0][3][2];
        tmp[0][27][3] = sigmaE[0][1][3] ^ sigmaE[0][2][3] ^ sigmaE[0][3][3];
        tmp[0][27][4] = sigmaE[0][1][4] ^ sigmaE[0][2][4] ^ sigmaE[0][3][4];
        tmp[0][27][5] = sigmaE[0][1][5] ^ sigmaE[0][2][5] ^ sigmaE[0][3][5];

        tmp[0][28][0] = sigmaE[0][2][0] ^ sigmaE[0][3][0] ^ sigmaE[0][4][0];
        tmp[0][28][1] = sigmaE[0][2][1] ^ sigmaE[0][3][1] ^ sigmaE[0][4][1];
        tmp[0][28][2] = sigmaE[0][2][2] ^ sigmaE[0][3][2] ^ sigmaE[0][4][2];
        tmp[0][28][3] = sigmaE[0][2][3] ^ sigmaE[0][3][3] ^ sigmaE[0][4][3];
        tmp[0][28][4] = sigmaE[0][2][4] ^ sigmaE[0][3][4] ^ sigmaE[0][4][4];
        tmp[0][28][5] = sigmaE[0][2][5] ^ sigmaE[0][3][5] ^ sigmaE[0][4][5];

        tmp[0][29][0] = sigmaE[0][3][0] ^ sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][29][1] = sigmaE[0][3][1] ^ sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][29][2] = sigmaE[0][3][2] ^ sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][29][3] = sigmaE[0][3][3] ^ sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][29][4] = sigmaE[0][3][4] ^ sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][29][5] = sigmaE[0][3][5] ^ sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][30][0] = sigmaE[0][0][0] ^ sigmaE[0][1][0] ^ sigmaE[0][4][0] ^ sigmaE[0][5][0];
        tmp[0][30][1] = sigmaE[0][0][1] ^ sigmaE[0][1][1] ^ sigmaE[0][4][1] ^ sigmaE[0][5][1];
        tmp[0][30][2] = sigmaE[0][0][2] ^ sigmaE[0][1][2] ^ sigmaE[0][4][2] ^ sigmaE[0][5][2];
        tmp[0][30][3] = sigmaE[0][0][3] ^ sigmaE[0][1][3] ^ sigmaE[0][4][3] ^ sigmaE[0][5][3];
        tmp[0][30][4] = sigmaE[0][0][4] ^ sigmaE[0][1][4] ^ sigmaE[0][4][4] ^ sigmaE[0][5][4];
        tmp[0][30][5] = sigmaE[0][0][5] ^ sigmaE[0][1][5] ^ sigmaE[0][4][5] ^ sigmaE[0][5][5];

        tmp[0][31][0] = sigmaE[0][0][0] ^ sigmaE[0][2][0] ^ sigmaE[0][5][0];
        tmp[0][31][1] = sigmaE[0][0][1] ^ sigmaE[0][2][1] ^ sigmaE[0][5][1];
        tmp[0][31][2] = sigmaE[0][0][2] ^ sigmaE[0][2][2] ^ sigmaE[0][5][2];
        tmp[0][31][3] = sigmaE[0][0][3] ^ sigmaE[0][2][3] ^ sigmaE[0][5][3];
        tmp[0][31][4] = sigmaE[0][0][4] ^ sigmaE[0][2][4] ^ sigmaE[0][5][4];
        tmp[0][31][5] = sigmaE[0][0][5] ^ sigmaE[0][2][5] ^ sigmaE[0][5][5];

        tmp[1][0][0] = sigmaE[1][0][0];
        tmp[1][0][1] = sigmaE[1][0][1];
        tmp[1][0][2] = sigmaE[1][0][2];
        tmp[1][0][3] = sigmaE[1][0][3];
        tmp[1][0][4] = sigmaE[1][0][4];
        tmp[1][0][5] = sigmaE[1][0][5];

        tmp[1][1][0] = sigmaE[1][1][0];
        tmp[1][1][1] = sigmaE[1][1][1];
        tmp[1][1][2] = sigmaE[1][1][2];
        tmp[1][1][3] = sigmaE[1][1][3];
        tmp[1][1][4] = sigmaE[1][1][4];
        tmp[1][1][5] = sigmaE[1][1][5];

        tmp[1][2][0] = sigmaE[1][2][0];
        tmp[1][2][1] = sigmaE[1][2][1];
        tmp[1][2][2] = sigmaE[1][2][2];
        tmp[1][2][3] = sigmaE[1][2][3];
        tmp[1][2][4] = sigmaE[1][2][4];
        tmp[1][2][5] = sigmaE[1][2][5];

        tmp[1][3][0] = sigmaE[1][3][0];
        tmp[1][3][1] = sigmaE[1][3][1];
        tmp[1][3][2] = sigmaE[1][3][2];
        tmp[1][3][3] = sigmaE[1][3][3];
        tmp[1][3][4] = sigmaE[1][3][4];
        tmp[1][3][5] = sigmaE[1][3][5];

        tmp[1][4][0] = sigmaE[1][4][0];
        tmp[1][4][1] = sigmaE[1][4][1];
        tmp[1][4][2] = sigmaE[1][4][2];
        tmp[1][4][3] = sigmaE[1][4][3];
        tmp[1][4][4] = sigmaE[1][4][4];
        tmp[1][4][5] = sigmaE[1][4][5];

        tmp[1][5][0] = sigmaE[1][5][0];
        tmp[1][5][1] = sigmaE[1][5][1];
        tmp[1][5][2] = sigmaE[1][5][2];
        tmp[1][5][3] = sigmaE[1][5][3];
        tmp[1][5][4] = sigmaE[1][5][4];
        tmp[1][5][5] = sigmaE[1][5][5];

        tmp[1][6][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][4][0];
        tmp[1][6][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][4][1];
        tmp[1][6][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][4][2];
        tmp[1][6][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][4][3];
        tmp[1][6][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][4][4];
        tmp[1][6][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][4][5];

        tmp[1][7][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][7][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][7][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][7][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][7][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][7][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[1][8][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][3][0];
        tmp[1][8][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][3][1];
        tmp[1][8][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][3][2];
        tmp[1][8][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][3][3];
        tmp[1][8][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][3][4];
        tmp[1][8][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][3][5];

        tmp[1][9][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][4][0];
        tmp[1][9][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][4][1];
        tmp[1][9][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][4][2];
        tmp[1][9][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][4][3];
        tmp[1][9][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][4][4];
        tmp[1][9][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][4][5];

        tmp[1][10][0] = sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][10][1] = sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][10][2] = sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][10][3] = sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][10][4] = sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][10][5] = sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[1][11][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0];
        tmp[1][11][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1];
        tmp[1][11][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2];
        tmp[1][11][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3];
        tmp[1][11][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4];
        tmp[1][11][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5];

        tmp[1][12][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][4][0];
        tmp[1][12][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][4][1];
        tmp[1][12][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][4][2];
        tmp[1][12][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][4][3];
        tmp[1][12][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][4][4];
        tmp[1][12][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][4][5];

        tmp[1][13][0] = sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][4][0] ^ sigmaE[1][5][0];
        tmp[1][13][1] = sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][4][1] ^ sigmaE[1][5][1];
        tmp[1][13][2] = sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][4][2] ^ sigmaE[1][5][2];
        tmp[1][13][3] = sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][4][3] ^ sigmaE[1][5][3];
        tmp[1][13][4] = sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][4][4] ^ sigmaE[1][5][4];
        tmp[1][13][5] = sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][4][5] ^ sigmaE[1][5][5];

        tmp[1][14][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][14][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][14][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][14][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][14][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][14][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[1][15][0] = sigmaE[1][0][0] ^ sigmaE[1][3][0];
        tmp[1][15][1] = sigmaE[1][0][1] ^ sigmaE[1][3][1];
        tmp[1][15][2] = sigmaE[1][0][2] ^ sigmaE[1][3][2];
        tmp[1][15][3] = sigmaE[1][0][3] ^ sigmaE[1][3][3];
        tmp[1][15][4] = sigmaE[1][0][4] ^ sigmaE[1][3][4];
        tmp[1][15][5] = sigmaE[1][0][5] ^ sigmaE[1][3][5];

        tmp[1][16][0] = sigmaE[1][1][0] ^ sigmaE[1][4][0];
        tmp[1][16][1] = sigmaE[1][1][1] ^ sigmaE[1][4][1];
        tmp[1][16][2] = sigmaE[1][1][2] ^ sigmaE[1][4][2];
        tmp[1][16][3] = sigmaE[1][1][3] ^ sigmaE[1][4][3];
        tmp[1][16][4] = sigmaE[1][1][4] ^ sigmaE[1][4][4];
        tmp[1][16][5] = sigmaE[1][1][5] ^ sigmaE[1][4][5];

        tmp[1][17][0] = sigmaE[1][2][0] ^ sigmaE[1][5][0];
        tmp[1][17][1] = sigmaE[1][2][1] ^ sigmaE[1][5][1];
        tmp[1][17][2] = sigmaE[1][2][2] ^ sigmaE[1][5][2];
        tmp[1][17][3] = sigmaE[1][2][3] ^ sigmaE[1][5][3];
        tmp[1][17][4] = sigmaE[1][2][4] ^ sigmaE[1][5][4];
        tmp[1][17][5] = sigmaE[1][2][5] ^ sigmaE[1][5][5];

        tmp[1][18][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][4][0];
        tmp[1][18][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][4][1];
        tmp[1][18][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][4][2];
        tmp[1][18][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][4][3];
        tmp[1][18][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][4][4];
        tmp[1][18][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][4][5];

        tmp[1][19][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][4][0] ^ sigmaE[1][5][0];
        tmp[1][19][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][4][1] ^ sigmaE[1][5][1];
        tmp[1][19][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][4][2] ^ sigmaE[1][5][2];
        tmp[1][19][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][4][3] ^ sigmaE[1][5][3];
        tmp[1][19][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][4][4] ^ sigmaE[1][5][4];
        tmp[1][19][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][4][5] ^ sigmaE[1][5][5];

        tmp[1][20][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][20][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][20][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][20][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][20][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][20][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[1][21][0] = sigmaE[1][0][0];
        tmp[1][21][1] = sigmaE[1][0][1];
        tmp[1][21][2] = sigmaE[1][0][2];
        tmp[1][21][3] = sigmaE[1][0][3];
        tmp[1][21][4] = sigmaE[1][0][4];
        tmp[1][21][5] = sigmaE[1][0][5];

        tmp[1][22][0] = sigmaE[1][1][0];
        tmp[1][22][1] = sigmaE[1][1][1];
        tmp[1][22][2] = sigmaE[1][1][2];
        tmp[1][22][3] = sigmaE[1][1][3];
        tmp[1][22][4] = sigmaE[1][1][4];
        tmp[1][22][5] = sigmaE[1][1][5];

        tmp[1][23][0] = sigmaE[1][2][0];
        tmp[1][23][1] = sigmaE[1][2][1];
        tmp[1][23][2] = sigmaE[1][2][2];
        tmp[1][23][3] = sigmaE[1][2][3];
        tmp[1][23][4] = sigmaE[1][2][4];
        tmp[1][23][5] = sigmaE[1][2][5];

        tmp[1][24][0] = sigmaE[1][3][0];
        tmp[1][24][1] = sigmaE[1][3][1];
        tmp[1][24][2] = sigmaE[1][3][2];
        tmp[1][24][3] = sigmaE[1][3][3];
        tmp[1][24][4] = sigmaE[1][3][4];
        tmp[1][24][5] = sigmaE[1][3][5];

        tmp[1][25][0] = sigmaE[1][4][0];
        tmp[1][25][1] = sigmaE[1][4][1];
        tmp[1][25][2] = sigmaE[1][4][2];
        tmp[1][25][3] = sigmaE[1][4][3];
        tmp[1][25][4] = sigmaE[1][4][4];
        tmp[1][25][5] = sigmaE[1][4][5];

        tmp[1][26][0] = sigmaE[1][5][0];
        tmp[1][26][1] = sigmaE[1][5][1];
        tmp[1][26][2] = sigmaE[1][5][2];
        tmp[1][26][3] = sigmaE[1][5][3];
        tmp[1][26][4] = sigmaE[1][5][4];
        tmp[1][26][5] = sigmaE[1][5][5];

        tmp[1][27][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][4][0];
        tmp[1][27][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][4][1];
        tmp[1][27][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][4][2];
        tmp[1][27][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][4][3];
        tmp[1][27][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][4][4];
        tmp[1][27][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][4][5];

        tmp[1][28][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][28][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][28][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][28][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][28][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][28][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[1][29][0] = sigmaE[1][0][0] ^ sigmaE[1][1][0] ^ sigmaE[1][3][0];
        tmp[1][29][1] = sigmaE[1][0][1] ^ sigmaE[1][1][1] ^ sigmaE[1][3][1];
        tmp[1][29][2] = sigmaE[1][0][2] ^ sigmaE[1][1][2] ^ sigmaE[1][3][2];
        tmp[1][29][3] = sigmaE[1][0][3] ^ sigmaE[1][1][3] ^ sigmaE[1][3][3];
        tmp[1][29][4] = sigmaE[1][0][4] ^ sigmaE[1][1][4] ^ sigmaE[1][3][4];
        tmp[1][29][5] = sigmaE[1][0][5] ^ sigmaE[1][1][5] ^ sigmaE[1][3][5];

        tmp[1][30][0] = sigmaE[1][1][0] ^ sigmaE[1][2][0] ^ sigmaE[1][4][0];
        tmp[1][30][1] = sigmaE[1][1][1] ^ sigmaE[1][2][1] ^ sigmaE[1][4][1];
        tmp[1][30][2] = sigmaE[1][1][2] ^ sigmaE[1][2][2] ^ sigmaE[1][4][2];
        tmp[1][30][3] = sigmaE[1][1][3] ^ sigmaE[1][2][3] ^ sigmaE[1][4][3];
        tmp[1][30][4] = sigmaE[1][1][4] ^ sigmaE[1][2][4] ^ sigmaE[1][4][4];
        tmp[1][30][5] = sigmaE[1][1][5] ^ sigmaE[1][2][5] ^ sigmaE[1][4][5];

        tmp[1][31][0] = sigmaE[1][2][0] ^ sigmaE[1][3][0] ^ sigmaE[1][5][0];
        tmp[1][31][1] = sigmaE[1][2][1] ^ sigmaE[1][3][1] ^ sigmaE[1][5][1];
        tmp[1][31][2] = sigmaE[1][2][2] ^ sigmaE[1][3][2] ^ sigmaE[1][5][2];
        tmp[1][31][3] = sigmaE[1][2][3] ^ sigmaE[1][3][3] ^ sigmaE[1][5][3];
        tmp[1][31][4] = sigmaE[1][2][4] ^ sigmaE[1][3][4] ^ sigmaE[1][5][4];
        tmp[1][31][5] = sigmaE[1][2][5] ^ sigmaE[1][3][5] ^ sigmaE[1][5][5];

        tmp[2][0][0] = sigmaE[2][0][0];
        tmp[2][0][1] = sigmaE[2][0][1];
        tmp[2][0][2] = sigmaE[2][0][2];
        tmp[2][0][3] = sigmaE[2][0][3];
        tmp[2][0][4] = sigmaE[2][0][4];
        tmp[2][0][5] = sigmaE[2][0][5];

        tmp[2][1][0] = sigmaE[2][1][0];
        tmp[2][1][1] = sigmaE[2][1][1];
        tmp[2][1][2] = sigmaE[2][1][2];
        tmp[2][1][3] = sigmaE[2][1][3];
        tmp[2][1][4] = sigmaE[2][1][4];
        tmp[2][1][5] = sigmaE[2][1][5];

        tmp[2][2][0] = sigmaE[2][2][0];
        tmp[2][2][1] = sigmaE[2][2][1];
        tmp[2][2][2] = sigmaE[2][2][2];
        tmp[2][2][3] = sigmaE[2][2][3];
        tmp[2][2][4] = sigmaE[2][2][4];
        tmp[2][2][5] = sigmaE[2][2][5];

        tmp[2][3][0] = sigmaE[2][3][0];
        tmp[2][3][1] = sigmaE[2][3][1];
        tmp[2][3][2] = sigmaE[2][3][2];
        tmp[2][3][3] = sigmaE[2][3][3];
        tmp[2][3][4] = sigmaE[2][3][4];
        tmp[2][3][5] = sigmaE[2][3][5];

        tmp[2][4][0] = sigmaE[2][4][0];
        tmp[2][4][1] = sigmaE[2][4][1];
        tmp[2][4][2] = sigmaE[2][4][2];
        tmp[2][4][3] = sigmaE[2][4][3];
        tmp[2][4][4] = sigmaE[2][4][4];
        tmp[2][4][5] = sigmaE[2][4][5];

        tmp[2][5][0] = sigmaE[2][5][0];
        tmp[2][5][1] = sigmaE[2][5][1];
        tmp[2][5][2] = sigmaE[2][5][2];
        tmp[2][5][3] = sigmaE[2][5][3];
        tmp[2][5][4] = sigmaE[2][5][4];
        tmp[2][5][5] = sigmaE[2][5][5];

        tmp[2][6][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][5][0];
        tmp[2][6][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][5][1];
        tmp[2][6][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][5][2];
        tmp[2][6][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][5][3];
        tmp[2][6][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][5][4];
        tmp[2][6][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][5][5];

        tmp[2][7][0] = sigmaE[2][0][0] ^ sigmaE[2][3][0] ^ sigmaE[2][5][0];
        tmp[2][7][1] = sigmaE[2][0][1] ^ sigmaE[2][3][1] ^ sigmaE[2][5][1];
        tmp[2][7][2] = sigmaE[2][0][2] ^ sigmaE[2][3][2] ^ sigmaE[2][5][2];
        tmp[2][7][3] = sigmaE[2][0][3] ^ sigmaE[2][3][3] ^ sigmaE[2][5][3];
        tmp[2][7][4] = sigmaE[2][0][4] ^ sigmaE[2][3][4] ^ sigmaE[2][5][4];
        tmp[2][7][5] = sigmaE[2][0][5] ^ sigmaE[2][3][5] ^ sigmaE[2][5][5];

        tmp[2][8][0] = sigmaE[2][0][0] ^ sigmaE[2][2][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][8][1] = sigmaE[2][0][1] ^ sigmaE[2][2][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][8][2] = sigmaE[2][0][2] ^ sigmaE[2][2][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][8][3] = sigmaE[2][0][3] ^ sigmaE[2][2][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][8][4] = sigmaE[2][0][4] ^ sigmaE[2][2][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][8][5] = sigmaE[2][0][5] ^ sigmaE[2][2][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][9][0] = sigmaE[2][0][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0];
        tmp[2][9][1] = sigmaE[2][0][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1];
        tmp[2][9][2] = sigmaE[2][0][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2];
        tmp[2][9][3] = sigmaE[2][0][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3];
        tmp[2][9][4] = sigmaE[2][0][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4];
        tmp[2][9][5] = sigmaE[2][0][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5];

        tmp[2][10][0] = sigmaE[2][1][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][10][1] = sigmaE[2][1][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][10][2] = sigmaE[2][1][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][10][3] = sigmaE[2][1][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][10][4] = sigmaE[2][1][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][10][5] = sigmaE[2][1][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][11][0] = sigmaE[2][2][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][11][1] = sigmaE[2][2][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][11][2] = sigmaE[2][2][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][11][3] = sigmaE[2][2][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][11][4] = sigmaE[2][2][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][11][5] = sigmaE[2][2][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][12][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0];
        tmp[2][12][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1];
        tmp[2][12][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2];
        tmp[2][12][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3];
        tmp[2][12][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4];
        tmp[2][12][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5];

        tmp[2][13][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][13][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][13][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][13][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][13][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][13][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][14][0] = sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][14][1] = sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][14][2] = sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][14][3] = sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][14][4] = sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][14][5] = sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][15][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][15][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][15][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][15][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][15][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][15][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][16][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][16][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][16][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][16][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][16][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][16][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][17][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][17][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][17][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][17][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][17][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][17][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][18][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][18][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][18][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][18][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][18][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][18][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][19][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][3][0];
        tmp[2][19][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][3][1];
        tmp[2][19][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][3][2];
        tmp[2][19][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][3][3];
        tmp[2][19][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][3][4];
        tmp[2][19][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][3][5];

        tmp[2][20][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][4][0];
        tmp[2][20][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][4][1];
        tmp[2][20][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][4][2];
        tmp[2][20][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][4][3];
        tmp[2][20][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][4][4];
        tmp[2][20][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][4][5];

        tmp[2][21][0] = sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][5][0];
        tmp[2][21][1] = sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][5][1];
        tmp[2][21][2] = sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][5][2];
        tmp[2][21][3] = sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][5][3];
        tmp[2][21][4] = sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][5][4];
        tmp[2][21][5] = sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][5][5];

        tmp[2][22][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][22][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][22][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][22][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][22][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][22][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][23][0] = sigmaE[2][0][0] ^ sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][23][1] = sigmaE[2][0][1] ^ sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][23][2] = sigmaE[2][0][2] ^ sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][23][3] = sigmaE[2][0][3] ^ sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][23][4] = sigmaE[2][0][4] ^ sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][23][5] = sigmaE[2][0][5] ^ sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][24][0] = sigmaE[2][1][0] ^ sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][24][1] = sigmaE[2][1][1] ^ sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][24][2] = sigmaE[2][1][2] ^ sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][24][3] = sigmaE[2][1][3] ^ sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][24][4] = sigmaE[2][1][4] ^ sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][24][5] = sigmaE[2][1][5] ^ sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][25][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0];
        tmp[2][25][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1];
        tmp[2][25][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2];
        tmp[2][25][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3];
        tmp[2][25][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4];
        tmp[2][25][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5];

        tmp[2][26][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0];
        tmp[2][26][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1];
        tmp[2][26][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2];
        tmp[2][26][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3];
        tmp[2][26][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4];
        tmp[2][26][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5];

        tmp[2][27][0] = sigmaE[2][2][0] ^ sigmaE[2][3][0];
        tmp[2][27][1] = sigmaE[2][2][1] ^ sigmaE[2][3][1];
        tmp[2][27][2] = sigmaE[2][2][2] ^ sigmaE[2][3][2];
        tmp[2][27][3] = sigmaE[2][2][3] ^ sigmaE[2][3][3];
        tmp[2][27][4] = sigmaE[2][2][4] ^ sigmaE[2][3][4];
        tmp[2][27][5] = sigmaE[2][2][5] ^ sigmaE[2][3][5];

        tmp[2][28][0] = sigmaE[2][3][0] ^ sigmaE[2][4][0];
        tmp[2][28][1] = sigmaE[2][3][1] ^ sigmaE[2][4][1];
        tmp[2][28][2] = sigmaE[2][3][2] ^ sigmaE[2][4][2];
        tmp[2][28][3] = sigmaE[2][3][3] ^ sigmaE[2][4][3];
        tmp[2][28][4] = sigmaE[2][3][4] ^ sigmaE[2][4][4];
        tmp[2][28][5] = sigmaE[2][3][5] ^ sigmaE[2][4][5];

        tmp[2][29][0] = sigmaE[2][4][0] ^ sigmaE[2][5][0];
        tmp[2][29][1] = sigmaE[2][4][1] ^ sigmaE[2][5][1];
        tmp[2][29][2] = sigmaE[2][4][2] ^ sigmaE[2][5][2];
        tmp[2][29][3] = sigmaE[2][4][3] ^ sigmaE[2][5][3];
        tmp[2][29][4] = sigmaE[2][4][4] ^ sigmaE[2][5][4];
        tmp[2][29][5] = sigmaE[2][4][5] ^ sigmaE[2][5][5];

        tmp[2][30][0] = sigmaE[2][0][0] ^ sigmaE[2][1][0] ^ sigmaE[2][2][0];
        tmp[2][30][1] = sigmaE[2][0][1] ^ sigmaE[2][1][1] ^ sigmaE[2][2][1];
        tmp[2][30][2] = sigmaE[2][0][2] ^ sigmaE[2][1][2] ^ sigmaE[2][2][2];
        tmp[2][30][3] = sigmaE[2][0][3] ^ sigmaE[2][1][3] ^ sigmaE[2][2][3];
        tmp[2][30][4] = sigmaE[2][0][4] ^ sigmaE[2][1][4] ^ sigmaE[2][2][4];
        tmp[2][30][5] = sigmaE[2][0][5] ^ sigmaE[2][1][5] ^ sigmaE[2][2][5];

        tmp[2][31][0] = sigmaE[2][1][0] ^ sigmaE[2][2][0] ^ sigmaE[2][3][0];
        tmp[2][31][1] = sigmaE[2][1][1] ^ sigmaE[2][2][1] ^ sigmaE[2][3][1];
        tmp[2][31][2] = sigmaE[2][1][2] ^ sigmaE[2][2][2] ^ sigmaE[2][3][2];
        tmp[2][31][3] = sigmaE[2][1][3] ^ sigmaE[2][2][3] ^ sigmaE[2][3][3];
        tmp[2][31][4] = sigmaE[2][1][4] ^ sigmaE[2][2][4] ^ sigmaE[2][3][4];
        tmp[2][31][5] = sigmaE[2][1][5] ^ sigmaE[2][2][5] ^ sigmaE[2][3][5];

        y[0][0] = sigma0[0] ^ tmp[0][0][0] ^ tmp[1][0][0] ^ tmp[2][0][0];
        y[0][1] = sigma0[1] ^ tmp[0][0][1] ^ tmp[1][0][1] ^ tmp[2][0][1];
        y[0][2] = sigma0[2] ^ tmp[0][0][2] ^ tmp[1][0][2] ^ tmp[2][0][2];
        y[0][3] = sigma0[3] ^ tmp[0][0][3] ^ tmp[1][0][3] ^ tmp[2][0][3];
        y[0][4] = sigma0[4] ^ tmp[0][0][4] ^ tmp[1][0][4] ^ tmp[2][0][4];
        y[0][5] = sigma0[5] ^ tmp[0][0][5] ^ tmp[1][0][5] ^ tmp[2][0][5];

        y[1][0] = sigma0[0] ^ tmp[0][1][0] ^ tmp[1][1][0] ^ tmp[2][1][0];
        y[1][1] = sigma0[1] ^ tmp[0][1][1] ^ tmp[1][1][1] ^ tmp[2][1][1];
        y[1][2] = sigma0[2] ^ tmp[0][1][2] ^ tmp[1][1][2] ^ tmp[2][1][2];
        y[1][3] = sigma0[3] ^ tmp[0][1][3] ^ tmp[1][1][3] ^ tmp[2][1][3];
        y[1][4] = sigma0[4] ^ tmp[0][1][4] ^ tmp[1][1][4] ^ tmp[2][1][4];
        y[1][5] = sigma0[5] ^ tmp[0][1][5] ^ tmp[1][1][5] ^ tmp[2][1][5];

        y[2][0] = sigma0[0] ^ tmp[0][2][0] ^ tmp[1][2][0] ^ tmp[2][2][0];
        y[2][1] = sigma0[1] ^ tmp[0][2][1] ^ tmp[1][2][1] ^ tmp[2][2][1];
        y[2][2] = sigma0[2] ^ tmp[0][2][2] ^ tmp[1][2][2] ^ tmp[2][2][2];
        y[2][3] = sigma0[3] ^ tmp[0][2][3] ^ tmp[1][2][3] ^ tmp[2][2][3];
        y[2][4] = sigma0[4] ^ tmp[0][2][4] ^ tmp[1][2][4] ^ tmp[2][2][4];
        y[2][5] = sigma0[5] ^ tmp[0][2][5] ^ tmp[1][2][5] ^ tmp[2][2][5];

        y[3][0] = sigma0[0] ^ tmp[0][3][0] ^ tmp[1][3][0] ^ tmp[2][3][0];
        y[3][1] = sigma0[1] ^ tmp[0][3][1] ^ tmp[1][3][1] ^ tmp[2][3][1];
        y[3][2] = sigma0[2] ^ tmp[0][3][2] ^ tmp[1][3][2] ^ tmp[2][3][2];
        y[3][3] = sigma0[3] ^ tmp[0][3][3] ^ tmp[1][3][3] ^ tmp[2][3][3];
        y[3][4] = sigma0[4] ^ tmp[0][3][4] ^ tmp[1][3][4] ^ tmp[2][3][4];
        y[3][5] = sigma0[5] ^ tmp[0][3][5] ^ tmp[1][3][5] ^ tmp[2][3][5];

        y[4][0] = sigma0[0] ^ tmp[0][4][0] ^ tmp[1][4][0] ^ tmp[2][4][0];
        y[4][1] = sigma0[1] ^ tmp[0][4][1] ^ tmp[1][4][1] ^ tmp[2][4][1];
        y[4][2] = sigma0[2] ^ tmp[0][4][2] ^ tmp[1][4][2] ^ tmp[2][4][2];
        y[4][3] = sigma0[3] ^ tmp[0][4][3] ^ tmp[1][4][3] ^ tmp[2][4][3];
        y[4][4] = sigma0[4] ^ tmp[0][4][4] ^ tmp[1][4][4] ^ tmp[2][4][4];
        y[4][5] = sigma0[5] ^ tmp[0][4][5] ^ tmp[1][4][5] ^ tmp[2][4][5];

        y[5][0] = sigma0[0] ^ tmp[0][5][0] ^ tmp[1][5][0] ^ tmp[2][5][0];
        y[5][1] = sigma0[1] ^ tmp[0][5][1] ^ tmp[1][5][1] ^ tmp[2][5][1];
        y[5][2] = sigma0[2] ^ tmp[0][5][2] ^ tmp[1][5][2] ^ tmp[2][5][2];
        y[5][3] = sigma0[3] ^ tmp[0][5][3] ^ tmp[1][5][3] ^ tmp[2][5][3];
        y[5][4] = sigma0[4] ^ tmp[0][5][4] ^ tmp[1][5][4] ^ tmp[2][5][4];
        y[5][5] = sigma0[5] ^ tmp[0][5][5] ^ tmp[1][5][5] ^ tmp[2][5][5];

        y[6][0] = sigma0[0] ^ tmp[0][6][0] ^ tmp[1][6][0] ^ tmp[2][6][0];
        y[6][1] = sigma0[1] ^ tmp[0][6][1] ^ tmp[1][6][1] ^ tmp[2][6][1];
        y[6][2] = sigma0[2] ^ tmp[0][6][2] ^ tmp[1][6][2] ^ tmp[2][6][2];
        y[6][3] = sigma0[3] ^ tmp[0][6][3] ^ tmp[1][6][3] ^ tmp[2][6][3];
        y[6][4] = sigma0[4] ^ tmp[0][6][4] ^ tmp[1][6][4] ^ tmp[2][6][4];
        y[6][5] = sigma0[5] ^ tmp[0][6][5] ^ tmp[1][6][5] ^ tmp[2][6][5];

        y[7][0] = sigma0[0] ^ tmp[0][7][0] ^ tmp[1][7][0] ^ tmp[2][7][0];
        y[7][1] = sigma0[1] ^ tmp[0][7][1] ^ tmp[1][7][1] ^ tmp[2][7][1];
        y[7][2] = sigma0[2] ^ tmp[0][7][2] ^ tmp[1][7][2] ^ tmp[2][7][2];
        y[7][3] = sigma0[3] ^ tmp[0][7][3] ^ tmp[1][7][3] ^ tmp[2][7][3];
        y[7][4] = sigma0[4] ^ tmp[0][7][4] ^ tmp[1][7][4] ^ tmp[2][7][4];
        y[7][5] = sigma0[5] ^ tmp[0][7][5] ^ tmp[1][7][5] ^ tmp[2][7][5];

        y[8][0] = sigma0[0] ^ tmp[0][8][0] ^ tmp[1][8][0] ^ tmp[2][8][0];
        y[8][1] = sigma0[1] ^ tmp[0][8][1] ^ tmp[1][8][1] ^ tmp[2][8][1];
        y[8][2] = sigma0[2] ^ tmp[0][8][2] ^ tmp[1][8][2] ^ tmp[2][8][2];
        y[8][3] = sigma0[3] ^ tmp[0][8][3] ^ tmp[1][8][3] ^ tmp[2][8][3];
        y[8][4] = sigma0[4] ^ tmp[0][8][4] ^ tmp[1][8][4] ^ tmp[2][8][4];
        y[8][5] = sigma0[5] ^ tmp[0][8][5] ^ tmp[1][8][5] ^ tmp[2][8][5];

        y[9][0] = sigma0[0] ^ tmp[0][9][0] ^ tmp[1][9][0] ^ tmp[2][9][0];
        y[9][1] = sigma0[1] ^ tmp[0][9][1] ^ tmp[1][9][1] ^ tmp[2][9][1];
        y[9][2] = sigma0[2] ^ tmp[0][9][2] ^ tmp[1][9][2] ^ tmp[2][9][2];
        y[9][3] = sigma0[3] ^ tmp[0][9][3] ^ tmp[1][9][3] ^ tmp[2][9][3];
        y[9][4] = sigma0[4] ^ tmp[0][9][4] ^ tmp[1][9][4] ^ tmp[2][9][4];
        y[9][5] = sigma0[5] ^ tmp[0][9][5] ^ tmp[1][9][5] ^ tmp[2][9][5];

        y[10][0] = sigma0[0] ^ tmp[0][10][0] ^ tmp[1][10][0] ^ tmp[2][10][0];
        y[10][1] = sigma0[1] ^ tmp[0][10][1] ^ tmp[1][10][1] ^ tmp[2][10][1];
        y[10][2] = sigma0[2] ^ tmp[0][10][2] ^ tmp[1][10][2] ^ tmp[2][10][2];
        y[10][3] = sigma0[3] ^ tmp[0][10][3] ^ tmp[1][10][3] ^ tmp[2][10][3];
        y[10][4] = sigma0[4] ^ tmp[0][10][4] ^ tmp[1][10][4] ^ tmp[2][10][4];
        y[10][5] = sigma0[5] ^ tmp[0][10][5] ^ tmp[1][10][5] ^ tmp[2][10][5];

        y[11][0] = sigma0[0] ^ tmp[0][11][0] ^ tmp[1][11][0] ^ tmp[2][11][0];
        y[11][1] = sigma0[1] ^ tmp[0][11][1] ^ tmp[1][11][1] ^ tmp[2][11][1];
        y[11][2] = sigma0[2] ^ tmp[0][11][2] ^ tmp[1][11][2] ^ tmp[2][11][2];
        y[11][3] = sigma0[3] ^ tmp[0][11][3] ^ tmp[1][11][3] ^ tmp[2][11][3];
        y[11][4] = sigma0[4] ^ tmp[0][11][4] ^ tmp[1][11][4] ^ tmp[2][11][4];
        y[11][5] = sigma0[5] ^ tmp[0][11][5] ^ tmp[1][11][5] ^ tmp[2][11][5];

        y[12][0] = sigma0[0] ^ tmp[0][12][0] ^ tmp[1][12][0] ^ tmp[2][12][0];
        y[12][1] = sigma0[1] ^ tmp[0][12][1] ^ tmp[1][12][1] ^ tmp[2][12][1];
        y[12][2] = sigma0[2] ^ tmp[0][12][2] ^ tmp[1][12][2] ^ tmp[2][12][2];
        y[12][3] = sigma0[3] ^ tmp[0][12][3] ^ tmp[1][12][3] ^ tmp[2][12][3];
        y[12][4] = sigma0[4] ^ tmp[0][12][4] ^ tmp[1][12][4] ^ tmp[2][12][4];
        y[12][5] = sigma0[5] ^ tmp[0][12][5] ^ tmp[1][12][5] ^ tmp[2][12][5];

        y[13][0] = sigma0[0] ^ tmp[0][13][0] ^ tmp[1][13][0] ^ tmp[2][13][0];
        y[13][1] = sigma0[1] ^ tmp[0][13][1] ^ tmp[1][13][1] ^ tmp[2][13][1];
        y[13][2] = sigma0[2] ^ tmp[0][13][2] ^ tmp[1][13][2] ^ tmp[2][13][2];
        y[13][3] = sigma0[3] ^ tmp[0][13][3] ^ tmp[1][13][3] ^ tmp[2][13][3];
        y[13][4] = sigma0[4] ^ tmp[0][13][4] ^ tmp[1][13][4] ^ tmp[2][13][4];
        y[13][5] = sigma0[5] ^ tmp[0][13][5] ^ tmp[1][13][5] ^ tmp[2][13][5];

        y[14][0] = sigma0[0] ^ tmp[0][14][0] ^ tmp[1][14][0] ^ tmp[2][14][0];
        y[14][1] = sigma0[1] ^ tmp[0][14][1] ^ tmp[1][14][1] ^ tmp[2][14][1];
        y[14][2] = sigma0[2] ^ tmp[0][14][2] ^ tmp[1][14][2] ^ tmp[2][14][2];
        y[14][3] = sigma0[3] ^ tmp[0][14][3] ^ tmp[1][14][3] ^ tmp[2][14][3];
        y[14][4] = sigma0[4] ^ tmp[0][14][4] ^ tmp[1][14][4] ^ tmp[2][14][4];
        y[14][5] = sigma0[5] ^ tmp[0][14][5] ^ tmp[1][14][5] ^ tmp[2][14][5];

        y[15][0] = sigma0[0] ^ tmp[0][15][0] ^ tmp[1][15][0] ^ tmp[2][15][0];
        y[15][1] = sigma0[1] ^ tmp[0][15][1] ^ tmp[1][15][1] ^ tmp[2][15][1];
        y[15][2] = sigma0[2] ^ tmp[0][15][2] ^ tmp[1][15][2] ^ tmp[2][15][2];
        y[15][3] = sigma0[3] ^ tmp[0][15][3] ^ tmp[1][15][3] ^ tmp[2][15][3];
        y[15][4] = sigma0[4] ^ tmp[0][15][4] ^ tmp[1][15][4] ^ tmp[2][15][4];
        y[15][5] = sigma0[5] ^ tmp[0][15][5] ^ tmp[1][15][5] ^ tmp[2][15][5];

        y[16][0] = sigma0[0] ^ tmp[0][16][0] ^ tmp[1][16][0] ^ tmp[2][16][0];
        y[16][1] = sigma0[1] ^ tmp[0][16][1] ^ tmp[1][16][1] ^ tmp[2][16][1];
        y[16][2] = sigma0[2] ^ tmp[0][16][2] ^ tmp[1][16][2] ^ tmp[2][16][2];
        y[16][3] = sigma0[3] ^ tmp[0][16][3] ^ tmp[1][16][3] ^ tmp[2][16][3];
        y[16][4] = sigma0[4] ^ tmp[0][16][4] ^ tmp[1][16][4] ^ tmp[2][16][4];
        y[16][5] = sigma0[5] ^ tmp[0][16][5] ^ tmp[1][16][5] ^ tmp[2][16][5];

        y[17][0] = sigma0[0] ^ tmp[0][17][0] ^ tmp[1][17][0] ^ tmp[2][17][0];
        y[17][1] = sigma0[1] ^ tmp[0][17][1] ^ tmp[1][17][1] ^ tmp[2][17][1];
        y[17][2] = sigma0[2] ^ tmp[0][17][2] ^ tmp[1][17][2] ^ tmp[2][17][2];
        y[17][3] = sigma0[3] ^ tmp[0][17][3] ^ tmp[1][17][3] ^ tmp[2][17][3];
        y[17][4] = sigma0[4] ^ tmp[0][17][4] ^ tmp[1][17][4] ^ tmp[2][17][4];
        y[17][5] = sigma0[5] ^ tmp[0][17][5] ^ tmp[1][17][5] ^ tmp[2][17][5];

        y[18][0] = sigma0[0] ^ tmp[0][18][0] ^ tmp[1][18][0] ^ tmp[2][18][0];
        y[18][1] = sigma0[1] ^ tmp[0][18][1] ^ tmp[1][18][1] ^ tmp[2][18][1];
        y[18][2] = sigma0[2] ^ tmp[0][18][2] ^ tmp[1][18][2] ^ tmp[2][18][2];
        y[18][3] = sigma0[3] ^ tmp[0][18][3] ^ tmp[1][18][3] ^ tmp[2][18][3];
        y[18][4] = sigma0[4] ^ tmp[0][18][4] ^ tmp[1][18][4] ^ tmp[2][18][4];
        y[18][5] = sigma0[5] ^ tmp[0][18][5] ^ tmp[1][18][5] ^ tmp[2][18][5];

        y[19][0] = sigma0[0] ^ tmp[0][19][0] ^ tmp[1][19][0] ^ tmp[2][19][0];
        y[19][1] = sigma0[1] ^ tmp[0][19][1] ^ tmp[1][19][1] ^ tmp[2][19][1];
        y[19][2] = sigma0[2] ^ tmp[0][19][2] ^ tmp[1][19][2] ^ tmp[2][19][2];
        y[19][3] = sigma0[3] ^ tmp[0][19][3] ^ tmp[1][19][3] ^ tmp[2][19][3];
        y[19][4] = sigma0[4] ^ tmp[0][19][4] ^ tmp[1][19][4] ^ tmp[2][19][4];
        y[19][5] = sigma0[5] ^ tmp[0][19][5] ^ tmp[1][19][5] ^ tmp[2][19][5];

        y[20][0] = sigma0[0] ^ tmp[0][20][0] ^ tmp[1][20][0] ^ tmp[2][20][0];
        y[20][1] = sigma0[1] ^ tmp[0][20][1] ^ tmp[1][20][1] ^ tmp[2][20][1];
        y[20][2] = sigma0[2] ^ tmp[0][20][2] ^ tmp[1][20][2] ^ tmp[2][20][2];
        y[20][3] = sigma0[3] ^ tmp[0][20][3] ^ tmp[1][20][3] ^ tmp[2][20][3];
        y[20][4] = sigma0[4] ^ tmp[0][20][4] ^ tmp[1][20][4] ^ tmp[2][20][4];
        y[20][5] = sigma0[5] ^ tmp[0][20][5] ^ tmp[1][20][5] ^ tmp[2][20][5];

        y[21][0] = sigma0[0] ^ tmp[0][21][0] ^ tmp[1][21][0] ^ tmp[2][21][0];
        y[21][1] = sigma0[1] ^ tmp[0][21][1] ^ tmp[1][21][1] ^ tmp[2][21][1];
        y[21][2] = sigma0[2] ^ tmp[0][21][2] ^ tmp[1][21][2] ^ tmp[2][21][2];
        y[21][3] = sigma0[3] ^ tmp[0][21][3] ^ tmp[1][21][3] ^ tmp[2][21][3];
        y[21][4] = sigma0[4] ^ tmp[0][21][4] ^ tmp[1][21][4] ^ tmp[2][21][4];
        y[21][5] = sigma0[5] ^ tmp[0][21][5] ^ tmp[1][21][5] ^ tmp[2][21][5];

        y[22][0] = sigma0[0] ^ tmp[0][22][0] ^ tmp[1][22][0] ^ tmp[2][22][0];
        y[22][1] = sigma0[1] ^ tmp[0][22][1] ^ tmp[1][22][1] ^ tmp[2][22][1];
        y[22][2] = sigma0[2] ^ tmp[0][22][2] ^ tmp[1][22][2] ^ tmp[2][22][2];
        y[22][3] = sigma0[3] ^ tmp[0][22][3] ^ tmp[1][22][3] ^ tmp[2][22][3];
        y[22][4] = sigma0[4] ^ tmp[0][22][4] ^ tmp[1][22][4] ^ tmp[2][22][4];
        y[22][5] = sigma0[5] ^ tmp[0][22][5] ^ tmp[1][22][5] ^ tmp[2][22][5];

        y[23][0] = sigma0[0] ^ tmp[0][23][0] ^ tmp[1][23][0] ^ tmp[2][23][0];
        y[23][1] = sigma0[1] ^ tmp[0][23][1] ^ tmp[1][23][1] ^ tmp[2][23][1];
        y[23][2] = sigma0[2] ^ tmp[0][23][2] ^ tmp[1][23][2] ^ tmp[2][23][2];
        y[23][3] = sigma0[3] ^ tmp[0][23][3] ^ tmp[1][23][3] ^ tmp[2][23][3];
        y[23][4] = sigma0[4] ^ tmp[0][23][4] ^ tmp[1][23][4] ^ tmp[2][23][4];
        y[23][5] = sigma0[5] ^ tmp[0][23][5] ^ tmp[1][23][5] ^ tmp[2][23][5];

        y[24][0] = sigma0[0] ^ tmp[0][24][0] ^ tmp[1][24][0] ^ tmp[2][24][0];
        y[24][1] = sigma0[1] ^ tmp[0][24][1] ^ tmp[1][24][1] ^ tmp[2][24][1];
        y[24][2] = sigma0[2] ^ tmp[0][24][2] ^ tmp[1][24][2] ^ tmp[2][24][2];
        y[24][3] = sigma0[3] ^ tmp[0][24][3] ^ tmp[1][24][3] ^ tmp[2][24][3];
        y[24][4] = sigma0[4] ^ tmp[0][24][4] ^ tmp[1][24][4] ^ tmp[2][24][4];
        y[24][5] = sigma0[5] ^ tmp[0][24][5] ^ tmp[1][24][5] ^ tmp[2][24][5];

        y[25][0] = sigma0[0] ^ tmp[0][25][0] ^ tmp[1][25][0] ^ tmp[2][25][0];
        y[25][1] = sigma0[1] ^ tmp[0][25][1] ^ tmp[1][25][1] ^ tmp[2][25][1];
        y[25][2] = sigma0[2] ^ tmp[0][25][2] ^ tmp[1][25][2] ^ tmp[2][25][2];
        y[25][3] = sigma0[3] ^ tmp[0][25][3] ^ tmp[1][25][3] ^ tmp[2][25][3];
        y[25][4] = sigma0[4] ^ tmp[0][25][4] ^ tmp[1][25][4] ^ tmp[2][25][4];
        y[25][5] = sigma0[5] ^ tmp[0][25][5] ^ tmp[1][25][5] ^ tmp[2][25][5];

        y[26][0] = sigma0[0] ^ tmp[0][26][0] ^ tmp[1][26][0] ^ tmp[2][26][0];
        y[26][1] = sigma0[1] ^ tmp[0][26][1] ^ tmp[1][26][1] ^ tmp[2][26][1];
        y[26][2] = sigma0[2] ^ tmp[0][26][2] ^ tmp[1][26][2] ^ tmp[2][26][2];
        y[26][3] = sigma0[3] ^ tmp[0][26][3] ^ tmp[1][26][3] ^ tmp[2][26][3];
        y[26][4] = sigma0[4] ^ tmp[0][26][4] ^ tmp[1][26][4] ^ tmp[2][26][4];
        y[26][5] = sigma0[5] ^ tmp[0][26][5] ^ tmp[1][26][5] ^ tmp[2][26][5];

        y[27][0] = sigma0[0] ^ tmp[0][27][0] ^ tmp[1][27][0] ^ tmp[2][27][0];
        y[27][1] = sigma0[1] ^ tmp[0][27][1] ^ tmp[1][27][1] ^ tmp[2][27][1];
        y[27][2] = sigma0[2] ^ tmp[0][27][2] ^ tmp[1][27][2] ^ tmp[2][27][2];
        y[27][3] = sigma0[3] ^ tmp[0][27][3] ^ tmp[1][27][3] ^ tmp[2][27][3];
        y[27][4] = sigma0[4] ^ tmp[0][27][4] ^ tmp[1][27][4] ^ tmp[2][27][4];
        y[27][5] = sigma0[5] ^ tmp[0][27][5] ^ tmp[1][27][5] ^ tmp[2][27][5];

        y[28][0] = sigma0[0] ^ tmp[0][28][0] ^ tmp[1][28][0] ^ tmp[2][28][0];
        y[28][1] = sigma0[1] ^ tmp[0][28][1] ^ tmp[1][28][1] ^ tmp[2][28][1];
        y[28][2] = sigma0[2] ^ tmp[0][28][2] ^ tmp[1][28][2] ^ tmp[2][28][2];
        y[28][3] = sigma0[3] ^ tmp[0][28][3] ^ tmp[1][28][3] ^ tmp[2][28][3];
        y[28][4] = sigma0[4] ^ tmp[0][28][4] ^ tmp[1][28][4] ^ tmp[2][28][4];
        y[28][5] = sigma0[5] ^ tmp[0][28][5] ^ tmp[1][28][5] ^ tmp[2][28][5];

        y[29][0] = sigma0[0] ^ tmp[0][29][0] ^ tmp[1][29][0] ^ tmp[2][29][0];
        y[29][1] = sigma0[1] ^ tmp[0][29][1] ^ tmp[1][29][1] ^ tmp[2][29][1];
        y[29][2] = sigma0[2] ^ tmp[0][29][2] ^ tmp[1][29][2] ^ tmp[2][29][2];
        y[29][3] = sigma0[3] ^ tmp[0][29][3] ^ tmp[1][29][3] ^ tmp[2][29][3];
        y[29][4] = sigma0[4] ^ tmp[0][29][4] ^ tmp[1][29][4] ^ tmp[2][29][4];
        y[29][5] = sigma0[5] ^ tmp[0][29][5] ^ tmp[1][29][5] ^ tmp[2][29][5];

        y[30][0] = sigma0[0] ^ tmp[0][30][0] ^ tmp[1][30][0] ^ tmp[2][30][0];
        y[30][1] = sigma0[1] ^ tmp[0][30][1] ^ tmp[1][30][1] ^ tmp[2][30][1];
        y[30][2] = sigma0[2] ^ tmp[0][30][2] ^ tmp[1][30][2] ^ tmp[2][30][2];
        y[30][3] = sigma0[3] ^ tmp[0][30][3] ^ tmp[1][30][3] ^ tmp[2][30][3];
        y[30][4] = sigma0[4] ^ tmp[0][30][4] ^ tmp[1][30][4] ^ tmp[2][30][4];
        y[30][5] = sigma0[5] ^ tmp[0][30][5] ^ tmp[1][30][5] ^ tmp[2][30][5];

        y[31][0] = sigma0[0] ^ tmp[0][31][0] ^ tmp[1][31][0] ^ tmp[2][31][0];
        y[31][1] = sigma0[1] ^ tmp[0][31][1] ^ tmp[1][31][1] ^ tmp[2][31][1];
        y[31][2] = sigma0[2] ^ tmp[0][31][2] ^ tmp[1][31][2] ^ tmp[2][31][2];
        y[31][3] = sigma0[3] ^ tmp[0][31][3] ^ tmp[1][31][3] ^ tmp[2][31][3];
        y[31][4] = sigma0[4] ^ tmp[0][31][4] ^ tmp[1][31][4] ^ tmp[2][31][4];
        y[31][5] = sigma0[5] ^ tmp[0][31][5] ^ tmp[1][31][5] ^ tmp[2][31][5];

    end

endmodule
