`timescale 1ns/1ps

module traffic_light_system_sim(
    input clk_100m,         // 100MHz系统时钟
    input peak_switch,      // 高峰模式开关
    input BTNC,             // 应急按键
    input BTNU,             // 休眠按键
    output [5:0] led_out,   // LED输出
    output CA, CB, CC, CD, CE, CF, CG,  // 数码管段选
    output dp,              // 数码管小数点
    output AN0, AN1, AN2, AN3  // 数码管位选
);

// --------------- 模式常量声明 ---------------
localparam MODE_NORMAL = 2'b00;
localparam MODE_PEAK   = 2'b01;
localparam MODE_EMERG  = 2'b10;
localparam MODE_SLEEP  = 2'b11;

// 内部互联信号
wire [1:0] current_mode;
wire [5:0] count_ew, count_ns;
wire pwm_signal;
wire [2:0] base_light_ew, base_light_ns;
wire [1:0] key_state;
wire core_rst_n;

// 按键输入：[1]=BTNU（休眠），[0]=BTNC（应急）（硬件：未按=0，按下=1）
wire [1:0] key_in = {BTNU, BTNC};

// 1. 按键消抖模块（仿真版）
key_debounce_sim u_key_debounce_sim(
    .clk(clk_100m),
    .key_in(key_in),
    .key_state(key_state)
);

// 2. 模式管理模块（仿真版）
mode_manager_sim u_mode_manager_sim(
    .clk(clk_100m),
    .peak_switch(peak_switch),
    .emergency_key(key_state[0]),
    .sleep_key(key_state[1]),
    .mode(current_mode),
    .core_rst_n(core_rst_n)
);

// 3. 呼吸灯模块（仿真版）
pwm_breathing_sim u_pwm_breathing_sim(
    .clk(clk_100m),
    .enable(current_mode == MODE_SLEEP),
    .pwm_out(pwm_signal)
);

// 4. 核心交通灯状态机（仿真版）
traffic_light_core_sim u_traffic_light_core_sim(
    .clk(clk_100m),
    .core_rst_n(core_rst_n),
    .current_mode(current_mode),
    .light_ew(base_light_ew),
    .light_ns(base_light_ns),
    .count_ew(count_ew),
    .count_ns(count_ns)
);

// 5. 数码管显示模块（仿真版）
display_controller_sim u_display_controller_sim(
    .clk_100m(clk_100m),
    .mode(current_mode),
    .count_ew(count_ew),
    .count_ns(count_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 6. LED输出映射（高电平亮，与仿真模式匹配）
// led_out[5] = LD10（东西绿），led_out[4] = LD9（东西黄），led_out[3] = LD8（东西红）
// led_out[2] = LD7（南北绿），led_out[1] = LD6（南北黄），led_out[0] = LD5（南北红）
assign led_out[5] = (current_mode == MODE_EMERG) ? 1'b0 :  // 应急模式：绿灯灭
                   (current_mode == MODE_SLEEP) ? 1'b0 :  // 休眠模式：绿灯灭
                   base_light_ew[0];

assign led_out[4] = (current_mode == MODE_EMERG) ? 1'b0 :  // 应急模式：黄灯灭
                   (current_mode == MODE_SLEEP) ? pwm_signal :  // 休眠模式：黄灯呼吸
                   base_light_ew[1];

assign led_out[3] = (current_mode == MODE_EMERG) ? 1'b1 :  // 应急模式：红灯亮
                   (current_mode == MODE_SLEEP) ? 1'b0 :  // 休眠模式：红灯灭
                   base_light_ew[2];

assign led_out[2] = (current_mode == MODE_EMERG) ? 1'b0 :  // 应急模式：绿灯灭
                   (current_mode == MODE_SLEEP) ? 1'b0 :  // 休眠模式：绿灯灭
                   base_light_ns[0];

assign led_out[1] = (current_mode == MODE_EMERG) ? 1'b0 :  // 应急模式：黄灯灭
                   (current_mode == MODE_SLEEP) ? pwm_signal :  // 休眠模式：黄灯呼吸
                   base_light_ns[1];

assign led_out[0] = (current_mode == MODE_EMERG) ? 1'b1 :  // 应急模式：红灯亮
                   (current_mode == MODE_SLEEP) ? 1'b0 :  // 休眠模式：红灯灭
                   base_light_ns[2];

endmodule