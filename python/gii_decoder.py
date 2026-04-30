import numpy as np
from pattern_gen.gii_code import GII_code
from bch_decoder import BCHDecoder


class GIIDecoder(GII_code):
    def __init__(self, q, m, v, t_list, p_str: str):
        super().__init__(q, m, v, t_list, p_str)

        self.q = q
        self.n = self.gf.power_max
        self.field = self.gf.field
        self.alpha = self.gf.alpha

        # Stage-1 BCH decoder uses t0
        self.bch_stage1 = BCHDecoder(q, t_list[0], p_str)

    # -------------------------------------------------
    # Basic format helpers
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

    # -------------------------------------------------
    # Stage 1
    # -------------------------------------------------

    def stage1_decode(self, received_words):
        """
        received_words: list of codewords in ascending-degree binary-list form

        Returns:
            corrected_words
            stage1_results
            failed_indices
        """
        corrected_words = []
        stage1_results = []
        failed_indices = []

        for idx, word in enumerate(received_words):
            result = self.bch_stage1.decode(word)
            stage1_results.append(result)

            if result["success"]:
                corrected_words.append(result["corrected"])
            else:
                corrected_words.append(list(word))
                failed_indices.append(idx)

        return corrected_words, stage1_results, failed_indices

    # -------------------------------------------------
    # Higher-order syndrome helpers
    # -------------------------------------------------

    def compute_word_syndrome(self, word, alpha_power):
        """
        Compute S = word(alpha^alpha_power)

        word: ascending-degree binary list
        alpha_power: 1-based power used in BCH syndrome definition
                     e.g. alpha_power = 1 means evaluate at alpha^1
        """
        return self.gf.eval_poly_at_alpha(word, alpha_power)

    def compute_nested_syndrome(self, words, nested_level, alpha_power):
        """
        Compute one nested syndrome:
            \tilde S^{(nested_level)} for a fixed alpha_power

        words: list of sub-codewords (ascending-degree binary lists)
        nested_level: l in \tilde y_l
        alpha_power: j in S_j = y(alpha^j), using 1-based convention
        """
        total = self.field(0)

        for i, word in enumerate(words):
            s_i = self.compute_word_syndrome(word, alpha_power)
            total += (self.alpha ** (i * nested_level)) * s_i

        return total

    def build_nested_syndrome_vector(self, words, num_failed, alpha_power):
        """
        Build:
            [\tilde S^{(0)}, \tilde S^{(1)}, ..., \tilde S^{(b-1)}]^T

        where b = num_failed
        """
        vec = [
            self.compute_nested_syndrome(words, nested_level=l, alpha_power=alpha_power)
            for l in range(num_failed)
        ]
        return self.field(vec)

    def build_A_matrix(self, failed_indices):
        """
        Build the matrix A in Eq. (3).

        IMPORTANT:
        From the nesting definition:
            \tilde c_l = sum_i alpha^{i l} c_i
        the natural matrix entry is:
            A[p, q] = alpha^(p * failed_indices[q])

        So row p corresponds to nested level p,
        column q corresponds to failed sub-codeword index failed_indices[q].
        """
        b = len(failed_indices)
        A = [[self.alpha ** (p * failed_indices[q]) for q in range(b)] for p in range(b)]
        return self.field(A)

    def recover_high_order_syndromes(self, words_for_nested, failed_indices, alpha_power_start, alpha_power_end):
        """
        Recover higher-order syndromes for failed sub-codewords 

        words_for_nested:
            list of words used to form nested syndromes.
            For stage 2 this should usually be:
                - corrected words for successful sub-codewords
                - original received words for failed sub-codewords

        failed_indices:
            list of failed sub-codeword indices, e.g. [0], [1, 3], ...

        alpha_power_start, alpha_power_end:
            inclusive range of BCH syndrome powers
            e.g. for t0=2, t1=4, recover S5..S8  -> alpha_power_start=5, alpha_power_end=8

        Returns:
            high_syn_dict:
                {
                    failed_idx_0: [S_{start}, ..., S_{end}],
                    failed_idx_1: [S_{start}, ..., S_{end}],
                    ...
                }
        """
        b = len(failed_indices)

        if b == 0:
            return {}

        if b > self.v:
            raise ValueError(
                f"Number of failed sub-codewords = {b}, but v = {self.v}"
            )

        A = self.build_A_matrix(failed_indices)
        A_inv = np.linalg.inv(A)

        high_syn_dict = {idx: [] for idx in failed_indices}

        for alpha_power in range(alpha_power_start, alpha_power_end + 1):
            nested_vec = self.build_nested_syndrome_vector(
                words=words_for_nested,
                num_failed=b,
                alpha_power=alpha_power
            )

            recovered_vec = A_inv @ nested_vec

            for q, failed_idx in enumerate(failed_indices):
                high_syn_dict[failed_idx].append(recovered_vec[q])

        return high_syn_dict



# ===== test code ========
# def read_codeword_lines(filename):
#     with open(filename, "r") as f:
#         return [line.strip() for line in f if line.strip()]

# filename = "../00_TB/testdata/pattern/p2.txt"

# gii_dec = GIIDecoder(
#     q=6,
#     m=4,
#     v=2,
#     t_list=[2, 4, 6],
#     p_str="x^6 + x + 1"
# )

# # 1. read received words and convert to internal format
# received_str = read_codeword_lines(filename)
# received_words = [gii_dec.bits_str_to_poly_list(s) for s in received_str]

# # 2. stage-1 decode
# corrected_words, stage1_results, failed_indices = gii_dec.stage1_decode(received_words)

# print("failed_indices =", failed_indices)

# # 3. build words_for_nested
# #    success -> corrected
# #    failure -> original received
# words_for_nested = []
# for i in range(len(received_words)):
#     if i in failed_indices:
#         words_for_nested.append(received_words[i])
#     else:
#         words_for_nested.append(corrected_words[i])

# # 4. recover higher-order syndromes
# # for example: from S5 to S8
# high_syn = gii_dec.recover_high_order_syndromes(
#     words_for_nested=words_for_nested,
#     failed_indices=failed_indices,
#     alpha_power_start=5,
#     alpha_power_end=8
# )

# # 5. print result
# for idx in failed_indices:
#     print(f"sub-codeword {idx} higher-order syndromes:")
#     for j, s in enumerate(high_syn[idx], start=5):
#         print(f"  S{j} = {s}")