import sys
import math

q = int(sys.argv[1])
n = int(sys.argv[2])
t_max = int(sys.argv[3])
parallel_num = int(sys.argv[4])

cycle_num = math.ceil(n / parallel_num)
cnt_bits = (cycle_num - 1).bit_length()
degree_bits = t_max.bit_length()

# print(f"parallel_num={parallel_num}, q={q}, n={n}, t_max={t_max}")
# print(f"cycle_num={cycle_num}, cnt_bits={cnt_bits}")

content = f"""module chien_search(
    input           clk,
    input           rst,
    input [{q-1}:0]     sigma[{t_max}:0],
    input           sigma_valid,
    output          ready,
    output [{n-1}:0]   cdata,
    output          cdone,
    output          cfail
);\n"""

if cycle_num > 1:
    content += f"""
    reg {f"[{cnt_bits-1}:0]" if cnt_bits > 1 else "     "}   cnt, cnt_next;
    reg [{q-1}:0]   sigma_rec[{t_max}:0], sigma_rec_next[{t_max}:0];
    reg [{parallel_num-1}:0]  zeros, zeros_next;
    reg [{degree_bits-1}:0]   degree, degree_next;

    wire [{q-1}:0]  sigma_now1[{t_max}:0], sigma_now2[{t_max}:0];
    wire [{q-1}:0]  sigma_rot[{t_max}:0];
    wire [{q-1}:0]  sigma_V[{parallel_num-1}:0];
    wire        start;

    integer i;

    genvar gi;

    assign ready = (cnt == 0) ? 1 : 0;
    assign start = (cnt == 1) ? 1 : 0;

    generate
        for (gi=0;gi<={t_max};gi=gi+1) begin
            assign sigma_now1[gi] = (cnt == 0) ? (sigma_valid ? sigma[gi] : 0) : sigma_rec[gi];
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

    chien_checker cc0(
        .clk(clk),
        .rst(rst),
        .start(start),
        .degree(degree),
        .zeros(zeros),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail)
    );

    always @(*) begin
        if (sigma_valid) begin
            if (sigma[{t_max}] != 0) degree_next = {t_max};"""
    
    for i in range(t_max-1, 0, -1):
        content += f"\n            else if (sigma[{i}] != 0) degree_next = {i};"

    content += f"""
            else degree_next = 0;
        end
        else if (cdone) degree_next = 0;
        else degree_next = degree;
    end

    always @(*) begin
        for (i=0;i<{parallel_num-1};i=i+1) begin
            zeros_next[i] = (cnt != 0 || sigma_valid) ? ~(|sigma_V[{parallel_num-1}-i]) : 0;
        end
        zeros_next[{parallel_num-1}] = (cnt != 0) ? ~(|sigma_V[0]) : 0;
    end

    always @(*) begin
        for (i=0;i<={t_max};i=i+1) begin
            if (cnt == 0) sigma_rec_next[i] = sigma_valid ? sigma_rot[i] : 0;"""

    if cycle_num > 2:
        content += f"\n            else if (cnt != {cycle_num-1}) sigma_rec_next[i] = sigma_rot[i];"

    content += f"""
            else sigma_rec_next[i] = 0;
        end
    end

    always @(*) begin
        if (cnt != 0 || sigma_valid) cnt_next = cnt + 1;
        else cnt_next = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            zeros   <= 0;
            degree  <= 0;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= 0;
            end
        end
        else begin
            cnt     <= cnt_next;
            zeros   <= zeros_next;
            degree  <= degree_next;
            for (i=0;i<={t_max};i=i+1) begin
                sigma_rec[i]    <= sigma_rec_next[i];
            end
        end
    end

endmodule"""

else:   # cycle_num == 1
    content += f"""
    reg [{parallel_num-1}:0]  zeros, zeros_next;
    reg [{degree_bits-1}:0]   degree, degree_next;
    reg         start, start_next;

    wire [{q-1}:0]  sigma_now[{t_max}:0];
    wire [{q-1}:0]  sigma_V[{parallel_num-1}:0];

    integer i;

    genvar gi;

    assign ready = 1;

    generate
        for (gi=0;gi<={t_max};gi=gi+1) begin
            assign sigma_now[gi] = sigma_valid ? sigma[gi] : 0;
        end
    endgenerate
    
    sigmaV sv0(
        .sigma(sigma_now),
        .y(sigma_V)
    );

    chien_checker cc0(
        .clk(clk),
        .rst(rst),
        .start(start),
        .degree(degree),
        .zeros(zeros),
        .cdata(cdata),
        .cdone(cdone),
        .cfail(cfail)
    );

    always @(*) begin
        if (sigma_valid) start_next = 1;
        else start_next = 0;
    end

    always @(*) begin
        if (sigma_valid) begin
            if (sigma[{t_max}] != 0) degree_next = {t_max};"""
    
    for i in range(t_max-1, 0, -1):
        content += f"\n            else if (sigma[{i}] != 0) degree_next = {i};"

    content += f"""
            else degree_next = 0;
        end
        else if (cdone) degree_next = 0;
        else degree_next = degree;
    end

    always @(*) begin
        zeros_next[0] = sigma_valid ? ~(|sigma_V[0]) : 0;
        for (i=1;i<{parallel_num};i=i+1) begin
            zeros_next[i] = sigma_valid ? ~(|sigma_V[{parallel_num}-i]) : 0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start   <= 0;
            zeros   <= 0;
            degree  <= 0;
        end
        else begin
            start   <= start_next;
            zeros   <= zeros_next;
            degree  <= degree_next;
        end
    end

endmodule"""

f = open("chien_search.sv", "w")
f.write(content)
f.close()

print("Generated chien_search.sv")