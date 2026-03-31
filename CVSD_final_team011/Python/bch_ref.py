# =========================
# GF(2^m) basic operations
# =========================

def gf_add(a: int, b: int) -> int:
    """加法就是 XOR"""
    return a ^ b

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
    exp_table = [0] * field_order     # exp_table[i] = α^i
    log_table = [0] * (1 << m)        # log_table[element] = i  (element = α^i)

    x = 1
    for i in range(field_order):
        exp_table[i] = x
        log_table[x] = i
        x = gf_mul(x, alpha, p, m)

    # 定義 log(0) 沒意義，保持 0 或另外處理
    return exp_table, log_table

def gf_to_poly_str(a: int, m: int = 6) -> str:
    """
    把 GF(2^m) element 轉成 polynomial form
    例如 a = 0b101011 -> "x^5 + x^3 + x + 1"
    """
    if a == 0:
        return "0"
    terms = []
    for k in range(m - 1, -1, -1):
        if a & (1 << k):
            if k == 0:
                terms.append("1")
            elif k == 1:
                terms.append("x")
            else:
                terms.append(f"x^{k}")
    return " + ".join(terms)

# =========================
# Syndrome computation
# =========================

def compute_syndromes(bits: str, t: int, n: int, exp_table):
    """
    bits: 接收的 bit 串，MSB 在左邊
          若長度 > n，預設使用最後 n 個 bit
    S_i = r(α^i) = Σ r_j * (α^i)^j, j = 0..n-1
    其中 bits[0] 對應 X^(n-1)，bits[-1] 對應 X^0
    """
    field_order = len(exp_table)  # = 2^m - 1

    if len(bits) != n:
        print(f"[warning] bits length = {len(bits)}, n = {n}, 使用最後 {n} 個 bit")
        bits = bits[-n:]

    syndromes = []
    for i in range(1, 2 * t + 1):
        Si = 0  # GF(2^m) element
        for pos, ch in enumerate(bits):
            if ch == '0':
                continue
            # 這個 bit 對應的是 X^j
            j = n - 1 - pos
            # (α^i)^j = α^{i*j}
            e = (i * j) % field_order
            term = exp_table[e]
            Si = gf_add(Si, term)
        syndromes.append(Si)
    return syndromes

# =========================
# Main: compute S1..S(2t) for r
# =========================

if __name__ == "__main__":
    # 1: (63,51,t=2), m=6
    # 2: (255,239,t=2), m=8
    # 3: (1023,983,t=4), m=10
    mode = 3

    if mode == 1:
        # Parameters for (63,51), t = 2, m = 6
        m = 6
        n = 63
        k = 51
        t = 2
        # primitive polynomial: x^6 + x + 1
        p = 0b1000011
        phi_1 = 0x43    # x^6 + x + 1
        phi_2 = 0x43    # x^6 + x + 1
        phi_3 = 0x57    # x^6 + x^4 + x^2 + x + 1
        phi_4 = 0x43    # x^6 + x + 1

        # 接收字 r（長度應該是 63 bits）
        # r = "0010_0101_0000_1111_1101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0100_0011"
        r = "010_0111_0000_1111_0101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0000_0011"
        r = "010_0111_0000_1111_1101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0000_0011"

    elif mode == 2:
        # Parameters for (255,239), t = 2, m = 8
        m = 8
        n = 255
        k = 239
        t = 2
        # primitive polynomial: x^8 + x^4 + x^3 + x^2 + 1
        p = 0b100011101

        # minimal polynomials (你原本給的 phi_1~phi_4)
        phi_1 = 0b100011101  # x^8 + x^4 + x^3 + x^2 + 1
        phi_2 = 0b100011101  # x^8 + x^4 + x^3 + x^2 + 1
        phi_3 = 0b101110111  # x^8 + x^6 + x^5 + x^4 + x^2 + x + 1
        phi_4 = 0b100011101  # x^8 + x^4 + x^3 + x^2 + 1

        # 實際使用時要確認總長度是否真的是 255 bits
        r = "010010100001111110110100101110001110011010111010101101100010100110000100011001011000101000010101101101000011110011000110011111100011001110000001101001011001100111010010101100011011011001100111111010011011100111000001110110100011001000011110101010010001000"

    elif mode == 3:
        # Parameters for (1023,983), t = 4, m = 10
        m = 10
        n = 1023
        k = 983
        t = 4
        # primitive polynomial: x^10 + x^3 + 1
        p = 0b10000001001

        # 這邊照你原本定義的 phi_1 ~ phi_8
        phi_1 = 0b10000001001   # x^10 + x^3 + 1
        phi_2 = 0b10000001001   # x^10 + x^3 + 1
        phi_3 = 0b10000001111   # x^10 + x^3 + x^2 + x + 1
        phi_4 = 0b10000001001   # x^10 + x^3 + 1
        phi_5 = 0b10100001101   # x^10 + x^8 + x^3 + x^2 + 1
        phi_6 = 0b10000001111   # x^10 + x^3 + x^2 + x + 1
        phi_7 = 0b11111111001   # x^10 + x^9 + ... + x^3 + 1
        phi_8 = 0b10000001001   # x^10 + x^3 + 1

        # r 長度應該是 1023 bits
        r = "010010100001111110110100101010001110011010111010101101100010100110000100011001011000101000010101101101000011110011000110011111100011001110000001101011011001100111010010101100011011011001100111111010011011100111000001110110100011001000011110000000010011001110011001111010010101000010000111100000110100110110111001010101110110110011011011010101001111111101010100010011001100100100011111011001101110101011001101101000111001010011001101100000100010001111110100011101011001001001100001000101001111010010101000111011110010000000101000001100000011100000010010001010100010001001000000000100000100001101110100010100001100000101000000010000010001111000100111011100010011100110111000101100101101011000101111101001011000110110011101100101100000000111011111011010111001001110101000111010110001001010001011001001111101011100010000111101101000011001010000111100011011110111001000111000110100000101011101101110000110110111110011001101000110101011001101110101011101001111100001000001100010110100110100100111100000011101110101101111111010111"

    else:
        raise ValueError("mode 必須是 1, 2, 或 3")

    # 把 r 字串中的底線移除
    r = r.replace("_", "")

    # 建 GF(2^m) 的 exp / log table
    alpha = 0b10  # 把 α 選成 x
    exp_table, log_table = build_exp_log_tables(alpha, p, m)

    # print exp/log table
    print("GF(2^{}) exp/log tables:".format(m))
    for i in range(100):
        poly = gf_to_poly_str(exp_table[i], m)
        print("α^{:3d} = {:0{width}b} = {}".format(i, exp_table[i], poly, width=m))

    print("r bits length:", len(r))
    print()

    # 計算 S1..S(2t)
    S_r = compute_syndromes(r, t, n, exp_table)

    print("Syndromes for r (received word):")
    for idx, Si in enumerate(S_r, start=1):
        # Si 用 m bits 印出來
        print(f"S{idx} = {Si:0{m}b}  (poly: {gf_to_poly_str(Si, m)})")
