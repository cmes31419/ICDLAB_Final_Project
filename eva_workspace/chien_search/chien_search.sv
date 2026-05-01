module chien_search(
    input           clk,
    input           rst,
    input [5:0]     sigma[6:0],
    input           sigma_valid,
    output          ready,
    output [62:0]   cdata,
    output          cdone,
    output          cfail
);

    reg         cnt, cnt_next;
    reg [5:0]   sigma_rec[6:0], sigma_rec_next[6:0];
    reg [31:0]  zeros, zeros_next;
    reg [2:0]   degree, degree_next;

    wire [5:0]  sigma_now1[6:0], sigma_now2[6:0];
    wire [5:0]  sigma_rot[6:0];
    wire [5:0]  sigma_V[31:0];
    wire        start;

    integer i;

    genvar gi;

    assign ready = (cnt == 0) ? 1 : 0;
    assign start = (cnt == 1) ? 1 : 0;

    generate
        for (gi=0;gi<=6;gi=gi+1) begin
            assign sigma_now1[gi] = (cnt == 0) ? (sigma_valid ? sigma[gi] : 0) : sigma_rec[gi];
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

    chien_checker cc0(
        .clk(clk),
        .rst(rst),
        .start(start),
        .degree(degree),
        .zeros(zeros),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail)
    );

    always @(*) begin
        if (sigma_valid) begin
            if (sigma[6] != 0) degree_next = 6;
            else if (sigma[5] != 0) degree_next = 5;
            else if (sigma[4] != 0) degree_next = 4;
            else if (sigma[3] != 0) degree_next = 3;
            else if (sigma[2] != 0) degree_next = 2;
            else if (sigma[1] != 0) degree_next = 1;
            else degree_next = 0;
        end
        else if (cdone) degree_next = 0;
        else degree_next = degree;
    end

    always @(*) begin
        for (i=0;i<31;i=i+1) begin
            zeros_next[i] = (cnt != 0 || sigma_valid) ? ~(|sigma_V[31-i]) : 0;
        end
        zeros_next[31] = (cnt != 0) ? ~(|sigma_V[0]) : 0;
    end

    always @(*) begin
        for (i=0;i<=6;i=i+1) begin
            if (cnt == 0) sigma_rec_next[i] = sigma_valid ? sigma_rot[i] : 0;
            else sigma_rec_next[i] = 0;
        end
    end

    always @(*) begin
        if (cnt != 0 || sigma_valid) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            zeros   <= 0;
            degree  <= 0;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            cnt     <= cnt_next;
            zeros   <= zeros_next;
            degree  <= degree_next;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule