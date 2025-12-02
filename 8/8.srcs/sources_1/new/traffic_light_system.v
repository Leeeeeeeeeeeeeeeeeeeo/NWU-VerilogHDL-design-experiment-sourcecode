module traffic_light_system(
    input clk_100m,         // 100MHz系统时钟（Basys3开发板时钟）
    input top_rst,          // 硬件复位键（BTND，高电平有效，修正：改名区分）
    input peak_switch,      // 高峰期模式开关（SW5：拨上=1，拨下=0，高电平有效）
    input [1:0] key_in,     // 按键输入：[1]=BTNU（休眠），[0]=BTNC（应急），高电平有效
    output [2:0] light_ew,  // 东西方向灯：[绿,黄,红]→LD10,LD9,LD8（高电平亮）
    output [2:0] light_ns,  // 南北方向灯：[绿,黄,红]→LD7,LD6,LD5（高电平亮）
    output CA, CB, CC, CD, CE, CF, CG,  // 七段数码管段选
    output dp,               // 小数点
    output AN0, AN1, AN2, AN3 // 数码管位选
);

// 内部互联信号
wire [1:0] current_mode;        // 模式管理模块输出的当前模式
wire [5:0] count_ew, count_ns;  // 核心模块输出的倒计时
wire pwm_signal;                // 呼吸灯PWM信号
wire [2:0] base_light_ew, base_light_ns; // 核心模块输出的基础灯状态
wire [1:0] key_state;           // 消抖后的按键状态
wire core_rst_n;                // 核心状态机复位信号（来自模式管理模块）
wire rst_n;                     // 子模块复位信号（低电平有效，修正核心）

// 关键修正：硬件复位键（高电平有效）→ 子模块低电平有效复位
assign rst_n = ~top_rst;

// 1. 按键消抖模块实例化（rst_n为低电平有效，key_in为硬件高电平有效）
key_debounce u_key_debounce(
    .clk(clk_100m),
    .rst_n(rst_n),
    .key_in(key_in),
    .key_state(key_state)
);

// 2. 模式管理模块实例化（逻辑不变，key_state仍为内部低电平按下）
mode_manager u_mode_manager(
    .clk(clk_100m),
    .rst_n(rst_n),
    .peak_switch(peak_switch),
    .emergency_key(key_state[0]),  // key_state[0]对应应急按键（内部低电平按下）
    .sleep_key(key_state[1]),      // key_state[1]对应休眠按键（内部低电平按下）
    .mode(current_mode),
    .core_rst_n(core_rst_n)
);

// 3. 呼吸灯模块实例化（逻辑不变，PWM高电平有效）
pwm_breathing u_pwm_breathing(
    .clk(clk_100m),
    .rst_n(rst_n),
    .enable(current_mode == 2'b11),  // 休眠模式（11）时启动呼吸灯
    .pwm_out(pwm_signal)
);

// 4. 核心交通灯状态机实例化（逻辑不变，灯状态高电平有效）
traffic_light_core u_traffic_light_core(
    .clk(clk_100m),
    .rst_n(rst_n),
    .core_rst_n(core_rst_n),
    .current_mode(current_mode),
    .light_ew(base_light_ew),
    .light_ns(base_light_ns),
    .count_ew(count_ew),
    .count_ns(count_ns)
);

// 5. 数码管显示模块实例化（逻辑不变）
display_controller u_display_controller(
    .clk_100m(clk_100m),
    .rst_n(rst_n),
    .mode(current_mode),
    .count_ew(count_ew),
    .count_ns(count_ns),
    .CA(CA), .CB(CB), .CC(CC), .CD(CD), .CE(CE), .CF(CF), .CG(CG),
    .dp(dp),
    .AN0(AN0), .AN1(AN1), .AN2(AN2), .AN3(AN3)
);

// 6. 最终灯状态输出（逻辑不变，高电平亮，适配修正后的电平）
assign light_ew = (current_mode == 2'b10) ? 3'b001 :  // 应急模式：东西红灯（高电平亮）
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠模式：东西黄灯呼吸（PWM高电平亮）
                  base_light_ew;  // 正常/高峰模式：核心模块输出（高电平亮）
                  
assign light_ns = (current_mode == 2'b10) ? 3'b001 :  // 应急模式：南北红灯（高电平亮）
                  (current_mode == 2'b11) ? {1'b0, pwm_signal, 1'b0} :  // 休眠模式：南北黄灯呼吸（PWM高电平亮）
                  base_light_ns;  // 正常/高峰模式：核心模块输出（高电平亮）

endmodule