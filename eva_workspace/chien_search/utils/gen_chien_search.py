import sys
import math

q = int(sys.argv[1])
n = int(sys.argv[2])
t_max = int(sys.argv[3])
parallel_num = int(sys.argv[4])

cycle_num = math.ceil(n / parallel_num)
cnt_bits = (cycle_num - 1).bit_length()

# print(f"parallel_num={parallel_num}, q={q}, n={n}, t_max={t_max}")
# print(f"cycle_num={cycle_num}, cnt_bits={cnt_bits}")

if cycle_num > 1:
    content = f"""module chien_search(
    input               clk,
    input               rst,
    input               ready,
    input [{q-1}:0]         sigma[{t_max}:0],
    output reg [{n-1}:0]   cdata,
    output reg          done
);

    reg {f"[{cnt_bits-1}:0]" if cnt_bits > 1 else "     "}   cnt, cnt_next;
    reg [{q-1}:0]   sigma_rec[{t_max}:0], sigma_rec_next[{t_max}:0];
    reg [{n-1}:0]  cdata_next;
    reg         done_next;
    reg [{parallel_num-1}:0]  zeros;

    wire [{q-1}:0]  sigma_now1[{t_max}:0], sigma_now2[{t_max}:0];
    wire [{q-1}:0]  sigma_rot[{t_max}:0];
    wire [{q-1}:0]  sigma_V[{parallel_num-1}:0];

    integer i;

    genvar gi;

    generate
        for (gi=0;gi<={t_max};gi=gi+1) begin
            assign sigma_now1[gi] = (cnt == 0) ? (ready ? sigma[gi] : 0) : sigma_rec[gi];
            assign sigma_now2[gi] = (cnt == {cycle_num-1}) ? 0 : sigma_now1[gi];
        end
    endgenerate
    
    sigmaV sv0(
        .sigma(sigma_now1),
        .y(sigma_V)
    );

    chien_rotate cr0(
        .sigma(sigma_now2),
        .sigma_rot(sigma_rot)
    );

    always @(*) begin
        for (i=0;i<{parallel_num};i=i+1) begin
            zeros[i] = (cnt != 0 || ready) ? ~(|sigma_V[{parallel_num-1}-i]) : 0;
        end

        if (cnt != 0 || ready) begin"""

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
            if (cnt == 0) sigma_rec_next[i] = ready ? sigma_rot[i] : 0;"""

    if cycle_num > 2:
        content += f"\n            else if (cnt != {cycle_num-1}) sigma_rec_next[i] = sigma_rot[i];"

    content += f"""
            else sigma_rec_next[i] = 0;
        end
    end

    always @(*) begin
        if (cnt == {cycle_num-1}) done_next = 1;
        else done_next = 0;
    end

    always @(*) begin
        if (cnt != 0 || ready) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            cdata   <= 0;
            done    <= 0;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            cnt     <= cnt_next;
            cdata   <= cdata_next;
            done    <= done_next;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule"""

else:   # cycle_num == 1
    content = f"""module chien_search(
    input               clk,
    input               rst,
    input               ready,
    input [{q-1}:0]         sigma[{t_max}:0],
    output reg [{n-1}:0]   cdata,
    output reg          done
);

    reg [{n-1}:0]  cdata_next;
    reg         done_next;
    reg [{parallel_num-1}:0]  zeros;
    
    wire [{q-1}:0]  sigma_now[{t_max}:0];
    wire [{q-1}:0]  sigma_rot[{t_max}:0];
    wire [{q-1}:0]  sigma_V[{parallel_num-1}:0];

    integer i;

    genvar gi;

    generate
        for (gi=0;gi<={t_max};gi=gi+1) begin
            assign sigma_now[gi] = ready ? sigma[gi] : 0;
        end
    endgenerate
    
    sigmaV sv0(
        .sigma(sigma_now),
        .y(sigma_V)
    );

    always @(*) begin
        zeros[0] = ready ? ~(|sigma_V[0]) : 0;
        for (i=1;i<{parallel_num};i=i+1) begin
            zeros[i] = ready ? ~(|sigma_V[{parallel_num}-i]) : 0;
        end

        cdata_next = zeros;
    end

    always @(*) begin
        if (ready) done_next = 1;
        else done_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cdata   <= 0;
            done    <= 0;
        end
        else begin
            cdata   <= cdata_next;
            done    <= done_next;
        end
    end

endmodule"""

f = open("chien_search.sv", "w")
f.write(content)
f.close()

print("Generated chien_search.sv")