import galois
import numpy as np

class GF:
    def __init__(self, m):
        self.m = m
        self.power_max = (2 ** m) - 1
        self.field = galois.GF(2 ** m)
        self.alpha = self.field.primitive_element

    def get_cyclotomic_coset(self, start_root):
        coset = []
        val = start_root % self.power_max
        while val not in coset:
            coset.append(val)
            val = (val * 2) % self.power_max
        return coset

    def get_minimal_polynomial(self, coset):
        roots = [self.alpha ** p for p in coset]
        poly = galois.Poly.Roots(roots, field=self.field)
        coeffs = poly.coeffs.tolist()
        coeffs.reverse() 
        return [int(c % 2) for c in coeffs]

    def poly_mul(self, p1, p2):
        if not p1 or not p2: return []
        res = [0] * (len(p1) + len(p2) - 1)
        for i, b1 in enumerate(p1):
            if b1:
                for j, b2 in enumerate(p2):
                    if b2: res[i + j] ^= 1
        return res

    def eval_poly_at_alpha(self, poly_bin, power):
        result = self.field(0)
        alpha_pow = self.alpha ** power
        curr_x = self.field(1)
        for coeff in poly_bin:
            if coeff: result += curr_x
            curr_x *= alpha_pow
        return result