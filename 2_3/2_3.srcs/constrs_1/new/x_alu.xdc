# ALU设计 - Basys3引脚约束文件

## 操作码输入
set_property PACKAGE_PIN T2 [get_ports {opcode[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opcode[0]}]

set_property PACKAGE_PIN R3 [get_ports {opcode[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {opcode[1]}]

## 操作数a输入
set_property PACKAGE_PIN W13 [get_ports {a[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {a[0]}]

set_property PACKAGE_PIN V2 [get_ports {a[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {a[1]}]

## 操作数b输入
set_property PACKAGE_PIN W15 [get_ports {b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[0]}]

set_property PACKAGE_PIN V15 [get_ports {b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[1]}]

## 运算结果输出
set_property PACKAGE_PIN V14 [get_ports {out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out[0]}]

set_property PACKAGE_PIN V13 [get_ports {out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out[1]}]

set_property PACKAGE_PIN V3 [get_ports {out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {out[2]}]