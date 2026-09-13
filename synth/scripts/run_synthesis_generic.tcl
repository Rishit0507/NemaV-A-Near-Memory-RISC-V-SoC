# 1. Set HDL search paths (fixed quotes around multi-path string)
set_db init_hdl_search_path "../../rtl/core ../../rtl/accelerator"

# 2. Read SystemVerilog files
read_hdl -sv {nema_decoder.sv nema_mac_16x16.sv}

# 3. Read built-in sample library so elaboration succeeds without custom PDKs
read_libs sample.lib

# 4. Elaborate top-level design
elaborate nema_mac_16x16

# 5. Read constraints and check design
read_sdc constraints.sdc
check_design -all > ../reports/check_design.log

# 6. Map to generic logic and output reports
syn_generic

write_hdl > ../outputs/nema_mac_generic.v
report_gates > ../reports/gate_area_report.txt
report_timing > ../reports/timing_report.txt

exit
