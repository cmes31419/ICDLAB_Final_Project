# Read Design
set DESIGN "CHIP"
analyze -format sverilog "flist.sv"
elaborate $DESIGN

current_design [get_designs $DESIGN]
uniquify
link

#source -echo -verbose ./your_design.sdc

############in sdc file
# Set the Optimization Constraints 
set cycle 10.0
create_clock -period $cycle -name "clk" -waveform {0 5} "clk"
set_dont_touch_network [get_ports clk]
set_fix_hold [get_clocks clk]


# Define the design environment
set_clock_uncertainty  0.1  [get_clocks clk]
set_clock_latency      0.5  [get_clocks clk]
set_input_delay  [expr $cycle*0.5] -clock clk [all_inputs]
set_output_delay [expr $cycle*0.5] -clock clk [all_outputs] 
set_drive 1  [all_inputs]
set_load  10 [all_outputs]


set_fix_multiple_port_nets -all -buffer_constants

set_operating_conditions -min_library fsa0m_a_generic_core_ff1p98vm40c -min BCCOM -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c

set_max_area 0
set_max_fanout 20 [all_inputs]
set_boundary_optimization {"*"}
#############in sdc file


check_design

# remove_attribute [find -hierarchy design {"*"}] dont_touch

# Map and Optimize the Design
# compile -map_effort medium
compile_ultra -no_autoungroup

# Analyze and debug the design
report_area -hierarchy > "./Report/area_${DESIGN}.out"
report_power > "./Report/power_${DESIGN}.out"
report_timing -path full -delay max > "./Report/timing_${DESIGN}.out"

#write -format db -hierarchy -output $active_design.db
write -format verilog -hierarchy -output "./Netlist/${DESIGN}_syn.v"
write_sdf -version 2.1 -context verilog "./Netlist/${DESIGN}_syn.sdf"
write_sdc "./Netlist/${DESIGN}_syn.sdc"

# exit