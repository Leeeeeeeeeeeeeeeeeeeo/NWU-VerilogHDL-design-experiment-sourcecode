# 交通灯系统约束文件 - 基于Basys3官方约束

# 时钟信号
set_property PACKAGE_PIN W5 [get_ports clk_100m]							
set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100m]

# 复位按钮 - 使用BTNR
set_property PACKAGE_PIN T17 [get_ports rst_n]						
set_property IOSTANDARD LVCMOS33 [get_ports rst_n] 
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rst_n]

# 高峰期模式开关 - 使用SW5
set_property PACKAGE_PIN V15 [get_ports peak_switch]					
set_property IOSTANDARD LVCMOS33 [get_ports peak_switch]

# 应急模式按钮 - 使用BTNC
set_property PACKAGE_PIN U18 [get_ports emergency_btn]						
set_property IOSTANDARD LVCMOS33 [get_ports emergency_btn]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets emergency_btn]

# 休眠模式按钮 - 使用BTNU
set_property PACKAGE_PIN T18 [get_ports sleep_btn]						
set_property IOSTANDARD LVCMOS33 [get_ports sleep_btn]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sleep_btn]

# 东西方向交通灯
# 东西绿灯 - LED10
set_property PACKAGE_PIN W3 [get_ports {light_ew[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[0]}]
# 东西黄灯 - LED9  
set_property PACKAGE_PIN U3 [get_ports {light_ew[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[1]}]
# 东西红灯 - LED8
set_property PACKAGE_PIN P3 [get_ports {light_ew[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[2]}]

# 南北方向交通灯
# 南北绿灯 - LED7
set_property PACKAGE_PIN V14 [get_ports {light_ns[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[0]}]
# 南北黄灯 - LED6
set_property PACKAGE_PIN U14 [get_ports {light_ns[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[1]}]
# 南北红灯 - LED5
set_property PACKAGE_PIN U15 [get_ports {light_ns[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[2]}]

# 七段数码管段选信号
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

# 小数点（不使用但需要约束）
set_property PACKAGE_PIN V7 [get_ports dp]							
set_property IOSTANDARD LVCMOS33 [get_ports dp]

# 七段数码管位选信号
set_property PACKAGE_PIN U2 [get_ports AN0]					
set_property IOSTANDARD LVCMOS33 [get_ports AN0]
set_property PACKAGE_PIN U4 [get_ports AN1]					
set_property IOSTANDARD LVCMOS33 [get_ports AN1]
set_property PACKAGE_PIN V4 [get_ports AN2]					
set_property IOSTANDARD LVCMOS33 [get_ports AN2]
set_property PACKAGE_PIN W4 [get_ports AN3]					
set_property IOSTANDARD LVCMOS33 [get_ports AN3]