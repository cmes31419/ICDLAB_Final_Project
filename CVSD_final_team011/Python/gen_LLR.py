import random
from gen_received import gen_receive
from soft_decoding import soft_decoding

seed = 89
# seed: 89, 69, 1000
random.seed(seed)
def int_to_str(n):
    """Convert integer -127 to 127 to 8-bit two's complement binary string"""
    if n < 0:
        # For negative numbers: compute two's complement
        n = (1 << 8) + n  # Add 2^8 = 256
    # Format as 8-bit binary
    return format(n, '08b')

def xor_with_shift_int(a, b, shift):
    """
    Alternative using integer bitwise operations
    """
    # Validate
    if shift < 0 or shift > len(a) - len(b):
        raise ValueError(f"Shift {shift} out of range [0, {len(a) - len(b)}]")
    # Convert binary strings to integers
    a_int = int(a, 2)
    b_int = int(b, 2) 
    # Shift b to the left by 'shift' positions
    b_shifted = b_int << shift 
    # Perform XOR
    result_int = a_int ^ b_shifted 
    # Convert back to binary string with same length as a
    return format(result_int, f'0{len(a)}b')

def gen_codeword(m, shift):
    assert m==10 or m==8 or m==6
    codeword_dict = {
        6: "010010100001111110110100101010001110011010111010101110100000011",
        8: "010010100001111110110100101010001110011010111010101101100010100110000100011001011000101000010101101101000011110011000110011111100011001110000001101011011001100111010010101100011011011001100111111010011011100111000001110110100011001000011110101010010001000",
        10: "010010100001111110110100101010001110011010111010101101100010100110000100011001011000101000010101101101000011110011000110011111100011001110000001101011011001100111010010101100011011011001100111111010011011100111000001110110100011001000011110000000010011001110011001111010010101000110000111100000110100110110111001010101110110110011011011010101001111111101010101010011001100100100011111011001101110101011001101101000111001010011000101100000100010001111110100011101011001001001100001000101001111010010101000111011110010000000101000001100000011100000010010001010100010001001000000000100000100001101110100010100001100000101000000010000010001111000100111011100010011100110111000101100101101011000101111101001011000110110011101100101100000000111011111011010111001001110101000111010110001001010001011001001111101011100010000111101101000011001010000111100011011110111001000111000110100000101011101101110000110110111110011001101000110101011001101110101011101001111100001000001100010110100110100100111100000011101100101101111111010111"
    }
    gen_poly_dict = {
        6 : "1010100111001",
        8 : "10110111101100011",
        10: "11000001011101011111010010001111010011011"
    }
    return xor_with_shift_int(codeword_dict[m], gen_poly_dict[m], shift)

def reset_file(m, case, hard:bool):
    mode = "soft" 
    if hard: mode = "hard"

    codeword_file = f"../01_RTL/testdata/{mode}_codeword/{mode}codeword_{m}_{case}.txt"
    write_file = f"../01_RTL/testdata/{mode}_pattern/{mode}_{m}_{case}.txt"
    ans_file = f"../01_RTL/testdata/{mode}_pattern/{mode}ans_{m}_{case}.txt"

    with open(codeword_file ,"w") as f:
        f.write("")
    with open(write_file ,"w") as f:
        f.write("")
    with open(ans_file ,"w") as f:
        f.write("")

def write_to_file(codeword, llr_str_list, error_pos, m, case, hard: bool):
    """
    hard = 1: hard, hard = 0: soft
    """
    n = 2**m-1
    mode = "soft" 
    if hard: mode = "hard"

    codeword_file = f"../01_RTL/testdata/{mode}_codeword/{mode}codeword_{m}_{case}.txt"
    write_file = f"../01_RTL/testdata/{mode}_pattern/{mode}_{m}_{case}.txt"
    ans_file = f"../01_RTL/testdata/{mode}_pattern/{mode}ans_{m}_{case}.txt"

    # write codeword ========
    with open(codeword_file, "a") as file:
        file.write(codeword+"\n")

    # write LLR ==========
    line_count = (n+1)//8
    with open(write_file, "a") as file:
        for i in range(line_count):
            line = ""
            for j in range(8):
                index = 8*i+j 
                if index == 0: line += "00000000"
                else: line += llr_str_list[index-1]
            file.write(line+"\n")  
        
    # write error position ======
    with open(ans_file, "a") as f:
        if len(error_pos)==0: f.write("1111111111"+"\n")
        else:
            error_pos = sorted(error_pos)
            for i in range(len(error_pos)):
                err_str = f"{error_pos[i]:0{10}b}"
                f.write(err_str + "\n")

def gen_hard_pattern(m, Ntest, case:int):
    assert m==10 or m==8 or m==6 
    t = 2
    if m==10: t= 4 
    n = 2**m-1
    gen_poly_degree = {
        6: 12,
        8: 16,
        10: 40
    }
    LRB = [(1, 10), (61, 15)] # (position, LLR), position: 0 ~ (2^m - 2), abs(LLR) = 1 ~ 127, position = log(alpha)
    max_p = LRB[0][1] if LRB[0][1] >= LRB[1][1] else LRB[1][1]
    llr_abs = [random.randint(max_p+1,127) for _ in range(n)] # abs value of LLR
    # add LRB =========
    for i in range(len(LRB)):
        j = n - 1 - LRB[i][0]
        llr_abs[j] = LRB[i][1]
    # ================
    reset_file(m, case, True)
    for _ in range(Ntest):
        # generate codeword ===
        shift_amt = random.randint(0, n-1- gen_poly_degree[m])
        codeword = gen_codeword(m, shift_amt)
        #==============
        num_error = random.randint(0, t)
        # print(num_error)
        error_pos = random.sample(range(0, n), num_error)        
        erronous_code = gen_receive(n, codeword, error_pos)
        
        llr_str = []
        for i in range(len(codeword)):
            if erronous_code[i] == "1":
                llr_str.append(int_to_str(-llr_abs[i]))
            else:
                llr_str.append(int_to_str(llr_abs[i]))

        write_to_file(codeword, llr_str, error_pos, m, case, True)


def gen_soft_pattern(m, Ntest, case:int):
    assert m==10 or m==8 or m==6 
    t = 2
    if m==10: t= 4 
    n = 2**m-1
    gen_poly_degree = {
        6: 12,
        8: 16,
        10: 40
    }
    max_error = t+2    

    min1, min2 = 10 ,15 # fix llr value
    reset_file(m, case, False)

    radius = 64
    sample_with_rad = True
    # sample_with_rad = False
    print(f"Sampling with radius: {sample_with_rad}")
    for test_idx in range(Ntest):
        test_pass = False

        while not test_pass:        
            # generate codeword ===
            shift_amt = random.randint(0, n-1- gen_poly_degree[m])
            codeword = gen_codeword(m, shift_amt)
            #==============
            # sample error position and LRB position
            num_error = test_idx % (max_error+1)
            # print(num_error)
            if num_error <= t:
                lrb_pos = random.sample(range(0, n), 2) 
                if sample_with_rad:
                    mid = random.randint(0, n-1)
                    left = mid - radius
                    right = mid + radius
                    if left < 0:
                        left = 0
                    elif right > n-1:
                        right = n-1
                    error_pos = random.sample(range(left, right+1), num_error)
                else: error_pos = random.sample(range(0, n), num_error)   
            else:
                if sample_with_rad:
                    mid = random.randint(0, n-1)
                    left = mid - radius
                    right = mid + radius
                    if left < 0:
                        left = 0
                    elif right > n-1:
                        right = n-1
                    error_pos = random.sample(range(left, right+1), num_error)             
                else: error_pos = random.sample(range(0, n), num_error)   

                extra_error = num_error - t
                lrb_pos = error_pos[:extra_error]

                if extra_error==1:
                    second_lrb_pos = random.randint(0,n-1)
                    while second_lrb_pos in lrb_pos:
                        second_lrb_pos = random.randint(0,n-1)
                    lrb_pos.append(second_lrb_pos)
            # =====================
            error_pos = sorted(error_pos)
            print(f"Desired error pos : {error_pos}")
            print(f"Desired lrb pos: {lrb_pos}")
            erronous_code = gen_receive(n, codeword, error_pos)

            # add LRB =========
            LRB = [(lrb_pos[0], min1), (lrb_pos[1], min2)] # (position, LLR), position: 0 ~ (2^m - 2), abs(LLR) = 1 ~ 127, position = log(alpha)
            max_p = LRB[0][1] if LRB[0][1] >= LRB[1][1] else LRB[1][1]
            llr_abs = [random.randint(max_p+1,127) for _ in range(n)] # abs value of LLR
            for i in range(len(LRB)):
                j = n - 1 - LRB[i][0]
                llr_abs[j] = LRB[i][1]
            # ================

            llr_str = []
            llr_list = []
            for i in range(len(codeword)):
                if erronous_code[i] == "1":
                    llr_str.append(int_to_str(-llr_abs[i]))
                    llr_list.append(-llr_abs[i])
                else:
                    llr_str.append(int_to_str(llr_abs[i]))
                    llr_list.append(llr_abs[i])

            true_error, _ , repeated_candidate = soft_decoding(m, erronous_code, llr_list, True)
            print(f"decoded error pos: {true_error}")
            if repeated_candidate:
                print("Repeated candidate! Pattern failed!")
                print("===========\n")
                continue

            # check whether the test pattern is consistent 
            if (len(error_pos) == len(true_error)):
                test_pass = True
                for i in range(len(error_pos)):
                    if (error_pos[i] != true_error[i]):
                        test_pass = False
                        print("Pattern Failed")
                        break
            else: print("Pattern Failed")

            if test_pass:
                write_to_file(codeword, llr_str, error_pos, m, case, False)
                print("Pattern Written")
            print("===========\n")
def gen_hard_faulty_pattern(m, Ntest, case:int):
    assert m==10 or m==8 or m==6 
    t = 2
    if m==10: t= 4 
    n = 2**m-1
    gen_poly_degree = {
        6: 12,
        8: 16,
        10: 40
    }
    LRB = [(1, 10), (61, 15)] # (position, LLR), position: 0 ~ (2^m - 2), abs(LLR) = 1 ~ 127, position = log(alpha)
    max_p = LRB[0][1] if LRB[0][1] >= LRB[1][1] else LRB[1][1]
    llr_abs = [random.randint(max_p+1,127) for _ in range(n)] # abs value of LLR
    # add LRB =========
    for i in range(len(LRB)):
        j = n - 1 - LRB[i][0]
        llr_abs[j] = LRB[i][1]
    # ================
    reset_file(m, case, True)
    for _ in range(Ntest):
        # generate codeword ===
        shift_amt = 0
        # shift_amt = random.randint(0, n-1- gen_poly_degree[m])
        codeword = gen_codeword(m, shift_amt)
        #==============
        # num_error = random.randint(0, t)
        num_error = 6
        error_pos = random.sample(range(0, n), num_error)        
        erronous_code = gen_receive(n, codeword, error_pos)
        
        llr_str = []
        for i in range(len(codeword)):
            if erronous_code[i] == "1":
                llr_str.append(int_to_str(-llr_abs[i]))
            else:
                llr_str.append(int_to_str(llr_abs[i]))

        write_to_file(codeword, llr_str, error_pos, m, case, True)


m = 10
Ntest = 64
case = 6
# gen_hard_pattern(m, Ntest, case)
gen_soft_pattern(m, Ntest, case)
# gen_hard_faulty_pattern(m, Ntest, case)
# error_pos = [30, 50, 61]
