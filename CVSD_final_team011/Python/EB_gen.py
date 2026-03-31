# -*- coding: utf-8 -*-

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
    """
    對每個 j 產生：
      // y[0][j] = Σ_i sigma_i * E(i, j)
      y[0][j][bit] = sigma0[..] ^ sigma1[..] ^ ...;

    也就是把原本的 y[0..4][j][bit] 合起來 XOR，集中寫在 y[0][j][bit]。
    """
    lines = []
    t_plus_1 = len(E)   # E 的列數 = t+1
    n = len(E[0])       # column 數 (8)
    max_sigma = 5       # sigma0 ~ sigma4

    for j in range(n):
        # lines.append(f"      // y[0][{j}] = Σ_i sigma_i * E(i, {j})")

        # 有效 bits 0..(q-1)
        for r in range(q):
            terms = []
            # 對所有 sigma_i 累積貢獻
            for i in range(max_sigma):
                if i >= t_plus_1:
                    continue
                c = E[i][j]
                if c == 0:
                    continue
                M = mult_matrix_for_const(c, q, prim_poly)
                for k in range(q):
                    if M[r][k] == 1:
                        terms.append(f"sigma{i}[{k}]")

            expr = " ^ ".join(terms) if terms else "1'b0"
            lines.append(f"                y[{j}][{r}] = {expr};")

        # 高位補 0 到 10 bit
        for r in range(q, 10):
            lines.append(f"                y[{j}][{r}] = 1'b0;")

        lines.append("")  # 空行分隔每個 j

    return lines

#############################
# sigmaEB：算 y = (sigmaE row0) * B
# 這裡把 sigmaE[0][k] 當作 base vector 的第 k 個元素
#############################

def gen_sigmaEB_case_body(B, q: int):
    """
    產生某一個 m 的 case 分支內容：
      y[j][r] = XOR_k B[k][j]*sigmaE[0][k][r];

    現在 sigmaE[0][k] 已經是 Σ_i sigma_i * E(i,k) 的結果。
    """
    lines = []
    n = len(B)  # 8
    m = len(B[0])

    for j in range(m):
        # lines.append(f"      // y[{j}] = Σ_k B[k][{j}] * sigmaE[0][k]")
        terms = []
        for k in range(n):
            if B[k][j] == 1:
                terms.append(f"sigmaE[{k}]")
        if terms:
            expr = " ^ ".join(terms)
        else:
            expr = "1'b0"
        lines.append(f"                y[{j}] = {expr};")
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
# Main: generate sigmaE_sigmaEB.v
#############################

if __name__ == "__main__":
    parallel_num = 8

    out_fname = f"sigmaEB_{parallel_num}.v"
    f = open(out_fname, "w")

    #========================
    # module sigmaE
    #========================
    f.write("module sigmaE(\n")
    f.write("    input  [1:0]      code,\n")
    f.write("    input  [9:0]      sigma0,\n")
    f.write("    input  [9:0]      sigma1,\n")
    f.write("    input  [9:0]      sigma2,\n")
    f.write("    input  [9:0]      sigma3,\n")
    f.write("    input  [9:0]      sigma4,\n")
    if parallel_num == 8:
        f.write(f"    output reg [9:0]  y[{parallel_num-1}:0]\n")
    else:
        f.write(f"    output reg [9:0]  y[{parallel_num+1}:0]\n")
    f.write(");\n\n")

    f.write("    integer i;\n\n")
    f.write("    always @* begin\n")
    # f.write("        // default: clear all y to avoid latch\n")
    f.write(f"        for (i=0;i<{parallel_num+2};i=i+1) begin\n")
    f.write("            y[i] = 10'b0;\n")
    f.write("        end\n")
    f.write("        case (code)\n")

    # ---- m = 6 ----
    n = 64
    q = 6
    prim_poly = 0b1000011        # x^6 + x + 1
    t = 2
    E6_full, B6_full = decompose_E_B(q, n, t, prim_poly)

    sample = 8 * n // parallel_num
    idx6_e, idx6_b = build_indices(q, n, sample, parallel_num)

    print(sample)
    print(idx6_e)
    print(idx6_b)

    # 切 E / B
    E6 = [[row[c] for c in idx6_e] for row in E6_full]
    B6 = [[B6_full[r][c] for c in idx6_b] for r in idx6_e]

    f.write("            2'd1: begin  // m = 6\n")
    for ln in gen_sigmaE_case_body(E6, q, prim_poly):
        f.write(ln + "\n")
    f.write("            end\n")

    # ---- m = 8 ----
    n = 256
    q = 8
    prim_poly = 0b100011101      # x^8 + x^4 + x^3 + x^2 + 1
    t = 2
    E8_full, B8_full = decompose_E_B(q, n, t, prim_poly)

    sample = 8 * n // parallel_num
    idx8_e, idx8_b = build_indices(q, n, sample, parallel_num)

    print(sample)
    print(idx8_e)
    print(idx8_b)

    E8 = [[row[c] for c in idx8_e] for row in E8_full]
    B8 = [[B8_full[r][c] for c in idx8_b] for r in idx8_e]

    f.write("            2'd2: begin  // m = 8\n")
    for ln in gen_sigmaE_case_body(E8, q, prim_poly):
        f.write(ln + "\n")
    f.write("            end\n")

    # ---- m = 10 ----
    n = 1024
    q = 10
    prim_poly = 0b10000001001    # x^10 + x^3 + 1
    t = 4
    E10_full, B10_full = decompose_E_B(q, n, t, prim_poly)

    sample = 8 * n // parallel_num
    idx10_e, idx10_b = build_indices(q, n, sample, parallel_num)

    if parallel_num == 8:
        idx10_e = idx10_b

    print(sample)
    print(idx10_e)
    print(idx10_b)

    E10 = [[row[c] for c in idx10_e] for row in E10_full]
    B10 = [[B10_full[r][c] for c in idx10_b] for r in idx10_e]

    print("E10:")
    for i in E10:
        print(i)
    print("B10:")
    for i in B10:
        print(i)

    f.write("            2'd3: begin  // m = 10\n")
    for ln in gen_sigmaE_case_body(E10, q, prim_poly):
        f.write(ln + "\n")
    f.write("            end\n")

    f.write("        endcase\n")
    f.write("    end\n\n")
    f.write("endmodule\n\n")

    #========================
    # module sigmaEB
    #========================
    f.write("module sigmaEB(\n")
    f.write("    input  [1:0]     code,\n")
    if parallel_num == 8:
        f.write(f"    input  [9:0]     sigmaE[{parallel_num-1}:0],\n")
    else:
        f.write(f"    input  [9:0]     sigmaE[{parallel_num+1}:0],\n")
    f.write(f"    output reg [9:0]  y[{parallel_num-1}:0]\n")
    f.write(");\n\n")

    f.write("    integer i;\n\n")
    f.write("    always @* begin\n")
    f.write(f"        for (i=0;i<{parallel_num};i=i+1) begin\n")
    f.write("            y[i] = 10'b0;\n")
    f.write("        end\n")
    f.write("        case (code)\n")

    # ---- m = 6 ----
    q = 6
    f.write("            2'd1: begin  // m = 6\n")
    for ln in gen_sigmaEB_case_body(B6, q):
        f.write(ln + "\n")
    f.write("            end\n")

    # ---- m = 8 ----
    q = 8
    f.write("            2'd2: begin  // m = 8\n")
    for ln in gen_sigmaEB_case_body(B8, q):
        f.write(ln + "\n")
    f.write("            end\n")

    # ---- m = 10 ----
    q = 10
    f.write("            2'd3: begin  // m = 10\n")
    for ln in gen_sigmaEB_case_body(B10, q):
        f.write(ln + "\n")
    f.write("            end\n")

    f.write("        endcase\n")
    f.write("    end\n\n")
    f.write("endmodule\n")

    f.close()
    print(f"Generated {out_fname}")
