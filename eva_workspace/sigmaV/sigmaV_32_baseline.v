module sigmaV_baseline(
    input  [5:0]        sigma[6:0],
    output reg [5:0]    y[31:0]
);

    wire [5:0]  sigmaE[31:0];

    sigmaE_baseline se0(
        .sigma(sigma),
        .y(sigmaE)
    );

    sigmaEB_baseline seb0(
        .sigmaE(sigmaE),
        .y(y)
    );

endmodule

module sigmaE_baseline(
    input  [5:0]      sigma[6:0],
    output reg [5:0]  y[31:0]
);

    always @* begin
        y[0][0] = sigma[0][0] ^ sigma[1][0] ^ sigma[2][0] ^ sigma[3][0] ^ sigma[4][0] ^ sigma[5][0] ^ sigma[6][0];
        y[0][1] = sigma[0][1] ^ sigma[1][1] ^ sigma[2][1] ^ sigma[3][1] ^ sigma[4][1] ^ sigma[5][1] ^ sigma[6][1];
        y[0][2] = sigma[0][2] ^ sigma[1][2] ^ sigma[2][2] ^ sigma[3][2] ^ sigma[4][2] ^ sigma[5][2] ^ sigma[6][2];
        y[0][3] = sigma[0][3] ^ sigma[1][3] ^ sigma[2][3] ^ sigma[3][3] ^ sigma[4][3] ^ sigma[5][3] ^ sigma[6][3];
        y[0][4] = sigma[0][4] ^ sigma[1][4] ^ sigma[2][4] ^ sigma[3][4] ^ sigma[4][4] ^ sigma[5][4] ^ sigma[6][4];
        y[0][5] = sigma[0][5] ^ sigma[1][5] ^ sigma[2][5] ^ sigma[3][5] ^ sigma[4][5] ^ sigma[5][5] ^ sigma[6][5];

        y[1][0] = sigma[0][0] ^ sigma[1][5] ^ sigma[2][4] ^ sigma[3][3] ^ sigma[4][2] ^ sigma[5][1] ^ sigma[6][0] ^ sigma[6][5];
        y[1][1] = sigma[0][1] ^ sigma[1][0] ^ sigma[1][5] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][5];
        y[1][2] = sigma[0][2] ^ sigma[1][1] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][1] ^ sigma[6][2];
        y[1][3] = sigma[0][3] ^ sigma[1][2] ^ sigma[2][1] ^ sigma[3][0] ^ sigma[3][5] ^ sigma[4][4] ^ sigma[4][5] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][3];
        y[1][4] = sigma[0][4] ^ sigma[1][3] ^ sigma[2][2] ^ sigma[3][1] ^ sigma[4][0] ^ sigma[4][5] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][3] ^ sigma[6][4];
        y[1][5] = sigma[0][5] ^ sigma[1][4] ^ sigma[2][3] ^ sigma[3][2] ^ sigma[4][1] ^ sigma[5][0] ^ sigma[5][5] ^ sigma[6][4] ^ sigma[6][5];

        y[2][0] = sigma[0][0] ^ sigma[1][4] ^ sigma[2][2] ^ sigma[3][0] ^ sigma[3][5] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][4];
        y[2][1] = sigma[0][1] ^ sigma[1][4] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[4][3] ^ sigma[4][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][1] ^ sigma[6][4] ^ sigma[6][5];
        y[2][2] = sigma[0][2] ^ sigma[1][0] ^ sigma[1][5] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[4][0] ^ sigma[4][4] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][5];
        y[2][3] = sigma[0][3] ^ sigma[1][1] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][5] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][3];
        y[2][4] = sigma[0][4] ^ sigma[1][2] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][4];
        y[2][5] = sigma[0][5] ^ sigma[1][3] ^ sigma[2][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][3] ^ sigma[6][5];

        y[3][0] = sigma[0][0] ^ sigma[1][3] ^ sigma[2][0] ^ sigma[2][5] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[4][0] ^ sigma[4][4] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[3][1] = sigma[0][1] ^ sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[4][1] ^ sigma[4][4] ^ sigma[4][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3];
        y[3][2] = sigma[0][2] ^ sigma[1][4] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][2] ^ sigma[4][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4];
        y[3][3] = sigma[0][3] ^ sigma[1][0] ^ sigma[1][5] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[4][1] ^ sigma[4][3] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[3][4] = sigma[0][4] ^ sigma[1][1] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[4][2] ^ sigma[4][4] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[3][5] = sigma[0][5] ^ sigma[1][2] ^ sigma[2][4] ^ sigma[2][5] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[4][3] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[4][0] = sigma[0][0] ^ sigma[1][2] ^ sigma[2][3] ^ sigma[2][4] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[4][0] ^ sigma[4][2] ^ sigma[4][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][2];
        y[4][1] = sigma[0][1] ^ sigma[1][2] ^ sigma[1][3] ^ sigma[2][3] ^ sigma[2][5] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][5] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[4][2] = sigma[0][2] ^ sigma[1][3] ^ sigma[1][4] ^ sigma[2][0] ^ sigma[2][4] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[4][3] = sigma[0][3] ^ sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[4][4] = sigma[0][4] ^ sigma[1][0] ^ sigma[1][5] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[4][0] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][4] ^ sigma[6][5];
        y[4][5] = sigma[0][5] ^ sigma[1][1] ^ sigma[2][2] ^ sigma[2][3] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[4][1] ^ sigma[4][4] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][5];

        y[5][0] = sigma[0][0] ^ sigma[1][1] ^ sigma[2][1] ^ sigma[2][2] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][4] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[5][1] = sigma[0][1] ^ sigma[1][1] ^ sigma[1][2] ^ sigma[2][1] ^ sigma[2][3] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[4][1] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];
        y[5][2] = sigma[0][2] ^ sigma[1][2] ^ sigma[1][3] ^ sigma[2][2] ^ sigma[2][4] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][2] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][1] ^ sigma[6][4];
        y[5][3] = sigma[0][3] ^ sigma[1][3] ^ sigma[1][4] ^ sigma[2][3] ^ sigma[2][5] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][3] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][5];
        y[5][4] = sigma[0][4] ^ sigma[1][4] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][4] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][4] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3];
        y[5][5] = sigma[0][5] ^ sigma[1][0] ^ sigma[1][5] ^ sigma[2][0] ^ sigma[2][1] ^ sigma[2][5] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[4][0] ^ sigma[4][1] ^ sigma[4][2] ^ sigma[4][3] ^ sigma[4][5] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];

        y[6][0] = sigma[0][0] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][4];
        y[6][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[6][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[6][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][4] ^ sigma[6][5];
        y[6][4] = sigma[0][4] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][5];
        y[6][5] = sigma[0][5] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][3];

        y[7][0] = sigma[0][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[7][1] = sigma[0][1] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][5];
        y[7][2] = sigma[0][2] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2];
        y[7][3] = sigma[0][3] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3];
        y[7][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4];
        y[7][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];

        y[8][0] = sigma[0][0] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][4] ^ sigma[6][5];
        y[8][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];
        y[8][2] = sigma[0][2] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[8][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[8][4] = sigma[0][4] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[8][5] = sigma[0][5] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[9][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][3];
        y[9][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4];
        y[9][2] = sigma[0][2] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[9][3] = sigma[0][3] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];
        y[9][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][4];
        y[9][5] = sigma[0][5] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][5];

        y[10][0] = sigma[0][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[10][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[10][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[10][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[10][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[10][5] = sigma[0][5] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];

        y[11][0] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[11][1] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][4];
        y[11][2] = sigma[3][1] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][5];
        y[11][3] = sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0];
        y[11][4] = sigma[3][0] ^ sigma[3][3] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1];
        y[11][5] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2];

        y[12][0] = sigma[0][0] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[12][1] = sigma[0][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][5];
        y[12][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3];
        y[12][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];
        y[12][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[12][5] = sigma[0][5] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][2] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];

        y[13][0] = sigma[0][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][4];
        y[13][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[13][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[13][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4];
        y[13][4] = sigma[0][4] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[13][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];

        y[14][0] = sigma[0][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[14][1] = sigma[0][1] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3];
        y[14][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4];
        y[14][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[14][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[14][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];

        y[15][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[15][1] = sigma[0][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][5];
        y[15][2] = sigma[0][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4];
        y[15][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[15][4] = sigma[0][4] ^ sigma[3][1] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][4];
        y[15][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4] ^ sigma[6][5];

        y[16][0] = sigma[3][0] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0];
        y[16][1] = sigma[3][1] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1];
        y[16][2] = sigma[3][2] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][2];
        y[16][3] = sigma[3][3] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[6][3];
        y[16][4] = sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][4];
        y[16][5] = sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][5];

        y[17][0] = sigma[3][3] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][5];
        y[17][1] = sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][5];
        y[17][2] = sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2];
        y[17][3] = sigma[3][0] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][2] ^ sigma[6][3];
        y[17][4] = sigma[3][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][3] ^ sigma[6][4];
        y[17][5] = sigma[3][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][4] ^ sigma[6][5];

        y[18][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2];
        y[18][1] = sigma[0][1] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[18][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[18][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[18][4] = sigma[0][4] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][4] ^ sigma[6][5];
        y[18][5] = sigma[0][5] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][5];

        y[19][0] = sigma[0][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[19][1] = sigma[0][1] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];
        y[19][2] = sigma[0][2] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][4];
        y[19][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][5];
        y[19][4] = sigma[0][4] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][3];
        y[19][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];

        y[20][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[20][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[20][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[20][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[20][4] = sigma[0][4] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][5];
        y[20][5] = sigma[0][5] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4];

        y[21][0] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[21][1] = sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[21][2] = sigma[3][0] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[21][3] = sigma[3][0] ^ sigma[3][1] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[21][4] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[21][5] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[22][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];
        y[22][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[22][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][5];
        y[22][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][4];
        y[22][4] = sigma[0][4] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[6][2] ^ sigma[6][5];
        y[22][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][3];

        y[23][0] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[23][1] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[6][1] ^ sigma[6][4];
        y[23][2] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][2] ^ sigma[6][5];
        y[23][3] = sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][3];
        y[23][4] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];
        y[23][5] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];

        y[24][0] = sigma[0][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[24][1] = sigma[0][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2];
        y[24][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[24][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[24][4] = sigma[0][4] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[24][5] = sigma[0][5] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[25][0] = sigma[0][0] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1];
        y[25][1] = sigma[0][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][2];
        y[25][2] = sigma[0][2] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][3];
        y[25][3] = sigma[0][3] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][4];
        y[25][4] = sigma[0][4] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][5];
        y[25][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[6][0];

        y[26][0] = sigma[3][1] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4];
        y[26][1] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[26][2] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[26][3] = sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][5];
        y[26][4] = sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][4];
        y[26][5] = sigma[3][0] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][5];

        y[27][0] = sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[27][1] = sigma[3][2] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2];
        y[27][2] = sigma[3][0] ^ sigma[3][3] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[27][3] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];
        y[27][4] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[27][5] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];

        y[28][0] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[6][0] ^ sigma[6][1];
        y[28][1] = sigma[3][2] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][2];
        y[28][2] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][3];
        y[28][3] = sigma[3][1] ^ sigma[3][4] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][4];
        y[28][4] = sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][4] ^ sigma[6][5];
        y[28][5] = sigma[3][0] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][5] ^ sigma[6][0];

        y[29][0] = sigma[3][1] ^ sigma[3][4] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[6][1];
        y[29][1] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][1] ^ sigma[6][2];
        y[29][2] = sigma[3][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][2] ^ sigma[6][3];
        y[29][3] = sigma[3][1] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][3] ^ sigma[6][4];
        y[29][4] = sigma[3][2] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][4] ^ sigma[6][5];
        y[29][5] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][5];

        y[30][0] = sigma[0][0] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][4] ^ sigma[6][5];
        y[30][1] = sigma[0][1] ^ sigma[3][0] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[6][0] ^ sigma[6][3] ^ sigma[6][4];
        y[30][2] = sigma[0][2] ^ sigma[3][1] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4] ^ sigma[6][5];
        y[30][3] = sigma[0][3] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[30][4] = sigma[0][4] ^ sigma[3][1] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][2] ^ sigma[6][3];
        y[30][5] = sigma[0][5] ^ sigma[3][0] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][3] ^ sigma[6][4];

        y[31][0] = sigma[3][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[5][0] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][3] ^ sigma[6][4] ^ sigma[6][5];
        y[31][1] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][3];
        y[31][2] = sigma[3][2] ^ sigma[3][3] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][4];
        y[31][3] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][4] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5] ^ sigma[6][0] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][5];
        y[31][4] = sigma[3][0] ^ sigma[3][1] ^ sigma[3][4] ^ sigma[3][5] ^ sigma[5][1] ^ sigma[5][3] ^ sigma[5][5] ^ sigma[6][1] ^ sigma[6][2] ^ sigma[6][3];
        y[31][5] = sigma[3][1] ^ sigma[3][2] ^ sigma[3][5] ^ sigma[5][0] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[6][2] ^ sigma[6][3] ^ sigma[6][4];

    end

endmodule

module sigmaEB_baseline(
    input  [5:0]      sigmaE[31:0],
    output reg [5:0]  y[31:0]
);

    always @* begin
        y[0] = sigmaE[0];
        y[1] = sigmaE[1];
        y[2] = sigmaE[2];
        y[3] = sigmaE[3];
        y[4] = sigmaE[4];
        y[5] = sigmaE[5];
        y[6] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[6];
        y[7] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[7];
        y[8] = sigmaE[2] ^ sigmaE[3] ^ sigmaE[8];
        y[9] = sigmaE[3] ^ sigmaE[4] ^ sigmaE[9];
        y[10] = sigmaE[4] ^ sigmaE[5] ^ sigmaE[10];
        y[11] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[5] ^ sigmaE[11];
        y[12] = sigmaE[0] ^ sigmaE[2] ^ sigmaE[12];
        y[13] = sigmaE[1] ^ sigmaE[3] ^ sigmaE[13];
        y[14] = sigmaE[2] ^ sigmaE[4] ^ sigmaE[14];
        y[15] = sigmaE[3] ^ sigmaE[5] ^ sigmaE[15];
        y[16] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[4] ^ sigmaE[16];
        y[17] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[5] ^ sigmaE[17];
        y[18] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[2] ^ sigmaE[3] ^ sigmaE[18];
        y[19] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[19];
        y[20] = sigmaE[2] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[20];
        y[21] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[21];
        y[22] = sigmaE[0] ^ sigmaE[2] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[22];
        y[23] = sigmaE[0] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[23];
        y[24] = sigmaE[0] ^ sigmaE[4] ^ sigmaE[24];
        y[25] = sigmaE[1] ^ sigmaE[5] ^ sigmaE[25];
        y[26] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[2] ^ sigmaE[26];
        y[27] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[3] ^ sigmaE[27];
        y[28] = sigmaE[2] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[28];
        y[29] = sigmaE[3] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[29];
        y[30] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[30];
        y[31] = sigmaE[0] ^ sigmaE[2] ^ sigmaE[5] ^ sigmaE[31];
    end

endmodule
