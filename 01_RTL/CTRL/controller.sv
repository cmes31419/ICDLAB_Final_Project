module controller(
    input           clk,
    input           rst,
    input           ivalid,
    input           ovalid,
    input           sdone,
    input           LKES_done,
    input           LKES_fail,
    input           cdone,
    input           cfail,
    input [3:0]     nflag,
    input           nested_cdone,
    input           nested_cfail,
    output          iready,
    output [5:0]    iaddr,
    output [5:0]    oaddr,
    output [2:0]    caddr,
    output [2:0]    naddr,
    output          nkill,
    output          Lsel_syn,
    output          Lwen_syn,
    output          Lsel_kes,
    output          Lwen_kes,
    output          Nwen,
    output          forward,
    output          late_cdone,
    output [2:0]    syn_cnt,
    output          nsu_start,
    output          nsu_start_new,
    output          nsu_b,
    output          nsu_stage_flag,
    output [1:0]    nsu_undecoded_idx_1,
    output [1:0]    nsu_undecoded_idx_2,
    output          nsu_stage2_match_idx,
    output          nsu_sel_idx
);

    localparam S_IDLE       = 4'd0;
    localparam S_START1A    = 4'd1;
    localparam S_STAGE1A    = 4'd2;
    localparam S_START1B    = 4'd3;
    localparam S_STAGE1B    = 4'd4;
    localparam S_CHECK      = 4'd5;
    localparam S_START2     = 4'd6;
    localparam S_STAGE2     = 4'd7;
    localparam S_KILL       = 4'd8;

    reg [6:0]   icnt, icnt_next;    // input byte counter with wrap bit
    reg [6:0]   ocnt, ocnt_next;    // output byte counter with wrap bit
    reg [3:0]   ccnt, ccnt_next;    // correction codeword counter
    reg [1:0]   ncnt, ncnt_next;

    reg [3:0]   nstate, nstate_next;
    reg [1:0]   npos, npos_next;
    reg [1:0]   npos1, npos1_next;
    reg [1:0]   npos2, npos2_next;

    reg [1:0]   err_num, err_num_next;
    reg         nested_err_num, nested_err_num_next;
    reg         b, b_next;

    reg [1:0]   sdone_num, sdone_num_next;

    wire [2:0]  npending;
    wire        npos_test;

    assign npending = nflag[0] + nflag[1] + nflag[2] + nflag[3];
    assign npos_test = (nstate == S_STAGE1B) ? npos2 : npos1;

    // Address mapping: input/output bytes are stored and read in reverse byte order
    assign iaddr = {icnt[5:3], 3'h7 - icnt[2:0]};
    assign oaddr = {ocnt[5:3], 3'h7 - ocnt[2:0]};
    assign caddr = ccnt[2:0];
    assign naddr = {ncnt[0], npos};

    assign Lsel_syn = err_num[0];
    assign Lwen_syn = ~err_num[1];
    assign Lsel_kes = err_num[0];
    assign Lwen_kes = ~err_num[1] & ~cfail;
    // assign Lsel_kes = (cfail | LKES_fail) ? ~err_num[0] : err_num[0];
    // assign Lwen_kes = ~err_num[1] | ~(err_num[0] & (cfail | LKES_fail));
    assign Nwen = ~nested_err_num;
    assign forward = (nstate == S_IDLE && ncnt != ccnt[3:2]) ? 1 : 0;
    assign late_cdone = (sdone_num == 2) ? 1 : 0;

    assign syn_cnt = icnt[2:0];

    assign nkill = (nstate == S_KILL) ? 1 : 0;

    assign nsu_start = (nstate == S_START1A || nstate == S_START2) ? 1 : 0;
    assign nsu_start_new = (nstate == S_START1A || nstate == S_START1B || nstate == S_START2) ? 1 : 0;
    assign nsu_b = b;
    assign nsu_stage_flag = (nstate == S_START2 || nstate == S_STAGE2) ? 1 : 0;
    assign nsu_undecoded_idx_1 = npos1;
    assign nsu_undecoded_idx_2 = npos2;
    assign nsu_stage2_match_idx = (npos == npos2) ? 1 : 0;
    assign nsu_sel_idx = (nstate == S_START1B || nstate == S_STAGE1B) ? 1 : 0;

    // FIFO-style full check
    assign iready = ((icnt[6] != ocnt[6] && icnt[5:3] == ocnt[5:3]) || (icnt[6] != ncnt[1] && icnt[5] == ncnt[0])) ? 0 : 1;

    always @(*) begin
        if (ivalid) icnt_next = icnt + 1;
        else icnt_next = icnt;
        if (ovalid) ocnt_next = ocnt + 1;
        else ocnt_next = ocnt;
        if (cdone | LKES_fail) ccnt_next = ccnt + 1;
        else ccnt_next = ccnt;
        if (nstate == S_KILL) ncnt_next = ncnt + 1;
        else ncnt_next = ncnt;
    end

    always @(*) begin
        if (icnt[4:0] == 5'd7) err_num_next = 2'd0;
        else if (err_num == 2'd2) err_num_next = err_num;
        else if (cfail | LKES_fail) err_num_next = err_num + 1;
        else err_num_next = err_num;
    end

    always @(*) begin
        if (nstate == S_KILL) nested_err_num_next = 1'd0;
        else if (nested_cfail) nested_err_num_next = 1'd1;
        else nested_err_num_next = nested_err_num;
    end

    always @(*) begin
        if (nstate == S_IDLE || nstate == S_CHECK) b_next = (npending == 3'd2) ? 1 : 0;
        else b_next = b;
    end

    always @(*) begin
        if (sdone & ~(cdone | LKES_fail)) sdone_num_next = sdone_num + 1;
        else if (~sdone & (cdone | LKES_fail)) sdone_num_next = sdone_num - 1;
        else sdone_num_next = sdone_num;
    end

    always @(*) begin
        if (nstate == S_IDLE || nstate == S_CHECK) begin
            if (nflag[0]) npos_next = 0;
            else if (nflag[1]) npos_next = 1;
            else if (nflag[2]) npos_next = 2;
            else npos_next = 3;
        end
        else if (nstate == S_STAGE1A && nested_cdone && b) begin
            if (nflag[3]) npos_next = 3;
            else if (nflag[2]) npos_next = 2;
            else if (nflag[1]) npos_next = 1;
            else npos_next = 0;
        end
        else npos_next = npos;
    end

    always @(*) begin
        if (nstate == S_IDLE) begin
            if (nflag[0]) npos1_next = 0;
            else if (nflag[1]) npos1_next = 1;
            else if (nflag[2]) npos1_next = 2;
            else npos1_next = 3;
            if (nflag[3]) npos2_next = 3;
            else if (nflag[2]) npos2_next = 2;
            else if (nflag[1]) npos2_next = 1;
            else npos2_next = 0;
        end
        else begin
            npos1_next = npos1;
            npos2_next = npos2;
        end
    end

    always @(*) begin
        case (nstate)
        S_IDLE: begin
            if (ncnt != ccnt[3:2]) begin
                if (npending == 3'd1 || npending == 3'd2) nstate_next = S_START1A;
                else nstate_next = S_KILL;
            end
            else nstate_next = S_IDLE;
        end
        S_START1A:  nstate_next = S_STAGE1A;
        S_STAGE1A:  nstate_next = nested_cdone ? (b ? S_START1B : S_CHECK) : S_STAGE1A;
        S_START1B:  nstate_next = S_STAGE1B;
        S_STAGE1B:  nstate_next = nested_cdone ? S_CHECK : S_STAGE1B;
        S_CHECK: begin
            if (npending == 3'd1) nstate_next = S_START2;
            else nstate_next = S_KILL;
        end
        S_START2:   nstate_next = S_STAGE2;
        S_STAGE2:   nstate_next = nested_cdone ? S_KILL : S_STAGE2;
        S_KILL:     nstate_next = S_IDLE;
        default:    nstate_next = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            icnt            <= 0;
            ocnt            <= 0;
            ccnt            <= 0;
            ncnt            <= 0;
            nstate          <= S_IDLE;
            npos            <= 0;
            npos1           <= 0;
            npos2           <= 0;
            err_num         <= 0;
            nested_err_num  <= 0;
            sdone_num       <= 0;
            b               <= 0;
        end
        else begin
            icnt            <= icnt_next;
            ocnt            <= ocnt_next;
            ccnt            <= ccnt_next;
            ncnt            <= ncnt_next;
            nstate          <= nstate_next;
            npos            <= npos_next;
            npos1           <= npos1_next;
            npos2           <= npos2_next;
            err_num         <= err_num_next;
            nested_err_num  <= nested_err_num_next;
            sdone_num       <= sdone_num_next;
            b               <= b_next;
        end
    end

endmodule