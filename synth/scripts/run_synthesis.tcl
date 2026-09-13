# Define array configuration tag for automated file naming
set ARRAY_SIZE "4x4"

set_db lib_search_path ../../libs/
set_db target_library slow.lib
set_db link_library slow.lib

read_hdl -sv ../../rtl/core/nema_decoder.sv \
             ../../rtl/accelerator/nema_decomp.sv \
             ../../rtl/accelerator/nema_mac_array.sv \
             ../../rtl/accelerator/nema_act.sv \
             ../../rtl/top/nema_top.sv

elaborate nema_top

define_clock -name clk -period 3330 [get_ports clk] 
# 300Mhz, 3.33ns

syn_generic
syn_map
syn_opt

file mkdir ../reports
file mkdir ../outputs

# Generate size-tagged PPA reports
report_timing > ../reports/nema_top_timing_${ARRAY_SIZE}.rpt
report_area   > ../reports/nema_top_area_${ARRAY_SIZE}.rpt
report_power  > ../reports/nema_top_power_${ARRAY_SIZE}.rpt

# Write out size-tagged netlist and SDC constraints
write_hdl nema_top > ../outputs/nema_top_opt_${ARRAY_SIZE}_netlist.v
write_sdc > ../outputs/nema_top_opt_${ARRAY_SIZE}.sdc
