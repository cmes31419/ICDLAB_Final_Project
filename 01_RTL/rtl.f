// testbench
../00_TB/tb_RTL.v

// Define files

// Design
TOP.sv

// CTRL
./CTRL/controller.sv

// MEM
./MEM/memory.sv

// LSU
./LSU/syndrome.sv
./LSU/syndrome_rotate_add.sv
./LSU/syndrome_pow.sv

// NSU
./NSU/Ainv.sv
./NSU/nsu_top.v
./NSU/horner_a5.v
./NSU/horner_a7.v
./NSU/horner_a9.v
./NSU/horner_a11.v
./NSU/HSU_top.v

// NKES
./NKES/NKES.sv
./NKES/NKES_PE_array.sv
./NKES/NKES_PE0_unified.sv
./NKES/NKES_PE1_unified.sv
./NKES/NKES_core.sv
./NKES/NKES_ctrl.sv
./NKES/state_buff.sv
./NKES/precompute_unit.sv
./NKES/gf_mul.sv

// CS
./CS/chien_search.sv
./CS/chien_search_new.sv
./CS/chien_checker.sv
./CS/chien_checker_new.sv
./CS/chien_rotate.sv
./CS/sigmaV.sv