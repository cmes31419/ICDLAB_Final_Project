module chien_rotate(
    input  [5:0]        sigma[6:0],
    output reg [5:0]    sigma_rot[6:0]
);

    always @(*) begin
        sigma_rot[0][0] = sigma[0][0];
        sigma_rot[0][1] = sigma[0][1];
        sigma_rot[0][2] = sigma[0][2];
        sigma_rot[0][3] = sigma[0][3];
        sigma_rot[0][4] = sigma[0][4];
        sigma_rot[0][5] = sigma[0][5];

        sigma_rot[1][0] = sigma[1][0] ^ sigma[1][3];
        sigma_rot[1][1] = sigma[1][1] ^ sigma[1][3] ^ sigma[1][4];
        sigma_rot[1][2] = sigma[1][2] ^ sigma[1][4] ^ sigma[1][5];
        sigma_rot[1][3] = sigma[1][0] ^ sigma[1][3] ^ sigma[1][5];
        sigma_rot[1][4] = sigma[1][1] ^ sigma[1][4];
        sigma_rot[1][5] = sigma[1][2] ^ sigma[1][5];

        sigma_rot[2][0] = sigma[2][5];
        sigma_rot[2][1] = sigma[2][0] ^ sigma[2][5];
        sigma_rot[2][2] = sigma[2][1];
        sigma_rot[2][3] = sigma[2][2];
        sigma_rot[2][4] = sigma[2][3];
        sigma_rot[2][5] = sigma[2][4];

        sigma_rot[3][0] = sigma[3][2] ^ sigma[3][5];
        sigma_rot[3][1] = sigma[3][0] ^ sigma[3][2] ^ sigma[3][3] ^ sigma[3][5];
        sigma_rot[3][2] = sigma[3][1] ^ sigma[3][3] ^ sigma[3][4];
        sigma_rot[3][3] = sigma[3][2] ^ sigma[3][4] ^ sigma[3][5];
        sigma_rot[3][4] = sigma[3][0] ^ sigma[3][3] ^ sigma[3][5];
        sigma_rot[3][5] = sigma[3][1] ^ sigma[3][4];

        sigma_rot[4][0] = sigma[4][4];
        sigma_rot[4][1] = sigma[4][4] ^ sigma[4][5];
        sigma_rot[4][2] = sigma[4][0] ^ sigma[4][5];
        sigma_rot[4][3] = sigma[4][1];
        sigma_rot[4][4] = sigma[4][2];
        sigma_rot[4][5] = sigma[4][3];

        sigma_rot[5][0] = sigma[5][1] ^ sigma[5][4];
        sigma_rot[5][1] = sigma[5][1] ^ sigma[5][2] ^ sigma[5][4] ^ sigma[5][5];
        sigma_rot[5][2] = sigma[5][0] ^ sigma[5][2] ^ sigma[5][3] ^ sigma[5][5];
        sigma_rot[5][3] = sigma[5][1] ^ sigma[5][3] ^ sigma[5][4];
        sigma_rot[5][4] = sigma[5][2] ^ sigma[5][4] ^ sigma[5][5];
        sigma_rot[5][5] = sigma[5][0] ^ sigma[5][3] ^ sigma[5][5];

        sigma_rot[6][0] = sigma[6][3];
        sigma_rot[6][1] = sigma[6][3] ^ sigma[6][4];
        sigma_rot[6][2] = sigma[6][4] ^ sigma[6][5];
        sigma_rot[6][3] = sigma[6][0] ^ sigma[6][5];
        sigma_rot[6][4] = sigma[6][1];
        sigma_rot[6][5] = sigma[6][2];

    end

endmodule