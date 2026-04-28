import random
import sys

ntest = int(sys.argv[1])
seed = int(sys.argv[2])
q = int(sys.argv[3])
t_max = int(sys.argv[4])

random.seed(seed)

with open("testdata.txt", "w") as f:
    for _ in range(ntest):
        bits = format(random.getrandbits(q * (t_max + 1)), f"0{q * (t_max + 1)}b")
        f.write(bits + "\n")