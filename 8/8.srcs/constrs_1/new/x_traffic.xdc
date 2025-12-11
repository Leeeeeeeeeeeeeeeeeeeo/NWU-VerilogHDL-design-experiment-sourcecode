# 1. 系统时钟约束（100MHz，顶层端口：clk_100m）
set_property PACKAGE_PIN W5 [get_ports clk_100m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
create_clock -add -name sys_clk_100m -period 10.00 -waveform {0 5} [get_ports clk_100m]

# 2. 高峰模式开关约束
set_property PACKAGE_PIN V15 [get_ports peak_switch]
set_property IOSTANDARD LVCMOS33 [get_ports peak_switch]

# 3. 功能按键约束（下拉电阻稳定未按状态，未按=低电平，按下=高电平）
# 应急按键（BTNC，顶层端口：BTNC）
set_property PACKAGE_PIN U18 [get_ports BTNC]
set_property IOSTANDARD LVCMOS33 [get_ports BTNC]
set_property PULLDOWN true [get_ports BTNC]

# 休眠按键（BTNU，顶层端口：BTNU）
set_property PACKAGE_PIN T18 [get_ports BTNU]
set_property IOSTANDARD LVCMOS33 [get_ports BTNU]
set_property PULLDOWN true [get_ports BTNU]

# 4. LED约束（顶层端口：led_out[5:0]，对应LD10~LD5，高电平点亮）
# led_out[5] = LD10（东西绿灯）
set_property PACKAGE_PIN W3 [get_ports {led_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[5]}]

# led_out[4] = LD9（东西黄灯）
set_property PACKAGE_PIN V3 [get_ports {led_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[4]}]

# led_out[3] = LD8（东西红灯）
set_property PACKAGE_PIN V13 [get_ports {led_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[3]}]

# led_out[2] = LD7（南北绿灯）
set_property PACKAGE_PIN V14 [get_ports {led_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]

# led_out[1] = LD6（南北黄灯）
set_property PACKAGE_PIN U14 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]

# led_out[0] = LD5（南北红灯）
set_property PACKAGE_PIN U15 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]

# 5. 七段数码管约束（顶层端口：CA~CG、dp、AN0~AN3）
# 段选信号（低电平点亮）
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

# 小数点（顶层端口：dp）
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

# 位选信号（AN3=最左/东西十位，AN0=最右/南北个位）
set_property PACKAGE_PIN W4 [get_ports AN3]
set_property IOSTANDARD LVCMOS33 [get_ports AN3]

set_property PACKAGE_PIN V4 [get_ports AN2]
set_property IOSTANDARD LVCMOS33 [get_ports AN2]

set_property PACKAGE_PIN U4 [get_ports AN1]
set_property IOSTANDARD LVCMOS33 [get_ports AN1]

set_property PACKAGE_PIN U2 [get_ports AN0]
set_property IOSTANDARD LVCMOS33 [get_ports AN0]