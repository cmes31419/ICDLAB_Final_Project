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

        self.bch_decoders = [
            BCHDecoder(q, t, p_str) for t in t_list
        ]

        # Stage-1 BCH decoder uses t0
        self.bch_stage1 = self.bch_decoders[0]

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

    def eval_bin_poly_at_alpha(self, poly_bin, alpha_power):
        """
        Evaluate a binary polynomial poly_bin at x = alpha^alpha_power.
        poly_bin is ascending-degree binary list.
        """
        return self.gf.eval_poly_at_alpha(poly_bin, alpha_power)

    def get_nested_coeff_poly(self, nested_level, sub_idx):
        """
        Return the binary polynomial coefficient used by the encoder relation
        for nested level `nested_level` and sub-codeword `sub_idx`.
        """
        # simplest consistent form if your model is alpha(x^(l*i))
        elem = self.gf.alpha ** (nested_level * sub_idx)
        return self.gf_elem_to_binary_poly(elem)

    def compute_nested_syndrome(self, words, nested_level, alpha_power):
        total = self.field(0)

        for i, word in enumerate(words):
            s_i = self.compute_word_syndrome(word, alpha_power)
            coeff_poly = self.get_nested_coeff_poly(nested_level, i)
            coeff_eval = self.eval_bin_poly_at_alpha(coeff_poly, alpha_power)
            total += coeff_eval * s_i

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

    def build_A_matrix(self, failed_indices, alpha_power):
        """
        Build the relation matrix in syndrome domain.

        A[p, q] = coeff_{p, failed_indices[q]}(alpha^alpha_power)
        where coeff_{p, i}(x) is the SAME binary polynomial coefficient
        used in the nested relation at codeword level.
        """
        b = len(failed_indices)
        A = []

        for p in range(b):
            row = []
            for q in range(b):
                sub_idx = failed_indices[q]
                coeff_poly = self.get_nested_coeff_poly(p, sub_idx)
                coeff_eval = self.eval_bin_poly_at_alpha(coeff_poly, alpha_power)
                row.append(coeff_eval)
            A.append(row)

        return self.field(A) 

    def recover_high_order_syndromes(self, words_for_nested, failed_indices, alpha_power_start, alpha_power_end):
        b = len(failed_indices)

        if b == 0:
            return {}

        if b > self.v:
            raise ValueError(
                f"Number of failed sub-codewords = {b}, but v = {self.v}"
            )

        high_syn_dict = {idx: [] for idx in failed_indices}

        for alpha_power in range(alpha_power_start, alpha_power_end + 1):
            A = self.build_A_matrix(failed_indices, alpha_power)
            A_inv = np.linalg.inv(A)

            nested_vec = self.build_nested_syndrome_vector(
                words=words_for_nested,
                num_failed=b,
                alpha_power=alpha_power
            )

            recovered_vec = A_inv @ nested_vec

            for q, failed_idx in enumerate(failed_indices):
                high_syn_dict[failed_idx].append(recovered_vec[q])

        return high_syn_dict

    # -------------------------------------------------
    # Nested KES helpers 
    # -------------------------------------------------
    def build_full_syndrome_dict(self, stage1_results, high_syn_dict, target_layer):
        """
        Build full syndrome list for each failed sub-codeword.

        target_layer:
            1 means use t1 and build S1..S_{2t1}
            2 means use t2 and build S1..S_{2t2}
            ...

        Returns:
            full_syn_dict = {
                failed_idx: [S1, S2, ..., S_{2 t_target}]
            }
        """
        t_target = self.t_list[target_layer]
        full_syn_dict = {}

        for idx, high_syn_list in high_syn_dict.items():
            base_syn = list(stage1_results[idx]["syndromes"])   # S1..S_{2t0}
            expected_total = 2 * t_target

            full_syn = base_syn + list(high_syn_list)

            if len(full_syn) != expected_total:
                raise ValueError(
                    f"sub-codeword {idx}: syndrome length = {len(full_syn)}, "
                    f"expected {expected_total}"
                )

            full_syn_dict[idx] = full_syn

        return full_syn_dict

    def decode_failed_with_full_syndromes(self, received_words, full_syn_dict, target_layer):
        """
        Restart BCH decoding from scratch using full syndrome list S1..S_{2t_target}.

        received_words:
            original received words (ascending-degree binary lists)

        full_syn_dict:
            {
                failed_idx: [S1, ..., S_{2t_target}]
            }

        target_layer:
            which layer decoder to use, e.g. 1 for t1

        Returns:
            nested_results = {
                failed_idx: {
                    "success": bool,
                    "syndromes": [...],
                    "locator": [...],
                    "error_positions": [...],
                    "corrected": [...],
                    "num_errors": int,
                }
            }
        """
        bch_dec = self.bch_decoders[target_layer]
        nested_results = {}

        for idx, syndromes_full in full_syn_dict.items():
            locator, B, b, L = bch_dec.berlekamp_massey(syndromes_full)
            error_positions = bch_dec.chien_search(locator)
            success = bch_dec.validate_locator(locator, error_positions)

            if success:
                corrected = bch_dec.flip_positions(received_words[idx], error_positions)
                num_errors = len(error_positions)
            else:
                corrected = list(received_words[idx])
                num_errors = 0

            nested_results[idx] = {
                "success": success,
                "syndromes": syndromes_full,
                "locator": locator,
                "error_positions": error_positions,
                "corrected": corrected,
                "num_errors": num_errors,
                "bm_state": (locator, B, b, L),
            }

        return nested_results

    def stage2_decode_restart(self, received_words, target_layer=1):
        """
        Stage 2 decoding by restarting BM from scratch using recovered higher-order syndromes.

        target_layer = 1  -> use t1
        target_layer = 2  -> use t2
        """
        if target_layer < 1 or target_layer > self.v:
            raise ValueError(f"target_layer must be between 1 and {self.v}")

        # 1. stage 1
        corrected_words, stage1_results, failed_indices = self.stage1_decode(received_words)

        if len(failed_indices) == 0:
            return {
                "failed_indices": [],
                "high_syn_dict": {},
                "full_syn_dict": {},
                "nested_results": {},
            }

        if len(failed_indices) > self.v:
            raise ValueError(
                f"Need at most {self.v} failed sub-codewords, "
                f"but got {len(failed_indices)}"
            )

        # 2. build words_for_nested
        words_for_nested = []
        for i in range(len(received_words)):
            if i in failed_indices:
                words_for_nested.append(received_words[i])
            else:
                words_for_nested.append(corrected_words[i])

        # 3. recover higher-order syndromes
        alpha_power_start = 2 * self.t_list[0] + 1
        alpha_power_end = 2 * self.t_list[target_layer]

        high_syn_dict = self.recover_high_order_syndromes(
            words_for_nested=words_for_nested,
            failed_indices=failed_indices,
            alpha_power_start=alpha_power_start,
            alpha_power_end=alpha_power_end
        )

        # 4. build full syndromes
        full_syn_dict = self.build_full_syndrome_dict(
            stage1_results=stage1_results,
            high_syn_dict=high_syn_dict,
            target_layer=target_layer
        )

        # 5. restart BM + Chien search with t_target
        nested_results = self.decode_failed_with_full_syndromes(
            received_words=received_words,
            full_syn_dict=full_syn_dict,
            target_layer=target_layer
        )

        return {
            "failed_indices": failed_indices,
            "high_syn_dict": high_syn_dict,
            "full_syn_dict": full_syn_dict,
            "nested_results": nested_results,
        }



# ===== test code ========
def read_codeword_lines(filename):
    with open(filename, "r") as f:
        return [line.strip() for line in f if line.strip()]

filename = "../00_TB/testdata/pattern/p2.txt"

gii_dec = GIIDecoder(
    q=6,
    m=4,
    v=2,
    t_list=[2, 4, 6],
    p_str="x^6 + x + 1"
)
# 1. read received words and convert to internal format
received_str = read_codeword_lines(filename)
received_words = [gii_dec.bits_str_to_poly_list(s) for s in received_str]

result = gii_dec.stage2_decode_restart(received_words, target_layer=1)

print("failed_indices =", result["failed_indices"])

# for idx, syn in result["full_syn_dict"].items():
#     print(f"sub-codeword {idx} full syndromes:")
#     for j, s in enumerate(syn, start=1):
#         print(f"  S{j} = {int(s)}")

for idx, res in result["nested_results"].items():
    print(f"sub-codeword {idx} stage2 result:")
    print("  success =", res["success"])
    print("  error_positions =", res["error_positions"])
    print("  num_errors =", res["num_errors"])

