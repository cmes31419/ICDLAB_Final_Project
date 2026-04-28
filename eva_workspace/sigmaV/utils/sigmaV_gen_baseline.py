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
# E, B decomposition
#############################

def decompose_E_B(q: int, n: int, t: int, prim_poly: int):
    """
    依論文產生 E, B，使得 Vandermonde V = E·B
    """
    pow_tab = build_pow_table(q, prim_poly)
    E = [[0] * n for _ in range(t + 1)]
    B = [[0] * n for _ in range(n)]

    # B 先設成 I
    for i in range(n):
        B[i][i] = 1

    # 前 q 欄：V_{i,j} = α^{i·j}
    for i in range(t + 1):
        for j in range(min(q, n)):
            E[i][j] = pow_alpha(i * j, pow_tab)

    if n <= q:
        return E, B

    order = len(pow_tab)
    for j in range(q, n):
        aj = pow_tab[j % order]
        for k in range(q):
            B[k][j] = (aj >> k) & 1

        for i in range(t + 1):
            if is_power_of_two(i):
                E[i][j] = 0
            else:
                val = pow_alpha(i * j, pow_tab)
                acc = 0
                for k in range(q):
                    if B[k][j]:
                        acc ^= pow_alpha(i * k, pow_tab)
                E[i][j] = val ^ acc

    return E, B

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

def gen_sigmaE_case_body(E, q: int, prim_poly: int):
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
                        terms.append(f"sigma[{i}][{k}]")

            expr = " ^ ".join(terms) if terms else "1'b0"
            lines.append(f"        y[{j}][{r}] = {expr};")

        lines.append("")  # 空行分隔每個 j

    return lines


#############################
# sigmaEB：算 y = (sigmaE row0) * B
# 這裡把 sigmaE[0][k] 當作 base vector 的第 k 個元素
#############################

def gen_sigmaEB_case_body(B, q: int):
    lines = []
    n = len(B)
    m = len(B[0])

    for j in range(m):
        for r in range(q):
            terms = []
            for k in range(n):
                if B[k][j] == 1:
                    terms.append(f"sigmaE[{k}][{r}]")
            if terms:
                expr = " ^ ".join(terms)
            else:
                expr = "1'b0"
            lines.append(f"        y[{j}][{r}] = {expr};")
            
        lines.append("")  # 空行分隔每個 r
        
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

    E6_full, B6_full = decompose_E_B(q, n, t_max, prim_poly)

    print(f"n: {n}, q: {q}, t_max: {t_max}, parallel_num: {parallel_num}")
    print(f"E6_full: {len(E6_full)} x {len(E6_full[0])}")
    print(f"B6_full: {len(B6_full)} x {len(B6_full[0])}")

    if mode != 2:   # mode 1: contiguous (default)
        print("Using contiguous mode for indices.")
        idx6_e = [i for i in range(parallel_num)]
        idx6_b = [i for i in range(parallel_num)]
    else:   # mode 2: interleave
        print("Using interleave mode for indices.")
        sample = 8 * n // parallel_num
        idx6_e, idx6_b = build_indices(q, n, sample, parallel_num)

    print(idx6_e)
    print(idx6_b)

    # 切 E / B
    E6 = [[row[c] for c in idx6_e] for row in E6_full]
    B6 = [[B6_full[r][c] for c in idx6_b] for r in idx6_e]

    print(f"E6: {len(E6)} x {len(E6[0])}")
    print(f"B6: {len(B6)} x {len(B6[0])}")

    
    f = open(out_fname, "w")

    #========================
    # module sigmaV
    #========================
    f.write("module sigmaV_baseline(\n")
    f.write(f"    input  [{q-1}:0]        sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]    y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write(f"    wire [{q-1}:0]  sigmaE[{parallel_num-1}:0];\n\n")

    f.write(f"    sigmaE_baseline se0(\n")
    f.write(f"        .sigma(sigma),\n")
    f.write(f"        .y(sigmaE)\n")
    f.write(f"    );\n\n")

    f.write(f"    sigmaEB_baseline seb0(\n")
    f.write(f"        .sigmaE(sigmaE),\n")
    f.write(f"        .y(y)\n")
    f.write(f"    );\n\n")

    f.write("endmodule\n\n")


    #========================
    # module sigmaE
    #========================
    f.write("module sigmaE_baseline(\n")
    f.write(f"    input  [{q-1}:0]      sigma[{t_max}:0],\n")
    f.write(f"    output reg [{q-1}:0]  y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write("    always @* begin\n")

    for ln in gen_sigmaE_case_body(E6, q, prim_poly):
        f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule\n\n")

    #========================
    # module sigmaEB
    #========================
    f.write("module sigmaEB_baseline(\n")
    f.write(f"    input  [{q-1}:0]      sigmaE[{parallel_num-1}:0],\n")
    f.write(f"    output reg [{q-1}:0]  y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write("    always @* begin\n")

    for ln in gen_sigmaEB_case_body(B6, q):
        f.write(ln + "\n")

    f.write("    end\n\n")
    f.write("endmodule\n")

    f.close()

    with open(out_fname, "r") as rf:
        caret_count = rf.read().count("^")

    print(f"Number of XOR in {out_fname}: {caret_count}")
    print(f"Generated {out_fname}")
