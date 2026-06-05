"""
Parametrized parallel Horner unit generator (v2, with enable signal).
"""

import sys


def gf_mul(a, b, q, prim_poly):
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


def build_pow_table(q, prim_poly):
    order = (1 << q) - 1
    alpha = 2
    tab = [1] * order
    for i in range(1, order):
        tab[i] = gf_mul(tab[i - 1], alpha, q, prim_poly)
    return tab


def pow_alpha(exp, tab):
    return tab[exp % len(tab)]


def mult_matrix_for_const(c, q, prim_poly):
    M = [[0] * q for _ in range(q)]
    for k in range(q):
        out_elem = gf_mul(c, 1 << k, q, prim_poly)
        for r in range(q):
            if (out_elem >> r) & 1:
                M[r][k] = 1
    return M


def gen_next_state_eqs(q, prim_poly, L, P):
    pow_tab = build_pow_table(q, prim_poly)
    fb_const = pow_alpha(L * P, pow_tab)
    M_fb = mult_matrix_for_const(fb_const, q, prim_poly)
    in_consts = [pow_alpha(L * i, pow_tab) for i in range(P)]

    eqs = []
    for r in range(q):
        terms = []
        for k in range(q):
            if M_fb[r][k] == 1:
                terms.append(f"state[{k}]")
        for i in range(P):
            if (in_consts[i] >> r) & 1:
                terms.append(f"eff_data[{i}]")
        expr = " ^ ".join(terms) if terms else "1'b0"
        eqs.append((r, expr, len(terms)))
    return eqs, fb_const


def gen_horner_module(q, prim_poly, L, P, n):
    eqs, fb_const = gen_next_state_eqs(q, prim_poly, L, P)
    cycles_needed = (n + P - 1) // P
    cnt_w = max(1, (cycles_needed - 1).bit_length())

    lines = []
    lines.append("//=========================================================================")
    lines.append(f"// horner_a{L}.v - Parallel Horner unit: r(alpha^{L}) over GF(2^{q})")
    lines.append(f"//   n={n}, P={P}, cycles={cycles_needed}, fb_const=alpha^{(L*P)%((1<<q)-1)}")
    lines.append("//   enable=0 freezes the unit (saves power)")
    lines.append("//   On start: state is effectively cleared before update")
    lines.append("//=========================================================================")
    lines.append("")
    lines.append(f"module horner_a{L} (")
    lines.append("    input  wire              clk,")
    lines.append("    input  wire              rst,")
    lines.append("    input  wire              enable,")
    lines.append("    input  wire              start,")
    lines.append(f"    input  wire [{P-1}:0]       data,")
    lines.append(f"    input  wire [{q-1}:0]        state,")
    lines.append(f"    output wire [{q-1}:0]        next_state")
    lines.append(");")
    lines.append("")
    # Build next_state with "effective state" that is zero when start is asserted.
    # We compute next_state by referring to a helper wire eff_state = start ? 0 : state
    lines.append(f"    wire [{q-1}:0] eff_state;")
    lines.append(f"    assign eff_state = enable ? (start ? {q}'b0 : state) : {q}'b0;")
    lines.append("")
    lines.append(f"    wire [{P-1}:0] eff_data;")
    lines.append(f"    assign eff_data = enable ? data : {P}'b0;")
    lines.append("")
    # Re-emit equations but replace 'state[i]' with 'eff_state[i]'
    for (r, expr, _) in eqs:
        expr_eff = expr.replace("state[", "eff_state[")
        lines.append(f"    assign next_state[{r}] = {expr_eff};")
    lines.append("")
    total_xor = sum((tc - 1) for (_, _, tc) in eqs if tc > 0)
    lines.append(f"    // Total XOR gates (combinational): {total_xor}")
    lines.append("endmodule")
    return "\n".join(lines), cycles_needed, total_xor


def main():
    if len(sys.argv) < 5:
        print("Usage: python3 gen_horner.py <q> <prim_poly> <L> <P> [<n>]")
        sys.exit(1)
    q         = int(sys.argv[1])
    prim_poly = int(sys.argv[2], 0)
    L         = int(sys.argv[3])
    P         = int(sys.argv[4])
    n         = int(sys.argv[5]) if len(sys.argv) > 5 else (1 << q) - 1

    rtl, cycles, total_xor = gen_horner_module(q, prim_poly, L, P, n)
    fname = f"horner_a{L}.v"
    with open(fname, "w") as f:
        f.write(rtl)
    print(f"Generated {fname}: alpha^{L}, P={P}, n={n}, cycles={cycles}, XOR={total_xor}")


if __name__ == "__main__":
    main()