# GF($2^q$) Multiplier Verilog Generator

This Python script generates a single Verilog/SystemVerilog file for a finite-field multiplier over \(GF(2^q)\).

The generated Verilog contains:

1. `gf_mul`  
   Top-level finite-field multiplier module.

2. `binary_mul`  
   Raw binary polynomial multiplier.

3. `reduction_table`  
   Modular reduction logic based on the given primitive polynomial.

---

## 1. Purpose

This generator is used to create a hardware multiplier for finite-field arithmetic:

\[
GF(2^q)
\]

The multiplication is performed in two steps:

1. Raw polynomial multiplication:

\[
A(x)B(x)
\]

2. Modular reduction by the primitive polynomial:

\[
p(x)
\]

For example, if:

\[
p(x)=x^6+x+1
\]

then the primitive polynomial is represented in binary as: 0b1000011

## 2. Usage

```bash
python gen_gf_mul.py <q> <prim_poly> <output_file>
```
