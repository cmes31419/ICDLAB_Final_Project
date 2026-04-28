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

def is_power_of_two(i: int) -> bool:
    return i > 0 and (i & (i - 1)) == 0


#############################
# Generate minimal polynomials
#############################

def poly_mul_gf2q(p, q_poly, q, prim_poly):
    r = [0] * (len(p) + len(q_poly) - 1)

    for i in range(len(p)):
        for j in range(len(q_poly)):
            r[i + j] ^= gf_mul(p[i], q_poly[j], q, prim_poly)

    return r

def cyclotomic_coset(e, q):
    n = (1 << q) - 1
    coset = []
    x = e % n

    while x not in coset:
        coset.append(x)
        x = (2 * x) % n

    return coset

def minimal_polynomial(e, q, prim_poly):
    tab = build_pow_table(q, prim_poly)
    coset = cyclotomic_coset(e, q)

    poly = [1]

    for power in coset:
        root = pow_alpha(power, tab)

        # multiply by (x + root)
        poly = poly_mul_gf2q(poly, [root, 1], q, prim_poly)

    # minimal polynomial should have GF(2) coefficients
    poly = [c & 1 for c in poly]

    return poly, coset

def poly_to_bin(poly):
    value = 0

    for i, c in enumerate(poly):
        if c:
            value |= (1 << i)

    return value


#############################
# E, B decomposition
#############################

def decompose_E_B_improved(q: int, n: int, t: int, poly_list: int):
    prim_pow_tab = build_pow_table(q, poly_list[0])
    E_list, B_list = [], []

    for i in range(1, t+1, 2):
        pow_tab = build_pow_table(q, poly_list[i//2])

        E = [[0] * q for _ in range(t + 1)]
        B = [[0] * n for _ in range(q)]

        for j in range(q):
            B[j][j] = 1

        pow = 0
        while i*(2**pow) <= t:
            for j in range(q):
                E[pow][j] = pow_alpha(i*(2**pow) * j, prim_pow_tab)
            pow += 1

        order = len(pow_tab)
        for j in range(q, n):
            aj = pow_tab[j % order]
            for k in range(q):
                B[k][j] = (aj >> k) & 1

        E_list.append(E[:pow])
        B_list.append(B)

    return E_list, B_list


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
# sigmaE：算 y[0][j] = Σ_i sigma_i * E(i,j)
# 也就是 (sigma^T * E) 的每一個 column
#############################

def gen_sigmaE_case_body(E, q: int, idx: int, prim_poly: int):
    lines = []
    n = len(E[0])       # column 數

    for j in range(n):
        # 有效 bits 0..(q-1)
        for r in range(q):
            terms = []
            # 對所有 sigma_i 累積貢獻
            for i in range(len(E)):
                c = E[i][j]
                if c == 0:
                    continue
                M = mult_matrix_for_const(c, q, prim_poly)
                for k in range(q):
                    if M[r][k] == 1:
                        terms.append(f"sigma[{(idx*2+1)*(2**i)}][{k}]")

            expr = " ^ ".join(terms) if terms else "1'b0"
            lines.append(f"        y[{idx}][{j}][{r}] = {expr};")

        lines.append("")  # 空行分隔每個 j

    return lines


#############################
# sigmaEB：算 y = (sigmaE row0) * B
# 這裡把 sigmaE[0][k] 當作 base vector 的第 k 個元素
#############################

def gen_sigmaEB_case_body(B, q: int, idx: int):
    lines = []
    n = len(B)
    m = len(B[0])

    for j in range(m):
        terms = []
        for k in range(n):
            if B[k][j] == 1:
                terms.append(f"sigmaE[{idx}][{k}]")
        if terms:
            expr = " ^ ".join(terms)
        else:
            expr = "1'b0"
        lines.append(f"        tmp[{idx}][{j}] = {expr};")

    lines.append("")  # 空行分隔每個 j

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
    poly_list = [prim_poly]
    mode = int(sys.argv[7])     # 1: contiguous (default), 2: interleave

    for i in range(3, t_max+1, 2):
        mini_poly, _ = minimal_polynomial(i, q, prim_poly)
        mini_int = poly_to_bin(mini_poly)
        poly_list.append(mini_int)

    print(f"poly_list: {[bin(p) for p in poly_list]}")

    E6_list, B6_list = decompose_E_B_improved(q, n, t_max, poly_list)

    if mode != 2:   # mode 1: contiguous (default)
        print("Using contiguous mode for indices.")
        idx6_e = [i for i in range(min(q, parallel_num))]
        idx6_b = [i for i in range(parallel_num)]
    else:   # mode 2: interleave
        print("Using interleave mode for indices.")
        sample = 8 * n // parallel_num
        idx6_e = [i for i in range(min(q, parallel_num))]
        _, idx6_b = build_indices(q, n, sample, parallel_num)

    print(idx6_e)
    print(idx6_b)

    # for i in range(len(E6_list)):
    #     E = E6_list[i]
    #     B = B6_list[i]
    #     # V = matrix multiplication of E and B over GF(2^q)
    #     # E: row_num x q
    #     # B: q x n, binary
    #     row_num = len(E)
    #     col_num = len(B[0])

    #     V = [[0] * col_num for _ in range(row_num)]

    #     for r in range(row_num):
    #         for c in range(col_num):
    #             acc = 0
    #             for k in range(len(B)):
    #                 if B[k][c]:
    #                     acc ^= E[r][k]
    #             V[r][c] = acc

    #     print()
    #     for r in range(row_num):
    #         print(V[r])

    f = open(out_fname, "w")

    #========================
    # module sigmaV
    #========================
    f.write("module sigmaV(\n")
    f.write(f"    input  [{q-1}:0]        sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]    y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write(f"    wire [{q-1}:0]  sigmaE[{t_max//2}:0][{parallel_num-1}:0];\n\n")

    f.write(f"    sigmaE se0(\n")
    f.write(f"        .sigma(sigma),\n")
    f.write(f"        .y(sigmaE)\n")
    f.write(f"    );\n\n")

    f.write(f"    sigmaEB seb0(\n")
    f.write(f"        .sigmaE(sigmaE),\n")
    f.write(f"        .sigma0(sigma[0]),\n")
    f.write(f"        .y(y)\n")
    f.write(f"    );\n\n")

    f.write("endmodule\n\n")


    #========================
    # module sigmaE
    #========================
    f.write("module sigmaE(\n")
    f.write(f"    input  [{q-1}:0]      sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]  y[{t_max//2}:0][{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write("    always @* begin\n")

    for i in range(len(E6_list)):
        E6 = [[row[c] for c in idx6_e] for row in E6_list[i]]

        for ln in gen_sigmaE_case_body(E6, q, i, poly_list[0]):
            f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule\n\n")

    #========================
    # module sigmaEB
    #========================
    f.write("module sigmaEB(\n")
    f.write(f"    input  [{q-1}:0]      sigmaE[{t_max//2}:0][{parallel_num-1}:0],\n")
    f.write(f"    input  [{q-1}:0]      sigma0,\n")
    f.write(f"    output reg [{q-1}:0]  y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write(f"    reg [{q-1}:0]    tmp[{t_max//2}:0][{parallel_num-1}:0];\n\n")

    f.write("    always @* begin\n")

    for i in range(len(B6_list)):
        B6 = [[B6_list[i][r][c] for c in idx6_b] for r in idx6_e]

        for ln in gen_sigmaEB_case_body(B6, q, i):
            f.write(ln + "\n")

    for i in range(parallel_num):
        terms = ["sigma0"]
        for j in range(t_max//2):
            terms.append(f"tmp[{j}][{i}]")
        expr = " ^ ".join(terms)
        f.write(f"        y[{i}] = {expr};\n")

    f.write("    end\n\n")
    f.write("endmodule\n")

    f.close()

    with open(out_fname, "r") as rf:
        caret_count = rf.read().count("^")

    print(f"Number of XOR in {out_fname}: {caret_count}")
    print(f"Generated {out_fname}")
