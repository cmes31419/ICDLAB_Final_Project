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
    order = (1 << q) - 1
    alpha = 2
    tab = [1] * order
    for i in range(1, order):
        tab[i] = gf_mul(tab[i - 1], alpha, q, prim_poly)
    return tab

def pow_alpha(exp: int, tab):
    return tab[exp % len(tab)]


#############################
# linear map for "multiply by const c"
#############################

def mult_matrix_for_const(c: int, q: int, prim_poly: int):
    """
    回傳 q×q 矩陣 M，使得 x (q-bit) -> y = c * x 對應 y = M * x (GF(2)).
    row: output bit, col: input bit
    """
    M = [[0] * q for _ in range(q)]
    for k in range(q):
        out_elem = gf_mul(c, 1 << k, q, prim_poly)
        for r in range(q):
            if (out_elem >> r) & 1:
                M[r][k] = 1
    return M

#############################
# Conventional Chien search
#############################

def gen_chien_case_body(indices, q: int, t_max: int, prim_poly: int):
    """
    Conventional Chien search:
      y[j] = Σ_i sigma_i * α^(i * pos_j)
    """
    lines = []
    pow_tab = build_pow_table(q, prim_poly)

    for jj, pos in enumerate(indices):
        for r in range(q):
            terms = []
            for i in range(t_max + 1):
                c = pow_alpha(i * pos, pow_tab)
                if c == 0:
                    continue

                M = mult_matrix_for_const(c, q, prim_poly)
                for k in range(q):
                    if M[r][k] == 1:
                        terms.append(f"sigma[{i}][{k}]")

            expr = " ^ ".join(terms) if terms else "1'b0"
            lines.append(f"        y[{jj}][{r}] = {expr};")

        lines.append("")

    return lines


def build_indices(q, n_full, sample, n_parallel):
    """
    產生 index 序列：
      [0,1,2,3,4,5,6,7,
       sample+0 ... sample+7,
       2*sample+0 ... 2*sample+7,
       ...]
    直到湊滿 n_parallel 個。
    """
    idx_e = [i for i in range(max(q, 8))]
    idx_b = [i for i in range(8)]
    k = 1
    while k * sample < n_full:
        base = k * sample
        for off in range(8):
            pos = base + off
            if pos < n_full:
                idx_e.append(pos)
                idx_b.append(pos)
        k += 1
        if base >= n_full:
            break
    return idx_e, idx_b


#############################
# Main
#############################

if __name__ == "__main__":
    out_fname = str(sys.argv[1])
    parallel_num = int(sys.argv[2])
    n = int(sys.argv[3])
    q = int(sys.argv[4])
    t_max = int(sys.argv[5])
    prim_poly = int(sys.argv[6], 0)
    mode = int(sys.argv[7])     # 1: contiguous (default), 2: interleave

    print(f"n: {n}, q: {q}, t_max: {t_max}, parallel_num: {parallel_num}")

    if mode != 2:   # mode 1: contiguous (default)
        print("Using contiguous mode for indices.")
        idx6 = [i for i in range(parallel_num)]
    else:   # mode 2: interleave
        print("Using interleave mode for indices.")
        sample = 8 * n // parallel_num
        _, idx6 = build_indices(q, n, sample, parallel_num)

    print(idx6)

    f = open(out_fname, "w")

    #========================
    # module sigmaV
    #========================
    f.write("module sigmaV_conventional(\n")
    f.write(f"    input  [{q-1}:0]        sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]    y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write("    always @* begin\n")

    for ln in gen_chien_case_body(idx6, q, t_max, prim_poly):
        f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule\n")

    f.close()

    with open(out_fname, "r") as rf:
        caret_count = rf.read().count("^")

    print(f"Number of XOR in {out_fname}: {caret_count}")
    print(f"Generated {out_fname}")