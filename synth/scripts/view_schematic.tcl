set ARRAY_SIZE "4x4"

set_db lib_search_path ../../libs/asap7/asap7sc7p5t_28/LIB/NLDM/

set TARGET_LIBS {asap7sc7p5t_AO_RVT_SS_nldm_211120.lib \
                 asap7sc7p5t_INVBUF_RVT_SS_nldm_220122.lib \
                 asap7sc7p5t_OA_RVT_SS_nldm_211120.lib \
                 asap7sc7p5t_SEQ_RVT_SS_nldm_220123.lib \
                 asap7sc7p5t_SIMPLE_RVT_SS_nldm_211120.lib}

set_db target_library $TARGET_LIBS
set_db link_library $TARGET_LIBS

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

read_hdl -netlist ../outputs/asap7/nema_top_opt_4x4_netlist.v
elaborate nema_top
gui_show
