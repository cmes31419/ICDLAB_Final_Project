text = f"""// testbench
tb.v

// Design
sigmaV_conventional.sv
sigmaV_baseline.sv
sigmaV.sv"""

f = open("rtl.f", "w")
f.write(text)
f.close()