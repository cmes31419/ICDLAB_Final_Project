module chien_search(
    input               clk,
    input               rst,
    input               ready,
    input [5:0]         sigma[6:0],
    output reg [62:0]   cdata,
    output reg          cdone
);

    reg         cnt, cnt_next;
    reg [5:0]   sigma_rec[6:0], sigma_rec_next[6:0];
    reg [62:0]  cdata_next;
    reg         cdone_next;
    reg [31:0]  zeros;

    wire [5:0]  sigma_now1[6:0], sigma_now2[6:0];
    wire [5:0]  sigma_rot[6:0];
    wire [5:0]  sigma_V[31:0];

    integer i;

    genvar gi;

    generate
        for (gi=0;gi<=6;gi=gi+1) begin
            assign sigma_now1[gi] = (cnt == 0) ? (ready ? sigma[gi] : 0) : sigma_rec[gi];
            assign sigma_now2[gi] = (cnt == 1) ? 0 : sigma_now1[gi];
        end
    endgenerate
    
    sigmaV sv0(
        .sigma(sigma_now1),
        .y(sigma_V)
    );

    chien_rotate cr0(
        .sigma(sigma_now2),
        .sigma_rot(sigma_rot)
    );

    always @(*) begin
        for (i=0;i<32;i=i+1) begin
            zeros[i] = (cnt != 0 || ready) ? ~(|sigma_V[31-i]) : 0;
        end

        if (cnt != 0 || ready) begin
            cdata_next[32+:31] = (cnt == 0) ? zeros[0+:31] : cdata[32+:31];
            cdata_next[0+:32] = (cnt == 1) ? zeros : cdata[0+:32];
        end
        else cdata_next = 0;
    end

    always @(*) begin
        for (i=0;i<=6;i=i+1) begin
            if (cnt == 0) sigma_rec_next[i] = ready ? sigma_rot[i] : 0;
            else sigma_rec_next[i] = 0;
        end
    end

    always @(*) begin
        if (cnt == 1) cdone_next = 1;
        else cdone_next = 0;
    end

    always @(*) begin
        if (cnt != 0 || ready) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            cdata   <= 0;
            cdone    <= 0;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            cnt     <= cnt_next;
            cdata   <= cdata_next;
            cdone    <= cdone_next;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule