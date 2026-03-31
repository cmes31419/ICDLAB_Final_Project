def gf_mul(a: int, b: int, p: int, m: int) -> int:
    """
    在 GF(2^m) 裡做乘法，模掉多項式 p(x)
    這裡用 'Russian peasant' 乘法法則
    a, b, p 都用 bit 代表多項式係數
    """
    res = 0
    while b:
        if b & 1:
            res ^= a
        b >>= 1
        a <<= 1
        # 如果出現 x^m 以上的項，就用 p(x) 簡化
        if a & (1 << m):
            a ^= p
    # 最後只保留 m 個 bit
    return res & ((1 << m) - 1)

def build_exp_log_tables(alpha: int, p: int, m: int):
    """
    建立 α^0...α^{2^m-2} 的 exp table
    以及 element -> exponent 的 log table
    """
    field_order = (1 << m) - 1        # 2^m - 1 = 63
    exp_table = [0] * (1 << m)        # exp_table[i] = α^i
    log_table = [0] * (1 << m)        # log_table[element] = i  (element = α^i)

    x = 1
    for i in range(field_order + 1):
        exp_table[i] = x
        log_table[x] = i
        x = gf_mul(x, alpha, p, m)

    log_table[0] = 2**m-1

    # 定義 log(0) 沒意義，保持 0 或另外處理
    return exp_table, log_table


if __name__ == "__main__":
    table = "exp_table" # exp_table / log_table

    alpha = 0b10  # 把 α 選成 x

    # 1: (63,51,t=2), m=6
    # 2: (255,239,t=2), m=8
    # 3: (1023,983,t=4), m=10
    m = 6

    parallel_num = 32
    sample = (1<<m) // parallel_num

    if m == 6:
        # primitive polynomial: x^6 + x + 1
        p = 0b1000011

    elif m == 8:
        # primitive polynomial: x^8 + x^4 + x^3 + x^2 + 1
        p = 0b100011101

    elif m == 10:
        # primitive polynomial: x^10 + x^3 + 1
        p = 0b10000001001

    exp_table, log_table = build_exp_log_tables(alpha, p, m)

    if table == "log_table":
        out_filename = f"log_table_m{m}.txt"
        with open(out_filename, 'w') as f:
            for x, i in enumerate(log_table):
                line = f"assign table{(1<<m)-1}[{x}] = {m}'d{i};\n"
                f.write(line)

        print(f"[OK] 已寫入 {out_filename}")

        out_filename = f"log_table_m{m}_minus.txt"
        with open(out_filename, 'w') as f:
            for x, i in enumerate(log_table):
                line = f"assign table{(1<<m)-1}[{x}] = {m}'d{(1<<m)-1-i};\n"
                f.write(line)

        print(f"[OK] 已寫入 {out_filename}")
    
    elif table == "exp_table":
        concat = 0
        out_filename = f"exp_table_m{m}.txt"
        out = [""] * 10
        with open(out_filename, 'w') as f:
            for i, x in enumerate(exp_table):
                # line = f"assign table[{i}] = {m}'b{format(x, 'b')};\n"
                # f.write(line)

                for j in range(10):
                    if (i <= 5*(m-1)) and (x & (1<<j)):
                        if out[j] == "": out[j] += f"in1[{i}]"
                        else: out[j] += f" ^ in1[{i}]"

                # if ((i-1)//8) % sample == 0:
                #     print(i, (i-1)//8, (m*((i-1)%8+(i-1)//(sample*8)*8)))
                #     concat = concat + (x << (m*((i-1)%8+(i-1)//(sample*8)*8)))
                #     line = f"assign table[{i}] = {m}'h{format(x, 'x')};\n"
                #     f.write(line)
                # if i % sample == 0:
                #     print(i, (m*i//sample))
                #     concat = concat + (x << (m*i//sample))
                #     line = f"assign table[{i}] = {m}'h{format(x, 'x')};\n"
                #     f.write(line)
            # line = f"`define CHIEN_INIT_POLY_{(1<<m)-1} {parallel_num*m}'h{format(concat, 'x')}\n"
            # f.write(line)
            for j in range(10):
                f.write(f"out[{j}] = {out[j]};\n")

        print(f"[OK] 已寫入 {out_filename}")