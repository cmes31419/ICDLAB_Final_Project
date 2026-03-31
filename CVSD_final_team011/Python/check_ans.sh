

# for case in {0..5}; do
#     echo "Running case $case"
#     python gen_received.py ${case}

#     python compute_syndrome.py ${case} --polyform

#     python invless_BM.py ${case} --polyform

#     python ELP_from_ans.py ${case}
# done

case=7
echo "Running case $case"
python gen_received.py ${case}
python compute_syndrome.py ${case} --polyform

python invless_BM.py ${case} --polyform 

python ELP_from_ans.py ${case}
