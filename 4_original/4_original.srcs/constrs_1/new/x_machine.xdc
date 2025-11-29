## 时钟信号 - 使用开关SW4而非专用时钟
set_property PACKAGE_PIN W15 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

## 复位信号 - 使用开关SW3
set_property PACKAGE_PIN W17 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]

## 投币输入信号 - coin[0] - 使用开关SW1
set_property PACKAGE_PIN V16 [get_ports {coin[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {coin[0]}]

## 投币输入信号 - coin[1] - 使用开关SW2
set_property PACKAGE_PIN W16 [get_ports {coin[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {coin[1]}]

## 出货输出信号 - 使用LED0
set_property PACKAGE_PIN U16 [get_ports sell]
set_property IOSTANDARD LVCMOS33 [get_ports sell]

## 找零输出信号 - 使用LED1
set_property PACKAGE_PIN E19 [get_ports change]
set_property IOSTANDARD LVCMOS33 [get_ports change]