import random
from gii_code import GII_code

# Field: GF(2^6), Interleaves: 4, Nested Layers: 2, Error Caps: [2, 4, 6]
seed = 67
random.seed(seed)


def write_to_file(gii_code:list, case:int):

    codeword_file = f"../00_TB/testdata/codeword/codeword_{case}.txt"

    # ==== write codeword =====
    with open(codeword_file, "w") as file:
        for code in gii_code:
            file.write(code+'\n')


gii = GII_code(q=6, m=4, v=2, t_list=[2, 4, 6])
    
print("\n--- Generating Polynomials ---")
gii.print_generators()
    
print("\n--- Generating GII-BCH Codewords ---")
codewords = gii.encode_random_data(n=63)
for i, c in enumerate(codewords):
    print(f"c{i}(x) length: {len(c)} bits")
    print(f"Bits: {c}")

write_to_file(codewords, 0)