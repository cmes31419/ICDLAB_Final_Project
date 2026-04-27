import random
from gii_code import GII_code

# Field: GF(2^6), Interleaves: 4, Nested Layers: 2, Error Caps: [2, 4, 6]
seed = 67
random.seed(seed)

def replace_char(s, index, new_char):
    return s[:index] + new_char + s[index+1:]

def gen_receive(n, codeword, error_pos : list):
    """
    Return a string of codeword with error
    e.g. 
    codeword: 10011
    error position: 3, 1
    received: 11001
    """
    c = codeword
    for i in range(len(error_pos)):
        pos = n - 1 - error_pos[i]
        bit = c[pos]
        if bit == "1": c = replace_char(c, pos, "0") 
        else: c = replace_char(c, pos, "1") 
    return c

def read_error_pos(filename):
    error_pos = []
    with open(filename, "r") as file:
        for line in file:
            line = line.strip()
            if line:   # skip empty lines
                error_pos.append([int(x) for x in line.split()])

    return error_pos

def write_to_file(gii_code:list, filename):
    # ==== write codeword =====
    with open(filename, "w") as file:
        for code in gii_code:
            file.write(code+'\n')

def main(case):
    gii = GII_code(q=6, m=4, v=2, t_list=[2, 4, 6], p_str="x^6 + x + 1")
    q = 6
    n = 2 ** q - 1
    codewords = gii.encode_random_data(n)
    error_pos_file = f"../00_TB/testdata/error_pos/p{case}e.txt"
    error_pos = read_error_pos(error_pos_file)
    print(error_pos)
    assert len(codewords) == len(error_pos)
    received = []
    for i in range(len(codewords)):
        received.append(gen_receive(n, codewords[i], error_pos[i]))

    codeword_file = f"../00_TB/testdata/codeword/p{case}a.txt"
    received_file = f"../00_TB/testdata/pattern/p{case}.txt"
    write_to_file(codewords, codeword_file)
    write_to_file(received, received_file)
    print(codewords)
    print(received)
# print("\n--- Generating Polynomials ---")
# gii.print_generators()
    
# print("\n--- Generating GII-BCH Codewords ---")
# codewords = gii.encode_random_data(n=63)
# for i, c in enumerate(codewords):
#     print(f"c{i}(x) length: {len(c)} bits")
#     print(f"Bits: {c}")

# write_to_file(codewords, 0)

main(0)