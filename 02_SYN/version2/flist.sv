// testbench
// ../00_TB/tb.v

// Define files

// CHIP
`include "../01_RTL/CHIP.v"

// DESIGN
`include "../01_RTL/TOP.sv"

// CTRL
`include "../01_RTL/CTRL/controller.sv"

// MEM
`include "../01_RTL/MEM/memory.sv"

// LSU
`include "../01_RTL/LSU/syndrome.sv"
`include "../01_RTL/LSU/syndrome_rotate_add.sv"
`include "../01_RTL/LSU/syndrome_pow.sv"

// NSU
`include "../01_RTL/NSU/NSU.sv"
`include "../01_RTL/NSU/NSU_core.sv"
`include "../01_RTL/NSU/horner_a5.sv"
`include "../01_RTL/NSU/horner_a7.sv"
`include "../01_RTL/NSU/horner_a9.sv"
`include "../01_RTL/NSU/horner_a11.sv"
`include "../01_RTL/NSU/Ainv.sv"

// NKES
`include "../01_RTL/NKES/NKES.sv"
`include "../01_RTL/NKES/NKES_PE_array.sv"
`include "../01_RTL/NKES/NKES_PE0_unified.sv"
`include "../01_RTL/NKES/NKES_PE1_unified.sv"
`include "../01_RTL/NKES/NKES_core.sv"
`include "../01_RTL/NKES/NKES_ctrl.sv"
`include "../01_RTL/NKES/state_buff.sv"
`include "../01_RTL/NKES/precompute_unit.sv"
`include "../01_RTL/NKES/gf_mul.sv"

// CS
`include "../01_RTL/CS/chien_search.sv"
`include "../01_RTL/CS/chien_checker.sv"
`include "../01_RTL/CS/chien_rotate.sv"
`include "../01_RTL/CS/sigmaV.sv"