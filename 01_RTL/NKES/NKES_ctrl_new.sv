module NKES_ctrl_new(
    input clk,
    input rst, 
    input syn_rdy,  // high order syndrome ready
    input sigma_done,

    input pe_cnt,

    input [5:0] discrepancy_in,
    input [5:0] gamma_init,
    input [3:0] k_init,

    output start,

    output [5:0] gamma_out,
    output [5:0] discrepancy_out,
    output branch_out
);

    parameter S_INIT0   = 2'd0;
    parameter S_INIT1   = 2'd1;
    parameter S_PROC    = 2'd2;

    reg [3:0] state, state_next;
    reg [5:0] gamma, gamma_next;
    reg [3:0] k, k_next;

    assign start = (state == S_INIT0 && syn_rdy) || (state == S_INIT1);

    assign gamma_out = gamma;
    assign discrepancy_out = discrepancy_in;
    assign branch_out = |discrepancy_in && (k <= 0);


    always @(*) begin
        if (start) begin
            gamma_next = gamma_init;
            k_next = k_init;
        end
        else if (pe_cnt) begin
            gamma_next = branch_out ? discrepancy_in : gamma; 
            k_next = branch_out ? -k : k - 1;
        end
        else begin
            gamma_next = gamma;
            k_next = k;
        end
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
        end
        else begin
            state       <= state_next;
            gamma       <= gamma_next;
            k           <= k_next;
        end
    end
endmodule