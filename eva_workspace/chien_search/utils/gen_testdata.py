import sys
import random

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


def chien_search(q: int, prim_poly: int, Lambda):
    """
    找 Λ(α^{-k}) = 0 的位置 k。
    Lambda[j] 是 x^j 的係數，係數用 int 表示 GF(2^q) 元素。
    回傳 zeros 字串，zeros[k] = '1' 代表第 k 位置是 root。
    """
    n = (1 << q) - 1
    tab = build_pow_table(q, prim_poly)

    zeros = ""

    for k in range(n):
        val = 0
        exp = (n - k) % n

        for j, c in enumerate(Lambda):
            if c != 0:
                xj = pow_alpha(j * exp, tab)   # (α^{-k})^j
                val ^= gf_mul(c, xj, q, prim_poly)

        if val == 0:
            zeros += "1"
        else:
            zeros += "0"

    zeros += zeros[0]  # for easy rotation in RTL
    return zeros


if __name__ == "__main__":
    seed = int(sys.argv[1])
    ntest = int(sys.argv[2])
    q = int(sys.argv[3])
    t_max = int(sys.argv[4])
    prim_poly = int(sys.argv[5], 0)

    random.seed(seed)

    tab = build_pow_table(q, prim_poly)

    f = open("testdata.txt", "w")
    f_ans = open("testdata_ans.txt", "w")

    for i in range(ntest):
        # random generate Lambda of (t_max+1) elements:
        # Lambda(x) = Lambda[0] + Lambda[1]x + ... + Lambda[(t_max+1)]x^(t_max+1)
        Lambda = []
        for _ in range(t_max + 1):
            Lambda.append(random.randint(0, (1 << q) - 1))

        zeros = chien_search(q, prim_poly, Lambda)

        # write test case to file
        lambda_bits = "".join(format(c, f"0{q}b") for c in Lambda[::-1])

        f.write(lambda_bits + "\n")
        f_ans.write(zeros + "\n")

    f.close()
    f_ans.close()