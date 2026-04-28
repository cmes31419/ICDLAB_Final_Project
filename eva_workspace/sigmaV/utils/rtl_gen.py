import sys

out_fname_conventional = str(sys.argv[1])
out_fname_baseline = str(sys.argv[2])
out_fname = str(sys.argv[3])

text = f"""// testbench
tb.v

// Design
{out_fname_conventional}
{out_fname_baseline}
{out_fname}"""

f = open("rtl.f", "w")
f.write(text)
f.close()