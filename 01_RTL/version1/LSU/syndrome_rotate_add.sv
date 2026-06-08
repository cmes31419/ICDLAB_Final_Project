module syndrome_rotate_add(
    input  [7:0]        data,
    input  [5:0]        syn[1:0],
    output reg [5:0]    syn_rot[1:0]
);

    always @(*) begin
        syn_rot[0][0] = syn[0][3] ^ syn[0][4] ^ data[0] ^ data[6];
        syn_rot[0][1] = syn[0][3] ^ syn[0][5] ^ data[1] ^ data[6] ^ data[7];
        syn_rot[0][2] = syn[0][0] ^ syn[0][4] ^ data[2] ^ data[7];
        syn_rot[0][3] = syn[0][0] ^ syn[0][1] ^ syn[0][5] ^ data[3];
        syn_rot[0][4] = syn[0][1] ^ syn[0][2] ^ data[4];
        syn_rot[0][5] = syn[0][2] ^ syn[0][3] ^ data[5];

        syn_rot[1][0] = syn[1][0] ^ syn[1][2] ^ data[0] ^ data[2] ^ data[4] ^ data[6] ^ data[7];
        syn_rot[1][1] = syn[1][1] ^ syn[1][2] ^ syn[1][3] ^ data[2] ^ data[6] ^ data[7];
        syn_rot[1][2] = syn[1][2] ^ syn[1][3] ^ syn[1][4] ^ data[4] ^ data[6];
        syn_rot[1][3] = syn[1][3] ^ syn[1][4] ^ syn[1][5] ^ data[1] ^ data[3] ^ data[5] ^ data[6] ^ data[7];
        syn_rot[1][4] = syn[1][0] ^ syn[1][4] ^ syn[1][5] ^ data[3] ^ data[7];
        syn_rot[1][5] = syn[1][1] ^ syn[1][5] ^ data[5] ^ data[7];

    end

endmodule