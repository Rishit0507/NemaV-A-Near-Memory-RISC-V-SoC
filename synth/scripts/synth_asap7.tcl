set ARRAY_SIZE "4x4"

set_db lib_search_path ../../libs/asap7/asap7sc7p5t_28/LIB/NLDM/

set_db target_library {asap7sc7p5t_AO_RVT_SS_nldm_211120.lib \
                       asap7sc7p5t_INVBUF_RVT_SS_nldm_220122.lib \
                       asap7sc7p5t_OA_RVT_SS_nldm_211120.lib \
                       asap7sc7p5t_SEQ_RVT_SS_nldm_220123.lib \
                       asap7sc7p5t_SIMPLE_RVT_SS_nldm_211120.lib}
set_db link_library $target_library

read_hdl -sv ../../rtl/core/nema_decoder.sv \
             ../../rtl/accelerator/nema_decomp.sv \
             ../../rtl/accelerator/nema_mac_array.sv \
             ../../rtl/accelerator/nema_act.sv \
             ../../rtl/top/nema_top.sv

elaborate nema_top

create_clock -name clk -period 3333 [get_ports clk]

set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

syn_generic
syn_map
syn_opt
syn_opt -incremental

file mkdir ../reports/asap7
file mkdir ../outputs/asap7

report_timing > ../reports/asap7/nema_top_timing_${ARRAY_SIZE}.rpt
report_area   > ../reports/asap7/nema_top_area_${ARRAY_SIZE}.rpt
report_power  > ../reports/asap7/nema_top_power_${ARRAY_SIZE}.rpt

write_hdl nema_top > ../outputs/asap7/nema_top_opt_${ARRAY_SIZE}_netlist.v
write_sdc > ../outputs/asap7/nema_top_opt_${ARRAY_SIZE}.sdc
