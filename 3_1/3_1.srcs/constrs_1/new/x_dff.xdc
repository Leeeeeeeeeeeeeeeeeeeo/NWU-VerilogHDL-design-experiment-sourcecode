## 时钟信号约束
## 重要：声明SW3不是专用时钟引脚
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets CP_IBUF]

# 将SW3 (引脚W17) 设置为时钟输入，内部电压标准为LVCMOS33
set_property PACKAGE_PIN W17 [get_ports CP]
set_property IOSTANDARD LVCMOS33 [get_ports CP]

## 拨码开关输入约束
# SW0 对应数据输入D，引脚V17
set_property PACKAGE_PIN V17 [get_ports D]
set_property IOSTANDARD LVCMOS33 [get_ports D]
# SW1 对应异步复位R，引脚V16
set_property PACKAGE_PIN V16 [get_ports R]
set_property IOSTANDARD LVCMOS33 [get_ports R]
# SW2 对应同步置位S，引脚W16
set_property PACKAGE_PIN W16 [get_ports S]
set_property IOSTANDARD LVCMOS33 [get_ports S]

## LED输出约束
# LD1 对应输出Q，引脚E19
set_property PACKAGE_PIN E19 [get_ports Q]
set_property IOSTANDARD LVCMOS33 [get_ports Q]
# LD0 对应反相输出Q_n，引脚U16
set_property PACKAGE_PIN U16 [get_ports Q_n]
set_property IOSTANDARD LVCMOS33 [get_ports Q_n]