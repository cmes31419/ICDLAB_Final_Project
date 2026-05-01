from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, List

from galois_field import GF
from bch_decoder import BCHDecoder


@dataclass
class RiBMState:
    """
    Register state for the simplified riBM / Berlekamp algorithm for binary BCH.

    Conventions used in this file:
    - lambda_reg, delta_reg, theta_reg are ordinary ascending-degree polynomials.
    - b_reg is stored in the paper's shifted form where index 0 corresponds to x^(-1).
      This matches Algorithm A in the reduced-complexity paper:
          B^(0)(x) = x^(-1)
      so the initial b_reg is simply [1].
    - gamma_reg and k_reg are scalars.
    - r_reg is the current even iteration index in the paper, i.e. r = 0, 2, 4, ...
    """

    lambda_reg: List[Any]
    b_reg: List[Any]          # shifted representation, index 0 corresponds to x^(-1)
    delta_reg: List[Any]
    theta_reg: List[Any]
    gamma_reg: Any
    k_reg: int
    r_reg: int


class BCHRiBMSkip:
    """
    Hardware-style Python model of Algorithm A in
    "Reduced-Complexity Key Equation Solvers for GII-BCH Decoders".

    This is the simplified riBM / Berlekamp algorithm for binary BCH decoding,
    where odd iterations are skipped.

    It is intended as a correctness reference before Verilog implementation.

    Important notes:
    1. Input syndromes are expected in the paper's order [S0, S1, ..., S_{2t-1}].
       If your current code uses [S1, ..., S_{2t}], you can pass that list directly
       as long as you use the same naming convention consistently.
    2. The saved B(x) state here follows the exact shifted initialization in the paper:
           B^(0)(x) = x^(-1)
       Therefore b_reg is NOT an ordinary polynomial list.
    3. This file only implements the low-order BCH KES. It does not yet implement
       the later nested continuation KES.
    """

    def __init__(self, q: int, t: int, p_str: str):
        self.gf = GF(q, p_str)
        self.field = self.gf.field
        self.alpha = self.gf.alpha
        self.q = q
        self.t = t
        self.p_str = p_str
        self.n = self.gf.power_max

    # -------------------------------------------------
    # basic helpers
    # -------------------------------------------------
    @staticmethod
    def _strip_trailing_zeros(poly: List[Any]) -> List[Any]:
        res = list(poly)
        while len(res) > 1 and int(res[-1]) == 0:
            res.pop()
        return res

    def _zero_poly(self, size: int) -> List[Any]:
        F = self.field
        return [F(0) for _ in range(size)]

    def _poly_pad(self, poly: List[Any], size: int) -> List[Any]:
        out = list(poly)
        F = self.field
        if len(out) < size:
            out += [F(0) for _ in range(size - len(out))]
        return out[:size]

    def _poly_add(self, p1: List[Any], p2: List[Any]) -> List[Any]:
        F = self.field
        n = max(len(p1), len(p2))
        out = [F(0) for _ in range(n)]
        for i in range(n):
            a = p1[i] if i < len(p1) else F(0)
            b = p2[i] if i < len(p2) else F(0)
            out[i] = a + b
        return self._strip_trailing_zeros(out)

    def _poly_scale(self, poly: List[Any], scalar: Any) -> List[Any]:
        return self._strip_trailing_zeros([scalar * c for c in poly])

    def _poly_div_x2(self, poly: List[Any]) -> List[Any]:
        """Ordinary ascending-degree polynomial divided by x^2 with truncation."""
        F = self.field
        if len(poly) <= 2:
            return [F(0)]
        return self._strip_trailing_zeros(list(poly[2:]))

    def _b_shift_x2(self, b_reg: List[Any]) -> List[Any]:
        """
        Shift the special B register by x^2.

        Since b_reg uses the paper's shifted representation where index 0 means x^(-1),
        multiplying B(x) by x^2 is equivalent to prepending two zeros in that register space.
        """
        F = self.field
        return [F(0), F(0)] + list(b_reg)

    def _b_from_lambda(self, lambda_reg: List[Any]) -> List[Any]:
        """
        Store an ordinary Lambda(x) into the shifted B-register space.

        Because b_reg index 0 corresponds to x^(-1), the ordinary x^0 coefficient of Lambda
        is stored at b_reg[1].
        """
        F = self.field
        return [F(0)] + list(lambda_reg)

    def _x2_times_b(self, b_reg: List[Any]) -> List[Any]:
        """
        Convert x^2 * B(x) into an ordinary ascending-degree polynomial.

        b_reg index i corresponds to x^(i-1), so x^2 * B(x) has ordinary coefficient:
            ordinary exponent = (i - 1) + 2 = i + 1
        Therefore we prepend one zero in ordinary representation.
        """
        F = self.field
        return [F(0)] + list(b_reg)

    # -------------------------------------------------
    # initialization
    # -------------------------------------------------
    def init_state(self, syndromes: List[Any]) -> RiBMState:
        """
        Initialize Algorithm A state from 2t syndromes [S0, ..., S_{2t-1}].
        """
        if len(syndromes) != 2 * self.t:
            raise ValueError(f"Expected {2 * self.t} syndromes, got {len(syndromes)}")

        F = self.field
        lambda_reg = [F(1)]
        b_reg = [F(1)]            # represents x^(-1)
        delta_reg = list(syndromes)
        theta_reg = list(syndromes[1:]) if len(syndromes) > 1 else [F(0)]
        gamma_reg = F(1)
        k_reg = -1
        r_reg = 0

        return RiBMState(
            lambda_reg=lambda_reg,
            b_reg=b_reg,
            delta_reg=delta_reg,
            theta_reg=theta_reg,
            gamma_reg=gamma_reg,
            k_reg=k_reg,
            r_reg=r_reg,
        )

    # -------------------------------------------------
    # one hardware-style step: r -> r+2
    # -------------------------------------------------
    def step(self, state: RiBMState) -> RiBMState:
        F = self.field
        t = self.t
        max_lambda_len = t + 1
        max_aux_len = 2 * t

        lambda_reg = list(state.lambda_reg)
        b_reg = list(state.b_reg)
        delta_reg = list(state.delta_reg)
        theta_reg = list(state.theta_reg)
        gamma_reg = state.gamma_reg
        k_reg = state.k_reg
        r_reg = state.r_reg

        delta0 = delta_reg[0] if len(delta_reg) > 0 else F(0)

        # -------------------------------------------------
        # comb logic
        # 1) Lambda^(r+2)(x) = gamma^(r) Lambda^(r)(x) + Delta0^(r) x^2 B^(r)(x)
        # 2) Delta^(r+2)(x)  = gamma^(r) Delta^(r)(x)/x^2 + Delta0^(r) Theta^(r)(x)
        # -------------------------------------------------
        lambda_term_1 = self._poly_scale(lambda_reg, gamma_reg)
        lambda_term_2 = self._poly_scale(self._x2_times_b(b_reg), delta0)
        print(f"lambdat1: {lambda_term_1}")
        print(f"lambdat2: {lambda_term_2}")
        lambda_next = self._poly_add(lambda_term_1, lambda_term_2)

        delta_term_1 = self._poly_scale(self._poly_div_x2(delta_reg), gamma_reg)
        delta_term_2 = self._poly_scale(theta_reg, delta0)
        delta_next = self._poly_add(delta_term_1, delta_term_2)

        if (delta0 != 0) and (k_reg >= -1):
            b_next = self._b_from_lambda(lambda_reg)
            theta_next = self._poly_div_x2(delta_reg)
            gamma_next = delta0
            k_next = -k_reg - 2
        else:
            b_next = self._b_shift_x2(b_reg)
            theta_next = list(theta_reg)
            gamma_next = gamma_reg
            k_next = k_reg + 2

        # fixed-width style for easier RTL comparison
        lambda_next = self._poly_pad(self._strip_trailing_zeros(lambda_next), max_lambda_len)
        b_next = self._poly_pad(self._strip_trailing_zeros(b_next), max_lambda_len + 1)
        delta_next = self._poly_pad(self._strip_trailing_zeros(delta_next), max_aux_len)
        theta_next = self._poly_pad(self._strip_trailing_zeros(theta_next), max_aux_len)

        return RiBMState(
            lambda_reg=lambda_next,
            b_reg=b_next,
            delta_reg=delta_next,
            theta_reg=theta_next,
            gamma_reg=gamma_next,
            k_reg=k_next,
            r_reg=r_reg + 2,
        )

    # -------------------------------------------------
    # full KES run
    # -------------------------------------------------
    def run(self, syndromes: List[Any]) -> Dict[str, Any]:
        """
        Run the simplified riBM / Berlekamp algorithm for binary BCH decoding.

        Input:
            syndromes = [S0, S1, ..., S_{2t-1}] as field elements

        Returns:
            {
                "locator": ordinary locator polynomial in ascending-degree form,
                "state": final RiBMState,
                "trace": cycle-by-cycle states,
            }
        """
        state = self.init_state(syndromes)
        trace = [self._snapshot(state)]

        for _ in range(self.t):
            state = self.step(state)
            trace.append(self._snapshot(state))

        locator = self._strip_trailing_zeros(state.lambda_reg)

        return {
            "locator": locator,
            "state": state,
            "trace": trace,
        }

    def _snapshot(self, state: RiBMState) -> Dict[str, Any]:
        return {
            "r_reg": state.r_reg,
            "lambda_reg": list(state.lambda_reg),
            "b_reg": list(state.b_reg),
            "delta_reg": list(state.delta_reg),
            "theta_reg": list(state.theta_reg),
            "gamma_reg": state.gamma_reg,
            "k_reg": state.k_reg,
        }

    # -------------------------------------------------
    # optional utility: pretty print
    # -------------------------------------------------
    def coeffs_to_int(self, poly: List[Any]) -> List[int]:
        return [int(x) for x in poly]


    def check_root(self, locator):
        bch_dec = BCHDecoder(self.q, self.t, self.p_str)
        error_pos = bch_dec.chien_search(locator)
        return error_pos

    def print_pe_state(self, state: RiBMState, title: str = ""):
        """
        Print one state in a PE-like style.

        lambda_reg: ordinary polynomial, PE i <-> x^i
        b_reg: shifted polynomial,  PE i <-> x^(i-1)
        delta_reg: ordinary discrepancy polynomial, PE i <-> x^i
        theta_reg: ordinary scratch polynomial, PE i <-> x^i
        """
        if title:
            print(title)

        print(f"r = {state.r_reg}, k = {state.k_reg}, gamma = {int(state.gamma_reg)}")

        print("\n[Lambda PEs]  (PE i stores coeff of x^i)")
        for i, v in enumerate(state.lambda_reg):
            print(f"  PE_L{i:02d} : {int(v)}")

        print("\n[B PEs]       (PE i stores coeff of x^(i-1))")
        for i, v in enumerate(state.b_reg):
            if i == 0:
                power_str = "x^(-1)"
            elif i == 1:
                power_str = "x^(0)"
            else:
                power_str = f"x^({i-1})"
            print(f"  PE_B{i:02d} : {int(v)}   <- {power_str}")

        print("\n[Delta PEs]   (PE i stores coeff of x^i)")
        for i, v in enumerate(state.delta_reg):
            print(f"  PE_D{i:02d} : {int(v)}")

        print("\n[Theta PEs]   (PE i stores coeff of x^i)")
        for i, v in enumerate(state.theta_reg):
            print(f"  PE_T{i:02d} : {int(v)}")

    def print_trace_pe_style(self, trace: List[Dict[str, Any]]):
        """
        Print the whole trace cycle by cycle.
        """
        for cyc, snap in enumerate(trace):
            print("=" * 60)
            print(f"Cycle / snapshot #{cyc}")

            state = RiBMState(
                lambda_reg=snap["lambda_reg"],
                b_reg=snap["b_reg"],
                delta_reg=snap["delta_reg"],
                theta_reg=snap["theta_reg"],
                gamma_reg=snap["gamma_reg"],
                k_reg=snap["k_reg"],
                r_reg=snap["r_reg"],
            )

            self.print_pe_state(state)
            print()
if __name__ == "__main__":
    # Minimal smoke-test scaffold.
    # Replace these syndromes with a real BCH syndrome sequence when testing.
    q = 6
    t = 2
    p_str = "x^6 + x + 1"

    kes = BCHRiBMSkip(q=q, t=t, p_str=p_str)
    F = kes.field

    # Example placeholder: 2t syndromes [S0, S1, ..., S_{2t-1}]
    syndromes = [F(24), F(15), F(47), F(2)]

    result = kes.run(syndromes)

    print("locator =", kes.coeffs_to_int(result["locator"]))
    print("error pos=", kes.check_root(result["locator"]))
    kes.print_trace_pe_style(result["trace"])

# [GF(9, order=2^6), GF(2, order=2^6), GF(42, order=2^6), GF(4, order=2^6)]
# [GF(24, order=2^6), GF(15, order=2^6), GF(47, order=2^6), GF(22, order=2^6)]
# 12, 41