## 时钟信号约束
# 将SW15 (引脚R2) 设置为时钟输入，并禁用专用时钟路由警告
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets Clk_IBUF]
set_property PACKAGE_PIN R2 [get_ports Clk]
set_property IOSTANDARD LVCMOS33 [get_ports Clk]

## 控制信号输入约束
# SW14 对应同步置位S，引脚T1
set_property PACKAGE_PIN T1 [get_ports S]
set_property IOSTANDARD LVCMOS33 [get_ports S]
# SW13 对应异步复位R，引脚U1
set_property PACKAGE_PIN U1 [get_ports R]
set_property IOSTANDARD LVCMOS33 [get_ports R]
# SW12 对应加减控制Up_Down，引脚W2
set_property PACKAGE_PIN W2 [get_ports Up_Down]
set_property IOSTANDARD LVCMOS33 [get_ports Up_Down]

## 数据输入约束 (置入数字)
# SW0 对应Load_Data[0]，引脚V17
set_property PACKAGE_PIN V17 [get_ports {Load_Data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Load_Data[0]}]
# SW1 对应Load_Data[1]，引脚V16
set_property PACKAGE_PIN V16 [get_ports {Load_Data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Load_Data[1]}]
# SW2 对应Load_Data[2]，引脚W16
set_property PACKAGE_PIN W16 [get_ports {Load_Data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Load_Data[2]}]
# SW3 对应Load_Data[3]，引脚W17
set_property PACKAGE_PIN W17 [get_ports {Load_Data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Load_Data[3]}]

## LED输出约束
# LD0 对应Count[0]，引脚U16
set_property PACKAGE_PIN U16 [get_ports {Count[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Count[0]}]
# LD1 对应Count[1]，引脚E19
set_property PACKAGE_PIN E19 [get_ports {Count[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Count[1]}]
# LD2 对应Count[2]，引脚U19
set_property PACKAGE_PIN U19 [get_ports {Count[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Count[2]}]
# LD3 对应Count[3]，引脚V19
set_property PACKAGE_PIN V19 [get_ports {Count[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Count[3]}]

## 状态输出约束
# GS (群组信号) 对应LD4，引脚W18
set_property PACKAGE_PIN W18 [get_ports GS]
set_property IOSTANDARD LVCMOS33 [get_ports GS]
# GC (群组进位) 对应LD5，引脚U15
set_property PACKAGE_PIN U15 [get_ports GC]
set_property IOSTANDARD LVCMOS33 [get_ports GC]