#!/bin/bash

ntest=100
parallel_num=32
n=64
q=6
t_max=6
prim_poly=0b1000011     # x^6 + x + 1
mode=1                  # 1: contiguous (default), 2: interleave

out_fname_conventional="sigmaV_${parallel_num}_conventional.v"
out_fname_baseline="sigmaV_${parallel_num}_baseline.v"
out_fname="sigmaV_${parallel_num}.v"

python utils/sigmaV_gen_conventional.py $out_fname_conventional $parallel_num $n $q $t_max $prim_poly $mode
python utils/sigmaV_gen_baseline.py $out_fname_baseline $parallel_num $n $q $t_max $prim_poly $mode
python utils/sigmaV_gen.py $out_fname $parallel_num $n $q $t_max $prim_poly $mode
python utils/rtl_gen.py $out_fname_conventional $out_fname_baseline $out_fname
python utils/tb_gen.py $ntest $parallel_num $q $t_max
python utils/testdata_gen.py $ntest