#!/bin/bash

q=6
n=63                    # n = 2^q - 1
prim_poly=0b1000011     # x^6 + x + 1
P=32
L1=5
L2=7
L3=9
L4=11

echo "=============================="
echo "Run parameters"
echo "q            = $q"
echo "n            = $n"
echo "prim_poly    = $prim_poly"
echo "P            = $P"
echo "=============================="

python utils/gen_horner.py $q $prim_poly $L1 $P $n
python utils/gen_horner.py $q $prim_poly $L2 $P $n
python utils/gen_horner.py $q $prim_poly $L3 $P $n
python utils/gen_horner.py $q $prim_poly $L4 $P $n