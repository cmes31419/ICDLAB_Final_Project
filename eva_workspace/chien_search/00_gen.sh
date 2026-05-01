#!/bin/bash

seed=42
ntest=100
q=6
n=63                    # n = 2^q - 1
t_max=6
prim_poly=0b1000011     # x^6 + x + 1
parallel_num=32         # parallel_num = 8, 16, 32, ..., 2^(q-1), 2^q - 1

echo "=============================="
echo "Run parameters"
echo "=============================="
echo "seed         = $seed"
echo "ntest        = $ntest"
echo "q            = $q"
echo "n            = $n"
echo "t_max        = $t_max"
echo "prim_poly    = $prim_poly"
echo "parallel_num = $parallel_num"
echo "=============================="

python utils/gen_chien_search.py $q $n $t_max $parallel_num
python utils/gen_chien_checker.py $n $t_max $parallel_num
python utils/gen_chien_rotate.py $q $n $t_max $prim_poly $parallel_num
python utils/gen_sigmaV.py $q $n $t_max $prim_poly $parallel_num
python utils/gen_rtl.py $n $parallel_num
python utils/gen_tb.py $ntest $q $n $t_max $parallel_num
python utils/gen_testdata.py $seed $ntest $q $t_max $prim_poly