from __future__ import annotations
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from dataclasses import dataclass
from typing import Any, Dict, List

from galois_field import GF


@dataclass
class NestedKESState:
    """
    Hardware-style register state for Algorithm B in
    'Reduced-Complexity Key Equation Solvers for GII-BCH Decoders'.

    Storage convention:
    - lambda_even_reg[i] stores coeff of x^(2i)
    - lambda_odd_reg[i]  stores coeff of x^(2i+1), but compressed as coeff list
    - b_even_reg[i]      stores coeff of x^(2i)
    - b_odd_reg[i]       stores coeff of x^(2i+1), compressed
    - delta_even_reg[i]  stores coeff of x^(2i)
    - theta_even_reg[i]  stores coeff of x^(2i)
    - gamma_reg, k_reg, r_reg are scalars
    """

    lambda_even_reg: List[Any]
    lambda_odd_reg: List[Any]
    b_even_reg: List[Any]
    b_odd_reg: List[Any]
    delta_even_reg: List[Any]
    theta_even_reg: List[Any]
    gamma_reg: Any
    k_reg: int
    r_reg: int


class GIIBCHNestedKES:
    """
    Hardware-style Python model of Algorithm B.

    This model is intended as a correctness / RTL-reference model.
    It starts from an existing KES state at iteration r = u and
    incorporates higher-order syndromes S_u ... S_{w-1}.
    """

    def __init__(self, q: int, tv: int, p_str: str):
        self.gf = GF(q, p_str)
        self.field = self.gf.field
        self.q = q
        self.tv = tv
        self.p_str = p_str

        # h + 1 = ceil((tv + 1) / 2)
        self.row_len = (tv + 2) // 2

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

    def _poly_shift_left(self, poly: List[Any], places: int) -> List[Any]:
        """
        Multiply compressed polynomial by x^(2*places) in compressed domain.
        Example:
            even-compressed [a0,a2,a4] -> x^2 * (...) => prepend one zero
        """
        F = self.field
        return [F(0)] * places + list(poly)

    def _poly_div_x2_compressed(self, poly: List[Any]) -> List[Any]:
        """
        Divide compressed even/odd polynomial by x^2.
        In compressed storage this is just dropping the first coefficient.
        """
        F = self.field
        if len(poly) <= 1:
            return [F(0)]
        return self._strip_trailing_zeros(list(poly[1:]))

    # -------------------------------------------------
    # initialization
    # -------------------------------------------------
    def init_state(
        self,
        lambda_even: List[Any],
        lambda_odd: List[Any],
        b_even: List[Any],
        b_odd: List[Any],
        delta_even: List[Any],
        theta_even: List[Any],
        gamma: Any,
        k: int,
        u: int,
        syndromes: List[Any],
    ) -> NestedKESState:
        """
        Initialize Algorithm B state at iteration r = u.

        syndromes is the full available syndrome list, and must contain S_u
        because initialization injects:
            delta_even += S_u * lambda_even
            theta_even += S_u * b_even
        """
        F = self.field
        Su = syndromes[u]

        lambda_even_reg = self._poly_pad(self._strip_trailing_zeros(lambda_even), self.row_len)
        lambda_odd_reg  = self._poly_pad(self._strip_trailing_zeros(lambda_odd),  self.row_len)
        b_even_reg      = self._poly_pad(self._strip_trailing_zeros(b_even),      self.row_len)
        b_odd_reg       = self._poly_pad(self._strip_trailing_zeros(b_odd),       self.row_len)
        delta_even_reg  = self._poly_pad(self._strip_trailing_zeros(delta_even),  self.row_len)
        theta_even_reg  = self._poly_pad(self._strip_trailing_zeros(theta_even),  self.row_len)

        # Algorithm B initialization:
        # Delta_even^(u) <- Delta_even^(u) + S_u * Lambda_even^(u)
        # Theta_even^(u) <- Theta_even^(u) + S_u * B_even^(u)
        delta_even_reg = self._poly_pad(
            self._poly_add(delta_even_reg, self._poly_scale(lambda_even_reg, Su)),
            self.row_len
        )
        # print(f"[DEBUG] delta_even_reg after init: {delta_even_reg}")
        theta_even_reg = self._poly_pad(
            self._poly_add(theta_even_reg, self._poly_scale(b_even_reg, Su)),
            self.row_len
        )
        # print(f"[DEBUG] theta_even_reg after init: {theta_even_reg}")

        return NestedKESState(
            lambda_even_reg=lambda_even_reg,
            lambda_odd_reg=lambda_odd_reg,
            b_even_reg=b_even_reg,
            b_odd_reg=b_odd_reg,
            delta_even_reg=delta_even_reg,
            theta_even_reg=theta_even_reg,
            gamma_reg=gamma,
            k_reg=k,
            r_reg=u,
        )

    # -------------------------------------------------
    # one step: r -> r+2
    # -------------------------------------------------
    def step(self, state: NestedKESState, syndromes: List[Any]) -> NestedKESState:
        F = self.field

        r = state.r_reg
        Sr1 = syndromes[r + 1]
        Sr2 = syndromes[r + 2] if (r + 2) < len(syndromes) else F(0)

        lambda_even = list(state.lambda_even_reg)
        lambda_odd = list(state.lambda_odd_reg)
        b_even = list(state.b_even_reg)
        b_odd = list(state.b_odd_reg)
        delta_even = list(state.delta_even_reg)
        theta_even = list(state.theta_even_reg)
        gamma = state.gamma_reg
        k = state.k_reg

        delta0 = delta_even[0] if len(delta_even) > 0 else F(0)

        # -------------------------------------------------
        # Lines 1-2:
        # Lambda_even^(r+2) = gamma * Lambda_even^(r) + Delta0 * x^2 * B_even^(r)
        # Lambda_odd^(r+2)  = gamma * Lambda_odd^(r)  + Delta0 * x^2 * B_odd^(r)
        # -------------------------------------------------
        # print(f"[DEBUG] delta0: {delta0}")
        # print(f"[DEBUG] b_even shifted: {self._poly_shift_left(b_even, 1)}")
        # print(f"[DEBUG] lambda_even: {lambda_even}, scaled: {self._poly_scale(lambda_even, gamma)}")
        lambda_even_next = self._poly_add(
            self._poly_scale(lambda_even, gamma),
            self._poly_scale(self._poly_shift_left(b_even, 1), delta0)
        )
        # print(f"[DEBUG] lambda_even_next: {lambda_even_next}")

        lambda_odd_next = self._poly_add(
            self._poly_scale(lambda_odd, gamma),
            self._poly_scale(self._poly_shift_left(b_odd, 1), delta0)
        )

        # -------------------------------------------------
        # Line 3:
        # Delta_even^(r+2) =
        # gamma*(Delta_even/x^2 + S_{r+1} Lambda_odd/x + S_{r+2} Lambda_even)
        # + Delta0*(Theta_even + S_{r+1} x B_odd + S_{r+2} x^2 B_even)
        #
        # In compressed storage:
        #   Lambda_odd/x   -> same compressed coeff list as lambda_odd
        #   x B_odd        -> same compressed coeff list as b_odd
        #   x^2 B_even     -> shift-left by 1 in compressed domain
        #   Delta_even/x^2 -> drop first compressed coeff
        # -------------------------------------------------
        delta_term_1 = self._poly_div_x2_compressed(delta_even)
        delta_term_2 = self._poly_scale(lambda_odd, Sr1)
        delta_term_3 = self._poly_scale(lambda_even, Sr2)

        delta_term_4 = theta_even
        delta_term_5 = self._poly_scale(self._poly_shift_left(b_odd, 1), Sr1)
        delta_term_6 = self._poly_scale(self._poly_shift_left(b_even, 1), Sr2)

        # print(f"[DEBUG] b_odd: {b_odd}, shifted b_odd: {self._poly_shift_left(b_odd, 1)}")
        # print(f"[DEBUG] b_even: {b_even}, shifted b_even: {self._poly_shift_left(b_even, 1)}")
        # print(f"[DEBUG] delta_term_4: {delta_term_4}")
        # print(f"[DEBUG] delta_term_5: {delta_term_5}")
        # print(f"[DEBUG] delta_term_6: {delta_term_6}")
        # print(f"[DEBUG] term1: {self._poly_add(self._poly_add(delta_term_1, delta_term_2), delta_term_3)}")
        # print(f"[DEBUG] term2: {self._poly_add(self._poly_add(delta_term_4, delta_term_5), delta_term_6)}")
        term1 = self._poly_add(self._poly_add(delta_term_1, delta_term_2), delta_term_3)
        term2 = self._poly_add(self._poly_add(delta_term_4, delta_term_5), delta_term_6)

        delta_even_next = self._poly_add(
            self._poly_scale(
                term1,
                gamma
            ),
            self._poly_scale(
                term2,
                delta0
            )
        )

        # -------------------------------------------------
        # Lines 4-9: branch
        # -------------------------------------------------
        if (delta0 != 0) and (k >= -1):
            b_even_next = list(lambda_even)
            b_odd_next = list(lambda_odd)

            # theta_even_next = self._poly_add(
            #     self._poly_add(
            #         self._poly_div_x2_compressed(delta_even),
            #         self._poly_scale(lambda_odd, Sr1)
            #     ),
            #     self._poly_scale(lambda_even, Sr2)
            # )
            theta_even_next = term1
            # print(f"[DEBUG] theta_even_next: {theta_even_next}")

            gamma_next = delta0
            k_next = -k - 2
        else:
            b_even_next = self._poly_shift_left(b_even, 1)
            b_odd_next = self._poly_shift_left(b_odd, 1)

            # theta_even_next = self._poly_add(
            #     self._poly_add(theta_even, self._poly_scale(b_odd, Sr1)),
            #     self._poly_scale(self._poly_shift_left(b_even, 1), Sr2)
            # )
            theta_even_next = term2

            gamma_next = gamma
            k_next = k + 2

        # fixed width for RTL-style comparison
        lambda_even_next = self._poly_pad(self._strip_trailing_zeros(lambda_even_next), self.row_len)
        lambda_odd_next  = self._poly_pad(self._strip_trailing_zeros(lambda_odd_next),  self.row_len)
        b_even_next      = self._poly_pad(self._strip_trailing_zeros(b_even_next),      self.row_len)
        b_odd_next       = self._poly_pad(self._strip_trailing_zeros(b_odd_next),       self.row_len)
        delta_even_next  = self._poly_pad(self._strip_trailing_zeros(delta_even_next),  self.row_len)
        theta_even_next  = self._poly_pad(self._strip_trailing_zeros(theta_even_next),  self.row_len)

        return NestedKESState(
            lambda_even_reg=lambda_even_next,
            lambda_odd_reg=lambda_odd_next,
            b_even_reg=b_even_next,
            b_odd_reg=b_odd_next,
            delta_even_reg=delta_even_next,
            theta_even_reg=theta_even_next,
            gamma_reg=gamma_next,
            k_reg=k_next,
            r_reg=r + 2,
        )

    # -------------------------------------------------
    # run from r=u to r=w-2
    # -------------------------------------------------
    def run(
        self,
        lambda_even: List[Any],
        lambda_odd: List[Any],
        b_even: List[Any],
        b_odd: List[Any],
        delta_even: List[Any],
        theta_even: List[Any],
        gamma: Any,
        k: int,
        u: int,
        w: int,
        syndromes: List[Any],
    ) -> Dict[str, Any]:
        """
        Run Algorithm B from r = u, u+2, ..., w-2.
        Caller should provide syndromes with S_w = 0 already appended if needed.
        """
        state = self.init_state(
            lambda_even=lambda_even,
            lambda_odd=lambda_odd,
            b_even=b_even,
            b_odd=b_odd,
            delta_even=delta_even,
            theta_even=theta_even,
            gamma=gamma,
            k=k,
            u=u,
            syndromes=syndromes,
        )

        trace = [self._snapshot(state)]

        for _ in range((w - u) // 2):
            state = self.step(state, syndromes)
            trace.append(self._snapshot(state))

        return {
            "state": state,
            "trace": trace,
        }

    # -------------------------------------------------
    # utilities
    # -------------------------------------------------
    def _snapshot(self, state: NestedKESState) -> Dict[str, Any]:
        return {
            "r_reg": state.r_reg,
            "lambda_even_reg": list(state.lambda_even_reg),
            "lambda_odd_reg": list(state.lambda_odd_reg),
            "b_even_reg": list(state.b_even_reg),
            "b_odd_reg": list(state.b_odd_reg),
            "delta_even_reg": list(state.delta_even_reg),
            "theta_even_reg": list(state.theta_even_reg),
            "gamma_reg": state.gamma_reg,
            "k_reg": state.k_reg,
        }

    def coeffs_to_int(self, poly: List[Any]) -> List[int]:
        return [int(x) for x in poly]

    def print_state(self, state: NestedKESState, title: str = ""):
        if title:
            print(title)
        print(f"r = {state.r_reg}, k = {state.k_reg}, gamma = {int(state.gamma_reg)}")

        print("\n[Lambda_even PEs] (coeffs of x^(0), x^(2), x^(4), ...)")
        for i, v in enumerate(state.lambda_even_reg):
            print(f"  PE_LE{i:02d}: {int(v)}")

        print("\n[Lambda_odd PEs]  (coeffs of x^(1), x^(3), x^(5), ...)")
        for i, v in enumerate(state.lambda_odd_reg):
            print(f"  PE_LO{i:02d}: {int(v)}")

        print("\n[B_even PEs]")
        for i, v in enumerate(state.b_even_reg):
            print(f"  PE_BE{i:02d}: {int(v)}")

        print("\n[B_odd PEs]")
        for i, v in enumerate(state.b_odd_reg):
            print(f"  PE_BO{i:02d}: {int(v)}")

        print("\n[Delta_even PEs]")
        for i, v in enumerate(state.delta_even_reg):
            print(f"  PE_DE{i:02d}: {int(v)}")

        print("\n[Theta_even PEs]")
        for i, v in enumerate(state.theta_even_reg):
            print(f"  PE_TE{i:02d}: {int(v)}")

    def print_trace(self, trace: List[Dict[str, Any]]):
        for idx, snap in enumerate(trace):
            print("=" * 60)
            print(f"Snapshot #{idx}")
            state = NestedKESState(
                lambda_even_reg=snap["lambda_even_reg"],
                lambda_odd_reg=snap["lambda_odd_reg"],
                b_even_reg=snap["b_even_reg"],
                b_odd_reg=snap["b_odd_reg"],
                delta_even_reg=snap["delta_even_reg"],
                theta_even_reg=snap["theta_even_reg"],
                gamma_reg=snap["gamma_reg"],
                k_reg=snap["k_reg"],
                r_reg=snap["r_reg"],
            )
            self.print_state(state)
            print()


if __name__ == "__main__":
    q = 6
    tv = 6
    p_str = "x^6 + x + 1"

    kes = GIIBCHNestedKES(q=q, tv=tv, p_str=p_str)
    F = kes.field

    # lambda_even = [F(7), F(18), F(37)]     
    # lambda_odd  = [F(63), F(42)]
    # b_even      = [F(49), F(35)]
    # b_odd       = [F(51), F(57)]
    # delta_even  = [F(41), F(41)]
    # theta_even  = [F(47), F(2)]
    # gamma       = F(4)
    # k           = -1

    lambda_even = [F(43), F(39)]     
    lambda_odd  = [F(54)]
    b_even      = [F(1), F(0)]
    b_odd       = [F(43)]
    delta_even  = [F(17), F(0)]
    theta_even  = [F(8), F(0)]
    gamma       = F(39)
    k           = -1
    # full syndrome array; must contain S_u ... S_w, with S_w = 0 if needed
    # syndromes = [F(0), F(0), F(0), F(0), F(11), F(12), F(13), F(0)]
    syndromes = [F(43), F(54), F(41), F(40), F(27), F(50), F(23), F(51), F(0)]
    # syndromes = [F(9), F(2), F(42), F(4), F(45), F(55), F(41), F(16), F(15), F(34), F(60), F(41)]
    # u = 8
    # w = 12   # run r = 4, 6

    u=4
    w=8

    # print(kes._poly_add(
    #     [F(17), F(0)],
    #     kes._poly_scale([F(43), F(39)], F(27))
    # ))

    # print(kes._poly_add(
    #     kes._poly_scale([F(43), F(39)], F(39)),
    #     kes._poly_scale([F(0), F(1)], F(22))
    # ))
    # print(kes._poly_add(
    #     kes._poly_scale([F(54), F(0)], F(39)),
    #     kes._poly_scale([F(0), F(43)], F(22))
    # ))


    # term1 = kes._poly_add(
    #     kes._poly_add([F(53), F(0)], kes._poly_scale([F(54), F(0)], F(50))),
    #     kes._poly_scale([F(43), F(39)], F(23)) 
    # )
    # term2 = kes._poly_add(
    #     kes._poly_add([F(19), F(0)], kes._poly_scale([F(0), F(43)], F(50))),
    #     kes._poly_scale([F(0), F(1)], F(23))
    # )
    # delta_even = kes._poly_add(
    #     kes._poly_scale(term1, F(39)),
    #     kes._poly_scale(term2, F(22))
    # )
    # print(f"delta_even: {delta_even}")

    result = kes.run(
        lambda_even=lambda_even,
        lambda_odd=lambda_odd,
        b_even=b_even,
        b_odd=b_odd,
        delta_even=delta_even,
        theta_even=theta_even,
        gamma=gamma,
        k=k,
        u=u,
        w=w,
        syndromes=syndromes,
    )

    kes.print_trace(result["trace"])