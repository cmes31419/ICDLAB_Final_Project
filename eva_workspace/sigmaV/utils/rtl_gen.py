import sys

out_fname_old = str(sys.argv[1])
out_fname = str(sys.argv[2])

text = f"""// testbench
tb.v

// Design
{out_fname_old}
{out_fname}"""

f = open("rtl.f", "w")
f.write(text)
f.close()