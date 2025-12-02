# Basys3开发板约束文件（适配key_debounce_led.v）
# 时钟配置：W5引脚（100MHz系统时钟）
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# 复位键配置：BTNC（U18引脚，高电平有效，下拉电阻稳定未按状态）
set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PULLDOWN true [get_ports rst_n]  # 下拉电阻：未按=低电平（0），按下=高电平（1）

# 功能按键配置（高电平有效，下拉电阻稳定状态）
# BTNU（T18引脚）→ key_in[2]
set_property PACKAGE_PIN T18 [get_ports {key_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[2]}]
set_property PULLDOWN true [get_ports {key_in[2]}]

# BTNL（W19引脚）→ key_in[1]
set_property PACKAGE_PIN W19 [get_ports {key_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[1]}]
set_property PULLDOWN true [get_ports {key_in[1]}]

# BTND（U17引脚）→ key_in[0]
set_property PACKAGE_PIN U17 [get_ports {key_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[0]}]
set_property PULLDOWN true [get_ports {key_in[0]}]

# LED配置（高电平点亮，Basys3阳极连接）
# LD5（U15引脚）→ led_out[2]（对应BTNU）
set_property PACKAGE_PIN U15 [get_ports {led_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[2]}]

# LD3（V19引脚）→ led_out[1]（对应BTNL）
set_property PACKAGE_PIN V19 [get_ports {led_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[1]}]

# LD1（U16引脚）→ led_out[0]（对应BTND）
set_property PACKAGE_PIN U16 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[0]}]