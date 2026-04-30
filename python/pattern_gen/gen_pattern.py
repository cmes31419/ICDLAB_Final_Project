import random
from pattern_gen.gii_code import GII_code
from bch_decoder import BCHDecoder

# Field: GF(2^6), Interleaves: 4, Nested Layers: 2, Error Caps: [2, 4, 6]

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

def gen_random_error_pos(n, num_subcodewords, min_err=0, max_err=4):
    error_pos = []
    for _ in range(num_subcodewords):
        err_cnt = random.randint(min_err, max_err)
        pos = random.sample(range(n), err_cnt)
        error_pos.append(sorted(pos))
    return error_pos

def is_good_pattern(received, error_pos, bch_dec, t0=2, max_failed_for_stage2=None,target_failed_stage1=None,):
    """
    received: list of received codeword strings (MSB-left)
    error_pos: list of inserted error position lists
    bch_dec: BCHDecoder object
    t0: base BCH capability
    max_failed_for_stage2: usually v
    """
    num_failed = 0
    num_gt_t0 = 0

    for i in range(len(received)):
        actual_err_cnt = len(error_pos[i])
        r = bch_dec.bits_str_to_poly_list(received[i])
        result = bch_dec.decode(r)

        if actual_err_cnt > t0:
            num_gt_t0 += 1
            if result["success"]:
                # miscorrection happened, discard this whole pattern
                return False

        if not result["success"]:
            num_failed += 1

    # Need at least one sub-codeword beyond base BCH capability
    if num_gt_t0 == 0:
        return False

    # do not exceed v
    if max_failed_for_stage2 is not None:
        if num_failed == 0 or num_failed > max_failed_for_stage2:
            return False

    # Exact failed count
    if target_failed_stage1 is not None:
        if num_failed != target_failed_stage1:
            return False
    return True

def write_codewords_to_file(codewords, filename):
    with open(filename, "w") as file:
        for code in codewords:
            file.write(code + "\n")
def write_error_pos_to_file(error_pos, filename):
    with open(filename, "w") as file:
        for pos_list in error_pos:
            file.write(" ".join(str(x) for x in pos_list) + "\n")

def main(case):
    random.seed(case)

    q = 6
    n = 2 ** q - 1
    m = 4
    v = 2
    t_list = [2, 4, 6]
    target_failed_stage1 = 2

    gii = GII_code(q=6, m=4, v=2, t_list=[2, 4, 6], p_str="x^6 + x + 1")
    bch_dec = BCHDecoder(q=q, t=t_list[0], p_str="x^6 + x + 1")

    # pattern generation loop
    attempt = 0
    while True:
        attempt += 1

        codewords = gii.encode_random_data(n)
        error_pos = gen_random_error_pos(n, num_subcodewords=m, min_err=0, max_err=6)

        received = []
        for i in range(m):
            received.append(gen_receive(n, codewords[i], error_pos[i]))

        if is_good_pattern(
            received,
            error_pos,
            bch_dec,
            t0=t_list[0],
            max_failed_for_stage2=v,
            target_failed_stage1=target_failed_stage1
        ):
            print(f"Found valid pattern after {attempt} attempts")
            print("error_pos =", error_pos)
            print("received =", received)
            break

    codeword_file = f"../00_TB/testdata/codeword/p{case}a.txt"
    received_file = f"../00_TB/testdata/pattern/p{case}.txt"
    error_pos_file = f"../00_TB/testdata/error_pos/p{case}e.txt"

    write_codewords_to_file(codewords, codeword_file)
    write_codewords_to_file(received, received_file)
    write_error_pos_to_file(error_pos, error_pos_file)


main(3)