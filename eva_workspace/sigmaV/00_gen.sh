#!/bin/bash

seed=42
ntest=100
parallel_num=32
m=4
q=6
n=63                    # n = 2^q - 1
t_max=6
prim_poly=0b1000011     # x^6 + x + 1

echo "=============================="
echo "Run parameters"
echo "=============================="
echo "seed         = $seed"
echo "ntest        = $ntest"
echo "parallel_num = $parallel_num"
echo "m            = $m"
echo "q            = $q"
echo "n            = $n"
echo "t_max        = $t_max"
echo "prim_poly    = $prim_poly"
echo "=============================="

python utils/gen_sigmaV_conventional.py $parallel_num $q $n $t_max $prim_poly
python utils/gen_sigmaV_baseline.py  $parallel_num $q $n $t_max $prim_poly
python utils/gen_sigmaV.py $parallel_num $q $n $t_max $prim_poly
python utils/gen_rtl.py
python utils/gen_tb.py $ntest $parallel_num $q $t_max
python utils/gen_testdata.py $ntest $seed $q $t_max