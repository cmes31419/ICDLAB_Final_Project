from galois_field import GF
from gen_received import gen_receive
from compute_syndrome import compute_syndromes
from invless_BM import invless_BM
from standard_BM import BM
from FiBM import FiBM
from chien_search import chien_search

import argparse

def replace_char(s, index, new_char):
    return s[:index] + new_char + s[index+1:]

def convert_str_to_int(binary_str):
    """Convert using bit manipulation"""
    value = int(binary_str, 2)
    n = len(binary_str)
    
    # If the number is negative (MSB set), adjust it
    if value & (1 << (n - 1)):
        value = value - (1 << n)
    
    return value

def read_and_soft_decode_llr(filename, m):
    """
    Read LLR file and convert to hard-decoded binary string
    Each 8-bit chunk represents an LLR value
    MSB determines the hard decision: 0->0, 1->1
    """
    codeword_len = 2 ** m
    with open(filename, 'r') as file:
        lines = [line.strip() for line in file if line.strip()]
    
    # Decode all bits
    all_bits = ""
    all_llr = []
    for line in lines:
        for i in range(0, len(line), 8):
            chunk = line[i:i+8]
            if len(chunk) == 8:
                all_bits += '0' if chunk[0] == '0' else '1'
                all_llr.append(convert_str_to_int(chunk))
    
    codewords = [all_bits[i+1:i+codeword_len] for i in range(0, len(all_bits), codeword_len)]
    llr_list = [all_llr[i+1:i+codeword_len] for i in range(0, len(all_llr), codeword_len)] 
    
    return codewords, llr_list

def find_p_LRB(nums:list):
    """
    Find indices of first two smallest absolute values
    here p = 2 
    """ 
    # Create list of (index, absolute value) pairs
    indexed = [(i, abs(num)) for i, num in enumerate(nums)]
    
    # Sort by absolute value, then by index (to get first occurrence if ties)
    sorted_indices = sorted(indexed, key=lambda x: (x[1], x[0]))
    
    # Return first two indices
    return [sorted_indices[0], sorted_indices[1]]

def flip(bit_str:str):
    if bit_str == "1": return "0"
    else: return "1"

def soft_decoding(m, hard_decoded_code, llr_list:list, verbose):
    t = 2
    if m==10: t = 4
    gf = GF(m)
    n = 2**m -1

    llr_abs = [abs(llr_list[i]) for i in range(len(llr_list))]
    lrb_list = find_p_LRB(llr_list) # (pos, llr_value), position is the index in the string, no conversion afterwards
    print(f"LRB list: {[n-1-lrb[0] for lrb in lrb_list]}") 
    # lrb_print = [n-1-lrb_list[i][0] for i in range(len(lrb_list))]
    candidate_err_list = []
    penalty_list = []
    for i in range(4): # test 2^p candidate
        penalty = 0

        # ==== generate test pattern ======
        cand_str = f"{i:02b}"
        test_pattern = hard_decoded_code
        for j in range(2):
            idx = lrb_list[j][0] # no conversion
            test_pattern = replace_char(test_pattern, idx, flip(test_pattern[idx])) if cand_str[j]=="1" else test_pattern
        for j in range(2):
            penalty += lrb_list[j][1] if cand_str[j]=="1" else 0
        # =====================

        syn = compute_syndromes(test_pattern, m ,t) # return in polyform
        syn = [gf.poly2power[s] for s in syn]

        # sigma_poly = FiBM(m ,t ,syn, False)
        # deg = 
        # valid = True

        sigma_poly, deg = BM(m ,t, syn, False)
        if deg > t: valid = False
        else: valid = True

        error_pos = []
        if valid: 
            valid, error_pos = chien_search(m, sigma_poly, deg)
            for j in range(len(error_pos)):
                index = n - 1 - error_pos[j]
                penalty += llr_abs[index]
            
            if valid:
                # add the LRB position to error pos =====
                for j in range(len(cand_str)):
                    # convert back to error position
                    pos = n - 1- lrb_list[j][0]
                    if cand_str[j] == "1": error_pos.append(pos)
                # ==================
                error_pos = list(set(error_pos))
                penalty_list.append(penalty)
                candidate_err_list.append(error_pos)
            else: # Chien search failed
                penalty_list.append(-1)
                candidate_err_list.append(error_pos)

        else: # BM failed
            penalty_list.append(-2)
            candidate_err_list.append([])

    
    # find the candidate with lowest penalty
    repeated_candidate = False
    best_penalty = 200000
    best_candidate = 0
    true_error = []
    for i, penalty in enumerate(penalty_list):
        if verbose:
            if penalty >= 0:
                print(f"i: {i}, penalty: {penalty}, error pos: {candidate_err_list[i]}")
            elif penalty == -2: 
                print(f"i: {i}, BM Failed")
            elif penalty == -1:
                print(f"i: {i}, CS Failed, error pos: {candidate_err_list[i]}")
                
        if penalty < 0: continue
        else:
            if penalty < best_penalty:
                repeated_candidate = False
                best_penalty = penalty
                best_candidate = i
            elif penalty == best_penalty:
                repeated_candidate = True
    if not repeated_candidate:
        true_error = sorted(candidate_err_list[best_candidate])

    return true_error, best_penalty, repeated_candidate

def main(args):
    m = int(args.m)
    case = args.case
    verbose = args.verbose
    filename = f"../01_RTL/testdata/soft_pattern/soft_{m}_{case}.txt"
    codeword_list, llr_list = read_and_soft_decode_llr(filename, m)
    for code_idx in range(len(codeword_list)):
        true_err, penalty, repeated_candidate = soft_decoding(m, codeword_list[code_idx], llr_list[code_idx], verbose)
        print(f"Error position: {true_err}, Penalty: {penalty}")
        print('==========================\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Soft decoding')
    parser.add_argument('--m', default=6, help="m")
    parser.add_argument('--case', type=str, help='Case number')
    parser.add_argument('--verbose', default=False, action="store_true", help="Print soft decoding steps")
    args = parser.parse_args()
    
    main(args)


    