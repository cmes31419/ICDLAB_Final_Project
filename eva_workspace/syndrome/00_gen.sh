#!/bin/bash

seed=42
ntest=100
q=6
n=63                    # n = 2^q - 1
t_min=2
prim_poly=0b1000011     # x^6 + x + 1

echo "=============================="
echo "Run parameters"
echo "=============================="
echo "seed         = $seed"
echo "ntest        = $ntest"
echo "q            = $q"
echo "n            = $n"
echo "t_min        = $t_min"
echo "prim_poly    = $prim_poly"
echo "=============================="

python utils/gen_syndrome_rotate_add.py $q $t_min $prim_poly
python utils/gen_syndrome_pow.py $q $t_min $prim_poly
python utils/gen_syndrome.py $q $t_min
python utils/gen_rtl.py
python utils/gen_tb.py $ntest $q $n $t_min
python utils/gen_testdata.py $seed $ntest $q $n $t_min $prim_poly