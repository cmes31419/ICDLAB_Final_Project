def gf_mul(a: int, b: int, p: int, m: int) -> int:
    """
    在 GF(2^m) 裡做乘法，模掉多項式 p(x)
    這裡用 'Russian peasant' 乘法法則
    a, b, p 都用 bit 代表多項式係數
    """
    res = 0
    while b:
        if b & 1:
            res ^= a
        b >>= 1
        a <<= 1
        # 如果出現 x^m 以上的項，就用 p(x) 簡化
        if a & (1 << m):
            a ^= p
    # 最後只保留 m 個 bit
    return res & ((1 << m) - 1)

def build_exp_log_tables(alpha: int, p: int, m: int):
    """
    建立 α^0...α^{2^m-2} 的 exp table
    以及 element -> exponent 的 log table
    """
    field_order = (1 << m) - 1        # 2^m - 1 = 63
    exp_table = [0] * (1 << m)        # exp_table[i] = α^i
    log_table = [0] * (1 << m)        # log_table[element] = i  (element = α^i)

    x = 1
    for i in range(field_order + 1):
        exp_table[i] = x
        log_table[x] = i
        x = gf_mul(x, alpha, p, m)

    log_table[0] = 2**m-1

    # 定義 log(0) 沒意義，保持 0 或另外處理
    return exp_table, log_table


if __name__ == "__main__":
    table = "exp_table" # exp_table / log_table

    alpha = 0b10  # 把 α 選成 x

    # 1: (63,51,t=2), m=6
    # 2: (255,239,t=2), m=8
    # 3: (1023,983,t=4), m=10
    m = 10

    parallel_num = 16
    sample = (1<<m) // parallel_num

    if m == 6:
        # primitive polynomial: x^6 + x + 1
        p = 0b1000011

    elif m == 8:
        # primitive polynomial: x^8 + x^4 + x^3 + x^2 + 1
        p = 0b100011101

    elif m == 10:
        # primitive polynomial: x^10 + x^3 + 1
        p = 0b10000001001

    exp_table, log_table = build_exp_log_tables(alpha, p, m)

    sigma = [0x307, 0x28e, 0x203, 0x0d6, 0x3aa]

    for t in range(2**m):
        sum = 0
        for i in range(len(sigma)):
            sum += gf_mul(sigma[i], exp_table[(t*i)%(2**m-1)], p, m)
        sum = gf_mul(sum, 1, p, m)
        # print(f"t={t}, sum={format(sum, 'b')}, {[(t*i)%(2**m-1) for i in range(len(sigma))]}")
        if sum == 0:
            print(f"find root: x^{t}")

    for t in range(10):
        print(f"t={t}, x^{8*t}: sigma={[format(s, 'x') for s in sigma]}", end="")
        for i in range(parallel_num//8):
            for j in range(8):
                print(f" x^{(sample*8*i+j+8*t-1)%(2**m-1)+1}", end="")
        print()
        for i in range(len(sigma)):
            sigma[i] = gf_mul(sigma[i], exp_table[i*8], p, m)