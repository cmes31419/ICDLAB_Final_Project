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
# 主流程：印出 (sigma * E) * B 的計算步驟
#############################

def print_sigmaEB_flow(q: int, prim_poly: int, n: int, sigmas, idx):
    """
    sigmas: [sigma0, sigma1, ..., sigma_t] 的 list, 每個是 GF(2^q) 元素 (int)
    n: 平行度 (E 是 (t+1)×n, B 是 n×n)
    """
    t = len(sigmas) - 1
    E, B = decompose_E_B(q, n, t, prim_poly)

    print("=== Parameters ===")
    print(f"q = {q}, prim_poly = 0x{prim_poly:x}, n = {n}, t = {t}")
    print("sigma:", [f"0x{x:x}" for x in sigmas])
    print()

    # print("=== E matrix (t+1 x n) ===")
    # for i, row in enumerate(E):
    #     print(f"E[{i}] :", " ".join(f"{x:02x}" for x in row))
    # print()

    # print("=== B matrix (n x n, binary) ===")
    # for i, row in enumerate(B):
    #     print(f"B[{i}] :", " ".join(str(x) for x in row))
    # print()

    # ---------- Stage 1: u = sigma^T * E ----------
    # u_j = Σ_i sigma_i * E[i][j]
    print("=== Stage 1: u = sigma^T * E ===")
    u = [0] * n
    for j in range(n):
        terms = []
        acc = 0
        for i in range(t + 1):
            s = sigmas[i]
            e = E[i][j]
            if e == 0 or s == 0:
                continue
            prod = gf_mul(s, e, q, prim_poly)
            terms.append(f"(sigma[{i}]=0x{s:x}) * (E[{i}][{j}]=0x{e:x}) = 0x{prod:x}")
            acc ^= prod
        # print(f"u[{j}] computation:")
        # if terms:
        #     for line in terms:
        #         print("  ", line)
        #     print(f"  ==> u[{j}] = XOR of above = 0x{acc:x}")
        # else:
        #     print("  all terms zero, u[{j}] = 0")
        u[j] = acc
        # print()
    print("u =", [f"0x{u[x]:x}" for x in idx])
    print()

    # (選擇性) 展開某個 sigma_i * E[i][j] 的 bit-level 線性關係
    # 示範一下用 mult_matrix_for_const：
    # print("=== Example: bit-level linear map for sigma[0] * E[0][0] ===")
    # e00 = E[0][0]
    # M00 = mult_matrix_for_const(e00, q, prim_poly)
    # print(f"E[0][0] = 0x{e00:x}")
    # for r in range(q):
    #     deps = [f"sigma0[{k}]" for k in range(q) if M00[r][k] == 1]
    #     expr = " ^ ".join(deps) if deps else "0"
    #     print(f"  (sigma0 * E[0][0]) bit {r} = {expr}")
    # print()

    # ---------- Stage 2: y = u * B ----------
    # y_k = Σ_j u_j * B[j][k]，但 B 只有 0/1，所以簡化成 XOR 所有 B[j][k]=1 的 u[j]
    print("=== Stage 2: y = u * B ===")
    y = [0] * n
    for k in range(n):
        used_js = [j for j in range(n) if B[j][k] == 1]
        # print(f"y[{k}] computation:")
        if not used_js:
            # print("  no j with B[j][k]=1 -> y[{k}] = 0")
            y[k] = 0
            # print()
            continue

        acc = 0
        for j in used_js:
            # print(f"  use u[{j}] = 0x{u[j]:x}  (because B[{j}][{k}] = 1)")
            acc ^= u[j]
        y[k] = acc
        # print(f"  ==> y[{k}] = XOR of selected u[j] = 0x{acc:x}")
        # print()

    print("Final y =", [f"0x{y[x]:x}" for x in idx])
    print("\n")


def build_indices(n_full, sample, n_parallel):
    """
    產生 index 序列：
      [0,1,2,3,4,5,6,7,
       sample+0 ... sample+7,
       2*sample+0 ... 2*sample+7,
       ...]
    直到湊滿 n_parallel 個。
    """
    idx = []
    k = 0
    while len(idx) < n_parallel:
        base = k * sample
        for off in range(8):
            pos = base + off
            if pos < n_full:
                idx.append(pos)
                if len(idx) >= n_parallel:
                    break
        k += 1
        if base >= n_full:
            break
    return idx[:n_parallel]

#############################
# Example main()
#############################

if __name__ == "__main__":
    # 你可以在這裡改 q / prim_poly / n / sigma
    # 例如 m=6, t=2, n=8:
    # q = 6
    # prim_poly = 0b1000011   # x^6 + x + 1
    # n = 1024

    n = 1024
    q = 10
    prim_poly = 0b10000001001    # x^10 + x^3 + 1

    # sigma0~sigma4，如果 t=2 就只會用到前 3 個 (sigma0,sigma1,sigma2)
    sigmas = [0x343, 0x1d4, 0x59, 0x271, 0xe1]

    pow_tab = build_pow_table(q, prim_poly)
    
    parallel_num = 16
    sample = 8 * n // parallel_num
    idx = build_indices(n, sample, parallel_num)

    print("idx:")
    print(idx)

    for _ in range(2):

        print_sigmaEB_flow(q, prim_poly, n, sigmas, idx)

        for i in range(len(sigmas)):
            if 8*i > 2**q -1: continue
            b = pow_tab[8*i]
            print(f"{sigmas[i]} * {b} = ")
            sigmas[i] = gf_mul(sigmas[i], b, q, prim_poly)
            print(f"{sigmas[i]}")