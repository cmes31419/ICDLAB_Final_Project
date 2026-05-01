import numpy as np
from pattern_gen.gii_code import GII_code
from bch_decoder import BCHDecoder


class GIIDecoder(GII_code):
    def __init__(self, q, m, v, t_list, p_str: str):
        super().__init__(q, m, v, t_list, p_str)
        self.q = q
        self.m = m
        self.v = v
        self.t_list = t_list
        self.p_str = p_str

        self.n = self.gf.power_max
        self.field = self.gf.field
        self.alpha = self.gf.alpha

        self.bch_decoders = [
            BCHDecoder(q, t, p_str) for t in t_list
        ]

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
            # print(f"codeword{idx}")
            # print(f"    syndromes: {result["syndromes"]}")
            # print(f"    ELP:       {result["locator"]}")
            # print(f"    error pos: {result["error_positions"]}")
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

    def decode_multi_round_restart(self, received_words):
        """
        Full GII decoding with multiple nested rounds.
        This version restarts BM from scratch at each round.

        Round 0: stage-1 BCH decode with t0
        Round 1: recover to t1
        Round 2: recover to t2
        ...
        Round v: last round

        Returns:
            {
                "success": bool,
                "final_words": [...],
                "stage1_results": [...],
                "round_logs": [...],
                "remaining_failed": [...],
            }
        """
        # ----------------------------------
        # Round 0: stage 1
        # ----------------------------------
        corrected_words, stage1_results, failed_indices = self.stage1_decode(received_words)

        round_logs = []

        if len(failed_indices) == 0:
            return {
                "success": True,
                "final_words": corrected_words,
                "stage1_results": stage1_results,
                "round_logs": [],
                "remaining_failed": [],
            }

        if len(failed_indices) > self.v:
            return {
                "success": False,
                "final_words": corrected_words,
                "stage1_results": stage1_results,
                "round_logs": [],
                "remaining_failed": failed_indices,
            }

        current_words = [list(w) for w in corrected_words]
        current_failed = list(failed_indices)

        # ----------------------------------
        # Nested rounds: 1 .. v
        # ----------------------------------
        for target_layer in range(1, self.v + 1):
            if len(current_failed) == 0:
                break

            # build words_for_nested:
            # failed rows use original/current received version
            # successful rows use corrected version already in current_words
            words_for_nested = [list(w) for w in current_words]

            alpha_power_start = 2 * self.t_list[0] + 1
            alpha_power_end = 2 * self.t_list[target_layer]

            high_syn_dict = self.recover_high_order_syndromes(
                words_for_nested=words_for_nested,
                failed_indices=current_failed,
                alpha_power_start=alpha_power_start,
                alpha_power_end=alpha_power_end
            )

            full_syn_dict = self.build_full_syndrome_dict(
                stage1_results=stage1_results,
                high_syn_dict=high_syn_dict,
                target_layer=target_layer
            )

            nested_results = self.decode_failed_with_full_syndromes(
                received_words=current_words,
                full_syn_dict=full_syn_dict,
                target_layer=target_layer
            )

            newly_corrected = []
            still_failed = []

            for idx in current_failed:
                if nested_results[idx]["success"]:
                    current_words[idx] = list(nested_results[idx]["corrected"])
                    newly_corrected.append(idx)
                else:
                    still_failed.append(idx)

            round_logs.append({
                "target_layer": target_layer,
                "input_failed": list(current_failed),
                "high_syn_dict": high_syn_dict,
                "full_syn_dict": full_syn_dict,
                "nested_results": nested_results,
                "newly_corrected": newly_corrected,
                "remaining_failed": still_failed,
            })

            # no progress => fail
            if len(newly_corrected) == 0:
                return {
                    "success": False,
                    "final_words": current_words,
                    "stage1_results": stage1_results,
                    "round_logs": round_logs,
                    "remaining_failed": still_failed,
                }

            current_failed = still_failed

        return {
            "success": len(current_failed) == 0,
            "final_words": current_words,
            "stage1_results": stage1_results,
            "round_logs": round_logs,
            "remaining_failed": current_failed,
        }

    # === tb
    def _pack_basis_list_to_hex(self, values, bits_per_symbol=6):
        """
        values: iterable of GF elements or ints, interpreted in basis form
        Return:
            concatenated bitstring packed into a hex string

        Example:
            [13, 10, 4, 1] with 6 bits each
            -> 24-bit packed value
            -> 6 hex digits
        """
        total_bits = len(values) * bits_per_symbol
        acc = 0

        for v in values:
            x = int(v) & ((1 << bits_per_symbol) - 1)
            acc = (acc << bits_per_symbol) | x

        hex_width = (total_bits + 3) // 4
        return f"{acc:0{hex_width}X}"

    def _pad_coeffs(self, coeffs, target_len):
        coeffs = list(coeffs)
        if len(coeffs) < target_len:
            coeffs += [self.field(0)] * (target_len - len(coeffs))
        return coeffs[:target_len]

    def export_stage1_ribm_patterns(self, received_words, syn_outfile, sigma_outfile):
        from hardware_KES.bch_ribm import BCHRiBMSkip

        corrected_words, stage1_results, failed_indices = self.stage1_decode(received_words)

        ribm = BCHRiBMSkip(
            q=self.q,
            t=self.t_list[0],
            p_str=self.p_str
        )

        with open(syn_outfile, "w") as fsyn, open(sigma_outfile, "w") as fsig:
            for res in stage1_results:
                syn = list(res["syndromes"])
                syn = self._pad_coeffs(syn, 2 * self.t_list[0])

                syn_hex = self._pack_basis_list_to_hex(syn, bits_per_symbol=self.q)
                fsyn.write(syn_hex + "\n")

                ribm_result = ribm.run(syn)
                sigma = list(ribm_result["locator"])
                print(f"locator {ribm_result["locator"]}")
                sigma = self._pad_coeffs(sigma, self.t_list[0] + 1)

                sigma_hex = self._pack_basis_list_to_hex(sigma, bits_per_symbol=self.q)
                fsig.write(sigma_hex + "\n")

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

result = gii_dec.decode_multi_round_restart(received_words)

print("overall success =", result["success"])
print("remaining_failed =", result["remaining_failed"])

for round_idx, log in enumerate(result["round_logs"], start=1):
    print(f"\nRound {round_idx}: target_layer = {log['target_layer']}")
    print("  input_failed    =", log["input_failed"])
    print("  newly_corrected =", log["newly_corrected"])
    print("  remaining_failed=", log["remaining_failed"])

    for idx, res in log["nested_results"].items():
        print(f"    sub-codeword {idx}:")
        print(f"      success = {res['success']}")
        print(f"      error_positions = {res['error_positions']}")
        print(f"      num_errors = {res['num_errors']}")

gii_dec.export_stage1_ribm_patterns(
    received_words,
    syn_outfile="./testdata.txt",
    sigma_outfile="./testdata_ans.txt"
)