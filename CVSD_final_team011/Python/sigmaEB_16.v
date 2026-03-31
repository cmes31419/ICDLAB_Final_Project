module sigmaE(
    input  [1:0]      code,
    input  [9:0]      sigma0,
    input  [9:0]      sigma1,
    input  [9:0]      sigma2,
    input  [9:0]      sigma3,
    input  [9:0]      sigma4,
    output reg [9:0]  y[17:0]
);

    integer i;

    always @* begin
        for (i=0;i<18;i=i+1) begin
            y[i] = 10'b0;
        end
        case (code)
            2'd1: begin  // m = 6
                y[0][0] = sigma0[0] ^ sigma1[0] ^ sigma2[0];
                y[0][1] = sigma0[1] ^ sigma1[1] ^ sigma2[1];
                y[0][2] = sigma0[2] ^ sigma1[2] ^ sigma2[2];
                y[0][3] = sigma0[3] ^ sigma1[3] ^ sigma2[3];
                y[0][4] = sigma0[4] ^ sigma1[4] ^ sigma2[4];
                y[0][5] = sigma0[5] ^ sigma1[5] ^ sigma2[5];
                y[0][6] = 1'b0;
                y[0][7] = 1'b0;
                y[0][8] = 1'b0;
                y[0][9] = 1'b0;

                y[1][0] = sigma0[0] ^ sigma1[5] ^ sigma2[4];
                y[1][1] = sigma0[1] ^ sigma1[0] ^ sigma1[5] ^ sigma2[4] ^ sigma2[5];
                y[1][2] = sigma0[2] ^ sigma1[1] ^ sigma2[0] ^ sigma2[5];
                y[1][3] = sigma0[3] ^ sigma1[2] ^ sigma2[1];
                y[1][4] = sigma0[4] ^ sigma1[3] ^ sigma2[2];
                y[1][5] = sigma0[5] ^ sigma1[4] ^ sigma2[3];
                y[1][6] = 1'b0;
                y[1][7] = 1'b0;
                y[1][8] = 1'b0;
                y[1][9] = 1'b0;

                y[2][0] = sigma0[0] ^ sigma1[4] ^ sigma2[2];
                y[2][1] = sigma0[1] ^ sigma1[4] ^ sigma1[5] ^ sigma2[2] ^ sigma2[3];
                y[2][2] = sigma0[2] ^ sigma1[0] ^ sigma1[5] ^ sigma2[3] ^ sigma2[4];
                y[2][3] = sigma0[3] ^ sigma1[1] ^ sigma2[4] ^ sigma2[5];
                y[2][4] = sigma0[4] ^ sigma1[2] ^ sigma2[0] ^ sigma2[5];
                y[2][5] = sigma0[5] ^ sigma1[3] ^ sigma2[1];
                y[2][6] = 1'b0;
                y[2][7] = 1'b0;
                y[2][8] = 1'b0;
                y[2][9] = 1'b0;

                y[3][0] = sigma0[0] ^ sigma1[3] ^ sigma2[0] ^ sigma2[5];
                y[3][1] = sigma0[1] ^ sigma1[3] ^ sigma1[4] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[3][2] = sigma0[2] ^ sigma1[4] ^ sigma1[5] ^ sigma2[1] ^ sigma2[2];
                y[3][3] = sigma0[3] ^ sigma1[0] ^ sigma1[5] ^ sigma2[2] ^ sigma2[3];
                y[3][4] = sigma0[4] ^ sigma1[1] ^ sigma2[3] ^ sigma2[4];
                y[3][5] = sigma0[5] ^ sigma1[2] ^ sigma2[4] ^ sigma2[5];
                y[3][6] = 1'b0;
                y[3][7] = 1'b0;
                y[3][8] = 1'b0;
                y[3][9] = 1'b0;

                y[4][0] = sigma0[0] ^ sigma1[2] ^ sigma2[3] ^ sigma2[4];
                y[4][1] = sigma0[1] ^ sigma1[2] ^ sigma1[3] ^ sigma2[3] ^ sigma2[5];
                y[4][2] = sigma0[2] ^ sigma1[3] ^ sigma1[4] ^ sigma2[0] ^ sigma2[4];
                y[4][3] = sigma0[3] ^ sigma1[4] ^ sigma1[5] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[4][4] = sigma0[4] ^ sigma1[0] ^ sigma1[5] ^ sigma2[1] ^ sigma2[2];
                y[4][5] = sigma0[5] ^ sigma1[1] ^ sigma2[2] ^ sigma2[3];
                y[4][6] = 1'b0;
                y[4][7] = 1'b0;
                y[4][8] = 1'b0;
                y[4][9] = 1'b0;

                y[5][0] = sigma0[0] ^ sigma1[1] ^ sigma2[1] ^ sigma2[2];
                y[5][1] = sigma0[1] ^ sigma1[1] ^ sigma1[2] ^ sigma2[1] ^ sigma2[3];
                y[5][2] = sigma0[2] ^ sigma1[2] ^ sigma1[3] ^ sigma2[2] ^ sigma2[4];
                y[5][3] = sigma0[3] ^ sigma1[3] ^ sigma1[4] ^ sigma2[3] ^ sigma2[5];
                y[5][4] = sigma0[4] ^ sigma1[4] ^ sigma1[5] ^ sigma2[0] ^ sigma2[4];
                y[5][5] = sigma0[5] ^ sigma1[0] ^ sigma1[5] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[5][6] = 1'b0;
                y[5][7] = 1'b0;
                y[5][8] = 1'b0;
                y[5][9] = 1'b0;

                y[6][0] = sigma0[0];
                y[6][1] = sigma0[1];
                y[6][2] = sigma0[2];
                y[6][3] = sigma0[3];
                y[6][4] = sigma0[4];
                y[6][5] = sigma0[5];
                y[6][6] = 1'b0;
                y[6][7] = 1'b0;
                y[6][8] = 1'b0;
                y[6][9] = 1'b0;

                y[7][0] = sigma0[0];
                y[7][1] = sigma0[1];
                y[7][2] = sigma0[2];
                y[7][3] = sigma0[3];
                y[7][4] = sigma0[4];
                y[7][5] = sigma0[5];
                y[7][6] = 1'b0;
                y[7][7] = 1'b0;
                y[7][8] = 1'b0;
                y[7][9] = 1'b0;

                y[8][0] = sigma0[0];
                y[8][1] = sigma0[1];
                y[8][2] = sigma0[2];
                y[8][3] = sigma0[3];
                y[8][4] = sigma0[4];
                y[8][5] = sigma0[5];
                y[8][6] = 1'b0;
                y[8][7] = 1'b0;
                y[8][8] = 1'b0;
                y[8][9] = 1'b0;

                y[9][0] = sigma0[0];
                y[9][1] = sigma0[1];
                y[9][2] = sigma0[2];
                y[9][3] = sigma0[3];
                y[9][4] = sigma0[4];
                y[9][5] = sigma0[5];
                y[9][6] = 1'b0;
                y[9][7] = 1'b0;
                y[9][8] = 1'b0;
                y[9][9] = 1'b0;

                y[10][0] = sigma0[0];
                y[10][1] = sigma0[1];
                y[10][2] = sigma0[2];
                y[10][3] = sigma0[3];
                y[10][4] = sigma0[4];
                y[10][5] = sigma0[5];
                y[10][6] = 1'b0;
                y[10][7] = 1'b0;
                y[10][8] = 1'b0;
                y[10][9] = 1'b0;

                y[11][0] = 1'b0;
                y[11][1] = 1'b0;
                y[11][2] = 1'b0;
                y[11][3] = 1'b0;
                y[11][4] = 1'b0;
                y[11][5] = 1'b0;
                y[11][6] = 1'b0;
                y[11][7] = 1'b0;
                y[11][8] = 1'b0;
                y[11][9] = 1'b0;

                y[12][0] = 1'b0;
                y[12][1] = 1'b0;
                y[12][2] = 1'b0;
                y[12][3] = 1'b0;
                y[12][4] = 1'b0;
                y[12][5] = 1'b0;
                y[12][6] = 1'b0;
                y[12][7] = 1'b0;
                y[12][8] = 1'b0;
                y[12][9] = 1'b0;

                y[13][0] = 1'b0;
                y[13][1] = 1'b0;
                y[13][2] = 1'b0;
                y[13][3] = 1'b0;
                y[13][4] = 1'b0;
                y[13][5] = 1'b0;
                y[13][6] = 1'b0;
                y[13][7] = 1'b0;
                y[13][8] = 1'b0;
                y[13][9] = 1'b0;

                y[14][0] = sigma0[0];
                y[14][1] = sigma0[1];
                y[14][2] = sigma0[2];
                y[14][3] = sigma0[3];
                y[14][4] = sigma0[4];
                y[14][5] = sigma0[5];
                y[14][6] = 1'b0;
                y[14][7] = 1'b0;
                y[14][8] = 1'b0;
                y[14][9] = 1'b0;

                y[15][0] = sigma0[0];
                y[15][1] = sigma0[1];
                y[15][2] = sigma0[2];
                y[15][3] = sigma0[3];
                y[15][4] = sigma0[4];
                y[15][5] = sigma0[5];
                y[15][6] = 1'b0;
                y[15][7] = 1'b0;
                y[15][8] = 1'b0;
                y[15][9] = 1'b0;

            end
            2'd2: begin  // m = 8
                y[0][0] = sigma0[0] ^ sigma1[0] ^ sigma2[0];
                y[0][1] = sigma0[1] ^ sigma1[1] ^ sigma2[1];
                y[0][2] = sigma0[2] ^ sigma1[2] ^ sigma2[2];
                y[0][3] = sigma0[3] ^ sigma1[3] ^ sigma2[3];
                y[0][4] = sigma0[4] ^ sigma1[4] ^ sigma2[4];
                y[0][5] = sigma0[5] ^ sigma1[5] ^ sigma2[5];
                y[0][6] = sigma0[6] ^ sigma1[6] ^ sigma2[6];
                y[0][7] = sigma0[7] ^ sigma1[7] ^ sigma2[7];
                y[0][8] = 1'b0;
                y[0][9] = 1'b0;

                y[1][0] = sigma0[0] ^ sigma1[7] ^ sigma2[6];
                y[1][1] = sigma0[1] ^ sigma1[0] ^ sigma2[7];
                y[1][2] = sigma0[2] ^ sigma1[1] ^ sigma1[7] ^ sigma2[0] ^ sigma2[6];
                y[1][3] = sigma0[3] ^ sigma1[2] ^ sigma1[7] ^ sigma2[1] ^ sigma2[6] ^ sigma2[7];
                y[1][4] = sigma0[4] ^ sigma1[3] ^ sigma1[7] ^ sigma2[2] ^ sigma2[6] ^ sigma2[7];
                y[1][5] = sigma0[5] ^ sigma1[4] ^ sigma2[3] ^ sigma2[7];
                y[1][6] = sigma0[6] ^ sigma1[5] ^ sigma2[4];
                y[1][7] = sigma0[7] ^ sigma1[6] ^ sigma2[5];
                y[1][8] = 1'b0;
                y[1][9] = 1'b0;

                y[2][0] = sigma0[0] ^ sigma1[6] ^ sigma2[4];
                y[2][1] = sigma0[1] ^ sigma1[7] ^ sigma2[5];
                y[2][2] = sigma0[2] ^ sigma1[0] ^ sigma1[6] ^ sigma2[4] ^ sigma2[6];
                y[2][3] = sigma0[3] ^ sigma1[1] ^ sigma1[6] ^ sigma1[7] ^ sigma2[4] ^ sigma2[5] ^ sigma2[7];
                y[2][4] = sigma0[4] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[4] ^ sigma2[5] ^ sigma2[6];
                y[2][5] = sigma0[5] ^ sigma1[3] ^ sigma1[7] ^ sigma2[1] ^ sigma2[5] ^ sigma2[6] ^ sigma2[7];
                y[2][6] = sigma0[6] ^ sigma1[4] ^ sigma2[2] ^ sigma2[6] ^ sigma2[7];
                y[2][7] = sigma0[7] ^ sigma1[5] ^ sigma2[3] ^ sigma2[7];
                y[2][8] = 1'b0;
                y[2][9] = 1'b0;

                y[3][0] = sigma0[0] ^ sigma1[5] ^ sigma2[2] ^ sigma2[6] ^ sigma2[7];
                y[3][1] = sigma0[1] ^ sigma1[6] ^ sigma2[3] ^ sigma2[7];
                y[3][2] = sigma0[2] ^ sigma1[5] ^ sigma1[7] ^ sigma2[2] ^ sigma2[4] ^ sigma2[6] ^ sigma2[7];
                y[3][3] = sigma0[3] ^ sigma1[0] ^ sigma1[5] ^ sigma1[6] ^ sigma2[2] ^ sigma2[3] ^ sigma2[5] ^ sigma2[6];
                y[3][4] = sigma0[4] ^ sigma1[1] ^ sigma1[5] ^ sigma1[6] ^ sigma1[7] ^ sigma2[2] ^ sigma2[3] ^ sigma2[4];
                y[3][5] = sigma0[5] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[3] ^ sigma2[4] ^ sigma2[5];
                y[3][6] = sigma0[6] ^ sigma1[3] ^ sigma1[7] ^ sigma2[0] ^ sigma2[4] ^ sigma2[5] ^ sigma2[6];
                y[3][7] = sigma0[7] ^ sigma1[4] ^ sigma2[1] ^ sigma2[5] ^ sigma2[6] ^ sigma2[7];
                y[3][8] = 1'b0;
                y[3][9] = 1'b0;

                y[4][0] = sigma0[0] ^ sigma1[4] ^ sigma2[0] ^ sigma2[4] ^ sigma2[5] ^ sigma2[6];
                y[4][1] = sigma0[1] ^ sigma1[5] ^ sigma2[1] ^ sigma2[5] ^ sigma2[6] ^ sigma2[7];
                y[4][2] = sigma0[2] ^ sigma1[4] ^ sigma1[6] ^ sigma2[0] ^ sigma2[2] ^ sigma2[4] ^ sigma2[5] ^ sigma2[7];
                y[4][3] = sigma0[3] ^ sigma1[4] ^ sigma1[5] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[3] ^ sigma2[4];
                y[4][4] = sigma0[4] ^ sigma1[0] ^ sigma1[4] ^ sigma1[5] ^ sigma1[6] ^ sigma2[0] ^ sigma2[1] ^ sigma2[2] ^ sigma2[6];
                y[4][5] = sigma0[5] ^ sigma1[1] ^ sigma1[5] ^ sigma1[6] ^ sigma1[7] ^ sigma2[1] ^ sigma2[2] ^ sigma2[3] ^ sigma2[7];
                y[4][6] = sigma0[6] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[2] ^ sigma2[3] ^ sigma2[4];
                y[4][7] = sigma0[7] ^ sigma1[3] ^ sigma1[7] ^ sigma2[3] ^ sigma2[4] ^ sigma2[5];
                y[4][8] = 1'b0;
                y[4][9] = 1'b0;

                y[5][0] = sigma0[0] ^ sigma1[3] ^ sigma1[7] ^ sigma2[2] ^ sigma2[3] ^ sigma2[4];
                y[5][1] = sigma0[1] ^ sigma1[4] ^ sigma2[3] ^ sigma2[4] ^ sigma2[5];
                y[5][2] = sigma0[2] ^ sigma1[3] ^ sigma1[5] ^ sigma1[7] ^ sigma2[0] ^ sigma2[2] ^ sigma2[3] ^ sigma2[5] ^ sigma2[6];
                y[5][3] = sigma0[3] ^ sigma1[3] ^ sigma1[4] ^ sigma1[6] ^ sigma1[7] ^ sigma2[1] ^ sigma2[2] ^ sigma2[6] ^ sigma2[7];
                y[5][4] = sigma0[4] ^ sigma1[3] ^ sigma1[4] ^ sigma1[5] ^ sigma2[0] ^ sigma2[4] ^ sigma2[7];
                y[5][5] = sigma0[5] ^ sigma1[0] ^ sigma1[4] ^ sigma1[5] ^ sigma1[6] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[5][6] = sigma0[6] ^ sigma1[1] ^ sigma1[5] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[2] ^ sigma2[6];
                y[5][7] = sigma0[7] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[1] ^ sigma2[2] ^ sigma2[3] ^ sigma2[7];
                y[5][8] = 1'b0;
                y[5][9] = 1'b0;

                y[6][0] = sigma0[0] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[2] ^ sigma2[6];
                y[6][1] = sigma0[1] ^ sigma1[3] ^ sigma1[7] ^ sigma2[1] ^ sigma2[2] ^ sigma2[3] ^ sigma2[7];
                y[6][2] = sigma0[2] ^ sigma1[2] ^ sigma1[4] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[3] ^ sigma2[4] ^ sigma2[6];
                y[6][3] = sigma0[3] ^ sigma1[2] ^ sigma1[3] ^ sigma1[5] ^ sigma1[6] ^ sigma2[0] ^ sigma2[4] ^ sigma2[5] ^ sigma2[6] ^ sigma2[7];
                y[6][4] = sigma0[4] ^ sigma1[2] ^ sigma1[3] ^ sigma1[4] ^ sigma2[2] ^ sigma2[5] ^ sigma2[7];
                y[6][5] = sigma0[5] ^ sigma1[3] ^ sigma1[4] ^ sigma1[5] ^ sigma2[3] ^ sigma2[6];
                y[6][6] = sigma0[6] ^ sigma1[0] ^ sigma1[4] ^ sigma1[5] ^ sigma1[6] ^ sigma2[0] ^ sigma2[4] ^ sigma2[7];
                y[6][7] = sigma0[7] ^ sigma1[1] ^ sigma1[5] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[6][8] = 1'b0;
                y[6][9] = 1'b0;

                y[7][0] = sigma0[0] ^ sigma1[1] ^ sigma1[5] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[4] ^ sigma2[7];
                y[7][1] = sigma0[1] ^ sigma1[2] ^ sigma1[6] ^ sigma1[7] ^ sigma2[0] ^ sigma2[1] ^ sigma2[5];
                y[7][2] = sigma0[2] ^ sigma1[1] ^ sigma1[3] ^ sigma1[5] ^ sigma1[6] ^ sigma2[1] ^ sigma2[2] ^ sigma2[4] ^ sigma2[6] ^ sigma2[7];
                y[7][3] = sigma0[3] ^ sigma1[1] ^ sigma1[2] ^ sigma1[4] ^ sigma1[5] ^ sigma2[2] ^ sigma2[3] ^ sigma2[4] ^ sigma2[5];
                y[7][4] = sigma0[4] ^ sigma1[1] ^ sigma1[2] ^ sigma1[3] ^ sigma1[7] ^ sigma2[0] ^ sigma2[3] ^ sigma2[5] ^ sigma2[6] ^ sigma2[7];
                y[7][5] = sigma0[5] ^ sigma1[2] ^ sigma1[3] ^ sigma1[4] ^ sigma2[1] ^ sigma2[4] ^ sigma2[6] ^ sigma2[7];
                y[7][6] = sigma0[6] ^ sigma1[3] ^ sigma1[4] ^ sigma1[5] ^ sigma2[2] ^ sigma2[5] ^ sigma2[7];
                y[7][7] = sigma0[7] ^ sigma1[0] ^ sigma1[4] ^ sigma1[5] ^ sigma1[6] ^ sigma2[3] ^ sigma2[6];
                y[7][8] = 1'b0;
                y[7][9] = 1'b0;

                y[8][0] = 1'b0;
                y[8][1] = 1'b0;
                y[8][2] = 1'b0;
                y[8][3] = 1'b0;
                y[8][4] = 1'b0;
                y[8][5] = 1'b0;
                y[8][6] = 1'b0;
                y[8][7] = 1'b0;
                y[8][8] = 1'b0;
                y[8][9] = 1'b0;

                y[9][0] = sigma0[0];
                y[9][1] = sigma0[1];
                y[9][2] = sigma0[2];
                y[9][3] = sigma0[3];
                y[9][4] = sigma0[4];
                y[9][5] = sigma0[5];
                y[9][6] = sigma0[6];
                y[9][7] = sigma0[7];
                y[9][8] = 1'b0;
                y[9][9] = 1'b0;

                y[10][0] = sigma0[0];
                y[10][1] = sigma0[1];
                y[10][2] = sigma0[2];
                y[10][3] = sigma0[3];
                y[10][4] = sigma0[4];
                y[10][5] = sigma0[5];
                y[10][6] = sigma0[6];
                y[10][7] = sigma0[7];
                y[10][8] = 1'b0;
                y[10][9] = 1'b0;

                y[11][0] = sigma0[0];
                y[11][1] = sigma0[1];
                y[11][2] = sigma0[2];
                y[11][3] = sigma0[3];
                y[11][4] = sigma0[4];
                y[11][5] = sigma0[5];
                y[11][6] = sigma0[6];
                y[11][7] = sigma0[7];
                y[11][8] = 1'b0;
                y[11][9] = 1'b0;

                y[12][0] = sigma0[0];
                y[12][1] = sigma0[1];
                y[12][2] = sigma0[2];
                y[12][3] = sigma0[3];
                y[12][4] = sigma0[4];
                y[12][5] = sigma0[5];
                y[12][6] = sigma0[6];
                y[12][7] = sigma0[7];
                y[12][8] = 1'b0;
                y[12][9] = 1'b0;

                y[13][0] = 1'b0;
                y[13][1] = 1'b0;
                y[13][2] = 1'b0;
                y[13][3] = 1'b0;
                y[13][4] = 1'b0;
                y[13][5] = 1'b0;
                y[13][6] = 1'b0;
                y[13][7] = 1'b0;
                y[13][8] = 1'b0;
                y[13][9] = 1'b0;

                y[14][0] = 1'b0;
                y[14][1] = 1'b0;
                y[14][2] = 1'b0;
                y[14][3] = 1'b0;
                y[14][4] = 1'b0;
                y[14][5] = 1'b0;
                y[14][6] = 1'b0;
                y[14][7] = 1'b0;
                y[14][8] = 1'b0;
                y[14][9] = 1'b0;

                y[15][0] = sigma0[0];
                y[15][1] = sigma0[1];
                y[15][2] = sigma0[2];
                y[15][3] = sigma0[3];
                y[15][4] = sigma0[4];
                y[15][5] = sigma0[5];
                y[15][6] = sigma0[6];
                y[15][7] = sigma0[7];
                y[15][8] = 1'b0;
                y[15][9] = 1'b0;

            end
            2'd3: begin  // m = 10
                y[0][0] = sigma0[0] ^ sigma1[0] ^ sigma2[0] ^ sigma3[0] ^ sigma4[0];
                y[0][1] = sigma0[1] ^ sigma1[1] ^ sigma2[1] ^ sigma3[1] ^ sigma4[1];
                y[0][2] = sigma0[2] ^ sigma1[2] ^ sigma2[2] ^ sigma3[2] ^ sigma4[2];
                y[0][3] = sigma0[3] ^ sigma1[3] ^ sigma2[3] ^ sigma3[3] ^ sigma4[3];
                y[0][4] = sigma0[4] ^ sigma1[4] ^ sigma2[4] ^ sigma3[4] ^ sigma4[4];
                y[0][5] = sigma0[5] ^ sigma1[5] ^ sigma2[5] ^ sigma3[5] ^ sigma4[5];
                y[0][6] = sigma0[6] ^ sigma1[6] ^ sigma2[6] ^ sigma3[6] ^ sigma4[6];
                y[0][7] = sigma0[7] ^ sigma1[7] ^ sigma2[7] ^ sigma3[7] ^ sigma4[7];
                y[0][8] = sigma0[8] ^ sigma1[8] ^ sigma2[8] ^ sigma3[8] ^ sigma4[8];
                y[0][9] = sigma0[9] ^ sigma1[9] ^ sigma2[9] ^ sigma3[9] ^ sigma4[9];

                y[1][0] = sigma0[0] ^ sigma1[9] ^ sigma2[8] ^ sigma3[7] ^ sigma4[6];
                y[1][1] = sigma0[1] ^ sigma1[0] ^ sigma2[9] ^ sigma3[8] ^ sigma4[7];
                y[1][2] = sigma0[2] ^ sigma1[1] ^ sigma2[0] ^ sigma3[9] ^ sigma4[8];
                y[1][3] = sigma0[3] ^ sigma1[2] ^ sigma1[9] ^ sigma2[1] ^ sigma2[8] ^ sigma3[0] ^ sigma3[7] ^ sigma4[6] ^ sigma4[9];
                y[1][4] = sigma0[4] ^ sigma1[3] ^ sigma2[2] ^ sigma2[9] ^ sigma3[1] ^ sigma3[8] ^ sigma4[0] ^ sigma4[7];
                y[1][5] = sigma0[5] ^ sigma1[4] ^ sigma2[3] ^ sigma3[2] ^ sigma3[9] ^ sigma4[1] ^ sigma4[8];
                y[1][6] = sigma0[6] ^ sigma1[5] ^ sigma2[4] ^ sigma3[3] ^ sigma4[2] ^ sigma4[9];
                y[1][7] = sigma0[7] ^ sigma1[6] ^ sigma2[5] ^ sigma3[4] ^ sigma4[3];
                y[1][8] = sigma0[8] ^ sigma1[7] ^ sigma2[6] ^ sigma3[5] ^ sigma4[4];
                y[1][9] = sigma0[9] ^ sigma1[8] ^ sigma2[7] ^ sigma3[6] ^ sigma4[5];

                y[2][0] = sigma0[0] ^ sigma1[8] ^ sigma2[6] ^ sigma3[4] ^ sigma4[2] ^ sigma4[9];
                y[2][1] = sigma0[1] ^ sigma1[9] ^ sigma2[7] ^ sigma3[5] ^ sigma4[3];
                y[2][2] = sigma0[2] ^ sigma1[0] ^ sigma2[8] ^ sigma3[6] ^ sigma4[4];
                y[2][3] = sigma0[3] ^ sigma1[1] ^ sigma1[8] ^ sigma2[6] ^ sigma2[9] ^ sigma3[4] ^ sigma3[7] ^ sigma4[2] ^ sigma4[5] ^ sigma4[9];
                y[2][4] = sigma0[4] ^ sigma1[2] ^ sigma1[9] ^ sigma2[0] ^ sigma2[7] ^ sigma3[5] ^ sigma3[8] ^ sigma4[3] ^ sigma4[6];
                y[2][5] = sigma0[5] ^ sigma1[3] ^ sigma2[1] ^ sigma2[8] ^ sigma3[6] ^ sigma3[9] ^ sigma4[4] ^ sigma4[7];
                y[2][6] = sigma0[6] ^ sigma1[4] ^ sigma2[2] ^ sigma2[9] ^ sigma3[0] ^ sigma3[7] ^ sigma4[5] ^ sigma4[8];
                y[2][7] = sigma0[7] ^ sigma1[5] ^ sigma2[3] ^ sigma3[1] ^ sigma3[8] ^ sigma4[6] ^ sigma4[9];
                y[2][8] = sigma0[8] ^ sigma1[6] ^ sigma2[4] ^ sigma3[2] ^ sigma3[9] ^ sigma4[0] ^ sigma4[7];
                y[2][9] = sigma0[9] ^ sigma1[7] ^ sigma2[5] ^ sigma3[3] ^ sigma4[1] ^ sigma4[8];

                y[3][0] = sigma0[0] ^ sigma1[7] ^ sigma2[4] ^ sigma3[1] ^ sigma3[8] ^ sigma4[5] ^ sigma4[8];
                y[3][1] = sigma0[1] ^ sigma1[8] ^ sigma2[5] ^ sigma3[2] ^ sigma3[9] ^ sigma4[6] ^ sigma4[9];
                y[3][2] = sigma0[2] ^ sigma1[9] ^ sigma2[6] ^ sigma3[3] ^ sigma4[0] ^ sigma4[7];
                y[3][3] = sigma0[3] ^ sigma1[0] ^ sigma1[7] ^ sigma2[4] ^ sigma2[7] ^ sigma3[1] ^ sigma3[4] ^ sigma3[8] ^ sigma4[1] ^ sigma4[5];
                y[3][4] = sigma0[4] ^ sigma1[1] ^ sigma1[8] ^ sigma2[5] ^ sigma2[8] ^ sigma3[2] ^ sigma3[5] ^ sigma3[9] ^ sigma4[2] ^ sigma4[6];
                y[3][5] = sigma0[5] ^ sigma1[2] ^ sigma1[9] ^ sigma2[6] ^ sigma2[9] ^ sigma3[3] ^ sigma3[6] ^ sigma4[0] ^ sigma4[3] ^ sigma4[7];
                y[3][6] = sigma0[6] ^ sigma1[3] ^ sigma2[0] ^ sigma2[7] ^ sigma3[4] ^ sigma3[7] ^ sigma4[1] ^ sigma4[4] ^ sigma4[8];
                y[3][7] = sigma0[7] ^ sigma1[4] ^ sigma2[1] ^ sigma2[8] ^ sigma3[5] ^ sigma3[8] ^ sigma4[2] ^ sigma4[5] ^ sigma4[9];
                y[3][8] = sigma0[8] ^ sigma1[5] ^ sigma2[2] ^ sigma2[9] ^ sigma3[6] ^ sigma3[9] ^ sigma4[3] ^ sigma4[6];
                y[3][9] = sigma0[9] ^ sigma1[6] ^ sigma2[3] ^ sigma3[0] ^ sigma3[7] ^ sigma4[4] ^ sigma4[7];

                y[4][0] = sigma0[0] ^ sigma1[6] ^ sigma2[2] ^ sigma2[9] ^ sigma3[5] ^ sigma3[8] ^ sigma4[1] ^ sigma4[4] ^ sigma4[8];
                y[4][1] = sigma0[1] ^ sigma1[7] ^ sigma2[3] ^ sigma3[6] ^ sigma3[9] ^ sigma4[2] ^ sigma4[5] ^ sigma4[9];
                y[4][2] = sigma0[2] ^ sigma1[8] ^ sigma2[4] ^ sigma3[0] ^ sigma3[7] ^ sigma4[3] ^ sigma4[6];
                y[4][3] = sigma0[3] ^ sigma1[6] ^ sigma1[9] ^ sigma2[2] ^ sigma2[5] ^ sigma2[9] ^ sigma3[1] ^ sigma3[5] ^ sigma4[1] ^ sigma4[7] ^ sigma4[8];
                y[4][4] = sigma0[4] ^ sigma1[0] ^ sigma1[7] ^ sigma2[3] ^ sigma2[6] ^ sigma3[2] ^ sigma3[6] ^ sigma4[2] ^ sigma4[8] ^ sigma4[9];
                y[4][5] = sigma0[5] ^ sigma1[1] ^ sigma1[8] ^ sigma2[4] ^ sigma2[7] ^ sigma3[0] ^ sigma3[3] ^ sigma3[7] ^ sigma4[3] ^ sigma4[9];
                y[4][6] = sigma0[6] ^ sigma1[2] ^ sigma1[9] ^ sigma2[5] ^ sigma2[8] ^ sigma3[1] ^ sigma3[4] ^ sigma3[8] ^ sigma4[0] ^ sigma4[4];
                y[4][7] = sigma0[7] ^ sigma1[3] ^ sigma2[6] ^ sigma2[9] ^ sigma3[2] ^ sigma3[5] ^ sigma3[9] ^ sigma4[1] ^ sigma4[5];
                y[4][8] = sigma0[8] ^ sigma1[4] ^ sigma2[0] ^ sigma2[7] ^ sigma3[3] ^ sigma3[6] ^ sigma4[2] ^ sigma4[6];
                y[4][9] = sigma0[9] ^ sigma1[5] ^ sigma2[1] ^ sigma2[8] ^ sigma3[4] ^ sigma3[7] ^ sigma4[0] ^ sigma4[3] ^ sigma4[7];

                y[5][0] = sigma0[0] ^ sigma1[5] ^ sigma2[0] ^ sigma2[7] ^ sigma3[2] ^ sigma3[5] ^ sigma3[9] ^ sigma4[0] ^ sigma4[4];
                y[5][1] = sigma0[1] ^ sigma1[6] ^ sigma2[1] ^ sigma2[8] ^ sigma3[3] ^ sigma3[6] ^ sigma4[1] ^ sigma4[5];
                y[5][2] = sigma0[2] ^ sigma1[7] ^ sigma2[2] ^ sigma2[9] ^ sigma3[4] ^ sigma3[7] ^ sigma4[2] ^ sigma4[6];
                y[5][3] = sigma0[3] ^ sigma1[5] ^ sigma1[8] ^ sigma2[0] ^ sigma2[3] ^ sigma2[7] ^ sigma3[2] ^ sigma3[8] ^ sigma3[9] ^ sigma4[3] ^ sigma4[4] ^ sigma4[7];
                y[5][4] = sigma0[4] ^ sigma1[6] ^ sigma1[9] ^ sigma2[1] ^ sigma2[4] ^ sigma2[8] ^ sigma3[3] ^ sigma3[9] ^ sigma4[4] ^ sigma4[5] ^ sigma4[8];
                y[5][5] = sigma0[5] ^ sigma1[0] ^ sigma1[7] ^ sigma2[2] ^ sigma2[5] ^ sigma2[9] ^ sigma3[0] ^ sigma3[4] ^ sigma4[5] ^ sigma4[6] ^ sigma4[9];
                y[5][6] = sigma0[6] ^ sigma1[1] ^ sigma1[8] ^ sigma2[3] ^ sigma2[6] ^ sigma3[1] ^ sigma3[5] ^ sigma4[0] ^ sigma4[6] ^ sigma4[7];
                y[5][7] = sigma0[7] ^ sigma1[2] ^ sigma1[9] ^ sigma2[4] ^ sigma2[7] ^ sigma3[2] ^ sigma3[6] ^ sigma4[1] ^ sigma4[7] ^ sigma4[8];
                y[5][8] = sigma0[8] ^ sigma1[3] ^ sigma2[5] ^ sigma2[8] ^ sigma3[0] ^ sigma3[3] ^ sigma3[7] ^ sigma4[2] ^ sigma4[8] ^ sigma4[9];
                y[5][9] = sigma0[9] ^ sigma1[4] ^ sigma2[6] ^ sigma2[9] ^ sigma3[1] ^ sigma3[4] ^ sigma3[8] ^ sigma4[3] ^ sigma4[9];

                y[6][0] = sigma0[0] ^ sigma1[4] ^ sigma2[5] ^ sigma2[8] ^ sigma3[2] ^ sigma3[6] ^ sigma4[0] ^ sigma4[6] ^ sigma4[7];
                y[6][1] = sigma0[1] ^ sigma1[5] ^ sigma2[6] ^ sigma2[9] ^ sigma3[0] ^ sigma3[3] ^ sigma3[7] ^ sigma4[1] ^ sigma4[7] ^ sigma4[8];
                y[6][2] = sigma0[2] ^ sigma1[6] ^ sigma2[0] ^ sigma2[7] ^ sigma3[1] ^ sigma3[4] ^ sigma3[8] ^ sigma4[2] ^ sigma4[8] ^ sigma4[9];
                y[6][3] = sigma0[3] ^ sigma1[4] ^ sigma1[7] ^ sigma2[1] ^ sigma2[5] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9] ^ sigma4[0] ^ sigma4[3] ^ sigma4[6] ^ sigma4[7] ^ sigma4[9];
                y[6][4] = sigma0[4] ^ sigma1[5] ^ sigma1[8] ^ sigma2[2] ^ sigma2[6] ^ sigma3[0] ^ sigma3[6] ^ sigma3[7] ^ sigma4[0] ^ sigma4[1] ^ sigma4[4] ^ sigma4[7] ^ sigma4[8];
                y[6][5] = sigma0[5] ^ sigma1[6] ^ sigma1[9] ^ sigma2[0] ^ sigma2[3] ^ sigma2[7] ^ sigma3[1] ^ sigma3[7] ^ sigma3[8] ^ sigma4[1] ^ sigma4[2] ^ sigma4[5] ^ sigma4[8] ^ sigma4[9];
                y[6][6] = sigma0[6] ^ sigma1[0] ^ sigma1[7] ^ sigma2[1] ^ sigma2[4] ^ sigma2[8] ^ sigma3[2] ^ sigma3[8] ^ sigma3[9] ^ sigma4[2] ^ sigma4[3] ^ sigma4[6] ^ sigma4[9];
                y[6][7] = sigma0[7] ^ sigma1[1] ^ sigma1[8] ^ sigma2[2] ^ sigma2[5] ^ sigma2[9] ^ sigma3[3] ^ sigma3[9] ^ sigma4[3] ^ sigma4[4] ^ sigma4[7];
                y[6][8] = sigma0[8] ^ sigma1[2] ^ sigma1[9] ^ sigma2[3] ^ sigma2[6] ^ sigma3[0] ^ sigma3[4] ^ sigma4[4] ^ sigma4[5] ^ sigma4[8];
                y[6][9] = sigma0[9] ^ sigma1[3] ^ sigma2[4] ^ sigma2[7] ^ sigma3[1] ^ sigma3[5] ^ sigma4[5] ^ sigma4[6] ^ sigma4[9];

                y[7][0] = sigma0[0] ^ sigma1[3] ^ sigma2[3] ^ sigma2[6] ^ sigma3[3] ^ sigma3[9] ^ sigma4[2] ^ sigma4[3] ^ sigma4[6] ^ sigma4[9];
                y[7][1] = sigma0[1] ^ sigma1[4] ^ sigma2[4] ^ sigma2[7] ^ sigma3[0] ^ sigma3[4] ^ sigma4[3] ^ sigma4[4] ^ sigma4[7];
                y[7][2] = sigma0[2] ^ sigma1[5] ^ sigma2[5] ^ sigma2[8] ^ sigma3[1] ^ sigma3[5] ^ sigma4[4] ^ sigma4[5] ^ sigma4[8];
                y[7][3] = sigma0[3] ^ sigma1[3] ^ sigma1[6] ^ sigma2[3] ^ sigma2[9] ^ sigma3[2] ^ sigma3[3] ^ sigma3[6] ^ sigma3[9] ^ sigma4[2] ^ sigma4[3] ^ sigma4[5];
                y[7][4] = sigma0[4] ^ sigma1[4] ^ sigma1[7] ^ sigma2[0] ^ sigma2[4] ^ sigma3[3] ^ sigma3[4] ^ sigma3[7] ^ sigma4[0] ^ sigma4[3] ^ sigma4[4] ^ sigma4[6];
                y[7][5] = sigma0[5] ^ sigma1[5] ^ sigma1[8] ^ sigma2[1] ^ sigma2[5] ^ sigma3[4] ^ sigma3[5] ^ sigma3[8] ^ sigma4[1] ^ sigma4[4] ^ sigma4[5] ^ sigma4[7];
                y[7][6] = sigma0[6] ^ sigma1[6] ^ sigma1[9] ^ sigma2[2] ^ sigma2[6] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9] ^ sigma4[2] ^ sigma4[5] ^ sigma4[6] ^ sigma4[8];
                y[7][7] = sigma0[7] ^ sigma1[0] ^ sigma1[7] ^ sigma2[0] ^ sigma2[3] ^ sigma2[7] ^ sigma3[0] ^ sigma3[6] ^ sigma3[7] ^ sigma4[0] ^ sigma4[3] ^ sigma4[6] ^ sigma4[7] ^ sigma4[9];
                y[7][8] = sigma0[8] ^ sigma1[1] ^ sigma1[8] ^ sigma2[1] ^ sigma2[4] ^ sigma2[8] ^ sigma3[1] ^ sigma3[7] ^ sigma3[8] ^ sigma4[0] ^ sigma4[1] ^ sigma4[4] ^ sigma4[7] ^ sigma4[8];
                y[7][9] = sigma0[9] ^ sigma1[2] ^ sigma1[9] ^ sigma2[2] ^ sigma2[5] ^ sigma2[9] ^ sigma3[2] ^ sigma3[8] ^ sigma3[9] ^ sigma4[1] ^ sigma4[2] ^ sigma4[5] ^ sigma4[8] ^ sigma4[9];

                y[8][0] = sigma0[0] ^ sigma1[2] ^ sigma1[9] ^ sigma2[1] ^ sigma2[4] ^ sigma2[8] ^ sigma3[0] ^ sigma3[6] ^ sigma3[7] ^ sigma4[2] ^ sigma4[5] ^ sigma4[6] ^ sigma4[8];
                y[8][1] = sigma0[1] ^ sigma1[3] ^ sigma2[2] ^ sigma2[5] ^ sigma2[9] ^ sigma3[1] ^ sigma3[7] ^ sigma3[8] ^ sigma4[0] ^ sigma4[3] ^ sigma4[6] ^ sigma4[7] ^ sigma4[9];
                y[8][2] = sigma0[2] ^ sigma1[4] ^ sigma2[3] ^ sigma2[6] ^ sigma3[2] ^ sigma3[8] ^ sigma3[9] ^ sigma4[0] ^ sigma4[1] ^ sigma4[4] ^ sigma4[7] ^ sigma4[8];
                y[8][3] = sigma0[3] ^ sigma1[2] ^ sigma1[5] ^ sigma1[9] ^ sigma2[1] ^ sigma2[7] ^ sigma2[8] ^ sigma3[0] ^ sigma3[3] ^ sigma3[6] ^ sigma3[7] ^ sigma3[9] ^ sigma4[1] ^ sigma4[6] ^ sigma4[9];
                y[8][4] = sigma0[4] ^ sigma1[3] ^ sigma1[6] ^ sigma2[2] ^ sigma2[8] ^ sigma2[9] ^ sigma3[0] ^ sigma3[1] ^ sigma3[4] ^ sigma3[7] ^ sigma3[8] ^ sigma4[0] ^ sigma4[2] ^ sigma4[7];
                y[8][5] = sigma0[5] ^ sigma1[4] ^ sigma1[7] ^ sigma2[3] ^ sigma2[9] ^ sigma3[1] ^ sigma3[2] ^ sigma3[5] ^ sigma3[8] ^ sigma3[9] ^ sigma4[0] ^ sigma4[1] ^ sigma4[3] ^ sigma4[8];
                y[8][6] = sigma0[6] ^ sigma1[5] ^ sigma1[8] ^ sigma2[0] ^ sigma2[4] ^ sigma3[2] ^ sigma3[3] ^ sigma3[6] ^ sigma3[9] ^ sigma4[1] ^ sigma4[2] ^ sigma4[4] ^ sigma4[9];
                y[8][7] = sigma0[7] ^ sigma1[6] ^ sigma1[9] ^ sigma2[1] ^ sigma2[5] ^ sigma3[3] ^ sigma3[4] ^ sigma3[7] ^ sigma4[2] ^ sigma4[3] ^ sigma4[5];
                y[8][8] = sigma0[8] ^ sigma1[0] ^ sigma1[7] ^ sigma2[2] ^ sigma2[6] ^ sigma3[4] ^ sigma3[5] ^ sigma3[8] ^ sigma4[0] ^ sigma4[3] ^ sigma4[4] ^ sigma4[6];
                y[8][9] = sigma0[9] ^ sigma1[1] ^ sigma1[8] ^ sigma2[0] ^ sigma2[3] ^ sigma2[7] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9] ^ sigma4[1] ^ sigma4[4] ^ sigma4[5] ^ sigma4[7];

                y[9][0] = sigma0[0] ^ sigma1[1] ^ sigma1[8] ^ sigma2[2] ^ sigma2[6] ^ sigma3[3] ^ sigma3[4] ^ sigma3[7] ^ sigma4[1] ^ sigma4[2] ^ sigma4[4] ^ sigma4[9];
                y[9][1] = sigma0[1] ^ sigma1[2] ^ sigma1[9] ^ sigma2[0] ^ sigma2[3] ^ sigma2[7] ^ sigma3[4] ^ sigma3[5] ^ sigma3[8] ^ sigma4[2] ^ sigma4[3] ^ sigma4[5];
                y[9][2] = sigma0[2] ^ sigma1[3] ^ sigma2[1] ^ sigma2[4] ^ sigma2[8] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9] ^ sigma4[0] ^ sigma4[3] ^ sigma4[4] ^ sigma4[6];
                y[9][3] = sigma0[3] ^ sigma1[1] ^ sigma1[4] ^ sigma1[8] ^ sigma2[5] ^ sigma2[6] ^ sigma2[9] ^ sigma3[0] ^ sigma3[3] ^ sigma3[4] ^ sigma3[6] ^ sigma4[2] ^ sigma4[5] ^ sigma4[7] ^ sigma4[9];
                y[9][4] = sigma0[4] ^ sigma1[2] ^ sigma1[5] ^ sigma1[9] ^ sigma2[0] ^ sigma2[6] ^ sigma2[7] ^ sigma3[1] ^ sigma3[4] ^ sigma3[5] ^ sigma3[7] ^ sigma4[3] ^ sigma4[6] ^ sigma4[8];
                y[9][5] = sigma0[5] ^ sigma1[3] ^ sigma1[6] ^ sigma2[1] ^ sigma2[7] ^ sigma2[8] ^ sigma3[2] ^ sigma3[5] ^ sigma3[6] ^ sigma3[8] ^ sigma4[4] ^ sigma4[7] ^ sigma4[9];
                y[9][6] = sigma0[6] ^ sigma1[4] ^ sigma1[7] ^ sigma2[2] ^ sigma2[8] ^ sigma2[9] ^ sigma3[0] ^ sigma3[3] ^ sigma3[6] ^ sigma3[7] ^ sigma3[9] ^ sigma4[0] ^ sigma4[5] ^ sigma4[8];
                y[9][7] = sigma0[7] ^ sigma1[5] ^ sigma1[8] ^ sigma2[3] ^ sigma2[9] ^ sigma3[0] ^ sigma3[1] ^ sigma3[4] ^ sigma3[7] ^ sigma3[8] ^ sigma4[1] ^ sigma4[6] ^ sigma4[9];
                y[9][8] = sigma0[8] ^ sigma1[6] ^ sigma1[9] ^ sigma2[0] ^ sigma2[4] ^ sigma3[1] ^ sigma3[2] ^ sigma3[5] ^ sigma3[8] ^ sigma3[9] ^ sigma4[0] ^ sigma4[2] ^ sigma4[7];
                y[9][9] = sigma0[9] ^ sigma1[0] ^ sigma1[7] ^ sigma2[1] ^ sigma2[5] ^ sigma3[2] ^ sigma3[3] ^ sigma3[6] ^ sigma3[9] ^ sigma4[0] ^ sigma4[1] ^ sigma4[3] ^ sigma4[8];

                y[10][0] = sigma3[0] ^ sigma3[3] ^ sigma3[7] ^ sigma3[8];
                y[10][1] = sigma3[1] ^ sigma3[4] ^ sigma3[8] ^ sigma3[9];
                y[10][2] = sigma3[0] ^ sigma3[2] ^ sigma3[5] ^ sigma3[9];
                y[10][3] = sigma3[0] ^ sigma3[1] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[10][4] = sigma3[1] ^ sigma3[2] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[10][5] = sigma3[2] ^ sigma3[3] ^ sigma3[8] ^ sigma3[9];
                y[10][6] = sigma3[3] ^ sigma3[4] ^ sigma3[9];
                y[10][7] = sigma3[0] ^ sigma3[4] ^ sigma3[5];
                y[10][8] = sigma3[1] ^ sigma3[5] ^ sigma3[6];
                y[10][9] = sigma3[2] ^ sigma3[6] ^ sigma3[7];

                y[11][0] = sigma0[0] ^ sigma3[0] ^ sigma3[5] ^ sigma3[7];
                y[11][1] = sigma0[1] ^ sigma3[1] ^ sigma3[6] ^ sigma3[8];
                y[11][2] = sigma0[2] ^ sigma3[2] ^ sigma3[7] ^ sigma3[9];
                y[11][3] = sigma0[3] ^ sigma3[0] ^ sigma3[3] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];
                y[11][4] = sigma0[4] ^ sigma3[1] ^ sigma3[4] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];
                y[11][5] = sigma0[5] ^ sigma3[0] ^ sigma3[2] ^ sigma3[5] ^ sigma3[7] ^ sigma3[9];
                y[11][6] = sigma0[6] ^ sigma3[1] ^ sigma3[3] ^ sigma3[6] ^ sigma3[8];
                y[11][7] = sigma0[7] ^ sigma3[2] ^ sigma3[4] ^ sigma3[7] ^ sigma3[9];
                y[11][8] = sigma0[8] ^ sigma3[3] ^ sigma3[5] ^ sigma3[8];
                y[11][9] = sigma0[9] ^ sigma3[4] ^ sigma3[6] ^ sigma3[9];

                y[12][0] = sigma0[0] ^ sigma3[2] ^ sigma3[4] ^ sigma3[7] ^ sigma3[9];
                y[12][1] = sigma0[1] ^ sigma3[3] ^ sigma3[5] ^ sigma3[8];
                y[12][2] = sigma0[2] ^ sigma3[4] ^ sigma3[6] ^ sigma3[9];
                y[12][3] = sigma0[3] ^ sigma3[0] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[9];
                y[12][4] = sigma0[4] ^ sigma3[1] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6];
                y[12][5] = sigma0[5] ^ sigma3[2] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7];
                y[12][6] = sigma0[6] ^ sigma3[0] ^ sigma3[3] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];
                y[12][7] = sigma0[7] ^ sigma3[1] ^ sigma3[4] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];
                y[12][8] = sigma0[8] ^ sigma3[0] ^ sigma3[2] ^ sigma3[5] ^ sigma3[7] ^ sigma3[9];
                y[12][9] = sigma0[9] ^ sigma3[1] ^ sigma3[3] ^ sigma3[6] ^ sigma3[8];

                y[13][0] = sigma0[0] ^ sigma3[1] ^ sigma3[4] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];
                y[13][1] = sigma0[1] ^ sigma3[0] ^ sigma3[2] ^ sigma3[5] ^ sigma3[7] ^ sigma3[9];
                y[13][2] = sigma0[2] ^ sigma3[1] ^ sigma3[3] ^ sigma3[6] ^ sigma3[8];
                y[13][3] = sigma0[3] ^ sigma3[1] ^ sigma3[2] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[13][4] = sigma0[4] ^ sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[13][5] = sigma0[5] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[8] ^ sigma3[9];
                y[13][6] = sigma0[6] ^ sigma3[0] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[9];
                y[13][7] = sigma0[7] ^ sigma3[1] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6];
                y[13][8] = sigma0[8] ^ sigma3[2] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7];
                y[13][9] = sigma0[9] ^ sigma3[0] ^ sigma3[3] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];

                y[14][0] = sigma0[0] ^ sigma3[1] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6];
                y[14][1] = sigma0[1] ^ sigma3[2] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7];
                y[14][2] = sigma0[2] ^ sigma3[0] ^ sigma3[3] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];
                y[14][3] = sigma0[3] ^ sigma3[3] ^ sigma3[4] ^ sigma3[5] ^ sigma3[8] ^ sigma3[9];
                y[14][4] = sigma0[4] ^ sigma3[0] ^ sigma3[4] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9];
                y[14][5] = sigma0[5] ^ sigma3[0] ^ sigma3[1] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7];
                y[14][6] = sigma0[6] ^ sigma3[1] ^ sigma3[2] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[14][7] = sigma0[7] ^ sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[14][8] = sigma0[8] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[8] ^ sigma3[9];
                y[14][9] = sigma0[9] ^ sigma3[0] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[9];

                y[15][0] = sigma0[0] ^ sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[15][1] = sigma0[1] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[8] ^ sigma3[9];
                y[15][2] = sigma0[2] ^ sigma3[0] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[9];
                y[15][3] = sigma0[3] ^ sigma3[0] ^ sigma3[1] ^ sigma3[2] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[15][4] = sigma0[4] ^ sigma3[1] ^ sigma3[2] ^ sigma3[3] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[15][5] = sigma0[5] ^ sigma3[2] ^ sigma3[3] ^ sigma3[4] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[15][6] = sigma0[6] ^ sigma3[3] ^ sigma3[4] ^ sigma3[5] ^ sigma3[8] ^ sigma3[9];
                y[15][7] = sigma0[7] ^ sigma3[0] ^ sigma3[4] ^ sigma3[5] ^ sigma3[6] ^ sigma3[9];
                y[15][8] = sigma0[8] ^ sigma3[0] ^ sigma3[1] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7];
                y[15][9] = sigma0[9] ^ sigma3[1] ^ sigma3[2] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];

                y[16][0] = sigma3[0] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7] ^ sigma3[9];
                y[16][1] = sigma3[0] ^ sigma3[1] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[16][2] = sigma3[1] ^ sigma3[2] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[16][3] = sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[16][4] = sigma3[0] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[16][5] = sigma3[0] ^ sigma3[1] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[16][6] = sigma3[1] ^ sigma3[2] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];
                y[16][7] = sigma3[2] ^ sigma3[3] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7] ^ sigma3[9];
                y[16][8] = sigma3[3] ^ sigma3[4] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];
                y[16][9] = sigma3[4] ^ sigma3[5] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];

                y[17][0] = sigma3[2] ^ sigma3[3] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7] ^ sigma3[9];
                y[17][1] = sigma3[3] ^ sigma3[4] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8];
                y[17][2] = sigma3[4] ^ sigma3[5] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];
                y[17][3] = sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[4] ^ sigma3[5];
                y[17][4] = sigma3[0] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[5] ^ sigma3[6];
                y[17][5] = sigma3[1] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7];
                y[17][6] = sigma3[0] ^ sigma3[2] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8];
                y[17][7] = sigma3[0] ^ sigma3[1] ^ sigma3[3] ^ sigma3[4] ^ sigma3[6] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[17][8] = sigma3[0] ^ sigma3[1] ^ sigma3[2] ^ sigma3[4] ^ sigma3[5] ^ sigma3[7] ^ sigma3[8] ^ sigma3[9];
                y[17][9] = sigma3[1] ^ sigma3[2] ^ sigma3[3] ^ sigma3[5] ^ sigma3[6] ^ sigma3[8] ^ sigma3[9];

            end
        endcase
    end

endmodule

module sigmaEB(
    input  [1:0]     code,
    input  [9:0]     sigmaE[17:0],
    output reg [9:0]  y[15:0]
);

    integer i;

    always @* begin
        for (i=0;i<16;i=i+1) begin
            y[i] = 10'b0;
        end
        case (code)
            2'd1: begin  // m = 6
                y[0] = sigmaE[0];
                y[1] = sigmaE[1];
                y[2] = sigmaE[2];
                y[3] = sigmaE[3];
                y[4] = sigmaE[4];
                y[5] = sigmaE[5];
                y[6] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[6];
                y[7] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[7];
                y[8] = sigmaE[0] ^ sigmaE[3] ^ sigmaE[8];
                y[9] = sigmaE[1] ^ sigmaE[4] ^ sigmaE[9];
                y[10] = sigmaE[2] ^ sigmaE[5] ^ sigmaE[10];
                y[11] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[3] ^ sigmaE[11];
                y[12] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[4] ^ sigmaE[12];
                y[13] = sigmaE[2] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[13];
                y[14] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[14];
                y[15] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[15];
            end
            2'd2: begin  // m = 8
                y[0] = sigmaE[0];
                y[1] = sigmaE[1];
                y[2] = sigmaE[2];
                y[3] = sigmaE[3];
                y[4] = sigmaE[4];
                y[5] = sigmaE[5];
                y[6] = sigmaE[6];
                y[7] = sigmaE[7];
                y[8] = sigmaE[0] ^ sigmaE[2] ^ sigmaE[7] ^ sigmaE[8];
                y[9] = sigmaE[0] ^ sigmaE[1] ^ sigmaE[2] ^ sigmaE[4] ^ sigmaE[9];
                y[10] = sigmaE[1] ^ sigmaE[2] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[10];
                y[11] = sigmaE[2] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[6] ^ sigmaE[11];
                y[12] = sigmaE[3] ^ sigmaE[4] ^ sigmaE[5] ^ sigmaE[7] ^ sigmaE[12];
                y[13] = sigmaE[0] ^ sigmaE[2] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[6] ^ sigmaE[13];
                y[14] = sigmaE[1] ^ sigmaE[3] ^ sigmaE[4] ^ sigmaE[6] ^ sigmaE[7] ^ sigmaE[14];
                y[15] = sigmaE[0] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[7] ^ sigmaE[15];
            end
            2'd3: begin  // m = 10
                y[0] = sigmaE[0];
                y[1] = sigmaE[1];
                y[2] = sigmaE[2];
                y[3] = sigmaE[3];
                y[4] = sigmaE[4];
                y[5] = sigmaE[5];
                y[6] = sigmaE[6];
                y[7] = sigmaE[7];
                y[8] = sigmaE[2] ^ sigmaE[4] ^ sigmaE[9] ^ sigmaE[10];
                y[9] = sigmaE[0] ^ sigmaE[5] ^ sigmaE[11];
                y[10] = sigmaE[1] ^ sigmaE[6] ^ sigmaE[12];
                y[11] = sigmaE[2] ^ sigmaE[7] ^ sigmaE[13];
                y[12] = sigmaE[3] ^ sigmaE[8] ^ sigmaE[14];
                y[13] = sigmaE[4] ^ sigmaE[9] ^ sigmaE[15];
                y[14] = sigmaE[0] ^ sigmaE[3] ^ sigmaE[5] ^ sigmaE[16];
                y[15] = sigmaE[1] ^ sigmaE[4] ^ sigmaE[6] ^ sigmaE[17];
            end
        endcase
    end

endmodule
