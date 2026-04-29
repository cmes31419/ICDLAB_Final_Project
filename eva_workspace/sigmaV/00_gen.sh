#!/bin/bash

seed=42
ntest=100
parallel_num=32
n=63
q=6
t_max=6
prim_poly=0b1000011     # x^6 + x + 1
mode=1                  # 1: contiguous (default), 2: interleave

out_fname_conventional="sigmaV_conventional.sv"
out_fname_baseline="sigmaV_baseline.sv"
out_fname="sigmaV.sv"

python utils/gen_sigmaV_conventional.py $out_fname_conventional $parallel_num $n $q $t_max $prim_poly $mode
python utils/gen_sigmaV_baseline.py $out_fname_baseline $parallel_num $n $q $t_max $prim_poly $mode
python utils/gen_sigmaV.py $out_fname $parallel_num $n $q $t_max $prim_poly $mode
python utils/gen_rtl.py $out_fname_conventional $out_fname_baseline $out_fname
python utils/gen_tb.py $ntest $parallel_num $q $t_max
python utils/gen_testdata.py $ntest $seed $q $t_max