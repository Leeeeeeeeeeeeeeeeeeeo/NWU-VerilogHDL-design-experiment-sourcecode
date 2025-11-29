## 输入信号 - 拨码开关
# A[1:0] 对应 SW1, SW0
set_property PACKAGE_PIN V16 [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]

set_property PACKAGE_PIN V17 [get_ports {A[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[1]}]

# B[1:0] 对应 SW3, SW2
set_property PACKAGE_PIN W17 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]

set_property PACKAGE_PIN W16 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]

# RST 对应 SW5
set_property PACKAGE_PIN V15 [get_ports {RST}]
set_property IOSTANDARD LVCMOS33 [get_ports {RST}]

## 输出信号 - LED灯
# AGTB 对应 LD0
set_property PACKAGE_PIN U16 [get_ports {AGTB}]
set_property IOSTANDARD LVCMOS33 [get_ports {AGTB}]

# AEQB 对应 LD1
set_property PACKAGE_PIN E19 [get_ports {AEQB}]
set_property IOSTANDARD LVCMOS33 [get_ports {AEQB}]

# ALTB 对应 LD2
set_property PACKAGE_PIN U19 [get_ports {ALTB}]
set_property IOSTANDARD LVCMOS33 [get_ports {ALTB}]