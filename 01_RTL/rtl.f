// testbench
../00_TB/tb.v

// Define files

// Design
CHIP.sv

// CTRL
./CTRL/controller.sv

// MEM
./MEM/memory.sv

// LSU
./LSU/syndrome.sv
./LSU/syndrome_rotate_add.sv
./LSU/syndrome_pow.sv

// NSU
./NSU/nsu_top.v
./NSU/horner_a5.v
./NSU/horner_a7.v
./NSU/horner_a9.v
./NSU/horner_a11.v
./NSU/HSU_top.v

// HSU
./HSU/Ainv.sv

// KES
./KES/BM.sv
./KES/BM_PE0.sv
./KES/BM_PE1.sv
./KES/gf_mul.sv

// NKES
./NKES/NKES.sv
./NKES/NKES_PE_array.sv
./NKES/NKES_PE_array_new.sv
./NKES/NKES_PE0.sv
./NKES/NKES_PE1.sv
./NKES/NKES_PE0_unified.sv
./NKES/NKES_PE1_unified.sv
./NKES/state_buff.sv
./NKES/precompute_unit.sv

// CS
./CS/chien_search.sv
./CS/chien_checker.sv
./CS/chien_rotate.sv
./CS/sigmaV.sv