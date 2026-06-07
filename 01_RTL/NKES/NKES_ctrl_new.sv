module NKES_ctrl_new(
    input           clk,
    input           rst, 
    input           syn_rdy,  // high order syndrome ready
    input           sigma_done,

    input           pe_cnt,

    input [5:0]     dis_in,
    input [5:0]     gamma_init,
    input [3:0]     k_init,

    output          start,

    output [5:0]    gamma_time,
    output [5:0]    dis_time,
    output          branch_time,

    output [5:0]    gamma_out,
    output [5:0]    dis_out,
    output          branch_out,
    output [2:0]    k_out
);

    parameter S_INIT0   = 2'd0;
    parameter S_INIT1   = 2'd1;
    parameter S_PROC    = 2'd2;

    reg [3:0]   state, state_next;

    reg [5:0]   gamma_delay, gamma_delay_next;
    reg [3:0]   k_delay, k_delay_next;

    reg [5:0]   gamma, gamma_next;
    reg [3:0]   k, k_next;

    reg [5:0]   gamma_rec, gamma_rec_next;
    reg [3:0]   k_rec, k_rec_next;

    reg [5:0]   dis_rec, dis_rec_next;

    assign start = (state == S_INIT0 && syn_rdy) || (state == S_INIT1);

    assign gamma_time = gamma_rec;
    assign dis_time = dis_rec;
    assign branch_time = |dis_rec && ($signed(k_rec) <= $signed(4'd0));

    assign gamma_out = gamma;
    assign dis_out = dis_in;
    assign branch_out = |dis_in && ($signed(k) <= $signed(4'd0));
    assign k_out = k[2:0];

    always @(*) begin
        if (start) begin
            gamma_delay_next = gamma_init;
            k_delay_next = k_init;
        end
        else begin
            gamma_delay_next = branch_out ? dis_in : gamma; 
            k_delay_next = branch_out ? -k : k - 1;
        end
        gamma_next = gamma_delay;
        k_next = k_delay;
        gamma_rec_next = (start & ~pe_cnt) ? 6'b1 : gamma;
        k_rec_next = (start & ~pe_cnt) ? 4'b0 : k;
        dis_rec_next = (start & ~pe_cnt) ? 6'b0 : dis_in;
    end

    always @(*) begin
        case(state) 
        S_INIT0:    state_next = syn_rdy ? S_INIT1 : S_INIT0;
        S_INIT1:    state_next = S_PROC;
        S_PROC:     state_next = sigma_done ? S_INIT0 : S_PROC;
        default:    state_next = S_INIT0;
        endcase 
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_INIT0;
            gamma       <= 6'b0;
            k           <= 4'b0;
            gamma_delay <= 6'b0;
            k_delay     <= 4'b0;
            gamma_rec   <= 6'b0;
            k_rec       <= 4'b0;
            dis_rec     <= 6'b0;
        end
        else begin
            state       <= state_next;
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