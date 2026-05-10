module memory(
    input           clk,
    input           rst,
    // from input
    input [7:0]     idata,
    input [4:0]     iaddr,
    input           iwen,
    // from chien search
    input [62:0]    cdata,
    input [1:0]     caddr,
    input           cwen,
    // for output
    input [4:0]     oaddr,
    output [7:0]    odata
);

    reg [62:0]  data[3:0], data_next[3:0];

    integer i, j;

    always @(*) begin
        for (i=0;i<4;i=i+1) begin
            for (j=0;j<7;j=j+1) begin
                if (iwen && iaddr[3+:2] == i && iaddr[0+:3] == j) data_next[i][j*8+:8] = idata;
                else if (icen && caddr == i) data_next[i][j*8+:8] = data[i][j*8+:8] ^ cdata[j*8+:8];
                else data_next[i][j*8+:8] = data[i][j*8+:8];
            end
            if (iwen && iaddr[3+:2] == i && iaddr[0+:3] == 7) data_next[i][56+:7] = idata[0+:7];
            else if (icen && caddr == i) data_next[i][56+:7] = data[i][56+:7] ^ cdata[56+:7];
            else data_next[i][56+:7] = data[i][56+:7];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<4;i=i+1) begin
                data[i] <= 0;
            end
        end
        else begin
            for (i=0;i<4;i=i+1) begin
                data[i] <= data_next[i];
            end
        end
    end

endmodule