from galois_field import GF
from soft_decoding import read_and_soft_decode_llr
from compute_syndrome import compute_syndromes
from invless_BM import invless_BM
from FiBM import FiBM
from SiBM import SiBM
from standard_BM import BM
from chien_search import chien_search

import argparse

def hard_decoding(m, hard_decoded_code, verbose, test:bool):
    t = 2
    if m==10: t = 4
    gf = GF(m)
    n = 2**m -1

    syn = compute_syndromes(hard_decoded_code, m, t) # return in polyform
    if verbose: 
        print(f"Syndromes in polyform: {syn}")
    syn = [gf.poly2power[s] for s in syn]
    # sigma_poly, deg = BM(m ,t, syn, False) # return in powerform

    # sigma_poly = FiBM(m, t, syn, False)
    # deg = len(sigma_poly)-1
    sigma_poly, deg = SiBM(m, t, syn, False)
    print(deg)

    error_pos = []
    if deg == 6: print("Found degree 6")    
    if verbose:
        print(f"Sigma in powerform: {sigma_poly}")
        print(f"Sigma in polyform: {[gf.power2poly[sig] for sig in sigma_poly]}")

    if deg > t:
        return error_pos
    else:
        valid, error_pos = chien_search(m, sigma_poly, deg)

    if valid: error_pos = sorted(error_pos)
    else: error_pos = []
    return error_pos

def main(args):
    m = int(args.m)
    case = args.case
    verbose = args.verbose
    filename = f"../01_RTL/testdata/hard_pattern/hard_{m}_{case}.txt"
    codeword_list, llr_list = read_and_soft_decode_llr(filename, m)
    for code_idx in range(len(codeword_list)):
        true_err = hard_decoding(m, codeword_list[code_idx], verbose, test=True)
        print(f"Error position: {true_err}")
        print("================\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Hard decoding')
    parser.add_argument('--m', default=6, help="m")
    parser.add_argument('--case', type=str, help='Case number')
    parser.add_argument('--verbose', default=False, action="store_true", help="Print hard decoding steps")
    args = parser.parse_args()
    
    main(args)