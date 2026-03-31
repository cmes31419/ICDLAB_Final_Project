from galois_field import GF
import argparse

def BM(m, t, syndrome, verbose=False):
    """
    Standard Berlekamp–Massey (with inversions) for BCH t-error-correcting decoder.

    Parameters
    ----------
    m : int
        GF(2^m) extension degree.
    t : int
        Designed error-correcting capability.
    syndrome : list[int]
        Length 2t list, syndromes in *power form* (alpha^k indices).
    verbose : bool
        If True, print internal BM state each iteration.

    Returns
    -------
    sigma_powers : list[int]
        Error-locator polynomial coefficients in *power form*,
        sigma_powers[i] is the exponent of alpha for x^i term,
        or -1 if the coefficient is 0.
        Length is (2*t + 1) so you can see deg(Λ) possibly > t.
    L : int
        Degree of the locator polynomial.
    """
    gf = GF(m)
    # Convert syndromes from power form to poly form
    s_poly = [gf.power2poly[s] for s in syndrome]

    N = len(s_poly)              # should be 2*t
    max_deg = 2 * t              # allow degree up to 2t

    # C(x) and B(x) in poly form, coefficient list: index = power of x
    C = [0] * (max_deg + 1)
    B = [0] * (max_deg + 1)
    C[0] = 1
    B[0] = 1

    L = 0        # current degree of C(x) (locator polynomial)
    m_idx = -1   # last index when C was updated
    b = 1        # last nonzero discrepancy (in poly form)

    for n in range(N):  # n = 0 .. 2t-1
        # Compute discrepancy d_n = S_n + sum_{i=1..L} C[i] * S_{n-i}
        d = s_poly[n]
        for i in range(1, L + 1):
            d = gf.add(d, gf.mul(C[i], s_poly[n - i]))

        if verbose:
            print(f"=== Iteration n = {n} ===")
            print(f"Syndrome S_{n+1} (poly) = {s_poly[n]}")
            print(f"Discrepancy d_n (poly) = {d}")
            print(f"Current degree L = {L}")
            print(f"C(x) (poly) = {C[:L+1]}")
            print(f"B(x) (poly) = {B}")

        if d == 0:
            # No update; this step just increases the "age" since last update
            continue

        # Save old C(x)
        T = C.copy()

        # factor = d / b in GF(2^m)
        factor = gf.mul(d, gf.inv(b))
        shift = n - m_idx  # x^(n - m_idx) factor

        # C(x) = C(x) - factor * x^(n - m_idx) * B(x)
        # (minus = plus in characteristic 2)
        for i in range(0, max_deg + 1 - shift):
            if B[i] != 0:
                C[i + shift] = gf.add(C[i + shift], gf.mul(factor, B[i]))

        # Update L, B, b, m_idx as in BM
        if 2 * L <= n:
            L_new = n + 1 - L
            B = T
            b = d
            m_idx = n
            L = L_new

        if verbose:
            print(f"Updated degree L = {L}")
            print(f"Updated C(x) (poly) = {C[:L+1]}")
            print()

    # Convert C(x) back to power form (for degrees 0..2t)
    sigma_powers = []
    for i in range(max_deg + 1):
        coeff = C[i]
        if coeff == 0:
            sigma_powers.append(-1)  # consistent with GF.poly2power[0] = -1
        else:
            sigma_powers.append(gf.poly2power[coeff])

    return sigma_powers, L
