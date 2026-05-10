#!/bin/bash

seed=42
ntest=100
m=4
q=6
n=63                    # n = 2^q - 1
t_max=6
prim_poly=0b1000011     # x^6 + x + 1
parallel_num=32         # parallel_num = 8, 16, 32, ..., 2^(q-1) or  2^q - 1
memory_bank_num=1

echo "===================================="
echo "Run parameters"
echo "===================================="
echo "seed            = $seed"
echo "ntest           = $ntest"
echo "m               = $m"
echo "q               = $q"
echo "n               = $n"
echo "t_max           = $t_max"
echo "prim_poly       = $prim_poly"
echo "parallel_num    = $parallel_num"
echo "memory_bank_num = $memory_bank_num"
echo "===================================="

python utils/gen_CHIP.py $m $n $memory_bank_num
python utils/gen_memory.py $m $n $memory_bank_num