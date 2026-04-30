import random
from galois_field import GF

class GII_code:

    def __init__(self,q, m ,v, t_list, p_str:str):
        """
        q: degree of Galois field, e.g. GF(2^q)
        m: number of interleaves
        v: number of nested layers
        t_list: list of error correcting capability, e.g. [t0, t1, ..., tv]
        p_str: primitive polynomial string, e.g. x^6 + x + 1
        """
        self.gf = GF(q, p_str)
        self.m = m
        self.v = v
        self.t_list = t_list

        # Validation checks
        assert len(self.t_list) == self.v + 1, f"t_list must have {self.v + 1} elements."
        assert all(self.t_list[i] <= self.t_list[i+1] for i in range(len(self.t_list)-1)), "t_list must be non-decreasing."

        self.g_polys = self._build_generators()
        self.w = [len(g) - 1 for g in self.g_polys] # degree of generator poly

    def _build_generators(self):
        """Builds the generator polynomial g_i(x) for each layer."""
        g_polys = []
        for t in self.t_list:
            g = [1] # Start with polynomial '1'
            processed_roots = set()
            for root_power in range(1, 2 * t + 1):
                if root_power not in processed_roots:
                    # Find the cyclotomic coset for this new root
                    coset = self.gf.get_cyclotomic_coset(root_power)
                    # Generate the minimal polynomial for this coset
                    min_poly = self.gf.get_minimal_polynomial(coset)
                    # Multiply it into the current layer's generator polynomial
                    g = self.gf.poly_mul(g, min_poly)
                    # Mark all roots in this coset as processed
                    processed_roots.update(coset)            
            g_polys.append(g)
            
        return g_polys

    # --- Purely Algorithmic Binary Math Helpers ---
    
    @staticmethod
    def poly_add_bin(p1, p2):
        """XORs two binary polynomials together."""
        max_len = max(len(p1), len(p2))
        res = [0] * max_len
        for i in range(max_len):
            b1 = p1[i] if i < len(p1) else 0
            b2 = p2[i] if i < len(p2) else 0
            res[i] = b1 ^ b2
        # Strip trailing zeros to maintain true polynomial degree
        while len(res) > 0 and res[-1] == 0:
            res.pop()
        return res

    @staticmethod
    def poly_mul_bin(p1, p2):
        if not p1 or not p2: return []
        res = [0] * (len(p1) + len(p2) - 1)
        for i, b1 in enumerate(p1):
            if b1:
                for j, b2 in enumerate(p2):
                    if b2:
                        res[i+j] ^= 1
        while len(res) > 0 and res[-1] == 0:
            res.pop()
        return res

    @staticmethod
    def poly_div_bin(dividend, divisor):
        """Returns remainder of dividend / divisor in GF(2)[x]"""
        rem = list(dividend)
        div = list(divisor)
        while len(div) > 0 and div[-1] == 0: div.pop()
        
        while len(rem) >= len(div):
            if rem[-1] == 1:
                shift = len(rem) - len(div)
                for i in range(len(div)):
                    rem[i + shift] ^= div[i]
            rem.pop()
        return rem

    # --- Operators for systematic encoding ---
    @staticmethod
    def U_w(f, w):
        """Upper operator: deletes lower w terms and divides by x^w"""
        return f[w:] if len(f) > w else []

    @staticmethod
    def L_w(f, w):
        """Lower operator: keeps only the lowest w terms"""
        res = f[:w]
        # Pad with zeros if f was shorter than w
        return res + [0] * (w - len(res))

    def Enc(self, data, g):
        """
        Algorithmic implementation of Enc{a(x), g(x)}.
        Computes remainder of a(x)*x^w / g(x).
        """
        w = len(g) - 1
        shifted_data = [0] * w + data
        p = self.poly_div_bin(shifted_data, g)
        return self.L_w(p, w) 



    def print_generators(self):
        """Helper to print the generated polynomials."""
        for i, (t, g) in enumerate(zip(self.t_list, self.g_polys)):
            print(f"--- Layer {i} (t={t}) ---")
            self.gf.print_binary_poly(f"g{i}(x)", g)
            print(f"Parity Length (r_{i}): {len(g) - 1} bits\n")

    def encode_random_data(self, n=63):
        c = [None] * self.m
        d = [None] * self.m # Data polynomials
        p = [None] * self.m # Parity polynomials
        
        # Generate random data arrays d_i based on required parity lengths
        for i in range(self.m):
            layer_idx = 0 if i >= self.v else self.v - i
            d[i] = [random.randint(0, 1) for _ in range(n - self.w[layer_idx])]

        # 1) First-level encoding (i = m-1 down to v)
        for i in range(self.m - 1, self.v - 1, -1):
            p[i] = self.Enc(d[i], self.g_polys[0])
            c[i] = p[i] + d[i] # Concatenate parity (lowest terms) with data

        # 2) Higher-level encoding (i = v-1 down to 0)
        for i in range(self.v - 1, -1, -1):
            layer_idx = self.v - i
            w_vi = self.w[layer_idx]
            g_vi = self.g_polys[layer_idx]

            pi_vector = self.gf.get_pi_vector(self.m, self.v, i)

            f_i = []
            
            # Perform the dot product: pi^(i)(x) * [c_{i+1}(x), ..., c_{m-1}(x)]^T
            for j, pi_poly in enumerate(pi_vector):
                target_c_idx = i + 1 + j
                term = self.poly_mul_bin(c[target_c_idx], pi_poly)
                f_i = self.poly_add_bin(f_i, term)
            # --------------------------------------------
            
            # Enc{ d_i(x) + U_w(f_i(x)), g_{v-i}(x) } -> p_i*(x)
            u_f = self.U_w(f_i, w_vi)
            d_plus_u = self.poly_add_bin(d[i], u_f)
            p_star = self.Enc(d_plus_u, g_vi)
            
            # p_i(x) = p_i*(x) + L_w(f_i(x))
            l_f = self.L_w(f_i, w_vi)
            p[i] = self.poly_add_bin(p_star, l_f)
            
            # Form final codeword
            c[i] = self.L_w(p[i], w_vi) + d[i]

        c_str = []
        for codeword in c:
            # Reverse the array so x^{n-1} is at index 0
            reversed_code = codeword[::-1]
            # Convert integers to string and join
            bit_string = "".join(str(bit) for bit in reversed_code)
            c_str.append(bit_string)

        return c_str

    