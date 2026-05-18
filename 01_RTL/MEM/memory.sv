module memory(
    input           clk,
    input           rst,
    // input write interface
    input [5:0]     iaddr,
    input [7:0]     idata,
    input           iwen,
    // Chien search correction interface
    input [2:0]     caddr,
    input [62:0]    cdata,
    input           cwen,
    input           ckill,  // force finish when decoding fails
    // nested code interface
    input           naddr,
    output [3:0]    nflag,  // bitmask of sub-codewords not yet decoded
    output [62:0]   ndata[3:0],
    // output read interface
    input [5:0]     oaddr,
    output [7:0]    odata,
    output          ovalid
);

    reg [63:0]  data[1:0][3:0], data_next[1:0][3:0];  // bit 63: fail flag, bits 62:0: codeword
    reg         done[1:0][3:0], done_next[1:0][3:0];  // decoding done flag

    integer h, i, j;

    genvar gi;

    assign odata = data[oaddr[5]][oaddr[4:3]][oaddr[2:0]*8+:8];
    assign ovalid = done[oaddr[5]][oaddr[4:3]];

    assign nflag = {~done[naddr][0], ~done[naddr][1], ~done[naddr][2], ~done[naddr][3]};

    generate
        for (gi=0;gi<4;gi=gi+1) begin
            assign ndata[gi] = data[naddr][gi];
        end
    endgenerate

    always @(*) begin
        for (h=0;h<2;h=h+1) begin
            for (i=0;i<4;i=i+1) begin
                for (j=0;j<7;j=j+1) begin
                    if (iwen && iaddr[5] == h && iaddr[3+:2] == i && iaddr[0+:3] == j) data_next[h][i][j*8+:8] = idata;
                    else if (cwen && caddr[2] == h && caddr[1:0] == i) data_next[h][i][j*8+:8] = data[h][i][j*8+:8] ^ cdata[j*8+:8];
                    else data_next[h][i][j*8+:8] = data[h][i][j*8+:8];
                end
                // fail flag and upper 7 codeword bits
                if (iwen && iaddr[5] == h && iaddr[3+:2] == i && iaddr[0+:3] == 7) data_next[h][i][56+:8] = {1'b1, idata[0+:7]};
                else if (cwen && caddr[2] == h && caddr[1:0] == i) data_next[h][i][56+:8] = {1'b0, data[h][i][56+:7] ^ cdata[56+:7]};
                else data_next[h][i][56+:8] = data[h][i][56+:8];
            end
        end
    end

    always @(*) begin
        for (h=0;h<2;h=h+1) begin
            for (i=0;i<4;i=i+1) begin
                if (iwen && iaddr[5] == h && iaddr[3+:2] == i) done_next[h][i] = 0;
                else if ((cwen | ckill) && caddr[2] == h && caddr[1:0] == i) done_next[h][i] = 1;
                else done_next[h][i] = done[h][i];
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (h=0;h<2;h=h+1) begin
                for (i=0;i<4;i=i+1) begin
                    data[h][i] <= 0;
                    done[h][i] <= 0;
                end
            end
        end
        else begin
            for (h=0;h<2;h=h+1) begin
                for (i=0;i<4;i=i+1) begin
                    data[h][i] <= data_next[h][i];
                    done[h][i] <= done_next[h][i];
                end
            end
        end
    end

endmodule