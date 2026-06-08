module chien_checker(
    input               clk,
    input               rst,
    input               start,
    input               nested,
    input [2:0]         degree,
    input [31:0]        zeros,
    output reg [62:0]   cdata,
    output reg          cdone,
    output              cfail,
    output reg          nested_cdone,
    output              nested_cfail
);

    reg         cnt, cnt_next;
    reg [2:0]   degree_rec, degree_rec_next;
    reg [2:0]   root_num, root_num_next;
    reg [62:0]  cdata_next;
    reg         cdone_next;
    reg         nested_cdone_next;

    reg [1:0]   sum2 [15:0];
    reg [2:0]   sum4 [7:0];
    reg [2:0]   sum8 [3:0];
    reg [2:0]   sum16 [1:0];
    reg [2:0]   pop_cnt32;

    wire fail;

    integer i;

    assign fail = (root_num != degree_rec) ? 1 : 0;
    assign cfail = (cdone & fail) ? 1 : 0;
    assign nested_cfail = (nested_cdone & fail) ? 1 : 0;

    always @(*) begin
        sum2[0] = zeros[0] + zeros[1];
        sum2[1] = zeros[2] + zeros[3];
        sum2[2] = zeros[4] + zeros[5];
        sum2[3] = zeros[6] + zeros[7];
        sum2[4] = zeros[8] + zeros[9];
        sum2[5] = zeros[10] + zeros[11];
        sum2[6] = zeros[12] + zeros[13];
        sum2[7] = zeros[14] + zeros[15];
        sum2[8] = zeros[16] + zeros[17];
        sum2[9] = zeros[18] + zeros[19];
        sum2[10] = zeros[20] + zeros[21];
        sum2[11] = zeros[22] + zeros[23];
        sum2[12] = zeros[24] + zeros[25];
        sum2[13] = zeros[26] + zeros[27];
        sum2[14] = zeros[28] + zeros[29];
        sum2[15] = zeros[30] + zeros[31];

        sum4[0] = sum2[0] + sum2[1];
        sum4[1] = sum2[2] + sum2[3];
        sum4[2] = sum2[4] + sum2[5];
        sum4[3] = sum2[6] + sum2[7];
        sum4[4] = sum2[8] + sum2[9];
        sum4[5] = sum2[10] + sum2[11];
        sum4[6] = sum2[12] + sum2[13];
        sum4[7] = sum2[14] + sum2[15];

        sum8[0] = sum4[0] + sum4[1];
        sum8[1] = sum4[2] + sum4[3];
        sum8[2] = sum4[4] + sum4[5];
        sum8[3] = sum4[6] + sum4[7];

        sum16[0] = sum8[0] + sum8[1];
        sum16[1] = sum8[2] + sum8[3];

        pop_cnt32 = sum16[0] + sum16[1];
    end

    always @(*) begin
        if (start) begin
            degree_rec_next = degree;
            root_num_next = pop_cnt32;
        end
        else if (cnt != 0) begin
            degree_rec_next = degree_rec;
            root_num_next = root_num + pop_cnt32;
        end
        else begin
            degree_rec_next = 0;
            root_num_next = 0;
        end
    end

    always @(*) begin
        if (cnt != 0 || start) begin
            cdata_next[32+:31] = (cnt == 0) ? zeros[0+:31] : cdata[32+:31];
            cdata_next[0+:32] = (cnt == 1) ? zeros : cdata[0+:32];
        end
        else cdata_next = 0;
    end

    always @(*) begin
        cdone_next = (cnt == 1 && ~nested) ? 1 : 0;
        nested_cdone_next = (cnt == 1 && nested) ? 1 : 0;
    end
    
    always @(*) begin
        if (cnt != 0 || start) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt             <= 0;
            degree_rec      <= 0;
            root_num        <= 0;
            cdata           <= 0;
            cdone           <= 0;
            nested_cdone    <= 0;
        end
        else begin
            cnt             <= cnt_next;
            degree_rec      <= degree_rec_next;
            root_num        <= root_num_next;
            cdata           <= cdata_next;
            cdone           <= cdone_next;
            nested_cdone    <= nested_cdone_next;
        end
    end

endmodule