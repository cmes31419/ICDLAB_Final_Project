import sys

n = int(sys.argv[1])
parallel_num = int(sys.argv[2])

text = f"""// testbench
tb.v

// Design
chien_search.sv
sigmaV.sv
chien_checker.sv"""

if parallel_num < n:
    text +="\nchien_rotate.sv"

f = open("rtl.f", "w")
f.write(text)
f.close()

print("Generated rtl.f")