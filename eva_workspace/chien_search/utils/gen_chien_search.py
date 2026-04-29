import sys
import math

parallel_num = int(sys.argv[1])
q = int(sys.argv[2])
n = int(sys.argv[3])
t_max = int(sys.argv[4])

cycle_num = (n + 1) // parallel_num
cnt_bits = (cycle_num - 1).bit_length()

# print(f"parallel_num={parallel_num}, q={q}, n={n}, t_max={t_max}")
# print(f"cycle_num={cycle_num}, cnt_bits={cnt_bits}")

content = f"""module chien_search(
    input               clk,
    input               rst,
    input               ready,
    input [{q-1}:0]         sigma[{t_max}:0],
    output reg [{n-1}:0]   cdata,
    output              done
);

    localparam S_IDLE = 2'd0;
    localparam S_PROC = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]   state, state_next;
    reg {f"[{cnt_bits-1}:0]" if cnt_bits > 1 else ""}        cnt, cnt_next;
    reg [{n-1}:0]  cdata_next;
    reg [{parallel_num-1}:0]  zeros;
    reg [{q-1}:0]   sigma_rec[{t_max}:0], sigma_rec_next[{t_max}:0];

    wire [{q-1}:0]  sigma_rot[{t_max}:0];
    wire [{q-1}:0]  sigma_V[{parallel_num-1}:0];

    integer i;

    assign done = (state == S_DONE) ? 1 : 0;

    chien_rotate cr0(
        .sigma(sigma_rec),
        .sigma_rot(sigma_rot)
    );
    
    sigmaV sv0(
        .sigma(sigma_rec),
        .y(sigma_V)
    );

    always @(*) begin
        for (i=0;i<{parallel_num};i=i+1) begin
            zeros[i] = (state == S_PROC) ? ~(|sigma_V[{parallel_num-1}-i]) : 0;
        end

        if (state == S_PROC) begin"""

for i in range(cycle_num):
    if i == 0:
        content += f"\n            cdata_next[{(cycle_num-1)*parallel_num}+:{parallel_num-1}] = (cnt == 0) ? zeros[0+:{parallel_num-1}] : cdata[{(cycle_num-1)*parallel_num}+:{parallel_num-1}];"
    else:
        content += f"\n            cdata_next[{(cycle_num-1-i)*parallel_num}+:{parallel_num}] = (cnt == {i}) ? zeros : cdata[{(cycle_num-1-i)*parallel_num}+:{parallel_num}];"

content += f"""
        end
        else cdata_next = 0;
    end

    always @(*) begin
        for (i=0;i<={t_max};i=i+1) begin
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
            S_PROC:     state_next = (cnt == {cycle_num-1}) ? S_DONE : S_PROC;
            S_DONE:     state_next = S_IDLE;
            default:    state_next = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= S_IDLE;
            cnt     <= 0;
            cdata   <= 0;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            state   <= state_next;
            cnt     <= cnt_next;
            cdata   <= cdata_next;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule"""

f = open("chien_search.sv", "w")
f.write(content)
f.close()

print("Generated chien_search.sv")