module NKES_ctrl_new(
    input           clk,
    input           rst, 
    input           LO_syn_rdy,     // low order syndrome ready
    input           HO_syn_rdy,     // high order syndrome ready

    input [5:0]     dis_in,
    input [5:0]     gamma_init,
    input [3:0]     k_init,

    output          start,
    output          mode,
    output          mode_init,
    output          pe_cnt,
    output          first_iter,
    output          LO_syn_get,
    output          HO_syn_get,
    output          Lwen,
    output          Nwen0,
    output          Nwen1,

    output [5:0]    gamma_time,
    output [5:0]    dis_time,
    output          branch_time,
    output [5:0]    gamma_out,
    output [5:0]    dis_out,
    output          branch_out,
    output [2:0]    k_out
);

    parameter S_IDLE    = 2'd0;
    parameter S_PROC0   = 2'd1;
    parameter S_PROC1   = 2'd2;

    reg [3:0]   state, state_next;
    reg [2:0]   cnt, cnt_next;
    reg         done0, done0_next;
    reg         done1, done1_next;

    reg [5:0]   gamma_delay, gamma_delay_next;
    reg [3:0]   k_delay, k_delay_next;
    reg [5:0]   gamma, gamma_next;
    reg [3:0]   k, k_next;
    reg [5:0]   gamma_rec, gamma_rec_next;
    reg [3:0]   k_rec, k_rec_next;
    reg [5:0]   dis_rec, dis_rec_next;

    wire        LO_en, HO_en;
    wire        start0, start1a, start1b;

    assign LO_en = (state == S_IDLE) ? 1 : 0;
    assign HO_en = (state == S_IDLE || (state == S_PROC0 && cnt == 1)) ? 1 : 0;

    assign start0 = (LO_syn_rdy & LO_en) ? 1 : 0;
    assign start1a = (HO_syn_rdy & HO_en & ~start0) ? 1 : 0;
    assign start1b = (state == S_PROC1 && cnt == 0) ? 1 : 0;
    
    assign start = start0 | start1a | start1b;
    assign mode = (state == S_PROC1) ? 1 : 0;
    assign mode_init = start1a | mode;
    assign pe_cnt = (state == S_PROC1 && ~cnt[0]) ? 1 : 0;
    assign first_iter = (state == S_PROC0 && cnt == 0) ? 1 : 0;
    assign LO_syn_get = start0;
    assign HO_syn_get = start1a;
    assign Lwen = done0;
    assign Nwen0 = done1_next;
    assign Nwen1 = done1;

    assign gamma_time = gamma_rec;
    assign dis_time = dis_rec;
    assign branch_time = |dis_rec && ($signed(k_rec) <= $signed(4'd0));
    assign gamma_out = gamma;
    assign dis_out = dis_in;
    assign branch_out = |dis_in && ($signed(k) <= $signed(4'd0));
    assign k_out = k[2:0];

    always @(*) begin
        if (start1a | start1b) begin
            gamma_delay_next = gamma_init;
            k_delay_next = k_init;
        end
        else begin
            gamma_delay_next = branch_out ? dis_in : gamma; 
            k_delay_next = branch_out ? -k : k - 4'b1;
        end
        if (start0) begin
            gamma_next = 6'b1;
            k_next = 4'b0;
        end
        else if (state == S_PROC0) begin
            gamma_next = branch_out ? dis_in : gamma; 
            k_next = branch_out ? -k : k - 4'b1;
        end
        else begin
            gamma_next = gamma_delay;
            k_next = k_delay;
        end
        gamma_rec_next = start1a ? 6'b1 : gamma;
        k_rec_next = start1a ? 4'b0 : k;
        dis_rec_next = start1a ? 6'b0 : dis_in;
    end

    always @(*) begin
        if (state == S_PROC0 && cnt == 1) done0_next = 1;
        else done0_next = 0;
        if (state == S_PROC1 && cnt == 5) done1_next = 1;
        else done1_next = 0;
    end

    always @(*) begin
        case(state)
        S_PROC0: cnt_next = (cnt == 1) ? 0 : cnt + 1;
        S_PROC1: cnt_next = (cnt == 5) ? 0 : cnt + 1;
        default: cnt_next = 0;
        endcase 
    end

    always @(*) begin
        case(state)
        S_IDLE: begin
            if (LO_syn_rdy & LO_en) state_next = S_PROC0;
            else if (HO_syn_rdy & HO_en) state_next = S_PROC1;
            else state_next = S_IDLE;
        end
        S_PROC0: begin
            if (HO_syn_rdy & HO_en) state_next = S_PROC1;
            else state_next = (cnt == 1) ? S_IDLE : S_PROC0;
        end
        S_PROC1: state_next = (cnt == 5) ? S_IDLE : S_PROC1;
        default: state_next = S_IDLE;
        endcase 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_IDLE;
            cnt         <= 0;
            done0       <= 0;
            done1       <= 0;
            gamma       <= 0;
            k           <= 0;
            gamma_delay <= 0;
            k_delay     <= 0;
            gamma_rec   <= 0;
            k_rec       <= 0;
            dis_rec     <= 0;
        end
        else begin
            state       <= state_next;
            cnt         <= cnt_next;
            done0       <= done0_next;
            done1       <= done1_next;
            gamma       <= gamma_next;
            k           <= k_next;
            gamma_delay <= gamma_delay_next;
            k_delay     <= k_delay_next;
            gamma_rec   <= gamma_rec_next;
            k_rec       <= k_rec_next;
            dis_rec     <= dis_rec_next;
        end
    end
endmodule