#!/bin/bash

seed=42
ntest=100
parallel_num=32
q=6
n=63                    # n = 2^q - 1
t_max=6
prim_poly=0b1000011     # x^6 + x + 1
mode=1                  # 1: contiguous (default), 2: interleave

python utils/gen_sigmaV_conventional.py $parallel_num $q $n $t_max $prim_poly $mode
python utils/gen_sigmaV_baseline.py  $parallel_num $q $n $t_max $prim_poly $mode
python utils/gen_sigmaV.py $parallel_num $q $n $t_max $prim_poly $mode
python utils/gen_rtl.py
python utils/gen_tb.py $ntest $parallel_num $q $t_max
python utils/gen_testdata.py $ntest $seed $q $t_max