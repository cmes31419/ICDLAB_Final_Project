# -*- coding: utf-8 -*-
"""
Auto-generate a rotate_1_k module that computes:
  sigma_rot = sigma * alpha^K
over GF(2^m), for m=6,8,10 selected by input [1:0] code.

code = 2'd1 -> GF(2^6),  primitive poly x^6 + x + 1
code = 2'd2 -> GF(2^8),  primitive poly x^8 + x^4 + x^3 + x^2 + 1
code = 2'd3 -> GF(2^10), primitive poly x^10 + x^3 + 1

Assume sigma[0] is coefficient of α^0, sigma[1] of α^1, etc.
"""

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


def mult_matrix_for_const(c: int, q: int, prim_poly: int):
    """
    Return q×q matrix M such that y = c * x in GF(2^q)
    corresponds to y_bits = M * x_bits (over GF(2)).
    M[row][col] = 1 if output_bit[row] depends on input_bit[col].
    """
    M = [[0] * q for _ in range(q)]
    for k in range(q):
        out_elem = gf_mul(c, 1 << k, q, prim_poly)
        for r in range(q):
            if (out_elem >> r) & 1:
                M[r][k] = 1
    return M


def gen_case_branch_for_m(code_val: int, m: int, prim_poly: int, K: int):
    """
    Generate the case branch:
      2'dX: begin
        sigma_rot[bit] = XOR of sigma[..];
      end
    for GF(2^m), primitive poly prim_poly, exponent K (alpha^K).
    """
    lines = []
    q = m  # field degree

    pow_tab = build_pow_table(q, prim_poly)
    c = pow_alpha(K, pow_tab)  # constant = alpha^K
    M = mult_matrix_for_const(c, q, prim_poly)

    # comment: show primitive polynomial and constant
    lines.append(f"            {code_val}'d{code_val}: begin  // m = {m}, const = alpha^{K} = 0x{c:x}")

    # bits 0..q-1 are valid GF bits; 其他保持 0 (已在 always 中 sigma_rot = 0)
    for r in range(q):
        terms = [f"sigma[{k}]" for k in range(q) if M[r][k] == 1]
        if terms:
            expr = " ^ ".join(terms)
        else:
            expr = "1'b0"
        lines.append(f"                sigma_rot[{r}] = {expr};")

    lines.append("            end")
    return lines


if __name__ == "__main__":
    # ===== 在這裡設定你要的 k（乘 alpha^K） =====
    P = 64  # 例如 k = 8 就是你現在 rotate_1_8 做的事

    out_fname = f"rotate_{P}.v"
    f = open(out_fname, "w")

    for i in range(1, 5):
        K = i*P
        # module header
        f.write(f"module rotate_{i}P(\n")
        f.write("    input  [1:0]        code,\n")
        f.write("    input  [9:0]        sigma,\n")
        f.write("    output reg [9:0]    sigma_rot\n")
        f.write(");\n\n")

        f.write("    always @(*) begin\n")
        f.write("        sigma_rot = 10'b0;\n")
        f.write("        case (code)\n")

        # m = 6, code = 2'd1
        m6 = 6
        prim6 = 0b1000011  # x^6 + x + 1
        for ln in gen_case_branch_for_m(1, m6, prim6, K):
            f.write(ln + "\n")

        # m = 8, code = 2'd2
        m8 = 8
        prim8 = 0b100011101  # x^8 + x^4 + x^3 + x^2 + 1
        for ln in gen_case_branch_for_m(2, m8, prim8, K):
            f.write(ln + "\n")

        # m = 10, code = 2'd3
        m10 = 10
        prim10 = 0b10000001001  # x^10 + x^3 + 1
        for ln in gen_case_branch_for_m(3, m10, prim10, K):
            f.write(ln + "\n")

        f.write("        endcase\n")
        f.write("    end\n\n")
        f.write("endmodule\n\n")

    f.close()
    print(f"Generated {out_fname} for P = {P}")
