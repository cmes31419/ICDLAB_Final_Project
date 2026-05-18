module controller(
    input           clk,
    input           rst,
    input           ivalid,
    input           ovalid,
    input           sdone,
    input           cdone,
    input           cfail,
    input [3:0]     nflag,
    input           nested_cdone,
    input           nested_cfail,
    output          iready,
    output [5:0]    iaddr,
    output [5:0]    oaddr,
    output [2:0]    caddr,
    output          naddr,
    output          nkill,
    output          swen,
    output          ssel,
    output [2:0]    syn_cnt,
    output          nsu_start,
    output          nsu_b,
    output          nsu_stage_flag
);

    localparam S_IDLE   = 3'd0;
    localparam S_START1 = 3'd1;
    localparam S_STAGE1 = 3'd2;
    localparam S_START2 = 3'd3;
    localparam S_STAGE2 = 3'd4;
    localparam S_KILL   = 3'd5;

    reg [5:0]   icnt, icnt_next;    // input byte counter with wrap bit
    reg [5:0]   ocnt, ocnt_next;    // output byte counter with wrap bit
    // reg [1:0]   scnt, scnt_next;
    reg [2:0]   ccnt, ccnt_next;    // correction codeword counter
    reg         ncnt, ncnt_next;

    reg [2:0]   nstate, nstate_next;

    reg [1:0]   err_num, err_num_next;

    wire [2:0]  npending;

    assign npending = nflag[0] + nflag[1] + nflag[2] + nflag[3];

    // Address mapping: input/output bytes are stored and read in reverse byte order
    assign iaddr = {icnt[5:3], 3'h7 - icnt[2:0]};
    assign oaddr = {ocnt[5:3], 3'h7 - ocnt[2:0]};
    assign caddr = ccnt;
    assign naddr = ncnt;

    assign swen = ~err_num[1] & sdone;
    assign ssel = err_num[0];

    assign syn_cnt = icnt[2:0];

    assign nkill = (nstate == S_KILL) ? 1 : 0;

    assign nsu_start = (nstate == S_START1 || nstate == S_START2) ? 1 : 0;
    assign nsu_b = (npending == 3'd2) ? 1 : 0;
    assign nsu_stage_flag = (nstate == S_START2 || nstate == S_STAGE2) ? 1 : 0;

    // FIFO-style full check
    assign iready = (icnt[5] != ccnt[2] || icnt[4:3] >= ccnt[1:0]) ? 1 : 0;

    always @(*) begin
        if (ivalid) icnt_next = icnt + 1;
        else icnt_next = icnt;
        if (ovalid) ocnt_next = ocnt + 1;
        else ocnt_next = ocnt;
        // if (sdone) scnt_next = scnt + 1;
        // else scnt_next = scnt;
        if (cdone) ccnt_next = ccnt + 1;
        else ccnt_next = ccnt;
        if (ncnt != ccnt[2] && npending == 3'd0) ncnt_next = ncnt + 1;
        else ncnt_next = ncnt;
    end

    always @(*) begin
        if (icnt[4:0] == 5'd7) err_num_next = 2'd0;
        else if (err_num == 2'd2) err_num_next = err_num;
        else if (cdone && cfail) err_num_next = err_num + 1;
        else err_num_next = err_num;
    end

    always @(*) begin
        case (nstate)
        S_IDLE:     nstate_next = (ncnt != ccnt[2] && (npending == 3'd1 || npending == 3'd2)) ? S_START1 : S_IDLE;
        S_START1:   nstate_next = S_STAGE1;
        S_STAGE1:   nstate_next = nested_cdone ? (nested_cfail ? S_START2 : S_IDLE) : S_STAGE1;
        S_START2:   nstate_next = S_STAGE2;
        S_STAGE2:   nstate_next = nested_cdone ? (nested_cfail ? S_KILL : S_IDLE) : S_STAGE2;
        S_KILL:     nstate_next = S_IDLE;
        default:    nstate_next = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            icnt    <= 0;
            ocnt    <= 0;
            // scnt    <= 0;
            ccnt    <= 0;
            ncnt    <= 0;
            nstate  <= S_IDLE;
            err_num <= 0;
        end
        else begin
            icnt    <= icnt_next;
            ocnt    <= ocnt_next;
            // scnt    <= scnt_next;
            ccnt    <= ccnt_next;
            ncnt    <= ncnt_next;
            nstate  <= nstate_next;
            err_num <= err_num_next;
        end
    end

endmodule