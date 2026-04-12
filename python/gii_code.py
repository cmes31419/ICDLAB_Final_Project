from galois_field import GF

class GII_code:

    def __init__(self,q, m ,v, t_list):
        """
        q: degree of Galois field, e.g. GF(2^q)
        m: number of interleaves
        v: number of nested layers
        t_list: list of error correcting capability, e.g. [t0, t1, ..., tv]
        """
        self.gf = GF(q)
        self.m = m
        self.v = v
        self.t_list = t_list

        # Validation checks
        assert len(self.t_list) == self.v + 1, f"t_list must have {self.v + 1} elements."
        assert all(self.t_list[i] <= self.t_list[i+1] for i in range(len(self.t_list)-1)), "t_list must be non-decreasing."

        self.g_polys = self._build_generators()

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

    def print_generators(self):
        """Helper to print the generated polynomials."""
        for i, (t, g) in enumerate(zip(self.t_list, self.g_polys)):
            print(f"--- Layer {i} (t={t}) ---")
            self.gf.print_binary_poly(f"g{i}(x)", g)
            print(f"Parity Length (r_{i}): {len(g) - 1} bits\n")

# --- Test Block ---
if __name__ == "__main__":
    # Field: GF(2^6), Interleaves: 4, Nested Layers: 2, Error Caps: [2, 4, 6]
    gii = GII_code(q=6, m=4, v=2, t_list=[2, 4, 6])
    # print(gii.g_polys)
    gii.print_generators()