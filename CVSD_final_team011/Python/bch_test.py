from galois_field import GF

m = 6
gf = GF(6)

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
    
    # Split into 256-bit codewords
    codewords = [all_bits[i+1:i+codeword_len] for i in range(0, len(all_bits), codeword_len)]
    
    return codewords

def compute_syndromes(codeword, t):
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

    return syndromes
filename = "../01_RTL/testdata/hard_pattern/hard_6_0.txt"
received_code = read_and_decode_llr_file_separate(filename, 6)

# r = "010_0101_0000_1111_1101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0100_0011"
# r = r.replace("_", "")
# syndromes = compute_syndromes(r, 2)

syndromes = compute_syndromes(received_code[0], 2)
syndromes = [gf.poly2power[syndromes[i]] for i in range(len(syndromes))]
print(syndromes)
# for i in range(len(temp_list)):
#     print(temp_list[i]) 
#     print(len(temp_list[i]))