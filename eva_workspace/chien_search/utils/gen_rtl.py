text = f"""// testbench
tb.v

// Design
chien_rotate.sv
chien_search.sv
sigmaV.sv"""

f = open("rtl.f", "w")
f.write(text)
f.close()