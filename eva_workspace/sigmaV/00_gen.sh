#!/bin/bash

ntest=100
parallel_num=32
n=64
q=6
t_max=2
prim_poly=0b1000011        # x^6 + x + 1

out_fname_old="sigmaV_${parallel_num}_old.v"
out_fname="sigmaV_${parallel_num}.v"

python utils/sigmaV_gen_old.py $out_fname_old $parallel_num $n $q $t_max $prim_poly
python utils/sigmaV_gen.py $out_fname $parallel_num $n $q $t_max $prim_poly
python utils/rtl_gen.py $out_fname_old $out_fname
python utils/tb_gen.py $ntest $parallel_num $q $t_max
python utils/testdata_gen.py $ntest