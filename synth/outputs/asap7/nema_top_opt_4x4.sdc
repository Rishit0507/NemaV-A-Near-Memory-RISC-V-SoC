# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Mon Sep 14 04:40:15 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1fF
set_units -time 1ps

# Set the current design
current_design nema_top

create_clock -name "clk" -period 3333.0 -waveform {0.0 1666.5} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
