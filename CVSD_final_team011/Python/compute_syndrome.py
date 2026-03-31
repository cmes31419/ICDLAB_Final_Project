from galois_field import GF
import sys
import argparse

def read_and_decode_llr_file_separate(filename, m):
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
    for line in lines:
        for i in range(0, len(line), 8):
            chunk = line[i:i+8]
            if len(chunk) == 8:
                all_bits += '0' if chunk[0] == '0' else '1'
    
    codewords = [all_bits[i+1:i+codeword_len] for i in range(0, len(all_bits), codeword_len)]
    
    return codewords

def compute_syndromes(codeword, m, t):
    gf = GF(m)
    syndromes = []
    
    for i in range(1, 2*t + 1):
        Si = 0
        for pos, ch in enumerate(codeword):
            if ch == '0': continue
            j = gf.power_max - 1 - pos
            # (α^i)^j = α^{i*j}
            power = (i*j) % gf.power_max
            Si = gf.add(Si, gf.power2poly[power])
        
        syndromes.append(Si)

    # return in poly form
    return syndromes

def main(args):
    case = args.case
    print_poly = args.polyform

    filename = f"./received_code/r{case}.txt"
    with open(filename, "r") as file:
        lines = [line.strip() for line in file if line.strip()]  

    m = int(lines[0])
    t = 2
    if m == 10: t = 4    

    code = lines[1]
    gf = GF(m)
    syn = compute_syndromes(code, m, t)
    if print_poly:
        print("Syndromes in polynomial form")
        print(syn)
    syn = [gf.poly2power[syn[i]] for i in range(len(syn))]
    output_file = f"./syndromes/syn{case}.txt"
    with open(output_file, "w") as file:
        file.write(str(m) + "\n")
        for i in range(len(syn)):
            file.write(str(syn[i]) + "\n")
    print(f"Computed Syndromes for case: {case}") 

# Code below provide an example usage of calculating syndromes from TA testdata
# m = 10
# t = 4
# filename = "../01_RTL/testdata/p300.txt"
# received_code = read_and_decode_llr_file_separate(filename, m)
# gf = GF(m)
# # r = "010_0101_0000_1111_1101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0100_0011"
# # r = r.replace("_", "")
# # syndromes = compute_syndromes(r, m, t)
# # print(syndromes)
    
# for i in range(len(received_code)):
#     # print(received_code[i])
#     # print(len(received_code[i]))
#     syndromes = compute_syndromes(received_code[i], m, t)
#     syndromes = [gf.poly2power[syndromes[j]] for j in range(len(syndromes))]
#     print(syndromes)

# ================ end of example ==================================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compute Syndromes')
    parser.add_argument('case', type=str, help='Case number')
    parser.add_argument('--polyform', default=False, action="store_true", help="Print syndrome in polyform")
    args = parser.parse_args()
    
    main(args)


