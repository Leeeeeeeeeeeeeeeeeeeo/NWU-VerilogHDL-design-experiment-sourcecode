# 时钟信号
set_property PACKAGE_PIN W5 [get_ports clk]							
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# 复位按键 (BTNC)
set_property PACKAGE_PIN U18 [get_ports reset]						
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# 独立按键 BTNU
set_property PACKAGE_PIN T18 [get_ports {keys[2]}]						
set_property IOSTANDARD LVCMOS33 [get_ports {keys[2]}]

# 独立按键 BTNL
set_property PACKAGE_PIN W19 [get_ports {keys[1]}]						
set_property IOSTANDARD LVCMOS33 [get_ports {keys[1]}]

# 独立按键 BTND
set_property PACKAGE_PIN U17 [get_ports {keys[0]}]						
set_property IOSTANDARD LVCMOS33 [get_ports {keys[0]}]

# LED LD5 (对应BTNU)
set_property PACKAGE_PIN U15 [get_ports {leds[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]

# LED LD3 (对应BTNL)
set_property PACKAGE_PIN V19 [get_ports {leds[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]

# LED LD1 (对应BTND)
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]