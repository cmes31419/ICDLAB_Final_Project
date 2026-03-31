def gf_mul(a: int, b: int, p: int, m: int) -> int:
    """GF(2^m) 乘法 (Russian peasant), 模 primitive poly p"""
    res = 0
    while b:
        if b & 1:
            res ^= a
        b >>= 1
        a <<= 1
        if a & (1 << m):   # x^m 項出現
            a ^= p
    return res & ((1 << m) - 1)

def build_exp_log_tables(alpha: int, p: int, m: int):
    """
    exp_table[i] = alpha^i, i=0..(2^m-2)
    log_table[x] = i  (x=alpha^i), log_table[0] = n (方便處理)
    """
    n = (1 << m) - 1
    exp_table = [0] * (2 * n)   # 做成 2n，方便不用一直 mod
    log_table = [0] * (1 << m)

    x = 1
    for i in range(n):
        exp_table[i] = x
        log_table[x] = i
        x = gf_mul(x, alpha, p, m)

    # 延伸 exp_table[n..2n-1]
    for i in range(n, 2 * n):
        exp_table[i] = exp_table[i - n]

    log_table[0] = n  # 代表 undefined
    return exp_table, log_table

def poly_eval_gf(coeffs, x, p, m):
    """
    在 GF(2^m) 評估多項式：
    coeffs[0] + coeffs[1] x + ... + coeffs[d] x^d
    用 Horner：從最高次往下做
    """
    acc = 0
    for c in reversed(coeffs):
        acc = gf_mul(acc, x, p, m) ^ c
    return acc

def chien_search(sigma, exp_table, p, m):
    """
    sigma = [Λ1, Λ2, ..., Λt] (不含常數項 1)
    Λ(x) = 1 + Λ1 x + ... + Λt x^t

    回傳：
      roots_i: 所有使 Λ(alpha^{-i})=0 的 i
      roots_x: 對應的 x = alpha^{-i} (GF element)
    """
    n = (1 << m) - 1
    # 組成完整係數 [1, Λ1, Λ2, ...]
    coeffs = [1] + list(sigma)

    roots_i = []
    roots_x = []

    for i in range(n):
        # x = alpha^{-i} = alpha^{n - i} (mod n)
        x = exp_table[(n - i) % n]
        val = poly_eval_gf(coeffs, x, p, m)
        if val == 0:
            roots_i.append(i)
            roots_x.append(x)

    return roots_i, roots_x

if __name__ == "__main__":
    alpha = 0b10  # alpha = x
    m = 10
    n = (1 << m) - 1

    # primitive polynomial: x^10 + x^3 + 1
    p = 0b10000001001

    exp_table, log_table = build_exp_log_tables(alpha, p, m)

    # 你的 sigma：假設代表 Λ1..Λt（不含常數 1）
    sigma = [0x307, 0x28e, 0x203, 0x0d6, 0x3aa]

    roots_i, roots_x = chien_search(sigma, exp_table, p, m)

    print(f"m={m}, n={n}")
    print("找到根的 i（使 Λ(alpha^{-i})=0）:")
    print(roots_i)

    print("\n對應的 x = alpha^{-i}（GF element, hex）:")
    print([hex(x) for x in roots_x])

    # 如果你要把 i 轉成「錯誤位置」(常見的一種是 loc = (n-1-i))
    # ⚠️ 這個 mapping 取決於你碼字 bit ordering / 多項式表示法
    error_locs_guess = [(n - 1 - i) for i in roots_i]
    print("\n(猜測) error location = n-1-i：")
    print(error_locs_guess)
