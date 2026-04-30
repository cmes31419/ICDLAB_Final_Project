import sys
import random

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


def syndrome(word, t: int, q: int, prim_poly: int):
    """
    Compute BCH syndromes:

        S_j = word(alpha^j), j = 1..2t

    word is ascending-degree:
        word[k] = coefficient of x^k

    Return:
        list of GF(2^q) elements in polynomial-form integer representation.
    """
    pow_tab = build_pow_table(q, prim_poly)

    S = []

    for j in range(1, 2 * t + 1):
        sj = 0

        for k, bit in enumerate(word):
            if bit:
                sj ^= pow_alpha(j * k, pow_tab)

        S.append(sj)

    return S


if __name__ == "__main__":
    seed = int(sys.argv[1])
    ntest = int(sys.argv[2])
    q = int(sys.argv[3])
    n = int(sys.argv[4])
    t_min = int(sys.argv[5])
    prim_poly = int(sys.argv[6], 0)

    random.seed(seed)

    tab = build_pow_table(q, prim_poly)

    f = open("testdata.txt", "w")
    f_ans = open("testdata_ans.txt", "w")

    for _ in range(ntest):
        word = [random.randint(0, 1) for _ in range(n)]

        S = syndrome(word, t_min, q, prim_poly)

        ans_bits = "".join(format(s, f"0{q}b") for s in S[::-1])  # S_2t, S_{2t-1}, ..., S_1

        f.write("".join(str(b) for b in [0] + word[::-1]) + "\n")
        f_ans.write(ans_bits + "\n")

    f.close()
    f_ans.close()

    print(f"Generated {ntest} test cases in testdata.txt and testdata_ans.txt")