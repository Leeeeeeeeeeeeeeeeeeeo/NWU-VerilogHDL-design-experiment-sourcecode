# 交通灯系统Basys3专用约束文件（traffic_light_system.xdc）
# 板型适配：Basys3 rev B
# 顶层模块匹配：traffic_light_system
# 功能覆盖：时钟/复位/按键/开关/LED/数码管，含输入上拉防悬空


# 1. 系统时钟约束（100MHz，顶层端口：clk_100m）
# 引脚：Basys3官方100MHz时钟引脚W5，配置LVCMOS33电平标准
# 创建10ns周期（100MHz）时钟，占空比50%，用于时序分析
set_property PACKAGE_PIN W5 [get_ports clk_100m]					
set_property IOSTANDARD LVCMOS33 [get_ports clk_100m]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100m]


# 2. 输入控制端口约束（复位键/高峰开关/功能按键，均加内部上拉防悬空）
# 2.1 硬件复位键（顶层端口：top_rst）
# 对应Basys3 btnD按键（引脚U17），高电平有效
# 加内部上拉确保未按下时稳定高电平，标记为非时钟信号避免资源误分配
set_property PACKAGE_PIN U17 [get_ports top_rst]						
set_property IOSTANDARD LVCMOS33 [get_ports top_rst]
set_property PULLUP TRUE [get_ports top_rst]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets top_rst]

# 2.2 高峰模式开关（顶层端口：peak_switch）
# 对应Basys3 SW5开关（引脚V15），拨下=0（正常模式），拨上=1（高峰模式）
# 加内部上拉确保未操作时默认0电平（正常模式）
set_property PACKAGE_PIN V15 [get_ports peak_switch]					
set_property IOSTANDARD LVCMOS33 [get_ports peak_switch]
set_property PULLUP TRUE [get_ports peak_switch]

# 2.3 功能按键（顶层端口：key_in[1:0]）
# 2.3.1 应急按键（key_in[0]）：对应Basys3 btnC按键（引脚U18）
# 高电平按下，加内部上拉确保未按下时稳定高电平，标记为非时钟信号
set_property PACKAGE_PIN U18 [get_ports key_in[0]]						
set_property IOSTANDARD LVCMOS33 [get_ports key_in[0]]
set_property PULLUP TRUE [get_ports key_in[0]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets key_in[0]]

# 2.3.2 休眠按键（key_in[1]）：对应Basys3 btnU按键（引脚T18）
# 高电平按下，加内部上拉确保未按下时稳定高电平，标记为非时钟信号
set_property PACKAGE_PIN T18 [get_ports key_in[1]]						
set_property IOSTANDARD LVCMOS33 [get_ports key_in[1]]
set_property PULLUP TRUE [get_ports key_in[1]]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets key_in[1]]


# 3. LED交通灯约束（顶层端口：light_ew[2:0]/light_ns[2:0]，匹配实验文档定义）
# 3.1 东西方向灯（light_ew[2]=绿/LD10，light_ew[1]=黄/LD9，light_ew[0]=红/LD8）
set_property PACKAGE_PIN W3 [get_ports light_ew[2]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ew[2]]

set_property PACKAGE_PIN V3 [get_ports light_ew[1]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ew[1]]

set_property PACKAGE_PIN V13 [get_ports light_ew[0]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ew[0]]

# 3.2 南北方向灯（light_ns[2]=绿/LD7，light_ns[1]=黄/LD6，light_ns[0]=红/LD5）
set_property PACKAGE_PIN V14 [get_ports light_ns[2]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ns[2]]

set_property PACKAGE_PIN U14 [get_ports light_ns[1]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ns[1]]

set_property PACKAGE_PIN U15 [get_ports light_ns[0]]					
set_property IOSTANDARD LVCMOS33 [get_ports light_ns[0]]


# 4. 数码管显示约束（顶层端口：CA~CG/dp/AN0~AN3，适配Basys3共阳极硬件）
# 4.1 段选信号（CA~CG/dp）：共阳极，低电平点亮，配置LVCMOS33电平标准
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

# 4.2 位选信号（AN0~AN3）：左2个显示东西倒计时，右2个显示南北倒计时
set_property PACKAGE_PIN U2 [get_ports AN0] 					
set_property IOSTANDARD LVCMOS33 [get_ports AN0]

set_property PACKAGE_PIN U4 [get_ports AN1] 					
set_property IOSTANDARD LVCMOS33 [get_ports AN1]

set_property PACKAGE_PIN V4 [get_ports AN2] 					
set_property IOSTANDARD LVCMOS33 [get_ports AN2]

set_property PACKAGE_PIN W4 [get_ports AN3] 					
set_property IOSTANDARD LVCMOS33 [get_ports AN3]