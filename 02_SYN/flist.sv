// testbench
// ../00_TB/tb.v

// Define files

// Design
`include "../01_RTL/CHIP.sv"

// CTRL
`include "../01_RTL/CTRL/controller.sv"

// MEM
`include "../01_RTL/MEM/memory.sv"

// LSU
`include "../01_RTL/LSU/syndrome.sv"
`include "../01_RTL/LSU/syndrome_rotate_add.sv"
`include "../01_RTL/LSU/syndrome_pow.sv"

// NSU
`include "../01_RTL/NSU/nsu_top.v"
`include "../01_RTL/NSU/horner_a5.v"
`include "../01_RTL/NSU/horner_a7.v"
`include "../01_RTL/NSU/horner_a9.v"
`include "../01_RTL/NSU/horner_a11.v"
`include "../01_RTL/NSU/HSU_top.v"

// HSU
`include "../01_RTL/HSU/Ainv.sv"
`include "../01_RTL/HSU/gf_mul.sv"

// KES
`include "../01_RTL/KES/BM.sv"
`include "../01_RTL/KES/BM_PE0.sv"
`include "../01_RTL/KES/BM_PE1.sv"
`include "../01_RTL/KES/gf_mul.sv"

// NKES
`include "../01_RTL/NKES/NKES.sv"
`include "../01_RTL/NKES/state_buff.sv"
`include "../01_RTL/NKES/NKES_PE0.sv"
`include "../01_RTL/NKES/NKES_PE1.sv"

// CS
`include "../01_RTL/CS/chien_search.sv"
`include "../01_RTL/CS/chien_checker.sv"
`include "../01_RTL/CS/chien_rotate.sv"
`include "../01_RTL/CS/sigmaV.sv"