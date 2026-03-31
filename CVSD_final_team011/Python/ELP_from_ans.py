from galois_field import GF
from gen_received import read_error_pos
import argparse
import sys

def roots_to_coefficients(m, roots):
    gf = GF(m)
    n = len(roots)
    roots = [gf.power2poly[roots[i]] for i in range(len(roots))]
    coeffs = [1] + [0] * n
    
    for root in roots:
        # Multiply current polynomial by (1 - root*x)
        # This is equivalent to: coeffs = coeffs * (1 - root*x)
        # We do this from highest degree to lowest to avoid overwriting
        for i in range(n, 0, -1):
            coeffs[i] ^= gf.mul(coeffs[i - 1], root)

    # return in power form
    coeffs = [gf.poly2power[coeffs[i]] for i in range(len(coeffs))]
    return coeffs

def construct_ELP_from_ans(filename, N, num_roots):
    """
    N: number of codewords
    """
    with open(filename, 'r') as file:
        lines = [line.strip() for line in file if line.strip()]
    
    # Decode all bits
    all_bits = ""
    error_pos = [] # error position in power form
    for loc in lines:
        error_pos.append(int(loc,2)) 
    # error_pos = [gf.power2poly[error_pos[i]] for i in range(len(error_pos))]
    error_pos = [[error_pos[i*num_roots+j] for j in range(num_roots)] for i in range(N)]
    print(error_pos)
    result = []
    for i in range(N):
        result.append(roots_to_coefficients(error_pos[i]))

    print(result)
    return result 

def compare_sigma_poly(m: int ,ans_poly : list, computed_poly: list):
    if len(ans_poly) != len(computed_poly):
        print("ERROR! Length of computed polynomial is incorrect!")
        return
    power_max = 63
    if m == 10: power_max = 1023
    elif m == 8: power_max = 255

    for i in range(len(ans_poly)-1):
        diff_ans = ans_poly[i+1] - ans_poly[i]
        diff_compute = computed_poly[i+1] - computed_poly[i]
        if diff_ans < 0: diff_ans += power_max
        if diff_compute < 0: diff_compute+= power_max
        
        if diff_ans != diff_compute:
            print("Computed Sigma is INCORRECT!")
            return
    print("CORRECT")

def main(case):
    error_pos_filename = f"./error_position/e{case}.txt"
    computed_sigma_file = f"./sigma_polynomial/sigma{case}.txt"

    m, error_pos = read_error_pos(error_pos_filename)
    ans_sigma = roots_to_coefficients(m, error_pos)

    with open(computed_sigma_file, "r") as file:
        lines = [line.strip() for line in file if line.strip()] 
    computed_sigma = [int(lines[i]) for i in range(len(lines))]

    ## compare answer
    print("Comparing Answer...")
    compare_sigma_poly(m, ans_sigma, computed_sigma)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compute Syndromes')
    parser.add_argument('case', type=str, help='Case number')
    args = parser.parse_args()

    main(args.case)



# num_roots = 4
# filename = "../01_RTL/testdata/p300a.txt"
# construct_ELP_from_ans(filename, 2, num_roots)