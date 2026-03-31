# Parameters
m = 6
n = 63
k = 51
t = 2

# primitive polynomial for GF(2^6): x^6 + x + 1
p = 0b1000011

phi_1 = 0x43    # x^6 + x + 1
phi_3 = 0x57    # x^6 + x^4 + x^2 + x + 1

c = "0010_0101_0000_1111_1101_1010_0101_0100_0111_0011_0101_1101_0101_1101_0000_0011"
c = c.replace("_", "")

r = "0010_0101_0000_1111_1101_1010_0101_0100_0111_0011_0100_1101_0101_1101_0100_0011"
r = r.replace("_", "")

def compute_syndromes(bits, phi, t, m):
    syndromes = []
    for i in range(1, t + 1):
        Si = 0
        for ch in bits:
            Si <<= 1
            if Si & (1 << m):
                Si ^= phi[i]
            if ch == '1':
                Si ^= 1
        syndromes.append(Si)
    syndromes_transformed = [0] * 2*t
    syndromes_transformed[0] = transform(syndromes[0], 1)
    syndromes_transformed[1] = transform(syndromes[0], 2)
    syndromes_transformed[2] = transform(syndromes[1], 3)
    syndromes_transformed[3] = transform(syndromes[0], 4)
    return syndromes_transformed

def transform(Si, i):
    s0 = Si & 1
    s1 = (Si >> 1) & 1
    s2 = (Si >> 2) & 1
    s3 = (Si >> 3) & 1
    s4 = (Si >> 4) & 1
    s5 = (Si >> 5) & 1
    if i == 1:
        return Si
    elif i == 2:
        r0 = s0 ^ s3
        r1 = s3
        r2 = s1 ^ s4
        r3 = s4
        r4 = s2 ^ s5
        r5 = s5
    elif i == 3:
        r0 = s0 ^ s2 ^ s4
        r1 = s2
        r2 = s4
        r3 = s1 ^ s3 ^ s5
        r4 = s3
        r5 = s5
    elif i == 4:
        r0 = s0 ^ s3 ^ s4
        r1 = s4
        r2 = s2 ^ s3 ^ s5
        r3 = s2 ^ s5
        r4 = s1 ^ s4 ^ s5
        r5 = s5
    return (r5 << 5) | (r4 << 4) | (r3 << 3) | (r2 << 2) | (r1 << 1) | r0


if __name__ == "__main__":
    
    phi = [0, phi_1, phi_3]

    print("r bits length:", len(r))
    print("c bits length:", len(c))
    print()

    S_r = compute_syndromes(r, phi, t, m)
    S_c = compute_syndromes(c, phi, t, m)

    print("Syndromes for r (received word):")
    for idx, Si in enumerate(S_r, start=1):
        print(f"S{idx} = {Si:06b}")

    print("\nSyndromes for c (codeword, should be all zero if c is valid):")
    for idx, Si in enumerate(S_c, start=1):
        print(f"S{idx} = {Si:06b}")



# S1 = 111111  (poly: x^5 + x^4 + x^3 + x^2 + x + 1)
# S2 = 101010  (poly: x^5 + x^3 + x)
# S3 = 110110  (poly: x^5 + x^4 + x^2 + x)
# S4 = 110111  (poly: x^5 + x^4 + x^2 + x + 1)
