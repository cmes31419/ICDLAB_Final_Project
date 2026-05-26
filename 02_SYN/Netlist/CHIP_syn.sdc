###################################################################

# Created by write_sdc on Tue May 26 23:47:49 2026

###################################################################
set sdc_version 2.2

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_area 0
set_load -pin_load 10 [get_ports iready]
set_load -pin_load 10 [get_ports {odata[7]}]
set_load -pin_load 10 [get_ports {odata[6]}]
set_load -pin_load 10 [get_ports {odata[5]}]
set_load -pin_load 10 [get_ports {odata[4]}]
set_load -pin_load 10 [get_ports {odata[3]}]
set_load -pin_load 10 [get_ports {odata[2]}]
set_load -pin_load 10 [get_ports {odata[1]}]
set_load -pin_load 10 [get_ports {odata[0]}]
set_load -pin_load 10 [get_ports ovalid]
set_max_fanout 20 [get_ports clk]
set_max_fanout 20 [get_ports rst]
set_max_fanout 20 [get_ports {idata[7]}]
set_max_fanout 20 [get_ports {idata[6]}]
set_max_fanout 20 [get_ports {idata[5]}]
set_max_fanout 20 [get_ports {idata[4]}]
set_max_fanout 20 [get_ports {idata[3]}]
set_max_fanout 20 [get_ports {idata[2]}]
set_max_fanout 20 [get_ports {idata[1]}]
set_max_fanout 20 [get_ports {idata[0]}]
set_max_fanout 20 [get_ports ivalid]
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_latency 0.5  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  5  [get_ports clk]
set_input_delay -clock clk  5  [get_ports rst]
set_input_delay -clock clk  5  [get_ports {idata[7]}]
set_input_delay -clock clk  5  [get_ports {idata[6]}]
set_input_delay -clock clk  5  [get_ports {idata[5]}]
set_input_delay -clock clk  5  [get_ports {idata[4]}]
set_input_delay -clock clk  5  [get_ports {idata[3]}]
set_input_delay -clock clk  5  [get_ports {idata[2]}]
set_input_delay -clock clk  5  [get_ports {idata[1]}]
set_input_delay -clock clk  5  [get_ports {idata[0]}]
set_input_delay -clock clk  5  [get_ports ivalid]
set_output_delay -clock clk  5  [get_ports iready]
set_output_delay -clock clk  5  [get_ports {odata[7]}]
set_output_delay -clock clk  5  [get_ports {odata[6]}]
set_output_delay -clock clk  5  [get_ports {odata[5]}]
set_output_delay -clock clk  5  [get_ports {odata[4]}]
set_output_delay -clock clk  5  [get_ports {odata[3]}]
set_output_delay -clock clk  5  [get_ports {odata[2]}]
set_output_delay -clock clk  5  [get_ports {odata[1]}]
set_output_delay -clock clk  5  [get_ports {odata[0]}]
set_output_delay -clock clk  5  [get_ports ovalid]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst]
set_drive 1  [get_ports {idata[7]}]
set_drive 1  [get_ports {idata[6]}]
set_drive 1  [get_ports {idata[5]}]
set_drive 1  [get_ports {idata[4]}]
set_drive 1  [get_ports {idata[3]}]
set_drive 1  [get_ports {idata[2]}]
set_drive 1  [get_ports {idata[1]}]
set_drive 1  [get_ports {idata[0]}]
set_drive 1  [get_ports ivalid]
