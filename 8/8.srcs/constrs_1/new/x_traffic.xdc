# ###########################################################################
# 交通灯实验约束文件（修正电平逻辑：按键高电平有效、LED高电平亮）
# ###########################################################################

# -------------------------- 1. 时钟端口 --------------------------
set_property PACKAGE_PIN W5 [get_ports clk_100m]
	set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100m]
	set_clock_uncertainty -setup 0.2 [get_clocks clk_100m]
	set_clock_jitter -period 0.1 [get_clocks clk_100m]

# -------------------------- 2. 复位端口（修正核心） --------------------------
# 功能：系统复位（硬件高电平有效），选用BTND下键
# 对应顶层模块信号：top_rst（修正：原rst_n，改名适配）
# 关键修正：PULLDOWN（未按=低电平0，按下=高电平1）
set_property PACKAGE_PIN U17 [get_ports top_rst]
	set_property IOSTANDARD LVCMOS33 [get_ports top_rst]
	set_property PULLDOWN true [get_ports top_rst]  # 修正：下拉电阻稳定未按状态

# -------------------------- 3. 应急按键端口（修正核心） --------------------------
# 对应顶层模块信号：key_in[0]（BTNC中间键，高电平有效）
# 关键修正：PULLDOWN（未按=低电平0，按下=高电平1）
set_property PACKAGE_PIN U18 [get_ports {key_in[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {key_in[0]}]
	set_property PULLDOWN true [get_ports {key_in[0]}]  # 修正：下拉电阻
	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {key_in[0]}]

# -------------------------- 4. 休眠按键端口（修正核心） --------------------------
# 对应顶层模块信号：key_in[1]（BTNU上键，高电平有效）
# 关键修正：PULLDOWN（未按=低电平0，按下=高电平1）
set_property PACKAGE_PIN T18 [get_ports {key_in[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {key_in[1]}]
	set_property PULLDOWN true [get_ports {key_in[1]}]  # 修正：下拉电阻
	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {key_in[1]}]

# -------------------------- 5. 高峰模式开关端口（修正核心） --------------------------
# 对应顶层模块信号：peak_switch（SW5，拨上=1高峰，高电平有效）
# 关键修正：PULLDOWN（未拨=低电平0，拨上=高电平1）
set_property PACKAGE_PIN V15 [get_ports peak_switch]
	set_property IOSTANDARD LVCMOS33 [get_ports peak_switch]
	set_property PULLDOWN true [get_ports peak_switch]  # 修正：下拉电阻

# -------------------------- 6. 东西方向LED端口（无修正，高电平亮） --------------------------
set_property PACKAGE_PIN W3 [get_ports {light_ew[0]}]  # LD10（绿灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[0]}]
set_property PACKAGE_PIN V3 [get_ports {light_ew[1]}]  # LD9（黄灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[1]}]
set_property PACKAGE_PIN V13 [get_ports {light_ew[2]}] # LD8（红灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[2]}]

# -------------------------- 7. 南北方向LED端口（无修正，高电平亮） --------------------------
set_property PACKAGE_PIN V14 [get_ports {light_ns[0]}] # LD7（绿灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[0]}]
set_property PACKAGE_PIN U14 [get_ports {light_ns[1]}] # LD6（黄灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[1]}]
set_property PACKAGE_PIN U15 [get_ports {light_ns[2]}] # LD5（红灯）
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[2]}]

# -------------------------- 8. 数码管端口（无修正） --------------------------
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
set_property PACKAGE_PIN V7 [get_ports dp]
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

# 数码管位选
set_property PACKAGE_PIN U2 [get_ports AN0]
	set_property IOSTANDARD LVCMOS33 [get_ports AN0]
set_property PACKAGE_PIN U4 [get_ports AN1]
	set_property IOSTANDARD LVCMOS33 [get_ports AN1]
set_property PACKAGE_PIN V4 [get_ports AN2]
	set_property IOSTANDARD LVCMOS33 [get_ports AN2]
set_property PACKAGE_PIN W4 [get_ports AN3]
	set_property IOSTANDARD LVCMOS33 [get_ports AN3]