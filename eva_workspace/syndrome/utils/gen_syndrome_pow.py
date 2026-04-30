import sys

#############################
# GF(2^q) arithmetic
#############################

def gf_mul(a: int, b: int, q: int, prim_poly: int) -> int:
    """Multiply a and b in GF(2^q) with given primitive polynomial."""
    res = 0
    for _ in range(2 * q):
        if b & 1:
            res ^= a
        b >>= 1
        if not b:
            break
        a <<= 1
        if a & (1 << q):
            a ^= prim_poly
    return res & ((1 << q) - 1)


def square_pow_matrix(q: int, prim_poly: int, power: int):
    """
    Return q×q matrix M such that y = x^(2^power) in GF(2^q)
    corresponds to y_bits = M * x_bits over GF(2).
    """
    M = [[0] * q for _ in range(q)]

    for k in range(q):
        x = 1 << k
        y = x

        for _ in range(power):
            y = gf_mul(y, y, q, prim_poly)

        for r in range(q):
            if (y >> r) & 1:
                M[r][k] = 1

    return M


def gen_assign_direct(dst: str, src: str, q: int):
    lines = []

    for r in range(q):
        lines.append(f"        {dst}[{r}] = {src}[{r}];")

    lines.append("")
    return lines


def gen_assign_square_pow(dst: str, src: str, q: int, prim_poly: int, power: int):
    lines = []
    M = square_pow_matrix(q, prim_poly, power)

    for r in range(q):
        terms = [f"{src}[{k}]" for k in range(q) if M[r][k] == 1]
        expr = " ^ ".join(terms) if terms else "1'b0"
        lines.append(f"        {dst}[{r}] = {expr};")

    lines.append("")
    return lines


def decompose_even_syndrome(k: int):
    """
    k is syndrome number, e.g. k = 4 means syndrome 4.
    Return odd_base, power such that:

        S_k = S_odd_base^(2^power)

    Example:
        k = 2  -> odd_base = 1, power = 1
        k = 4  -> odd_base = 1, power = 2
        k = 6  -> odd_base = 3, power = 1
        k = 8  -> odd_base = 1, power = 3
        k = 10 -> odd_base = 5, power = 1
    """
    power = 0

    while k % 2 == 0:
        k //= 2
        power += 1

    return k, power


def gen_syndrome_pow(q: int, t_min: int, prim_poly: int):
    lines = []

    for j in range(2 * t_min):
        syndrome_idx = j + 1

        if syndrome_idx % 2 == 1:
            # S[2i] = syndrome 2i+1 = syn[i]
            syn_idx = (syndrome_idx - 1) // 2
            lines += gen_assign_direct(f"S[{j}]", f"syn[{syn_idx}]", q)
        else:
            # syndrome_idx = odd_base * 2^power
            # S_syndrome_idx = S_odd_base^(2^power)
            odd_base, power = decompose_even_syndrome(syndrome_idx)
            syn_idx = (odd_base - 1) // 2

            lines += gen_assign_square_pow(
                f"S[{j}]",
                f"syn[{syn_idx}]",
                q,
                prim_poly,
                power
            )

    return lines


if __name__ == "__main__":
    q = int(sys.argv[1])
    t_min = int(sys.argv[2])
    prim_poly = int(sys.argv[3], 0)

    out_fname = "syndrome_pow.sv"
    f = open(out_fname, "w")

    # module header
    f.write(f"module syndrome_pow(\n")
    f.write(f"    input  [{q-1}:0]        syn[{t_min-1}:0],\n")
    f.write(f"    output reg [{q-1}:0]    S[{2*t_min-1}:0]\n")
    f.write(");\n\n")

    f.write("    always @(*) begin\n")

    for ln in gen_syndrome_pow(q, t_min, prim_poly):
        f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule")

    f.close()

    print(f"Generated {out_fname}")