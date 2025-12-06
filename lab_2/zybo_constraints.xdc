## Clock Constraints
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports clk];
create_clock -period 8.000 -waveform {0.000 4.000} [get_ports clk];

## PIN Constraints
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports rst];
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports x[0]];
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports x[1]];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports x[2]];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports x[3]];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports x[4]];
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports x[5]];
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports x[6]];
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports x[7]];
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports y[0]];
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports y[1]];
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports y[2]];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports y[3]];
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports y[4]];
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports y[5]];
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports y[6]];
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports y[7]];

### PLACEMENT constraints
create_pblock pblock_adder
add_cells_to_pblock [get_pblocks pblock_adder] [get_cells -quiet [list m0 m1 m2 m3]]
resize_pblock [get_pblocks pblock_adder] -add {SLICE_X90Y68:SLICE_X104Y59}

## These constraints are required when one or more of the input/output top level
## ports are not assigned to any physical pin on the FPGA (no pin constraints). 
## If all the input/output ports are assigned with physical pins the following 
## constraints can be safely ignored.
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]