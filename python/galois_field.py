import galois
import numpy as np

class GF:
    def __init__(self,m):
        self.m = m
        self.power_max = (2**m) - 1
        self.field = galois.GF(2**m)
        self.alpha = self.field.primitive_element

    # ------ cyclotomic cosets and minimal polynomial -----
    def get_cyclotomic_coset(self, start_root):
        """Generates the cyclotomic coset for a given root."""
        coset = []
        val = start_root
        while val not in coset:
            coset.append(val)
            val = (val * 2) % self.power_max
        return coset

    def get_minimal_polynomial(self, coset):
        """Constructs the minimal polynomial natively using the galois library."""
        # 1. Generate the actual roots in the field: alpha^p
        roots = [self.alpha**p for p in coset]
        
        # 2. galois automatically multiplies (x - r) for all roots
        poly = galois.Poly.Roots(roots, field=self.field)
        
        # 3. Extract coefficients. galois outputs descending order [x^m ... x^0].
        # We reverse it to match the ascending hardware array format [x^0 ... x^m].
        coeffs = poly.coeffs.tolist()
        coeffs.reverse()
        return [int(c) for c in coeffs]
    
    # --- Binary Polynomial Operations ---

    def poly_mul(self, p1, p2):
        """Multiplies two binary polynomials using galois GF(2) arithmetic."""
        if not p1 or not p2: return []
        
        GF2 = galois.GF(2)
        # Convert our ascending lists [x^0, x^1...] to galois descending Poly objects
        poly1 = galois.Poly(p1[::-1], field=GF2)
        poly2 = galois.Poly(p2[::-1], field=GF2)
        
        # Multiply and extract
        res_poly = poly1 * poly2
        res_coeffs = res_poly.coeffs.tolist()
        res_coeffs.reverse()
        return [int(c) for c in res_coeffs]

    def print_binary_poly(self, name, poly):
        """Helper to print the polynomial in standard mathematical notation."""
        terms = []
        for deg in range(len(poly)-1, -1, -1):
            if poly[deg] != 0:
                if deg == 0:
                    terms.append("1")
                elif deg == 1:
                    terms.append("x")
                else:
                    terms.append(f"x^{deg}")
        if not terms:
            terms.append("0")
        print(f"{name} = " + " + ".join(terms))
    
    # --- GII-BCH Matrix Operations ---

    def get_pi_vector(self, m_interleaves, v_layers, i_layer):
        """
        Dynamically calculates the pi^(i) target polynomial multiplier vector 
        for GII-BCH encoding using native finite field matrix inversion.
        """
        # 1. Build the H Matrix: H[l, i] = alpha^(l*i)
        H_elements = [[self.alpha**(l * i) for i in range(m_interleaves)] for l in range(v_layers)]
        H = self.field(H_elements)

        # 2. Extract Gamma and Theta sub-matrices for the current layer
        Gamma = H[0 : i_layer + 1, 0 : i_layer + 1]
        Theta = H[0 : i_layer + 1, i_layer + 1 : m_interleaves]

        # 3. Invert Gamma using numpy and multiply its i-th row by Theta
        Gamma_inv = np.linalg.inv(Gamma)
        pi_vector_gf = Gamma_inv[i_layer, :] @ Theta

        # 4. Map the GF(2^m) elements to their binary basis polynomials for the VLSI shift registers
        pi_binary_polys = []
        for element in pi_vector_gf:
            # .vector() gives the binary representation [x^(m-1), ..., x^1, x^0]
            bin_array = element.vector().tolist()
            bin_array.reverse() 
            
            # Strip trailing zeros so the array length matches the true polynomial degree
            while len(bin_array) > 0 and bin_array[-1] == 0:
                bin_array.pop()
                
            pi_binary_polys.append(bin_array)
            
        return pi_binary_polys