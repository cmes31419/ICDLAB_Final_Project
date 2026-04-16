module sort_desc(
    input           clk,
    input           rstn,
    input           ready,
    input [5:0]     loc[3:0],
    output          sort_done,
    output          out_stop,
    output [5:0]    out_loc
);

    localparam S_IDLE = 1'd0;
    localparam S_PROC = 1'd1;

    reg         state, state_next;
    reg [5:0]   sorted_loc[3:0], sorted_loc_next[3:0];

    wire [5:0]  b1;
    wire [5:0]  s0;
    wire [5:0]  cmp_loc[3:0];
    wire        sel0, sel1, sel2;

    integer i;

    assign sort_done = (state == S_PROC) & sel0 & sel1 & sel2;
    assign out_stop = (sorted_loc[1] == 6'd0) ? 1 : 0;
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
        .s(cmp_loc[3]),
        .sel(sel1)
    );

    cmp cmp2(
        .x(s0),
        .y(b1),
        .b(cmp_loc[1]),
        .s(cmp_loc[2]),
        .sel(sel2)
    );

    always @(*) begin
        for (i=0;i<3;i=i+1) begin
            if (ready) sorted_loc_next[i] = loc[i];
            else if (state == S_PROC) sorted_loc_next[i] = cmp_loc[i];
            else sorted_loc_next[i] = sorted_loc[i+1];
        end
        if (ready) sorted_loc_next[3] = loc[3];
        else if (state == S_PROC) sorted_loc_next[3] = cmp_loc[3];
        else sorted_loc_next[3] = 0;
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
            for (i=0;i<4;i=i+1) begin
                sorted_loc[i]  <= 0;
            end
        end
        else begin
            state   <= state_next;
            for (i=0;i<4;i=i+1) begin
                sorted_loc[i]  <= sorted_loc_next[i];
            end
        end
    end

endmodule

module cmp(
    input [5:0]     x,
    input [5:0]     y,
    output [5:0]    b,
    output [5:0]    s,
    output          sel
);

    assign sel = (x >= y) ? 1 : 0;
    assign b = sel ? x : y;
    assign s = sel ? y : x;

endmodule