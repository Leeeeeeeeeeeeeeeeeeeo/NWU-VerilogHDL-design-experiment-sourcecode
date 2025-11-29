## 此约束文件适用于Basys3开发板 (xc7a35tcpg236-1)

## 输入信号 - 拨码开关
# I[7:0] 对应 SW7-SW0
set_property PACKAGE_PIN W13 [get_ports {I[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[7]}]

set_property PACKAGE_PIN W14 [get_ports {I[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[6]}]

set_property PACKAGE_PIN V15 [get_ports {I[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[5]}]

set_property PACKAGE_PIN W15 [get_ports {I[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[4]}]

set_property PACKAGE_PIN W17 [get_ports {I[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[3]}]

set_property PACKAGE_PIN W16 [get_ports {I[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[2]}]

set_property PACKAGE_PIN V16 [get_ports {I[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[1]}]

set_property PACKAGE_PIN V17 [get_ports {I[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I[0]}]

# EN 对应 SW10
set_property PACKAGE_PIN T2 [get_ports {EN}]
set_property IOSTANDARD LVCMOS33 [get_ports {EN}]

## 输出信号 - LED灯
# Y[2:0] 对应 LD2-LD0
set_property PACKAGE_PIN U19 [get_ports {Y[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[2]}]

set_property PACKAGE_PIN E19 [get_ports {Y[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[1]}]

set_property PACKAGE_PIN U16 [get_ports {Y[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[0]}]

# GS 对应 LD10
set_property PACKAGE_PIN W3 [get_ports {GS}]
set_property IOSTANDARD LVCMOS33 [get_ports {GS}]

# GC 对应 LD11
set_property PACKAGE_PIN U3 [get_ports {GC}]
set_property IOSTANDARD LVCMOS33 [get_ports {GC}]