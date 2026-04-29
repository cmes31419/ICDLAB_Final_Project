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


def build_pow_table(q: int, prim_poly: int):
    """Build table of alpha^0 .. alpha^(2^q-2). alpha is represented by 0b10."""
    order = (1 << q) - 1
    alpha = 2
    tab = [1] * order
    for i in range(1, order):
        tab[i] = gf_mul(tab[i - 1], alpha, q, prim_poly)
    return tab


def pow_alpha(exp: int, tab):
    """Return alpha^exp using pow table (exp mod order)."""
    return tab[exp % len(tab)]


def mult_matrix_for_const(c: int, q: int, prim_poly: int):
    """
    Return q×q matrix M such that y = c * x in GF(2^q)
    corresponds to y_bits = M * x_bits (over GF(2)).
    M[row][col] = 1 if output_bit[row] depends on input_bit[col].
    """
    M = [[0] * q for _ in range(q)]
    for k in range(q):
        out_elem = gf_mul(c, 1 << k, q, prim_poly)
        for r in range(q):
            if (out_elem >> r) & 1:
                M[r][k] = 1
    return M


def gen_case_branch(q: int, t: int, prim_poly: int, P: int):
    lines = []

    pow_tab = build_pow_table(q, prim_poly)

    for i in range(t+1):
        K = i * P
        c = pow_alpha(K, pow_tab)  # constant = alpha^K
        M = mult_matrix_for_const(c, q, prim_poly)

        for r in range(q):
            terms = [f"sigma[{i}][{k}]" for k in range(q) if M[r][k] == 1]
            if terms:
                expr = " ^ ".join(terms)
            else:
                expr = "1'b0"
            lines.append(f"        sigma_rot[{i}][{r}] = {expr};")

        lines.append("") 

    return lines


if __name__ == "__main__":
    parallel_num = int(sys.argv[1])
    q = int(sys.argv[2])
    t_max = int(sys.argv[3])
    prim_poly = int(sys.argv[4], 0)

    out_fname = f"chien_rotate.sv"
    f = open(out_fname, "w")

    # module header
    f.write(f"module chien_rotate(\n")
    f.write(f"    input  [{q-1}:0]        sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]    sigma_rot[{t_max}:0]\n")
    f.write(");\n\n")

    f.write("    always @(*) begin\n")

    for ln in gen_case_branch(q, t_max, prim_poly, parallel_num):
        f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule")

    f.close()

    print(f"Generated {out_fname}")