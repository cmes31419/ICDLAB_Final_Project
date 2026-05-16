"""
NSU golden reference model.
"""

from gf64 import alpha_pow, gf_mul, gf_add


def cyclic_rotate_left(poly_int, n_shift, length=63):
    n_shift = n_shift % length
    mask = (1 << length) - 1
    low = (poly_int << n_shift) & mask
    high = poly_int >> (length - n_shift) if n_shift else 0
    return low | high


def int_to_bits(x, n=63):
    return [(x >> i) & 1 for i in range(n)]


def eval_poly_int(x_int, alpha_L):
    """Evaluate polynomial (as int bit-vector, LSB=x^0) at alpha_L."""
    bits = int_to_bits(x_int)
    state = 0
    for k in range(62, -1, -1):
        state = gf_mul(state, alpha_L) ^ bits[k]
    return state


def nsu_compute(r0, r1, r2, r3, b, stage_flag):
    """
    r0..r3 : int 63-bit codewords (LSB=bit 0=coef of x^0)
    b: 0 -> b=1 (1 undecoded); 1 -> b=2 (2 undecoded)
    stage_flag: 0 -> stage 0 done (L=5,7); 1 -> stage 1 done (L=9,11)
    Returns (S0, S1, S2, S3, b_out).
    """
    r_xor   = r0 ^ r1 ^ r2 ^ r3
    r_shift = r0 ^ cyclic_rotate_left(r1, 1) ^ cyclic_rotate_left(r2, 2) ^ cyclic_rotate_left(r3, 3)
    
    if stage_flag == 0:
        L1, L2 = 5, 7
    else:
        L1, L2 = 9, 11
    
    aL1 = alpha_pow(L1)
    aL2 = alpha_pow(L2)
    
    Shat0_a = eval_poly_int(r_xor, aL1)
    Shat0_b = eval_poly_int(r_xor, aL2)
    
    if b == 0:
        return (Shat0_a, Shat0_b, 0, 0, b)
    else:
        Shat1_a = eval_poly_int(r_shift, aL1)
        Shat1_b = eval_poly_int(r_shift, aL2)
        return (Shat0_a, Shat0_b, Shat1_a, Shat1_b, b)


def verify_cyclic_equivalence(r0, r1, r2, r3, stage_flag):
    """Verify cyclic rotate == standard GII-BCH formula."""
    if stage_flag == 0:
        Ls = [5, 7]
    else:
        Ls = [9, 11]
    
    rs = [r0, r1, r2, r3]
    
    for L in Ls:
        aL = alpha_pow(L)
        # standard
        Shat1_std = 0
        for i in range(4):
            Ri = eval_poly_int(rs[i], aL)
            Shat1_std = gf_add(Shat1_std, gf_mul(alpha_pow((L*i) % 63), Ri))
        # cyclic rotate
        r_shift = r0 ^ cyclic_rotate_left(r1, 1) ^ cyclic_rotate_left(r2, 2) ^ cyclic_rotate_left(r3, 3)
        Shat1_nsu = eval_poly_int(r_shift, aL)
        assert Shat1_std == Shat1_nsu
    return True


if __name__ == "__main__":
    import random
    rng = random.Random(0xDEAD)
    
    print("=" * 60)
    print("NSU Golden Model Verification")
    print("=" * 60)
    
    print("\nTest 1: cyclic rotate equivalence (10 trials/stage)")
    for stage in [0, 1]:
        for _ in range(10):
            r0 = rng.randint(0, (1 << 63) - 1)
            r1 = rng.randint(0, (1 << 63) - 1)
            r2 = rng.randint(0, (1 << 63) - 1)
            r3 = rng.randint(0, (1 << 63) - 1)
            verify_cyclic_equivalence(r0, r1, r2, r3, stage)
        print(f"  stage_flag={stage}: 10 trials PASS")
    
    print("\nTest 2: Sample computations")
    test_cases = [
        # (r0, r1, r2, r3, b, stage)
        (0, (1 << 5) | (1 << 20), 0, 0, 0, 0),
        (0, (1 << 5) | (1 << 20), 0, 0, 1, 0),
        (0, (1 << 5) | (1 << 20), 0, 0, 0, 1),
        (0, (1 << 5) | (1 << 20), 0, 0, 1, 1),
        ((1 << 10), (1 << 5), (1 << 25), (1 << 40), 1, 0),
    ]
    
    for (r0, r1, r2, r3, b, st) in test_cases:
        S0, S1, S2, S3, bo = nsu_compute(r0, r1, r2, r3, b, st)
        Ls = "(5,7)" if st == 0 else "(9,11)"
        print(f"  stage={st} b={b} L={Ls}: S=({S0:02x}, {S1:02x}, {S2:02x}, {S3:02x}), b_out={bo}")
    
    print("\nAll Python golden model checks PASS ✓")