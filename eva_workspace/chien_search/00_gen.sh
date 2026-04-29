#!/bin/bash

seed=42
ntest=100
parallel_num=16
q=6
n=63                    # n = 2^q - 1
t_max=10
prim_poly=0b1000011     # x^6 + x + 1
mode=1                  # 1: contiguous (default), 2: interleave

python utils/gen_chien_search.py $parallel_num $q $n $t_max
python utils/gen_chien_rotate.py $parallel_num $q $t_max $prim_poly
python utils/gen_sigmaV.py $parallel_num $q $n $t_max $prim_poly $mode
python utils/gen_rtl.py
python utils/gen_tb.py $ntest $parallel_num $q $n $t_max
python utils/gen_testdata.py $seed $ntest $q $t_max $prim_poly