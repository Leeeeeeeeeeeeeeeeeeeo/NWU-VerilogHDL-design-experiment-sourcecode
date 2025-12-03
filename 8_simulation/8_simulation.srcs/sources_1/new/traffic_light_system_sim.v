`timescale 1ns/1ps

module traffic_light_system_sim(
    input clk_100m,         // 100MHz系统时钟（不变）
    input top_rst,          // 硬件复位键（高电平有效）（不变）
    input peak_switch,      // 高峰模式开关（不变）
    input [1:0] key_in,     // 按键输入：[1]=休眠，[0]=应急（不变）
    output [2:0] light_ew,  // 东西方向灯（不变）
    output [2:0] light_ns,  // 南北方向灯（不变）
    output CA, CB, CC, CD, CE, CF, CG,  // 不变
    output dp,              // 不变
    output AN0, AN1, AN2, AN3  // 不变
);

// 内部互联信号（完全不变，确保所有信号都有驱动）
wire [1:0] current_mode;
wire [5:0] count_ew, count_ns;
wire pwm_signal;
wire [2:0] base_light_ew, base_light_ns;
wire [1:0] key_state;
wire core_rst_n;
wire rst_n;  // 子模块低电平有效复位

// 硬件复位键（高电平有效）→ 子模块低电平有效复位（不变）
assign rst_n = ~top_rst;

// 1. 按键消抖模块（仿真专用，连接不变）
key_debounce_sim u_key_debounce(
    .clk(clk_100m),
    .rst_n(rst_n),
    .key_in(key_in),
    .key_state(key_state)
);

// 2. 模式管理模块（仿真专用，连接不变）
mode_manager_sim u_mode_manager(
    .clk(clk_100m),
    .rst_n(rst_n),
    .peak_switch(peak_switch),
    .emergency_key(key_state[0]),
    .sleep_key(key_state[1]),
    .mode(current_mode),
    .core_rst_n(core_rst_n)
);

// 3. 呼吸灯模块（仿真专用，连接不变）
pwm_breathing_sim u_pwm_breathing(
    .clk(clk_100m),
    .rst_n(rst_n),
    .enable(current_mode == 2'b11),
    .pwm_out(pwm_signal)
);

// 4. 核心交通灯状态机（仿真专用，连接不变）
traffic_light_core_sim u_traffic_light_core(
    .clk(clk_100m),
    .rst_n(rst_n),
    .core_rst_n(core_rst_n),
    .current_mode(current_mode),
    .light_ew(base_light_ew),
    .light_ns(base_light_ns),
    .count_ew(count_ew),
    .count_ns(count_ns)
);

// 5. 数码管显示模块（仿真专用，连接不变）
display_controller_sim u_display_controller(
    .clk_100m(clk_100m),
    .rst_n(rst_n),
    .mode(current_mode),
    .count_ew(count_ew),
    .count_ns(count_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 6. 最终灯状态输出（不变，确保无悬空）
assign light_ew = (current_mode == 2'b10) ? 3'b100 :  // 应急模式→全红灯
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠→黄灯呼吸
                  base_light_ew;
                  
assign light_ns = (current_mode == 2'b10) ? 3'b100 :  // 应急模式→全红灯
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠→黄灯呼吸
                  base_light_ns;

endmodule