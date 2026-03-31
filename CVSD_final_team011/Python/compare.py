from ELP_from_ans import compare_sigma_poly
from gen_received import read_error_pos
import argparse

def main(case):
    error_pos_filename = f"./error_position/e{case}.txt"
    sigma_file = f"./sigma_polynomial/sigma{case}.txt"
    sigmaF_file = f"./sigma_polynomial/sigma_F{case}.txt"

    m, error_pos = read_error_pos(error_pos_filename)

    with open(sigma_file, "r") as file:
        lines = [line.strip() for line in file if line.strip()] 
    sigma = [int(lines[i]) for i in range(len(lines))]
    with open(sigmaF_file, "r") as file:
        lines = [line.strip() for line in file if line.strip()] 
    sigma_F = [int(lines[i]) for i in range(len(lines))]
    ## compare answer
    print("Comparing Answer...")
    compare_sigma_poly(m, sigma, sigma_F)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compute Syndromes')
    parser.add_argument('case', type=str, help='Case number')
    args = parser.parse_args()

    main(args.case)
