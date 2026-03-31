from galois_field import GF
from ELP_from_ans import roots_to_coefficients

from gen_received import gen_receive
from compute_syndrome import compute_syndromes
from invless_BM import invless_BM


def chien_search(m:int, sigma_poly:list, degree:int):
    """
    Return:
    1. validity of decoding
    2. error position
    """
    if len(sigma_poly) == 1:
        return True, []
    
    gf = GF(m)
    sigma_poly = [gf.power2poly[sig] for sig in sigma_poly]
    sigma_poly = sigma_poly[:degree+1]

    t=2
    if m==10: t=4
    n = 2 ** m - 1
    roots_list = []
    for root_pow in range(n):
        x_list = [1] + [0]*degree
        result = 0
        for j in range(degree):
            x_list[j+1] = gf.mul(x_list[j], gf.power2poly[root_pow])
        for j in range(degree+1):
            result = gf.add(result, gf.mul(sigma_poly[j], x_list[j]))
        if result == 0: 
            roots_list.append(root_pow)

    # find inverse of the roots 
    error_pos = [n-roots_list[i] if roots_list[i]!=0 else 0 for i in range(len(roots_list))]
    
    valid = (len(error_pos) == degree)
    return valid, error_pos
# m = 6
# t = 2
# n = 2**m-1
# gf = GF(m)
# sigma_poly = [35,21,40]
# ans_poly = roots_to_coefficients(6, error_pos)
# print(ans_poly)
# print(chien_search(m, ans_poly))

# print(chien_search(m, sigma_poly))

# error_pos = [43, 44, 53]
# code_63_soft = "101100010100110000100011001011000101000010101101101101010001001"
# received_code = gen_receive(n, code_63_soft, error_pos)
# print(received_code)
# syn = compute_syndromes(received_code, m ,t) # return in poly
# syn = [gf.poly2power[syn[i]] for i in range(len(syn))]
# sigma_poly = invless_BM(m ,t, syn, False)
# print(sigma_poly)
# print(chien_search(m, sigma_poly))