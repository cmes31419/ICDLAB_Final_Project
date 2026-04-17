module collect_loc(
    input               clk,
    input               rstn,
    input               reset,
    input [31:0]        zero_sum,
    output              valid,
    output              stall,
    output reg [4:0]    loc
);

    reg  [31:0] zero_sum_rec, zero_sum_rec_next;
    reg         valid_rec, valid_rec_next;

    wire [31:0] zero_sum_now;

    wire        valid0, valid1;
    wire [2:0]  num, num0, num1;
    wire [3:0]  loc0, loc1;

    integer i;

    assign zero_sum_now = valid_rec ? zero_sum_rec : zero_sum;
    assign num = num0 + num1;

    assign valid = valid0 | valid1;
    assign stall = (num > 3'd1);

    collect_loc_16 cl16_0(
        .zero_sum(zero_sum_now[15:0]),
        .valid(valid0),
        .num(num0),
        .loc(loc0)
    );

    collect_loc_16 cl16_1(
        .zero_sum(zero_sum_now[31:16]),
        .valid(valid1),
        .num(num1),
        .loc(loc1)
    );

    always @(*) begin
        if (valid0) begin
            loc = {1'b0, loc0};
        end
        else if (valid1) begin
            loc = {1'b1, loc1};
        end
        else begin
            loc = 5'd0;
        end
    end

    always @(*) begin
        if (~reset & valid) begin
            zero_sum_rec_next = zero_sum_now;
            zero_sum_rec_next[loc] = 0;
            valid_rec_next = |zero_sum_rec_next;
        end
        else begin
            zero_sum_rec_next = 0;
            valid_rec_next = 0;
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            zero_sum_rec    <= 0;
            valid_rec       <= 0;
        end
        else begin
            zero_sum_rec    <= zero_sum_rec_next;
            valid_rec       <= valid_rec_next;
        end
    end

endmodule

module collect_loc_16(
    input  [15:0]       zero_sum,
    output              valid,
    output [2:0]        num,
    output reg [3:0]    loc
);

    wire        valid0, valid1, valid2, valid3;
    wire [2:0]  num0, num1, num2, num3;
    wire [1:0]  loc0, loc1, loc2, loc3;

    assign valid = (valid0 | valid1) | (valid2 | valid3);
    assign num = (num0 + num1) + (num2 + num3);

    collect_loc_4 cl40(
        .zero_sum(zero_sum[0+:4]),
        .valid(valid0),
        .num(num0),
        .loc(loc0)
    );

    collect_loc_4 cl41(
        .zero_sum(zero_sum[4+:4]),
        .valid(valid1),
        .num(num1),
        .loc(loc1)
    );

    collect_loc_4 cl42(
        .zero_sum(zero_sum[8+:4]),
        .valid(valid2),
        .num(num2),
        .loc(loc2)
    );

    collect_loc_4 cl43(
        .zero_sum(zero_sum[12+:4]),
        .valid(valid3),
        .num(num3),
        .loc(loc3)
    );

    always @(*) begin
        if (valid0) begin
            loc = {2'd0, loc0};
        end
        else if (valid1) begin
            loc = {2'd1, loc1};
        end
        else if (valid2) begin
            loc = {2'd2, loc2};
        end
        else if (valid3) begin
            loc = {2'd3, loc3};
        end
        else begin
            loc = 4'd0;
        end
    end

endmodule

module collect_loc_4(
    input [3:0]         zero_sum,
    output              valid,
    output [2:0]        num,
    output reg [1:0]    loc
);

    assign valid = |zero_sum;
    assign num = (zero_sum[0] + zero_sum[1]) + (zero_sum[2] + zero_sum[3]);

    always @(*) begin
        if (zero_sum[0]) begin
            loc = 2'd0;
        end
        else if (zero_sum[1]) begin
            loc = 2'd1;
        end
        else if (zero_sum[2]) begin
            loc = 2'd2;
        end
        else if (zero_sum[3]) begin
            loc = 2'd3;
        end
        else begin
            loc = 2'd0;
        end
    end

endmodule
