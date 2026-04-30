text = f"""// testbench
tb.v

// Design
syndrome.sv
syndrome_pow.sv
syndrome_rotate_add.sv"""

f = open("rtl.f", "w")
f.write(text)
f.close()

print("Generated rtl.f")