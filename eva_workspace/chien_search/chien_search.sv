module chien_search(
    input               clk,
    input               rst,
    input               ready,
    input [5:0]         sigma[6:0],
    output reg [31:0]   zeros
);

    localparam S_IDLE = 2'd0;
    localparam S_PROC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]   state, state_next;
    reg         cnt, cnt_next;
    reg [31:0]  zeros_next;
    reg [5:0]   sigma_rec[6:0], sigma_rec_next[6:0];

    wire [5:0]  sigma_rot[6:0];
    wire [5:0]  sigma_V[31:0];

    integer i;

    chien_rotate cr0(
        .sigma(sigma_rec),
        .sigma_rot(sigma_rot)
    );
    
    sigmaV sv0(
        .sigma(sigma_rec),
        .y(sigma_V)
    );

    always @(*) begin
        for (i=0;i<32;i=i+1) begin
            zeros_next[i] = (state == S_PROC) ? ~(|sigma_V[i]) : 0;
        end
    end

    always @(*) begin
        for (i=0;i<=6;i=i+1) begin
            if (state == S_IDLE && ready) sigma_rec_next[i] = sigma[i];
            else if (state == S_PROC) sigma_rec_next[i] = sigma_rot[i];
            else sigma_rec_next[i] = 0;
        end
    end

    always @(*) begin
        if (state == S_PROC) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(*) begin
        case (state)
            S_IDLE:     state_next = ready ? S_PROC : S_IDLE;
            S_PROC:     state_next = (cnt == 1) ? S_DONE : S_PROC;
            S_DONE:     state_next = S_IDLE;
            default:    state_next = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= S_IDLE;
            cnt     <= 0;
            zeros    <= 0;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            state   <= state_next;
            cnt     <= cnt_next;
            zeros    <= zeros_next;
            for (i=0;i<=6;i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule