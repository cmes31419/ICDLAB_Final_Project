module rotate_8(
    input  [5:0]        sigma,
    output reg [5:0]    sigma_rot
);

    always @(*) begin
        sigma_rot[0] = sigma[3] ^ sigma[4];
        sigma_rot[1] = sigma[3] ^ sigma[5];
        sigma_rot[2] = sigma[0] ^ sigma[4];
        sigma_rot[3] = sigma[0] ^ sigma[1] ^ sigma[5];
        sigma_rot[4] = sigma[1] ^ sigma[2];
        sigma_rot[5] = sigma[2] ^ sigma[3];
    end

endmodule

module rotate_16(
    input  [5:0]        sigma,
    output reg [5:0]    sigma_rot
);

    always @(*) begin
        sigma_rot[0] = sigma[0] ^ sigma[2] ^ sigma[5];
        sigma_rot[1] = sigma[0] ^ sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[5];
        sigma_rot[2] = sigma[1] ^ sigma[2] ^ sigma[3] ^ sigma[4];
        sigma_rot[3] = sigma[2] ^ sigma[3] ^ sigma[4] ^ sigma[5];
        sigma_rot[4] = sigma[0] ^ sigma[3] ^ sigma[4] ^ sigma[5];
        sigma_rot[5] = sigma[1] ^ sigma[4] ^ sigma[5];
    end

endmodule
