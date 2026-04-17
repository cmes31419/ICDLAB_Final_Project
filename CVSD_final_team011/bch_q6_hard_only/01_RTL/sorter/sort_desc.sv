module sort_desc(
    input           clk,
    input           rstn,
    input           ready,
    input [5:0]     loc[1:0],
    output          sort_done,
    output          out_stop,
    output [5:0]    out_loc
);

    localparam S_IDLE = 1'd0;
    localparam S_PROC = 1'd1;

    reg         state, state_next;
    reg [5:0]   sorted_loc[1:0], sorted_loc_next[1:0];

    wire [5:0]  cmp_loc[1:0];
    wire        sel;

    integer i;

    assign sort_done = (state == S_PROC) & sel;
    assign out_stop = (sorted_loc[1] == 6'd0) ? 1 : 0;
    assign out_loc = sorted_loc[0];

    cmp cmp0(
        .x(sorted_loc[0]),
        .y(sorted_loc[1]),
        .b(cmp_loc[0]),
        .s(cmp_loc[1]),
        .sel(sel)
    );

    always @(*) begin
        if (ready) begin
            sorted_loc_next[0] = loc[0];
            sorted_loc_next[1] = loc[1];
        end
        else if (state == S_PROC) begin
            sorted_loc_next[0] = cmp_loc[0];
            sorted_loc_next[1] = cmp_loc[1];
        end
        else begin
            sorted_loc_next[0] = sorted_loc[1];
            sorted_loc_next[1] = 0;
        end
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
            for (i=0;i<2;i=i+1) begin
                sorted_loc[i]  <= 0;
            end
        end
        else begin
            state   <= state_next;
            for (i=0;i<2;i=i+1) begin
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