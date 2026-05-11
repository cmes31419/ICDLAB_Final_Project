module memory(
    input           clk,
    input           rst,
    // input write interface
    input [4:0]     iaddr,
    input [7:0]     idata,
    input           iwen,
    // Chien search correction interface
    input [1:0]     caddr,
    input [62:0]    cdata,
    input           cwen,
    input           ckill,  // force finish when decoding fails
    // output read interface
    input [4:0]     oaddr,
    output [7:0]    odata,
    output          ovalid
);

    reg [63:0]  data[3:0], data_next[3:0];  // bit 63: fail flag, bits 62:0: codeword
    reg         done[3:0], done_next[3:0];  // decoding done flag

    integer i, j;

    assign odata = data[oaddr[4:3]][oaddr[2:0]*8+:8];
    assign ovalid = done[oaddr[4:3]];

    always @(*) begin
        for (i=0;i<4;i=i+1) begin
            for (j=0;j<7;j=j+1) begin
                if (iwen && iaddr[3+:2] == i && iaddr[0+:3] == j) data_next[i][j*8+:8] = idata;
                else if (cwen && caddr == i) data_next[i][j*8+:8] = data[i][j*8+:8] ^ cdata[j*8+:8];
                else data_next[i][j*8+:8] = data[i][j*8+:8];
            end
            // fail flag and upper 7 codeword bits
            if (iwen && iaddr[3+:2] == i && iaddr[0+:3] == 7) data_next[i][56+:8] = {1'b1, idata[0+:7]};
            else if (cwen && caddr == i) data_next[i][56+:8] = {1'b0, data[i][56+:7] ^ cdata[56+:7]};
            else data_next[i][56+:8] = data[i][56+:8];
        end
    end

    always @(*) begin
        for (i=0;i<4;i=i+1) begin
            if (iwen && iaddr[3+:2] == i) done_next[i] = 0;
            else if ((cwen | ckill) && caddr == i) done_next[i] = 1;
            else done_next[i] = done[i];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<4;i=i+1) begin
                data[i] <= 0;
                done[i] <= 0;
            end
        end
        else begin
            for (i=0;i<4;i=i+1) begin
                data[i] <= data_next[i];
                done[i] <= done_next[i];
            end
        end
    end

endmodule