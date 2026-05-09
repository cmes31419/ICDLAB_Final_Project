import random
from ..galois_field import GF

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
        self.w = [len(g) - 1 for g in self.g_polys] # degree of generator y

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

    @staticmethod
    def bits_str_to_poly_list(bit_string):
        """
        Input string format: MSB on left, LSB on right
        Output list format: ascending-degree, i.e. index 0 is x^0
        """
        return [int(ch) for ch in bit_string[::-1]]

    @staticmethod
    def poly_list_to_bits_str(poly):
        """
        Input list format: ascending-degree
        Output string format: MSB on left, LSB on right
        """
        return "".join(str(b) for b in poly[::-1])

    @staticmethod
    def strip_trailing_zeros(poly):
        res = list(poly)
        while len(res) > 0 and res[-1] == 0:
            res.pop()
        return res

    def gf_elem_to_binary_poly(self, elem):
        """
        Convert a GF(2^q) field element to ascending-degree binary polynomial form.
        Example:
            alpha^k  -->  [b0, b1, ..., b_{q-1}]
        """
        bin_array = elem.vector().tolist()   # [x^(q-1), ..., x, 1]
        bin_array.reverse()                  # [1, x, ..., x^(q-1)]
        return self.strip_trailing_zeros([int(b) for b in bin_array])

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
    def compute_syndromes(self, word, t):
        """
        word: ascending-degree binary polynomial
        return:
            [S1, S2, ..., S_{2t}] as GF field elements
        """
        return [self.gf.eval_poly_at_alpha(word, j) for j in range(1, 2 * t + 1)]
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

    # --- Checker ---
    def check_word_in_code(self, word, layer_idx):
        """
        Check whether word belongs to C_layer_idx by verifying
        S1..S_{2t_layer_idx} are all zero.

        layer_idx = 0 means C0
        layer_idx = 1 means C1
        ...
        """
        t = self.t_list[layer_idx]
        syn = self.compute_syndromes(word, t)
        success = all(s == 0 for s in syn)
        return success, syn

    def build_nested_codeword(self, codewords, nested_level):
        """
        Build nested codeword for level `nested_level`:

            c_tilde_l(x) = sum_i alpha(x^{i*l}) * c_i(x)

        Here we implement it as:
            coefficient poly of alpha^(i*l)  *  c_i(x)
        and then XOR all terms together.

        codewords:
            list of sub-codewords in ascending-degree binary-list form
        """
        c_tilde = []

        for i, c_i in enumerate(codewords):
            elem = self.gf.alpha ** (i * nested_level)
            coeff_poly = self.gf_elem_to_binary_poly(elem)
            term = self.poly_mul_bin(c_i, coeff_poly)
            c_tilde = self.poly_add_bin(c_tilde, term)

        return c_tilde

    def check_gii_codeword(self, codewords, verbose=True):
        """
        Check whether a list of codewords satisfies:
          1. each c_i belongs to C0
          2. each nested codeword c_tilde_l belongs to C_{v-l}

        Input:
            codewords:
                can be either
                - list of MSB-left bit strings
                - list of ascending-degree binary lists

        Returns:
            result = {
                "base_ok": bool,
                "nested_ok": bool,
                "overall_ok": bool,
                "base_results": [...],
                "nested_results": [...],
            }
        """
        # normalize input to ascending-degree binary lists
        if len(codewords) != self.m:
            raise ValueError(f"Expected {self.m} codewords, got {len(codewords)}")

        if isinstance(codewords[0], str):
            words = [self.bits_str_to_poly_list(c) for c in codewords]
        else:
            words = [list(c) for c in codewords]

        base_results = []
        base_ok = True

        # 1) check each c_i in C0
        for i, w in enumerate(words):
            ok, syn = self.check_word_in_code(w, layer_idx=0)
            base_results.append({
                "index": i,
                "success": ok,
                "syndromes": syn,
            })
            if not ok:
                base_ok = False

        nested_results = []
        nested_ok = True

        # 2) check each nested codeword in C_{v-l}
        for l in range(self.v):
            c_tilde = self.build_nested_codeword(words, l)
            layer_idx = self.v - l   # l=0 -> C_v, l=1 -> C_{v-1}, ...
            ok, syn = self.check_word_in_code(c_tilde, layer_idx=layer_idx)

            nested_results.append({
                "nested_level": l,
                "target_layer": layer_idx,
                "success": ok,
                "nested_codeword": c_tilde,
                "syndromes": syn,
            })

            if not ok:
                nested_ok = False

        overall_ok = base_ok and nested_ok

        if verbose:
            print("=" * 60)
            print("GII encoding check")
            print("=" * 60)

            print("\n[Base codeword check]")
            for item in base_results:
                syn_int = [int(s) for s in item["syndromes"]]
                print(
                    f"c[{item['index']}] in C0 ? {item['success']} "
                    f"| syndromes = {syn_int}"
                )

            print("\n[Nested codeword check]")
            for item in nested_results:
                syn_int = [int(s) for s in item["syndromes"]]
                print(
                    f"c_tilde_{item['nested_level']} in C{item['target_layer']} ? "
                    f"{item['success']} | syndromes = {syn_int}"
                )

            print(f"\nOverall OK = {overall_ok}")

        return {
            "base_ok": base_ok,
            "nested_ok": nested_ok,
            "overall_ok": overall_ok,
            "base_results": base_results,
            "nested_results": nested_results,
        }

