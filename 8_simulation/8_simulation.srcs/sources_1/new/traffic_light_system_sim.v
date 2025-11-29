module traffic_light_system_sim(
    input clk_100m,         // 100MHz系统时钟
    input rst_n,            // 异步复位（低电平有效）
    input peak_switch,      // 高峰期模式开关（SW5：拨上=高峰，拨下=正常）
    input [1:0] key_in,     // 按键输入：[1]=BTNU（休眠），[0]=BTNC（应急）
    output [2:0] light_ew,  // 东西方向灯：[绿,黄,红]
    output [2:0] light_ns,  // 南北方向灯：[绿,黄,红]
    output CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选
    output dp,               // 小数点
    output AN0, AN1, AN2, AN3 // 数码管位选
);

// 内部互联信号（逻辑不变）
wire [1:0] current_mode;        // 当前模式
wire [5:0] count_ew, count_ns;  // 倒计时（仿真ms）
wire pwm_signal;                // 呼吸灯PWM信号
wire [2:0] base_light_ew, base_light_ns; // 基础灯状态
wire [1:0] key_state;           // 消抖后的按键状态
wire core_rst_n;                // 核心状态机复位信号

// 1. 仿真专用按键消抖模块实例化
key_debounce_sim u_key_debounce_sim(
    .clk(clk_100m),
    .rst_n(rst_n),
    .key_in(key_in),
    .key_state(key_state)
);

// 2. 模式管理模块实例化（仿真专用，无修改）
mode_manager_sim u_mode_manager_sim(
    .clk(clk_100m),
    .rst_n(rst_n),
    .peak_switch(peak_switch),
    .emergency_key(key_state[0]),  // key_state[0]→应急按键（BTNC）
    .sleep_key(key_state[1]),      // key_state[1]→休眠按键（BTNU）
    .mode(current_mode),
    .core_rst_n(core_rst_n)
);

// 3. 仿真专用呼吸灯模块实例化
pwm_breathing_sim u_pwm_breathing_sim(
    .clk(clk_100m),
    .rst_n(rst_n),
    .enable(current_mode == 2'b11),  // 休眠模式（11）启动呼吸灯
    .pwm_out(pwm_signal)
);

// 4. 仿真专用核心交通灯状态机实例化
traffic_light_core_sim u_traffic_light_core_sim(
    .clk(clk_100m),
    .rst_n(rst_n),
    .core_rst_n(core_rst_n),
    .current_mode(current_mode),
    .light_ew(base_light_ew),
    .light_ns(base_light_ns),
    .count_ew(count_ew),
    .count_ns(count_ns)
);

// 5. 仿真专用数码管显示模块实例化
display_controller_sim u_display_controller_sim(
    .clk_100m(clk_100m),
    .rst_n(rst_n),
    .mode(current_mode),
    .count_ew(count_ew),
    .count_ns(count_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 6. 最终灯状态输出（逻辑不变）
assign light_ew = (current_mode == 2'b10) ? 3'b001 :  // 应急模式：东西红灯
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠模式：东西黄灯呼吸
                  base_light_ew;  // 正常/高峰模式：核心模块输出
                  
assign light_ns = (current_mode == 2'b10) ? 3'b001 :  // 应急模式：南北红灯
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠模式：南北黄灯呼吸
                  base_light_ns;  // 正常/高峰模式：核心模块输出

endmodule