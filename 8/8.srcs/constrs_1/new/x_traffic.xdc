# ###########################################################################
# 交通灯实验约束文件（参考官方格式：一个端口的引脚分配+电气特性相邻，注释单独成行）
# 实验文档对应关系：
# - LD10/LD9/LD8 = 东西方向绿/黄/红；LD7/LD6/LD5 = 南北方向绿/黄/红
# - BTNC = 应急按键；BTNU = 休眠按键；SW5 = 高峰模式切换开关
# - 左2个数码管 = 东西方向计时器；右2个数码管 = 南北方向计时器
# ###########################################################################

# -------------------------- 1. 时钟端口 --------------------------
# 功能：100MHz系统主时钟
# 对应顶层模块信号：clk_100m
# 官方引脚：W5
set_property PACKAGE_PIN W5 [get_ports clk_100m]
	set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
	# 时钟周期配置：10ns（100MHz），占空比50%
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100m]
	# 时序优化：建立时间不确定性预留0.2ns，兼容硬件延迟差异
	set_clock_uncertainty -setup 0.2 [get_clocks clk_100m]
	# 时序优化：时钟周期抖动预留0.1ns，兼容晶振误差
	set_clock_jitter -period 0.1 [get_clocks clk_100m]

# -------------------------- 2. 复位端口 --------------------------
# 功能：系统复位（低电平有效），选用BTND下键
# 对应顶层模块信号：rst_n
# 官方引脚：U17
set_property PACKAGE_PIN U17 [get_ports rst_n]
	set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
	# 内部上拉：避免引脚浮空导致的误触发
	set_property PULLUP true [get_ports rst_n]

# -------------------------- 3. 应急按键端口 --------------------------
# 功能：触发/解除应急模式（实验文档指定BTNC中间键）
# 对应顶层模块信号：key_in[0]
# 官方引脚：U18
set_property PACKAGE_PIN U18 [get_ports {key_in[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {key_in[0]}]
	# 内部上拉：避免引脚浮空导致的误触发
	set_property PULLUP true [get_ports {key_in[0]}]
	# 关闭时钟专用路由：避免非时钟信号占用时钟资源导致DRC警告
	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {key_in[0]}]

# -------------------------- 4. 休眠按键端口 --------------------------
# 功能：触发/解除休眠模式（实验文档指定BTNU上键）
# 对应顶层模块信号：key_in[1]
# 官方引脚：T18
set_property PACKAGE_PIN T18 [get_ports {key_in[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {key_in[1]}]
	# 内部上拉：避免引脚浮空导致的误触发
	set_property PULLUP true [get_ports {key_in[1]}]
	# 关闭时钟专用路由：避免非时钟信号占用时钟资源导致DRC警告
	set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {key_in[1]}]

# -------------------------- 5. 高峰模式开关端口 --------------------------
# 功能：切换正常/高峰模式（实验文档指定SW5）
# 对应顶层模块信号：peak_switch
# 官方引脚：V15
set_property PACKAGE_PIN V15 [get_ports peak_switch]
	set_property IOSTANDARD LVCMOS33 [get_ports peak_switch]
	# 内部上拉：避免引脚浮空导致的误触发
	set_property PULLUP true [get_ports peak_switch]

# -------------------------- 6. 东西方向LED端口 --------------------------
# 功能：东西方向绿灯（实验文档指定LD10）
# 对应顶层模块信号：light_ew[0]
# 官方引脚：W3（LED10）
set_property PACKAGE_PIN W3 [get_ports {light_ew[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[0]}]

# 功能：东西方向黄灯（实验文档指定LD9）
# 对应顶层模块信号：light_ew[1]
# 官方引脚：V3（LED9）
set_property PACKAGE_PIN V3 [get_ports {light_ew[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[1]}]

# 功能：东西方向红灯（实验文档指定LD8）
# 对应顶层模块信号：light_ew[2]
# 官方引脚：V13（LED8）
set_property PACKAGE_PIN V13 [get_ports {light_ew[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ew[2]}]

# -------------------------- 7. 南北方向LED端口 --------------------------
# 功能：南北方向绿灯（实验文档指定LD7）
# 对应顶层模块信号：light_ns[0]
# 官方引脚：V14（LED7）
set_property PACKAGE_PIN V14 [get_ports {light_ns[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[0]}]

# 功能：南北方向黄灯（实验文档指定LD6）
# 对应顶层模块信号：light_ns[1]
# 官方引脚：U14（LED6）
set_property PACKAGE_PIN U14 [get_ports {light_ns[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[1]}]

# 功能：南北方向红灯（实验文档指定LD5）
# 对应顶层模块信号：light_ns[2]
# 官方引脚：U15（LED5）
set_property PACKAGE_PIN U15 [get_ports {light_ns[2]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {light_ns[2]}]

# -------------------------- 8. 数码管段选端口 --------------------------
# 功能：数码管段选CA
# 对应顶层模块信号：CA
# 官方引脚：W7
set_property PACKAGE_PIN W7 [get_ports CA]
	set_property IOSTANDARD LVCMOS33 [get_ports CA]

# 功能：数码管段选CB
# 对应顶层模块信号：CB
# 官方引脚：W6
set_property PACKAGE_PIN W6 [get_ports CB]
	set_property IOSTANDARD LVCMOS33 [get_ports CB]

# 功能：数码管段选CC
# 对应顶层模块信号：CC
# 官方引脚：U8
set_property PACKAGE_PIN U8 [get_ports CC]
	set_property IOSTANDARD LVCMOS33 [get_ports CC]

# 功能：数码管段选CD
# 对应顶层模块信号：CD
# 官方引脚：V8
set_property PACKAGE_PIN V8 [get_ports CD]
	set_property IOSTANDARD LVCMOS33 [get_ports CD]

# 功能：数码管段选CE
# 对应顶层模块信号：CE
# 官方引脚：U5
set_property PACKAGE_PIN U5 [get_ports CE]
	set_property IOSTANDARD LVCMOS33 [get_ports CE]

# 功能：数码管段选CF
# 对应顶层模块信号：CF
# 官方引脚：V5
set_property PACKAGE_PIN V5 [get_ports CF]
	set_property IOSTANDARD LVCMOS33 [get_ports CF]

# 功能：数码管段选CG
# 对应顶层模块信号：CG
# 官方引脚：U7
set_property PACKAGE_PIN U7 [get_ports CG]
	set_property IOSTANDARD LVCMOS33 [get_ports CG]

# 功能：数码管小数点dp（始终熄灭）
# 对应顶层模块信号：dp
# 官方引脚：V7
set_property PACKAGE_PIN V7 [get_ports dp]
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

# -------------------------- 9. 数码管位选端口 --------------------------
# 功能：数码管最右位（南北方向个位）
# 对应顶层模块信号：AN0
# 官方引脚：U2
set_property PACKAGE_PIN U2 [get_ports AN0]
	set_property IOSTANDARD LVCMOS33 [get_ports AN0]

# 功能：数码管右二位（南北方向十位）
# 对应顶层模块信号：AN1
# 官方引脚：U4
set_property PACKAGE_PIN U4 [get_ports AN1]
	set_property IOSTANDARD LVCMOS33 [get_ports AN1]

# 功能：数码管左二位（东西方向个位）
# 对应顶层模块信号：AN2
# 官方引脚：V4
set_property PACKAGE_PIN V4 [get_ports AN2]
	set_property IOSTANDARD LVCMOS33 [get_ports AN2]

# 功能：数码管最左位（东西方向十位）
# 对应顶层模块信号：AN3
# 官方引脚：W4
set_property PACKAGE_PIN W4 [get_ports AN3]
	set_property IOSTANDARD LVCMOS33 [get_ports AN3]