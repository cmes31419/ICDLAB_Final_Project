import random
import sys

ntest = int(sys.argv[1])

with open("testdata.txt", "w") as f:
    for _ in range(ntest):
        bits = format(random.getrandbits(42), "042b")
        f.write(bits + "\n")