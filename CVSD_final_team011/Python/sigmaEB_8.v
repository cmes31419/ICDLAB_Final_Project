module sigmaE(
    input  [1:0]      code,
    input  [9:0]      sigma0,
    input  [9:0]      sigma1,
    input  [9:0]      sigma2,
    input  [9:0]      sigma3,
    input  [9:0]      sigma4,
    output reg [9:0]  y[7:0]
);

    integer i;

    always @* begin
        for (i=0;i<10;i=i+1) begin
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

            end
        endcase
    end

endmodule

module sigmaEB(
    input  [1:0]     code,
    input  [9:0]     sigmaE[7:0],
    output reg [9:0]  y[7:0]
);

    integer i;

    always @* begin
        for (i=0;i<8;i=i+1) begin
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
            end
        endcase
    end

endmodule
