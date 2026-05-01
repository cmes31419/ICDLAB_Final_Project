import sys


def poly_degree(poly: int) -> int:
    return poly.bit_length() - 1


def xor_join(terms):
    if len(terms) == 0:
        return "1'b0"
    if len(terms) == 1:
        return terms[0]
    return " ^ ".join(terms)


def gen_raw_coeff_terms(q: int):
    raw_terms = []

    for k in range(2 * q - 1):
        terms = []
        for i in range(q):
            j = k - i
            if 0 <= j < q:
                terms.append(f"(in1[{i}] & in2[{j}])")
        raw_terms.append(terms)

    return raw_terms


def reduce_monomial_power(power: int, q: int, prim_poly: int):
    terms = {power}

    changed = True
    while changed:
        changed = False
        new_terms = set()

        for p in terms:
            if p < q:
                if p in new_terms:
                    new_terms.remove(p)
                else:
                    new_terms.add(p)
            else:
                changed = True
                shift = p - q

                # prim_poly = x^q + lower terms
                # x^q = lower terms over GF(2)
                for bit in range(q):
                    if (prim_poly >> bit) & 1:
                        new_p = bit + shift

                        if new_p in new_terms:
                            new_terms.remove(new_p)
                        else:
                            new_terms.add(new_p)

        terms = new_terms

    return terms


def build_reduction_map(q: int, prim_poly: int):
    red_map = []

    for k in range(2 * q - 1):
        reduced_powers = reduce_monomial_power(k, q, prim_poly)
        red_map.append(sorted(reduced_powers))

    return red_map


def gen_gf_mul_module(q: int):
    content = f"""module gf_mul(
    input  [{q-1}:0] in1,
    input  [{q-1}:0] in2,
    output [{q-1}:0] prod
);

    wire [{2*q-2}:0] raw_prod;

    binary_mul u_binary_mul (
        .in1(in1),
        .in2(in2),
        .raw_prod(raw_prod)
    );

    reduction_table u_reduction_table (
        .in1(raw_prod),
        .prod(prod)
    );

endmodule

"""

    return content


def gen_bin_mul_module(q: int):
    out_w = 2 * q - 1
    raw_terms = gen_raw_coeff_terms(q)

    content = f"""module binary_mul(
    input  [{q-1}:0] in1,
    input  [{q-1}:0] in2,
    output reg [{2*q-2}:0] raw_prod
);

    always @(*) begin
"""

    # Print from MSB to LSB, similar to your example.
    for k in range(out_w - 1, -1, -1):
        expr = xor_join(raw_terms[k])
        space = " " if k < 10 else ""
        content += f"        raw_prod[{k}]{space} = {expr};\n"

    content += f"""    end

endmodule

"""

    return content


def gen_reduction_table_module(q: int, prim_poly: int):
    out_w = 2 * q - 1
    red_map = build_reduction_map(q, prim_poly)

    final_terms = [[] for _ in range(q)]

    for raw_idx in range(out_w):
        for out_idx in red_map[raw_idx]:
            final_terms[out_idx].append(f"in1[{raw_idx}]")

    content = f"""module reduction_table(
    input  [{2*q-2}:0] in1,
    output reg [{q-1}:0] prod
);

    always @(*) begin
"""

    for i in range(q):
        expr = xor_join(final_terms[i])
        space = " " if i < 10 else ""
        content += f"        prod[{i}]{space} = {expr};\n"

    content += f"""    end

endmodule

"""

    return content


def gen_all_modules(q: int, prim_poly: int):
    content = ""

    content += gen_gf_mul_module(q)
    content += gen_bin_mul_module(q)
    content += gen_reduction_table_module(q, prim_poly)

    return content


def main():
    q = int(sys.argv[1])
    prim_poly = int(sys.argv[2], 0)

    if len(sys.argv) >= 4:
        outfname = sys.argv[3]
    else:
        outfname = "gf_mul.sv"

    if poly_degree(prim_poly) != q:
        raise ValueError(
            f"Error: prim_poly degree should be q={q}, "
            f"but got degree {poly_degree(prim_poly)}"
        )

    content = gen_all_modules(q, prim_poly)

    with open(outfname, "w") as f:
        f.write(content)

    print(f"Generated {outfname}")


if __name__ == "__main__":
    main()