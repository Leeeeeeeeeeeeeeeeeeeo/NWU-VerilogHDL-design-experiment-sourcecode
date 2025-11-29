# 时钟信号约束
set_property PACKAGE_PIN W5 [get_ports clk_100m]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100m]

# 七段数码管段选信号约束
set_property PACKAGE_PIN W7 [get_ports CA]					
	set_property IOSTANDARD LVCMOS33 [get_ports CA]

set_property PACKAGE_PIN W6 [get_ports CB]					
	set_property IOSTANDARD LVCMOS33 [get_ports CB]

set_property PACKAGE_PIN U8 [get_ports CC]					
	set_property IOSTANDARD LVCMOS33 [get_ports CC]

set_property PACKAGE_PIN V8 [get_ports CD]					
	set_property IOSTANDARD LVCMOS33 [get_ports CD]

set_property PACKAGE_PIN U5 [get_ports CE]					
	set_property IOSTANDARD LVCMOS33 [get_ports CE]

set_property PACKAGE_PIN V5 [get_ports CF]					
	set_property IOSTANDARD LVCMOS33 [get_ports CF]

set_property PACKAGE_PIN U7 [get_ports CG]					
	set_property IOSTANDARD LVCMOS33 [get_ports CG]

# 小数点约束
set_property PACKAGE_PIN V7 [get_ports dp]							
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

# 数码管位选信号约束
set_property PACKAGE_PIN U2 [get_ports AN0]					
	set_property IOSTANDARD LVCMOS33 [get_ports AN0]

set_property PACKAGE_PIN U4 [get_ports AN1]					
	set_property IOSTANDARD LVCMOS33 [get_ports AN1]

set_property PACKAGE_PIN V4 [get_ports AN2]					
	set_property IOSTANDARD LVCMOS33 [get_ports AN2]

set_property PACKAGE_PIN W4 [get_ports AN3]					
	set_property IOSTANDARD LVCMOS33 [get_ports AN3]