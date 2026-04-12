class GF:
    # prim_poly stores the primive polynomial of given m
    # example m = 6, p(x) = 1 + x + x^6
    # x^6 = 1 + x (3 in table)
    prim_poly = {6:3, 8:29, 10:9}

    def __init__(self, m):
        self.m = m
        self.field_order = 2 ** m
        self.power_max = self.field_order - 1
        self.prim = self.prim_poly[m]
        self.power2poly = [0] * (self.field_order)  # Increased size to include 0
        self.poly2power = [0] * (self.field_order) 
        self.gentables()

    def gentables(self):
        self.power2poly[0] = 1 #alpha^0 = 1
        self.poly2power[0] = -1 # 0 has no power representation
        self.poly2power[1] = 0 # 1 = alpha^0
        for i in range(1, self.power_max):
            temp = self.power2poly[i-1] << 1
            if temp >= self.field_order:
                result = (temp % (self.field_order)) ^ self.prim
                self.power2poly[i] = result
                self.poly2power[result] = i
            else:
                self.power2poly[i]  = temp
                self.poly2power[temp] = i
                
    def print_table(self):
        for i in range(self.field_order):
            print(f"polyform: {self.power2poly[i]:0{self.m}b}, powerform: {self.poly2power[self.power2poly[i]]}")
    
    def print_poly(self, a):
        print(f"{a:0{self.m}b}")

    def poly_bin(self, a):
        return f"{a:0{self.m}b}"

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
        print(f"{name} = " + " + ".join(terms))

    def add(self, a, b):
        # add a, b in polyform
        return a ^ b

    def mul(self, a, b):
        """Multiply two elements using power form"""
        if a == 0 or b == 0:
            return 0
        a_power = self.poly2power[a]
        b_power = self.poly2power[b]
        result_power = (a_power + b_power) % self.power_max
        return self.power2poly[result_power]

    def inv(self, a):
        """Multiplicative inverse in GF(2^m), input in poly form."""
        if a == 0:
            raise ZeroDivisionError("Attempted to invert 0 in GF(2^m)")
        a_power = self.poly2power[a]
        inv_power = (self.power_max - a_power) % self.power_max
        return self.power2poly[inv_power]

    def div(self, a, b):
        """Division a / b in GF(2^m), inputs in poly form."""
        if b == 0:
            raise ZeroDivisionError("Attempted to divide by 0 in GF(2^m)")
        if a == 0:
            return 0
        a_power = self.poly2power[a]
        b_power = self.poly2power[b]
        res_power = (a_power - b_power) % self.power_max
        return self.power2poly[res_power]

    def get_cyclotomic_coset(self, start_root):
        """Generates the cyclotomic coset for a given root."""
        coset = []
        val = start_root
        while val not in coset:
            coset.append(val)
            val = (val * 2) % self.power_max
        return coset

    def poly_mul(self, p1, p2):
        """Multiplies two polynomials over GF(2^m).
        p1 and p2 are lists of coefficients where index i is the coeff for x^i."""
        deg1 = len(p1) - 1
        deg2 = len(p2) - 1
        res = [0] * (deg1 + deg2 + 1)
        
        for i, c1 in enumerate(p1):
            for j, c2 in enumerate(p2):
                # Multiply the coefficients and add (XOR) them to the corresponding degree
                product = self.mul(c1, c2)
                res[i+j] = self.add(res[i+j], product)
                
        return res

    def get_minimal_polynomial(self, coset):
        """Constructs the minimal polynomial from a cyclotomic coset."""
        res = [1]  # Start with the polynomial '1'
        for p in coset:
            # factor is (x - alpha^p) -> in GF(2) this is (alpha^p + x)
            # represented as [alpha^p, 1] since index 0 is x^0, index 1 is x^1
            alpha_p = self.power2poly[p]
            factor = [alpha_p, 1]
            res = self.poly_mul(res, factor)
        return res