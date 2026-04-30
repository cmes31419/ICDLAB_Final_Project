from galois_field import GF


class BCHDecoder:
    def __init__(self, q: int, t: int, p_str: str):
        """
        q: GF(2^q)
        t: BCH error-correcting capability
        p_str: primitive / irreducible polynomial string used by main/galois_field.py
        """
        self.q = q
        self.t = t
        self.gf = GF(q, p_str)
        self.n = self.gf.power_max
        self.field = self.gf.field
        self.alpha = self.gf.alpha

    # -------------------------------------------------
    # Basic helpers
    # -------------------------------------------------

    @staticmethod
    def poly_degree(poly):
        """
        poly: ascending-degree list
        returns the true degree
        """
        d = len(poly) - 1
        while d > 0 and int(poly[d]) == 0:
            d -= 1
        return d

    @staticmethod
    def strip_trailing_zeros(poly):
        res = list(poly)
        while len(res) > 1 and int(res[-1]) == 0:
            res.pop()
        return res

    # -------------------------------------------------
    # Syndrome computation
    # -------------------------------------------------

    def compute_syndromes(self, word, t=None):
        """
        word: binary polynomial in ascending-degree form
              word[i] is coefficient of x^i
        returns:
            [S1, S2, ..., S_{2t}] as field elements
        """
        if t is None:
            t = self.t
        return [self.gf.eval_poly_at_alpha(word, j) for j in range(1, 2 * t + 1)]

    def compute_syndromes_range(self, word, j_start, j_end):
        """
        returns:
            [S_{j_start}, ..., S_{j_end}] as field elements
        """
        return [self.gf.eval_poly_at_alpha(word, j) for j in range(j_start, j_end + 1)]

    def syndromes_are_zero(self, syndromes):
        return all(s == 0 for s in syndromes)

    # -------------------------------------------------
    # Berlekamp-Massey
    # -------------------------------------------------

    def berlekamp_massey(self, syndromes):
        """
        Standard Berlekamp-Massey over GF(2^q).

        Input:
            syndromes = [S1, S2, ..., S_{2t}] as field elements

        Returns:
            locator polynomial Lambda(x) in ascending-degree form:
                Lambda = [1, lambda1, lambda2, ...]
            plus BM state for continuation:
                (Lambda, B, b, L)
        """
        F = self.field

        Lambda = [F(1)]
        B = [F(1)]
        L = 0
        b = F(1)

        for r in range(len(syndromes)):
            d = F(0)
            for j in range(min(L + 1, len(Lambda))):
                if 0 <= r - j < len(syndromes):
                    d += Lambda[j] * syndromes[r - j]

            if d == 0:
                B = [F(0)] + B

            elif 2 * L <= r:
                T = Lambda[:]
                db = d / b
                xB = [F(0)] + B

                size = max(len(Lambda), len(xB))
                new_Lambda = [F(0)] * size

                for i, v in enumerate(Lambda):
                    new_Lambda[i] += v
                for i, v in enumerate(xB):
                    new_Lambda[i] += db * v

                Lambda = new_Lambda
                L = r + 1 - L
                B = T
                b = d

            else:
                db = d / b
                xB = [F(0)] + B

                size = max(len(Lambda), len(xB))
                new_Lambda = [F(0)] * size

                for i, v in enumerate(Lambda):
                    new_Lambda[i] += v
                for i, v in enumerate(xB):
                    new_Lambda[i] += db * v

                Lambda = new_Lambda
                B = [F(0)] + B

        Lambda = self.strip_trailing_zeros(Lambda)
        B = self.strip_trailing_zeros(B)

        return Lambda, B, b, L

    def berlekamp_massey_continue(self, Lambda, B, b, L, syndromes_full, r_start, r_end):
        """
        Continue BM from iteration r_start to r_end-1.

        This is useful later for GII nested decoding.

        Input:
            Lambda, B, b, L : saved BM state
            syndromes_full  : [S1, S2, ..., S_k]
            r_start, r_end  : BM loop index range

        Returns:
            updated (Lambda, B, b, L)
        """
        F = self.field

        for r in range(r_start, r_end):
            d = F(0)
            for j in range(min(L + 1, len(Lambda))):
                if 0 <= r - j < len(syndromes_full):
                    d += Lambda[j] * syndromes_full[r - j]

            if d == 0:
                B = [F(0)] + B

            elif 2 * L <= r:
                T = Lambda[:]
                db = d / b
                xB = [F(0)] + B

                size = max(len(Lambda), len(xB))
                new_Lambda = [F(0)] * size

                for i, v in enumerate(Lambda):
                    new_Lambda[i] += v
                for i, v in enumerate(xB):
                    new_Lambda[i] += db * v

                Lambda = new_Lambda
                L = r + 1 - L
                B = T
                b = d

            else:
                db = d / b
                xB = [F(0)] + B

                size = max(len(Lambda), len(xB))
                new_Lambda = [F(0)] * size

                for i, v in enumerate(Lambda):
                    new_Lambda[i] += v
                for i, v in enumerate(xB):
                    new_Lambda[i] += db * v

                Lambda = new_Lambda
                B = [F(0)] + B

        Lambda = self.strip_trailing_zeros(Lambda)
        B = self.strip_trailing_zeros(B)

        return Lambda, B, b, L

    # -------------------------------------------------
    # Chien search
    # -------------------------------------------------

    def chien_search(self, locator):
        """
        Find error positions k such that Lambda(alpha^{-k}) = 0.

        Input:
            locator polynomial in ascending-degree form with field coefficients

        Returns:
            error_positions: list[int]
        """
        F = self.field
        alpha = self.alpha
        n = self.n

        error_positions = []

        for k in range(n):
            val = F(0)
            exp = (n - k) % n
            for j, coeff in enumerate(locator):
                val += coeff * (alpha ** ((j * exp) % n))
            if val == 0:
                error_positions.append(k)

        return error_positions

    # -------------------------------------------------
    # Error correction helpers
    # -------------------------------------------------

    def flip_positions(self, word, error_positions):
        """
        word: binary polynomial in ascending-degree form
        error_positions: positions in polynomial index convention
        """
        corrected = list(word)
        for pos in error_positions:
            corrected[pos] ^= 1
        return corrected

    def validate_locator(self, locator, error_positions):
        """
        Basic consistency check:
            number of roots found should equal locator degree
        """
        deg = self.poly_degree(locator)
        return len(error_positions) == deg and deg > 0

    # -------------------------------------------------
    # One-shot BCH decode
    # -------------------------------------------------

    def decode(self, received):
        """
        Decode one BCH codeword.

        Input:
            received: binary polynomial in ascending-degree form

        Returns dict:
            {
                "success": bool,
                "syndromes": [...],
                "locator": [...],
                "error_positions": [...],
                "corrected": [...],
                "num_errors": int,
                "bm_state": (Lambda, B, b, L),
            }
        """
        syndromes = self.compute_syndromes(received, self.t)

        if self.syndromes_are_zero(syndromes):
            F = self.field
            return {
                "success": True,
                "syndromes": syndromes,
                "locator": [F(1)],
                "error_positions": [],
                "corrected": list(received),
                "num_errors": 0,
                "bm_state": ([F(1)], [F(1)], F(1), 0),
            }

        locator, B, b, L = self.berlekamp_massey(syndromes)
        error_positions = self.chien_search(locator)

        if not self.validate_locator(locator, error_positions):
            return {
                "success": False,
                "syndromes": syndromes,
                "locator": locator,
                "error_positions": error_positions,
                "corrected": list(received),
                "num_errors": 0,
                "bm_state": (locator, B, b, L),
            }

        corrected = self.flip_positions(received, error_positions)
        check_syndromes = self.compute_syndromes(corrected, self.t)

        success = self.syndromes_are_zero(check_syndromes)

        return {
            "success": success,
            "syndromes": syndromes,
            "locator": locator,
            "error_positions": error_positions,
            "corrected": corrected,
            "num_errors": len(error_positions) if success else 0,
            "bm_state": (locator, B, b, L),
        }

    # -------------------------------------------------
    # Optional format helpers for file/string interface
    # -------------------------------------------------

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

def read_codeword_lines(filename, n):
    """
    Read one binary codeword per line.
    Input format: MSB at left, LSB at right.
    """
    with open(filename, "r") as file:
        lines = [line.strip() for line in file if line.strip()]

    for idx, line in enumerate(lines, start=1):
        if len(line) != n:
            raise ValueError(
                f"Line {idx}: length = {len(line)}, expected {n}"
            )
        if any(ch not in "01" for ch in line):
            raise ValueError(
                f"Line {idx}: contains non-binary character"
            )

    return lines

q=6
t=2
n=2**q - 1
bch_dec = BCHDecoder(q, t, p_str="x^6 + x + 1")
filename = "../00_TB/testdata/pattern/p1.txt"

codewords = read_codeword_lines(filename, n)

print(f"Input file: {filename}")
print(f"q = {q}, n = {n}, t = {t}")
print(f"Total codewords = {len(codewords)}")
print()

for idx, code in enumerate(codewords):
    print(f"sub-codeword {idx}:")
    print(f"  received codeword = {code}")
    r = bch_dec.bits_str_to_poly_list(code)
    
    result = bch_dec.decode(r)

    syn_power = []
    for s in result["syndromes"]:
        if s == 0:
            syn_power.append(-1)
        else:
            syn_power.append(bch_dec.gf.field(s).log())
    print(syn_power)
    print(result["error_positions"])
    print(result["bm_state"])