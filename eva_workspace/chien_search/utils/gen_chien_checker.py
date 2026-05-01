import sys
import math

def gen_popcount_tree_array_no_last_array(bitwidth, parallel_num, out_name):
    in_name="zeros"

    decl_lines = []
    always_lines = []

    current = []
    for i in range(parallel_num):
        current.append((f"{in_name}[{i}]", 1))

    group_size = 1

    always_lines.append(f"    always @(*) begin")

    while len(current) > 1:
        next_level = []
        group_size *= 2

        num_pairs = len(current) // 2
        is_last_level = (num_pairs == 1 and len(current) == 2)

        out_width = min(bitwidth, math.ceil(math.log2(group_size + 1)))
        array_name = f"sum{group_size}"

        if is_last_level:
            decl_lines.append(f"    reg [{out_width-1}:0]   {out_name};")
        else:
            decl_lines.append(f"    reg [{out_width-1}:0]   {array_name} [{num_pairs-1}:0];")

        pair_idx = 0

        for idx in range(0, len(current), 2):
            a_name, a_width = current[idx]

            if idx + 1 >= len(current):
                next_level.append((a_name, a_width))
                continue

            b_name, b_width = current[idx + 1]

            if is_last_level:
                always_lines.append(f"        {out_name} = {a_name} + {b_name};")
                next_level.append((out_name, out_width))
            else:
                always_lines.append(f"        {array_name}[{pair_idx}] = {a_name} + {b_name};")
                next_level.append((f"{array_name}[{pair_idx}]", out_width))

            pair_idx += 1

        if len(current) > 2:
            always_lines.append("")

        current = next_level

    always_lines.append(f"    end\n")

    return "\n".join(decl_lines), "\n".join(always_lines)


if __name__ == "__main__":
    n = int(sys.argv[1])
    t_max = int(sys.argv[2])
    parallel_num = int(sys.argv[3])

    cycle_num = math.ceil(n / parallel_num)
    cnt_bits = (cycle_num - 1).bit_length()
    degree_bits = t_max.bit_length()

    out_name = f"pop_cnt{parallel_num}"

    content = f"""module chien_checker(
    input               clk,
    input               rst,
    input               start,
    input [{degree_bits-1}:0]         degree,
    input [{parallel_num-1}:0]        zeros,
    output reg [{n-1}:0]   cdata,
    output reg          cdone,
    output              cfail
);\n"""

    if cycle_num > 1:
        content += f"\n    reg {f"[{cnt_bits-1}:0]" if cnt_bits > 1 else "     "}   cnt, cnt_next;"
    
    content +=f"""
    reg [{degree_bits-1}:0]   degree_rec, degree_rec_next;
    reg [{degree_bits-1}:0]   root_num, root_num_next;
    reg [{n-1}:0]  cdata_next;
    reg         cdone_next;\n\n"""

    decl_content, always_content = gen_popcount_tree_array_no_last_array(degree_bits, parallel_num, out_name)

    content += decl_content

    content += f"\n\n    integer i;"

    content += f"\n\n    assign cfail = (cdone && root_num != degree_rec) ? 1 : 0;\n\n"

    content += always_content

    if cycle_num == 1:
        content += f"""
    always @(*) begin
        if (start) begin
            degree_rec_next = degree;
            root_num_next = {out_name};
        end
        else begin
            degree_rec_next = 0;
            root_num_next = 0;
        end
    end\n"""
    else:
        content += f"""
    always @(*) begin
        if (start) begin
            degree_rec_next = degree;
            root_num_next = {out_name};
        end
        else if (cnt != 0) begin
            degree_rec_next = degree_rec;
            root_num_next = root_num + {out_name};
        end
        else begin
            degree_rec_next = 0;
            root_num_next = 0;
        end
    end\n"""

    if cycle_num == 1:
        content += f"""
    always @(*) begin
        cdata_next = start ? zeros : 0;
        cdone_next = start ? 1 : 0;
    end\n"""
    else:
        content += f"""
    always @(*) begin
        if (cnt != 0 || start) begin"""

        for i in range(cycle_num):
            if i == 0:
                content += f"\n            cdata_next[{(cycle_num-1)*parallel_num}+:{parallel_num-1}] = (cnt == 0) ? zeros[0+:{parallel_num-1}] : cdata[{(cycle_num-1)*parallel_num}+:{parallel_num-1}];"
            else:
                content += f"\n            cdata_next[{(cycle_num-1-i)*parallel_num}+:{parallel_num}] = (cnt == {i}) ? zeros : cdata[{(cycle_num-1-i)*parallel_num}+:{parallel_num}];"

        content += f"""
        end
        else cdata_next = 0;

        cdone_next = (cnt == {cycle_num-1}) ? 1 : 0;
    end
    
    always @(*) begin
        if (cnt != 0 || start) cnt_next = cnt + 1;
        else cnt_next = 0;
    end\n"""

    content += f"""
    always @(posedge clk or posedge rst) begin
        if (rst) begin"""
    
    if cycle_num > 1:
        content += "\n            cnt         <= 0;"

    content += f"""
            degree_rec  <= 0;
            root_num    <= 0;
            cdata       <= 0;
            cdone       <= 0;
        end
        else begin"""
    
    if cycle_num > 1:
        content += "\n            cnt         <= cnt_next;"

    content += f"""
            degree_rec  <= degree_rec_next;
            root_num    <= root_num_next;
            cdata       <= cdata_next;
            cdone       <= cdone_next;
        end
    end

endmodule"""

    f = open("chien_checker.sv", "w")
    f.write(content)
    f.close()

    print("Generated chien_checker.sv")