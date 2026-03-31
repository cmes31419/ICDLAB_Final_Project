module sort_desc(
    input           clk,
    input           rstn,
    input           ready,
    input [9:0]     loc[5:0],
    output          sort_done,
    output          out_stop,
    output [9:0]    out_loc
);

    localparam S_IDLE = 1'd0;
    localparam S_PROC = 1'd1;

    reg         state, state_next;
    reg [9:0]   sorted_loc[5:0], sorted_loc_next[5:0];

    wire [9:0]  b1, b2;
    wire [9:0]  s0, s1;
    wire [9:0]  cmp_loc[5:0];
    wire        sel0, sel1, sel2, sel3, sel4;

    integer i;

    assign sort_done = (state == S_PROC) & sel0 & sel1 & sel2 & sel3 & sel4;
    assign out_stop = (sorted_loc[1] == 10'd0) ? 1 : 0;
    assign out_loc = sorted_loc[0];

    cmp cmp0(
        .x(sorted_loc[0]),
        .y(sorted_loc[1]),
        .b(cmp_loc[0]),
        .s(s0),
        .sel(sel0)
    );

    cmp cmp1(
        .x(sorted_loc[2]),
        .y(sorted_loc[3]),
        .b(b1),
        .s(s1),
        .sel(sel1)
    );

    cmp cmp2(
        .x(sorted_loc[4]),
        .y(sorted_loc[5]),
        .b(b2),
        .s(cmp_loc[5]),
        .sel(sel2)
    );

    cmp cmp3(
        .x(s0),
        .y(b1),
        .b(cmp_loc[1]),
        .s(cmp_loc[2]),
        .sel(sel3)
    );

    cmp cmp4(
        .x(s1),
        .y(b2),
        .b(cmp_loc[3]),
        .s(cmp_loc[4]),
        .sel(sel4)
    );

    always @(*) begin
        for (i=0;i<5;i=i+1) begin
            if (ready) sorted_loc_next[i] = loc[i];
            else if (state == S_PROC) sorted_loc_next[i] = cmp_loc[i];
            else sorted_loc_next[i] = sorted_loc[i+1];
        end
        if (ready) sorted_loc_next[5] = loc[5];
        else if (state == S_PROC) sorted_loc_next[5] = cmp_loc[5];
        else sorted_loc_next[5] = 0;
    end

    always @(*) begin
        case(state)
            S_IDLE: state_next = ready ? S_PROC : S_IDLE;
            S_PROC: state_next = ready ? S_PROC : (sort_done ? S_IDLE : S_PROC);
        endcase
    end

    always @(posedge clk) begin
        if (~rstn) begin
            state   <= S_IDLE;
            for (i=0;i<6;i=i+1) begin
                sorted_loc[i]  <= 0;
            end
        end
        else begin
            state   <= state_next;
            for (i=0;i<6;i=i+1) begin
                sorted_loc[i]  <= sorted_loc_next[i];
            end
        end
    end

endmodule

module cmp(
    input [9:0]     x,
    input [9:0]     y,
    output [9:0]    b,
    output [9:0]    s,
    output          sel
);

    assign sel = (x >= y) ? 1 : 0;
    assign b = sel ? x : y;
    assign s = sel ? y : x;

endmodule