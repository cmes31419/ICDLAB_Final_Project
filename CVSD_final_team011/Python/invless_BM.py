
from galois_field import GF
import sys
import argparse
# for i in range(63):
#     print(f"poly form: {power_to_poly[i]:06b}, powerform: {poly_to_power[power_to_poly[i]]}")
# m = 10
# t = 4
# gf = GF(m)
# gf.print_table()

# === m = 6, t = 2 ================
# syndrome = [58, 53, 39, 43] # store syndrome in power form
# syndrome = [1, 2, 5, 4]
# syndrome = [56, 49, 48, 35]

# === m = 8, t = 2 ================
# syndrome = [149, 43, 224, 86]
# syndrome = [58, 116, 119, 232]

# === m = 10, t = 4 ================
# syndrome = [35, 70, 217, 140, 741, 434, 308, 280]
# syndrome = [632, 241, 43, 482, 328, 86, 987, 964]
# syndrome =[873, 723, 734, 423, 270, 445, 631, 846]
def invless_BM(m, t, syndrome, verbose):
    gf = GF(m)
    sigma = [1] + [0] * t
    b = [1] + [0] * (t+1)

    k = 0
    k_next = 0
    gamma = 1
    gamma_next = 0

    syndrome = [gf.power2poly[syndrome[i]] for i in range(2*t)]

    delta_poly = syndrome 
    theta_poly = syndrome
    # print(delta)
    for r in range(2*t-1):
        discrepancy = delta_poly[0]

        if verbose:
            print(f"=== Iteration r = {r} ===")
            # print(f"discrepancy: {gf.poly2power[discrepancy]}")
            # print(f"k({r}) = {k}, γ({r}) = {gf.poly2power[gamma]} ")
            print(f"discrepancy: {discrepancy}")
            print(f"k({r}) = {k}, γ({r}) = {gamma} ")
            print("Before Update:")
            # print(f"𝛔(x) = {[gf.poly2power[sigma[i]] for i in range(len(sigma))]}")
            # print(f"b(x) = {[gf.poly2power[b[i]] for i in range(len(b))]}")
            # print(f"δ(x) = {[gf.poly2power[delta_poly[i]] for i in range(len(delta_poly))]}")
            # print(f"θ(x) = {[gf.poly2power[theta_poly[i]] for i in range(len(theta_poly))]}")
            print(f"𝛔(x) = {sigma}")
            print(f"b(x) = {b}")
            print(f"δ(x) = {delta_poly}")
            print(f"θ(x) = {theta_poly}")

        sigma_next = [0] * (t+1)
        b_next = [0] * (t+2)
        delta_poly_next = [0] * (2*t)
        theta_poly_next = [0] * (2*t)

        if discrepancy != 0 and k >= 0:
            gamma_next = discrepancy
            k_next = -k-1
        else:
            gamma_next = gamma
            k_next = k + 1
        # gf.print_poly(gamma_next)
        # print(f"k_next = {k_next}")
        for i in range(2*t):
            # update delta
            if i+1 < len(delta_poly):
                mul_res1 = gf.mul(gamma, delta_poly[i+1])
            else:
                mul_res1 = 0
            mul_res2 = gf.mul(discrepancy, theta_poly[i]) 
            # print(gf.poly2power[mul_res1], gf.poly2power[mul_res2])
            add_result = gf.add(mul_res1, mul_res2)
            # print(add_result)
            delta_poly_next[i] = add_result

            # update theta_poly
            if discrepancy != 0 and k >= 0:
                if i+1 < len(delta_poly):
                    theta_poly_next[i] = delta_poly[i+1]
                else: 
                    theta_poly_next[i] = 0
            else:
                theta_poly_next[i] = theta_poly[i]

        for j in range(t+1):
            mul_res1 = gf.mul(gamma, sigma[j])
            b_prev = b[j-1] if i > 0 else 0
            mul_res2 = gf.mul(discrepancy, b_prev)
            add_result = gf.add(mul_res1, mul_res2)
            sigma_next[j] = add_result

            if discrepancy != 0 and k >= 0:
                b_next[j] = sigma[j]
            else: 
                b_next[j] = b[j-1]

        delta_poly = delta_poly_next
        theta_poly = theta_poly_next

        sigma = sigma_next 
        b = b_next
        gamma = gamma_next
        k = k_next
        if verbose:
            print("After Update:")
            # print(f"𝛔(x) = {[gf.poly2power[sigma[i]] for i in range(len(sigma))]}")
            # print(f"b(x) = {[gf.poly2power[b[i]] for i in range(len(b))]}")
            # print(f"δ(x) = {[gf.poly2power[delta_poly[i]] for i in range(len(delta_poly))]}")
            # print(f"θ(x) = {[gf.poly2power[theta_poly[i]] for i in range(len(theta_poly))]}")
            print(f"𝛔(x) = {sigma}")
            print(f"b(x) = {b}")
            print(f"δ(x) = {delta_poly}")
            print(f"θ(x) = {theta_poly}")
            print("\n")
    
    return [gf.poly2power[sigma[i]] for i in range(len(sigma))]
# answer obtained using Peterson's algorithm
# need to convert to poly form first
# sigma_ans = [syndrome[0], 0, 0]
# sigma_ans[1] = gf.mul(syndrome[0], syndrome[0]) 
# sigma_ans[2] = gf.add(gf.mul(syndrome[1], syndrome[0]), syndrome[2])
def main(args):
    case = args.case
    verbose = args.print_steps
    print_poly = args.polyform

    filename = f"./syndromes/syn{case}.txt"
    with open(filename, "r") as file:
        lines = [line.strip() for line in file if line.strip()]  

    m = int(lines[0])
    t = 2
    if m == 10: t = 4    
    gf = GF(m)
    syndrome = lines[1:]
    syndrome = [int(syndrome[i]) for i in range(len(syndrome))]

    sigma_poly = invless_BM(m, t, syndrome, verbose)
    if print_poly:
        print("Sigma in polynomial form")
        print([gf.power2poly[sigma_poly[i]] for i in range(len(sigma_poly))])

    output_file = f"./sigma_polynomial/sigma{case}.txt"
    with open(output_file, "w") as file:
        for i in range(len(sigma_poly)):
            if (sigma_poly[i] != -1):
                file.write(str(sigma_poly[i]) + "\n")
    print(f"Computed Error Location Polynomial for case: {case}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compute Syndromes')
    parser.add_argument('case', type=str, help='Case number')
    parser.add_argument('--print_steps', default=False, action="store_true", help='Print Inversionless BM calculation steps in polynomial form')
    parser.add_argument('--polyform', default=False, action="store_true", help="Print ELP in polyform")
    args = parser.parse_args()
    
    main(args)




        


        