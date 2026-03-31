import random
from galois_field import GF

m = 6
gf = GF(m)
print(f"m: {m}")

if m == 10:
    a, b = random.randint(0, 1023), random.randint(0, 1023)
    c = gf.mul(a, b)
    print(f"a: {a}, b: {b}, a*b: {c}")
elif m == 8:
    a, b = random.randint(0, 255), random.randint(0, 255)
    c = gf.mul(a, b)
    print(f"a: {a}, b: {b}, a*b: {c}")
else:
    a, b = random.randint(0, 63), random.randint(0, 63)
    c = gf.mul(a, b)
    print(f"a: {a}, b: {b}, a*b: {c}")